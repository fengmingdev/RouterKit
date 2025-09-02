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
                let (finalUrl, finalParameters, presentationStyle) = try await handleInterceptors(
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
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// 处理拦截器链
    /// - Parameters:
    ///   - url: 原始URL
    ///   - parameters: 原始参数
    /// - Returns: 处理后的URL、参数和展示样式
    private func handleInterceptors(url: String, parameters: RouterParameters) async throws
        -> (String, RouterParameters, NavigationPresentationStyle?) {
        var currentUrl = url
        var currentParameters = parameters
        var presentationStyle: NavigationPresentationStyle?
        
        for interceptor in interceptors {
            let result = try await interceptor.intercept(
                url: currentUrl,
                parameters: currentParameters
            )
            
            switch result {
            case .continue(let newUrl, let newParameters):
                currentUrl = newUrl ?? currentUrl
                currentParameters = newParameters ?? currentParameters
                
            case .redirect(let redirectUrl, let redirectParameters):
                currentUrl = redirectUrl
                currentParameters = redirectParameters ?? [:]
                
            case .block(let error):
                throw error
                
            case .modifyPresentation(let style):
                presentationStyle = style
                
            case .complete:
                // 拦截器已完成处理，直接返回
                return (currentUrl, currentParameters, presentationStyle)
            }
        }
        
        return (currentUrl, currentParameters, presentationStyle)
    }
    
    /// 取消当前导航
    public func cancelCurrentNavigation() {
        Task {
            await withCheckedContinuation { continuation in
                Task {
                    if let task = currentNavigationTask {
                        task.cancel()
                        currentNavigationTask = nil
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
                                   completion: @escaping RouterCompletion) {
        
        let task = Task {
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
                        case .replace:
                            finalType = .replace
                        }
                    }
                    
                    // 处理自定义动画
                    if let animationId = animationId {
                        if let animation = animations[animationId] {
                            viewController.transitioningDelegate = self
                            currentAnimation = animation
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
                        if retryCount < maxRetryCount {
                            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                self.performNavigation(
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
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
                
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
        
        currentNavigationTask = task
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