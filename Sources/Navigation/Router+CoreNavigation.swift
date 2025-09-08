//
//  Router+CoreNavigation.swift
//  RouterKit
//
//  Created by fengming on 2025/8/4.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import Foundation

#if canImport(UIKit) || canImport(AppKit)

// MARK: - 导航配置结构体

/// 内部导航执行配置
private struct InternalNavigationConfig {
    let urlString: String
    let presentationStyle: NavigationPresentationStyle?
    let parameters: RouterParameters
    let sourceVC: PlatformViewController?
    let type: NavigationType
    let animated: Bool
    let animationId: String?
    let retryCount: Int
    let completion: RouterCompletion
}

/// 导航配置
public struct NavigationConfig {
    public let parameters: RouterParameters?
    public let sourceVC: PlatformViewController?
    public let type: NavigationType
    public let animated: Bool
    public let animationId: String?
    public let retryCount: Int
    
    public init(
        parameters: RouterParameters? = nil,
        sourceVC: PlatformViewController? = nil,
        type: NavigationType = .push,
        animated: Bool = true,
        animationId: String? = nil,
        retryCount: Int = 0
    ) {
        self.parameters = parameters
        self.sourceVC = sourceVC
        self.type = type
        self.animated = animated
        self.animationId = animationId
        self.retryCount = retryCount
    }
}

// MARK: - 核心导航逻辑扩展

@MainActor
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    /// 核心导航方法
    /// - Parameters:
    ///   - urlString: 目标URL字符串
    ///   - config: 导航配置
    ///   - completion: 完成回调
    public func navigate(to urlString: String,
                         config: NavigationConfig = NavigationConfig(),
                         completion: @escaping RouterCompletion) {
        Task {
            do {
                // 处理拦截器
                let interceptorList = await state.getInterceptors()
                let (finalUrl, finalParameters, presentationStyle) = try await handleInterceptors(
                    interceptors: interceptorList,
                    url: urlString,
                    parameters: config.parameters ?? [:]
                )

                // 执行导航
                let internalConfig = InternalNavigationConfig(
                    urlString: finalUrl,
                    presentationStyle: presentationStyle,
                    parameters: finalParameters,
                    sourceVC: config.sourceVC,
                    type: config.type,
                    animated: config.animated,
                    animationId: config.animationId,
                    retryCount: config.retryCount,
                    completion: completion
                )
                await performNavigation(config: internalConfig)
            } catch {
                await MainActor.run {
                    let routerError = error as? RouterError ?? RouterError.navigationError(error.localizedDescription)
                    completion(Result.failure(routerError))
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
            // 使用 continuation 来处理异步拦截器回调
            let result: (Bool, String?, String?, RouterParameters?, NavigationPresentationStyle?) = await withCheckedContinuation { continuation in
                interceptor.intercept(
                    url: currentUrl,
                    parameters: currentParameters
                ) { allow, redirectUrl, errorMsg, newParams, style in
                    continuation.resume(returning: (allow, redirectUrl, errorMsg, newParams, style))
                }
            }

            // 处理拦截器结果
            let (allow, redirectUrl, errorMsg, newParams, style) = result
            
            if allow {
                // 允许继续导航，可能有重定向URL和新参数
                if let newUrl = redirectUrl {
                    currentUrl = newUrl
                }
                if let newParams = newParams {
                    currentParameters = newParams
                }
                if let newStyle = style {
                    presentationStyle = newStyle
                }
            } else {
                // 拦截器拒绝访问，但可能提供重定向URL
                if let redirectUrl = redirectUrl {
                    // 有重定向URL，执行重定向
                    currentUrl = redirectUrl
                    if let newParams = newParams {
                        currentParameters = newParams
                    }
                    if let newStyle = style {
                        presentationStyle = newStyle
                    }
                } else if let error = errorMsg {
                    // 没有重定向URL但有错误信息，抛出错误
                    throw RouterError.interceptorRejected(error)
                } else {
                    // 没有重定向URL也没有错误信息
                    throw RouterError.interceptorRejected("拦截器拒绝访问")
                }
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
    /// 执行导航
    /// - Parameter config: 内部导航配置
    private func performNavigation(config: InternalNavigationConfig) async {

        let task: Task<Void, Error> = Task {
            do {
                guard let url = URL(string: config.urlString) else {
                    throw RouterError.invalidURL(config.urlString)
                }

                // 创建视图控制器
                let viewController: PlatformViewController
                do {
                    viewController = try await createViewController(for: url, parameters: config.parameters)
                } catch let error as RouterError {
                    // 捕获特定的路由错误并提供更详细的错误信息
                    throw RouterError.viewControllerNotFound(config.urlString, debugInfo: "创建视图控制器失败: \(error.localizedDescription)")
                } catch {
                    // 捕获其他错误
                    throw RouterError.navigationError("创建视图控制器时发生未知错误: \(error.localizedDescription)")
                }

                await MainActor.run {
                    #if canImport(UIKit)
                    // 处理自定义动画
                    if let animationId = config.animationId {
                        Task {
                            if let animation = await state.getAnimation(animationId) {
                                await MainActor.run {
                                    viewController.transitioningDelegate = self
                                }
                                await state.setCurrentAnimation(animation)
                            }
                        }
                    }
                    #endif

                    // 执行导航
                    do {
                        let sourceViewController = config.sourceVC ?? getTopMostViewController()
                        
                        // 检查源视图控制器是否存在
                        guard let sourceVC = sourceViewController else {
                            throw RouterError.navigationError("无法获取源视图控制器")
                        }

                        // 拦截器可能覆盖导航类型
                        var finalType = config.type
                        if let style = config.presentationStyle {
                            switch style {
                            case .push:
                                finalType = .push
                            case .present, .presentWithNavigation:
                                finalType = .present
                            case .replace:
                                finalType = .replace
                            case .custom:
                                // 自定义样式保持原有类型
                                break
                            }
                        }

                        switch finalType {
                        case .push:
                            try push(from: sourceVC, to: viewController, animated: config.animated)

                        case .present:
                            present(from: sourceVC, to: viewController, animated: config.animated) {
                                config.completion(Result.success(()))
                            }
                            return // present有自己的completion处理

                        case .replace:
                            try replace(from: sourceVC, to: viewController, animated: config.animated)

                        case .pop:
                            pop(from: sourceVC, animated: config.animated)

                        case .popToRoot:
                            popToRoot(from: sourceVC, animated: config.animated)

                        case .popTo:
                            if let targetVC = findViewController(matching: config.urlString) {
                                popTo(target: targetVC, from: sourceVC, animated: config.animated)
                            } else {
                                throw RouterError.viewControllerNotFound(config.urlString)
                            }
                        }

                        config.completion(Result.success(()))

                    } catch {
                        // 错误处理和重试机制
                        Task {
                            let maxRetryCount = await state.getMaxRetryCount()
                            let retryDelay = await state.getRetryDelay()

                            await MainActor.run {
                                if config.retryCount < maxRetryCount {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                                        Task {
                                            let retryConfig = InternalNavigationConfig(
                                                urlString: config.urlString,
                                                presentationStyle: config.presentationStyle,
                                                parameters: config.parameters,
                                                sourceVC: config.sourceVC,
                                                type: config.type,
                                                animated: config.animated,
                                                animationId: config.animationId,
                                                retryCount: config.retryCount + 1,
                                                completion: config.completion
                                            )
                                            await self.performNavigation(config: retryConfig)
                                        }
                                    }
                                } else {
                                    config.completion(Result.failure(RouterError.navigationError(error.localizedDescription)))
                                }
                            }
                        }
                    }
                }

            } catch {
                await MainActor.run {
                    let routerError = error as? RouterError ?? RouterError.navigationError(error.localizedDescription)
                    config.completion(Result.failure(routerError))
                }
            }
        }

        await state.setCurrentNavigationTask(task)
    }

    /// 查找匹配的视图控制器
    /// - Parameter urlString: URL字符串
    /// - Returns: 匹配的视图控制器
    private func findViewController(matching urlString: String) -> PlatformViewController? {
        #if canImport(UIKit)
        guard let navigationController = topMostViewController()?.navigationController else {
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
        #elseif canImport(AppKit)
        // macOS上的简化实现，返回nil
        return nil
        #else
        return nil
        #endif
    }
}

#endif
