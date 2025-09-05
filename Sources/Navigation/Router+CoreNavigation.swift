//
//  Router+CoreNavigation.swift
//  RouterKit
//
//  Created by fengming on 2025/8/4.
//

import Foundation
#if canImport(UIKit)
import UIKit

// MARK: - 核心导航逻辑扩展

@MainActor
extension Router {
    /// 核心导航方法
    /// - Parameters:
    ///   - urlString: 目标URL字符串
    ///   - parameters: 路由参数
    ///   - sourceVC: 源视图控制器
    ///   - type: 导航类型
    ///   - animated: 是否动画
    ///   - animationId: 动画ID
    ///   - retryCount: 重试次数
    ///   - completion: 完成回调
    public func navigate(to urlString: String,
                         parameters: RouterParameters? = nil,
                         from sourceVC: UIViewController? = nil,
                         type: NavigationType = .push,
                         animated: Bool = true,
                         animationId: String? = nil,
                         retryCount: Int = 0,
                         completion: @escaping RouterCompletion) {
        Task {
            do {
                // 处理拦截器
                let interceptorList = await state.getInterceptors()
                let (finalUrl, finalParameters, presentationStyle) = try await handleInterceptors(
                    interceptors: interceptorList,
                    url: urlString,
                    parameters: parameters ?? [:]
                )
                
                // 执行导航
                await performNavigation(
                    urlString: finalUrl,
                    presentationStyle: presentationStyle,
                    parameters: finalParameters,
                    sourceVC: sourceVC,
                    type: type,
                    animated: animated,
                    animationId: animationId,
                    retryCount: retryCount,
                    completion: completion
                )
            } catch {
                await MainActor.run {
                    let routerError = error as? RouterError ?? RouterError.navigationError(error.localizedDescription)
                    completion(.failure(routerError))
                }
            }
        }
    }
    
    /// 处理拦截器链
    /// - Parameters:
    ///   - interceptors: 拦截器列表
    ///   - url: 原始URL
    ///   - parameters: 原始参数
    /// - Returns: 处理后的URL、参数和展示样式
    private func handleInterceptors(interceptors: [RouterInterceptor], url: String, parameters: RouterParameters) async throws
        -> (String, RouterParameters, NavigationPresentationStyle?) {
        var currentUrl = url
        var currentParameters = parameters
        var presentationStyle: NavigationPresentationStyle?
        
        for interceptor in interceptors {
            let result = try await withCheckedThrowingContinuation { continuation in
                interceptor.intercept(
                    url: currentUrl,
                    parameters: currentParameters
                ) { allow, redirectUrl, errorMsg, newParams, style in
                    if allow {
                        continuation.resume(returning: InterceptorResult.continue(redirectUrl, newParams))
                    } else if let error = errorMsg {
                        continuation.resume(throwing: RouterError.interceptorRejected(error))
                    } else {
                        continuation.resume(throwing: RouterError.interceptorRejected("拦截器拒绝访问"))
                    }
                }
            }
            
            switch result {
            case .continue(let newUrl, let newParameters):
                currentUrl = newUrl ?? currentUrl
                currentParameters = newParameters ?? currentParameters
                
            case .redirect(let redirectUrl, let redirectParameters):
                currentUrl = redirectUrl
                currentParameters = redirectParameters ?? [:]
                
            case .block(let error):
                throw RouterError.interceptorRejected(error)
            }
        }
        
        return (currentUrl, currentParameters, presentationStyle)
    }
    
    /// 取消当前导航
    public func cancelCurrentNavigation() {
        Task {
            await withCheckedContinuation { continuation in
                Task {
                    if let task = await state.getCurrentNavigationTask() {
                        task.cancel()
                        await state.setCurrentNavigationTask(nil)
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    /// 执行导航操作
    /// - Parameters:
    ///   - urlString: URL字符串
    ///   - presentationStyle: 展示样式
    ///   - parameters: 参数
    ///   - sourceVC: 源视图控制器
    ///   - type: 导航类型
    ///   - animated: 是否动画
    ///   - animationId: 动画ID
    ///   - retryCount: 重试次数
    ///   - completion: 完成回调
    private func performNavigation(urlString: String,
                                   presentationStyle: NavigationPresentationStyle?,
                                   parameters: RouterParameters,
                                   sourceVC: UIViewController?,
                                   type: NavigationType,
                                   animated: Bool,
                                   animationId: String?,
                                   retryCount: Int,
                                   completion: @escaping RouterCompletion) async {
        
        let task: Task<Void, Error> = Task {
            do {
                guard let url = URL(string: urlString) else {
                    throw RouterError.invalidURL(urlString)
                }
                
                // 创建视图控制器
                let viewController = try await createViewController(for: url, parameters: parameters)
                
                await MainActor.run {
                    // 拦截器可能覆盖导航类型
                    var finalType = type
                    if let style = presentationStyle {
                        switch style {
                        case .push:
                            finalType = .push
                        case .present:
                            finalType = .present
                        case .presentWithNavigation:
                            finalType = .present
                        case .replace:
                            finalType = .replace
                        case .custom(_):
                            // 自定义样式保持原有类型
                            break
                        }
                    }
                    
                    // 处理自定义动画
                    if let animationId = animationId {
                        Task {
                            if let animation = await state.getAnimation(animationId) {
                                await MainActor.run {
                                    viewController.transitioningDelegate = self
                                }
                                await state.setCurrentAnimation(animation)
                            }
                        }
                    }
                    
                    // 执行导航
                    do {
                        let sourceViewController = sourceVC ?? topMostViewController()
                        
                        switch finalType {
                        case .push:
                            try push(from: sourceViewController, to: viewController, animated: animated)
                            
                        case .present:
                            present(from: sourceViewController, to: viewController, animated: animated) {
                                completion(.success(()))
                            }
                            return // present有自己的completion处理
                            
                        case .replace:
                            try replace(from: sourceViewController, to: viewController, animated: animated)
                            
                        case .pop:
                            pop(from: sourceViewController, animated: animated)
                            
                        case .popToRoot:
                            popToRoot(from: sourceViewController, animated: animated)
                            
                        case .popTo:
                            if let targetVC = findViewController(matching: urlString) {
                                popTo(target: targetVC, from: sourceViewController, animated: animated)
                            } else {
                                throw RouterError.viewControllerNotFound(urlString)
                            }
                        }
                        
                        completion(.success(()))
                        
                    } catch {
                        // 错误处理和重试机制
                        Task {
                            let maxRetryCount = await state.getMaxRetryCount()
                            let retryDelay = await state.getRetryDelay()
                            
                            await MainActor.run {
                                if retryCount < maxRetryCount {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                        Task {
                                            await self.performNavigation(
                                                urlString: urlString,
                                                presentationStyle: presentationStyle,
                                                parameters: parameters,
                                                sourceVC: sourceVC,
                                                type: type,
                                                animated: animated,
                                                animationId: animationId,
                                                retryCount: retryCount + 1,
                                                completion: completion
                                            )
                                        }
                                    }
                                } else {
                                    completion(.failure(RouterError.navigationError(error.localizedDescription)))
                                }
                            }
                        }
                    }
                }
                
            } catch {
                await MainActor.run {
                    let routerError = error as? RouterError ?? RouterError.navigationError(error.localizedDescription)
                    completion(.failure(routerError))
                }
            }
        }
        
        await state.setCurrentNavigationTask(task)
    }
    
    /// 查找匹配的视图控制器
    /// - Parameter urlString: URL字符串
    /// - Returns: 匹配的视图控制器
    private func findViewController(matching urlString: String) -> UIViewController? {
        guard let navigationController = topMostViewController().navigationController else {
            return nil
        }
        
        // 简单的类名匹配逻辑
        let targetClassName = urlString.components(separatedBy: "/").last ?? ""
        
        for viewController in navigationController.viewControllers {
            let className = String(describing: type(of: viewController))
            if className.contains(targetClassName) {
                return viewController
            }
        }
        
        return nil
    }
}

#endif