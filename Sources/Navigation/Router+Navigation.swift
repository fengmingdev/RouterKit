//
//  Router+Navigation.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation
import UIKit

// MARK: - 导航功能扩展

@MainActor
extension Router: UIViewControllerTransitioningDelegate {
    /// 静态push方法，方便全局调用
    /// - Parameters:
    ///   - url: 目标URL字符串
    ///   - parameters: 路由参数
    public static func push(to url: String,
                            parameters: RouterParameters? = nil,
                            from sourceVC: UIViewController? = nil,
                            animated: Bool = true,
                            animationId: String? = nil,
                            completion: @escaping RouterCompletion = { _ in })
    {
        shared.navigate(
            to: url,
            parameters: parameters,
            from: sourceVC,
            type: .push,
            animated: animated,
            animationId: animationId,
            completion: completion
        )
    }

    /// 静态present方法，方便全局调用
    /// - Parameters:
    ///   - url: 目标URL字符串
    ///   - parameters: 路由参数
    public static func present(to url: String,
                               parameters: RouterParameters? = nil,
                               from sourceVC: UIViewController? = nil,
                               animated: Bool = true,
                               animationId: String? = nil,
                               completion: @escaping RouterCompletion = { _ in })
    {
        shared.navigate(
            to: url,
            parameters: parameters,
            from: sourceVC,
            type: .present,
            animated: animated,
            animationId: animationId,
            completion: completion
        )
    }

    /// 静态replace方法，替换当前页面
    /// - Parameters:
    ///   - url: 目标URL字符串
    ///   - parameters: 路由参数
    public static func replace(to url: String,
                               parameters: RouterParameters? = nil,
                               from sourceVC: UIViewController? = nil,
                               animated: Bool = true,
                               animationId: String? = nil,
                               completion: @escaping RouterCompletion = { _ in })
    {
        shared.navigate(
            to: url,
            parameters: parameters,
            from: sourceVC,
            type: .replace,
            animated: animated,
            animationId: animationId,
            completion: completion
        )
    }

    /// 静态popToRoot方法，返回根页面
    /// - Parameters:
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    public static func popToRoot(animated: Bool = true,
                                 completion: @escaping RouterCompletion = { _ in })
    {
        shared.navigate(
            to: "",
            parameters: nil,
            from: nil,
            type: .popToRoot,
            animated: animated,
            animationId: nil,
            completion: completion
        )
    }

    /// 静态popTo方法，返回指定页面
    /// - Parameters:
    ///   - url: 目标URL字符串（用于匹配要返回的页面）
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    public static func popTo(url: String,
                             animated: Bool = true,
                             completion: @escaping RouterCompletion = { _ in })
    {
        shared.navigate(
            to: url,
            parameters: nil,
            from: nil,
            type: .popTo,
            animated: animated,
            animationId: nil,
            completion: completion
        )
    }

    /// 执行页面导航
    /// - 使用场景：应用内页面跳转的核心方法，支持多种导航类型
    /// - 注意事项：
    ///   1. URL字符串应符合路由规则，格式为"模块名/路径"（如"UserModule/profile"）
    ///   2. 导航操作会自动处理模块依赖和加载
    ///   3. 对于需要权限验证的页面，建议通过拦截器实现
    ///   4. 重试机制仅适用于可重试的错误类型
    /// - Parameters:
    ///   - urlString: 目标URL字符串
    ///   - parameters: 路由参数，支持基本类型、字典和数组
    ///   - sourceVC: 源视图控制器（默认取顶层控制器）
    ///   - type: 导航类型（push/present/replace/popToRoot/popTo）
    ///   - animated: 是否使用动画
    ///   - animationId: 自定义动画标识，需提前注册
    ///   - retryCount: 当前重试次数（内部使用）
    ///   - completion: 导航完成回调，返回成功或失败信息
    public func navigate(to urlString: String,
                         parameters: RouterParameters? = nil,
                         from sourceVC: UIViewController? = nil,
                         type: NavigationType = .push,
                         animated: Bool = true,
                         animationId: String? = nil,
                         retryCount: Int = 0,
                         completion: @escaping RouterCompletion)
    {
        // 启动异步任务处理拦截器（因为需要访问actor）
        Task {
            do {
                // 先执行拦截器链
                let (url, params) = try await handleInterceptors(url: urlString, parameters: parameters ?? [:])
                
                // 拦截通过，执行导航
                self.performNavigation(urlString: url,
                                       parameters: params,
                                       sourceVC: sourceVC,
                                       type: type,
                                       animated: animated,
                                       animationId: animationId,
                                       retryCount: retryCount,
                                       completion: completion)
            } catch let error as RouterError {
                // 拦截失败，返回错误
                log("导航失败: \(error)", level: .error)
                completion(.failure(error))
            } catch {
                completion(.failure(.interceptorRejected(error.localizedDescription)))
            }
        }
    }
    
    /// 处理拦截器链（改为异步方法）
    /// - Parameters:
    ///   - url: 目标URL
    ///   - parameters: 路由参数
    /// - Returns: 处理后的URL和参数
    /// - Throws: 拦截失败时抛出错误
    private func handleInterceptors(url: String, parameters: RouterParameters) async throws -> (String, RouterParameters) {
        // 通过actor安全获取拦截器列表
        let interceptors = await state.getInterceptors()
        var currentUrl = url
        var currentParams = parameters
        var index = 0
        let total = interceptors.count
        
        // 使用异步序列处理拦截器链
        while index < total {
            let interceptor = interceptors[index]
            index += 1
            
            // 使用withCheckedThrowingContinuation将回调转为async/await，并使用弱引用避免循环引用
            let (redirectUrl, newParams) = try await withCheckedThrowingContinuation { [weak interceptor] continuation in
                guard let interceptor = interceptor else { return }
                interceptor.intercept(url: currentUrl, parameters: currentParams) { allowed, reason, url, params in
                    if allowed {
                        continuation.resume(returning: (url, params))
                    } else if let redirectUrl = url {
                        // 拦截并重定向
                        continuation.resume(returning: (redirectUrl, params))
                    } else {
                        continuation.resume(throwing: RouterError.interceptorRejected(reason ?? "未指定原因"))
                    }
                }
            }
            
            // 处理重定向和参数更新
            if let redirectUrl = redirectUrl {
                currentUrl = redirectUrl
            }
            if let newParams = newParams {
                currentParams.merge(newParams) { $1 }
            }
        }
        
        return (currentUrl, currentParams)
    }
    
    /// 取消当前正在进行的导航
    public func cancelCurrentNavigation() {
        log("取消当前导航任务", level: .info)
        currentNavigationTask?.cancel()
        currentNavigationTask = nil
    }

    /// 执行实际导航操作
    private func performNavigation(urlString: String,
                                   parameters: RouterParameters,
                                   sourceVC: UIViewController?,
                                   type: NavigationType,
                                   animated: Bool,
                                   animationId: String?,
                                   retryCount: Int,
                                   completion: @escaping RouterCompletion)
    {
        log("开始执行导航: \(urlString), 类型: \(type)", level: .info)
        guard let url = URL(string: urlString) else {
            log("无效URL: \(urlString)", level: .error)
            completion(.failure(.invalidURL(urlString)))
            return
        }
        log("URL解析成功: \(url)", level: .info)
        
        // 取消现有导航任务
        cancelCurrentNavigation()
        
        // 启动新的导航任务
        currentNavigationTask = Task { [weak self] in
            guard let self = self else { return }
        
            do {
                // 创建目标视图控制器
                let targetVC = try await createViewController(for: url, parameters: parameters)
                // 获取源视图控制器（默认顶层控制器）
                let sourceVC = sourceVC ?? topMostViewController()
                // 处理自定义动画（通过actor获取）
                var animation: NavigationAnimatable?
                if let animationId = animationId {
                    animation = await state.getAnimation(animationId)
                    if animation == nil {
                        throw RouterError.animationNotFound(animationId)
                    }
                    targetVC.transitioningDelegate = self // 设置转场代理
                    currentAnimation = animation // 记录当前动画
                }
                
                // 根据导航类型执行不同操作
                switch type {
                case .push:
                    log("执行push导航", level: .info)
                    try push(from: sourceVC, to: targetVC, animated: animated)
                    // 清理动画引用
                    targetVC.transitioningDelegate = nil
                    currentAnimation = nil
                    completion(.success(nil))
                    
                case .present:
                    log("执行present导航", level: .info)
                    present(from: sourceVC, to: targetVC, animated: animated) {
                        // 清理动画引用
                        targetVC.transitioningDelegate = nil
                        self.currentAnimation = nil
                        completion(.success(nil))
                    }
                    
                case .replace:
                    log("执行replace导航", level: .info)
                    try replace(from: sourceVC, to: targetVC, animated: animated)
                    // 清理动画引用
                    targetVC.transitioningDelegate = nil
                    currentAnimation = nil
                    completion(.success(nil))
                    
                case .popToRoot:
                    log("执行popToRoot导航", level: .info)
                    popToRoot(from: sourceVC, animated: animated)
                    // 清理动画引用
                    targetVC.transitioningDelegate = nil
                    currentAnimation = nil
                    completion(.success(nil))
                    
                case .popTo:
                    // 返回指定页面
                    if let targetVC = parameters["targetViewController"] as? UIViewController {
                        popTo(target: targetVC, from: sourceVC, animated: animated)
                        // 清理动画引用
                        targetVC.transitioningDelegate = nil
                        currentAnimation = nil
                        completion(.success(nil))
                    } else if let targetClassName = parameters["targetViewControllerClass"] as? String {
                        popToViewController(withClassName: targetClassName, from: sourceVC, animated: animated)
                        // 清理动画引用
                        targetVC.transitioningDelegate = nil
                        currentAnimation = nil
                        completion(.success(nil))
                    } else {
                        completion(.failure(.parameterError("popTo需要指定targetViewController或targetViewControllerClass参数", "请提供要返回的视图控制器实例或类名")))
                    }
                }
                
                log("导航成功: \(urlString)", level: .info)
            } catch let error as RouterError {
                // 处理错误（支持重试）
                let maxRetryCount = await state.getMaxRetryCount()
                let retryDelay = await state.getRetryDelay()
                
                if retryCount < maxRetryCount, error.isRetryable {
                    log("导航失败，将重试 (\(retryCount + 1)/\(maxRetryCount)): \(error)", level: .warning)
                    DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                        self?.navigate(to: urlString,
                                       parameters: parameters,
                                       from: sourceVC,
                                       type: type,
                                       animated: animated,
                                       animationId: animationId,
                                       retryCount: retryCount + 1,
                                       completion: completion)
                    }
                    return
                }
                
                completion(.failure(error))
            } catch {
                log("导航发生未知错误: \(error.localizedDescription)", level: .error)
                completion(.failure(.navigationError(error.localizedDescription)))
            }
        }
    }
    
    /// 根据URL和参数创建视图控制器（改为异步方法）
    private func createViewController(for url: URL, parameters: RouterParameters) async throws -> UIViewController {
        let (path, urlParams) = parseURL(url) // 解析URL路径和参数
        
        // 查找匹配的路由（异步方式）
        guard let (routableType, pathParams, _) = await findMatchingRoute(for: path) else {
            throw RouterError.viewControllerNotFound(path)
        }
        
        // 合并参数（URL参数 < 路径参数 < 外部参数）
        var mergedParams = urlParams
        pathParams.forEach { mergedParams[$0.key] = $0.value }
        parameters.forEach { mergedParams[$0.key] = $0.value }
        
        // 确保在主线程创建视图控制器
        return try await MainActor.run {
            guard let vc = routableType.viewController(with: mergedParams) else {
                throw RouterError.viewControllerNotFound(path)
            }
            return vc
        }
    }
    
    /// 解析URL获取路径和参数
    private func parseURL(_ url: URL) -> (path: String, parameters: RouterParameters) {
        var params: RouterParameters = [:]
        
        // 解析查询参数（?key=value&...）
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                params[item.name] = item.value
            }
        }
        
        // 解析锚点（#fragment）
        if let fragment = url.fragment, !fragment.isEmpty {
            params["fragment"] = fragment
        }
        
        return (url.path, params)
    }
    
    /// 查找与路径匹配的路由（改为异步方法）
    private func findMatchingRoute(for path: String) async -> (Routable.Type, RouterParameters, String)? {
        let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
        guard !pathComponents.isEmpty else {
            return nil
        }
        
        let moduleName = pathComponents[0]
        
        // 尝试获取并加载模块，获取路由模式
        guard let patterns = try? await loadModuleAndGetPatterns(moduleName) else {
            return nil
        }
        
        // 按优先级排序路由模式（精确匹配优先）
        let sortedPatterns = sortPatternsByPriority(patterns)
        
        // 遍历模块下的所有路由模式
        for (_, pattern) in sortedPatterns.enumerated() {
            // 通过actor获取适合的匹配器
            let matcher = await state.findMatcher(for: pattern.pattern)
            
            let (isMatch, params) = matcher.match(path: path, pattern: pattern.pattern)
            
            if isMatch {
                // 通过actor获取路由对应的可路由类型
                if let routableType = await state.getRoutableType(for: pattern) {
                    return (routableType, params, moduleName)
                }
            }
        }
        
        return nil // 未找到匹配的路由
    }

    /// 加载模块并获取路由模式
    private func loadModuleAndGetPatterns(_ moduleName: String) async throws -> [RoutePattern] {
        // 通过actor获取模块下的路由模式
        let patterns = await state.getRoutesByModule(moduleName)
        
        // 检查模块是否已加载
        guard patterns.isEmpty else {
            return patterns
        }
        
        // 尝试获取模块
        var module = await state.getModule(moduleName)
        
        // 如果模块不存在，尝试创建并注册
        if module == nil {
            module = Router.shared.createModule(named: moduleName)
            
            guard let newModule = module else {
                throw RouterError.moduleLoadFailed(moduleName)
            }
            
            await state.registerModule(newModule)
            module = newModule
        }
        
        // 确保模块已初始化
        guard let module = module else {
            throw RouterError.moduleLoadFailed(moduleName)
        }
        
        // 尝试加载模块
        let loaded = try await withCheckedThrowingContinuation { continuation in
            module.load { success in
                if success {
                    continuation.resume(returning: success)
                } else {
                    continuation.resume(throwing: RouterError.moduleLoadFailed(moduleName))
                }
            }
        }
        
        guard loaded else {
            throw RouterError.moduleLoadFailed(moduleName)
        }
        
        let newPatterns = await state.getRoutesByModule(moduleName)
        
        guard !newPatterns.isEmpty else {
            throw RouterError.routeNotFound(moduleName)
        }
        
        return newPatterns
    }

    /// 按优先级排序路由模式（精确匹配优先于动态参数匹配）
    private func sortPatternsByPriority(_ patterns: [RoutePattern]) -> [RoutePattern] {
        return patterns.sorted { pattern1, pattern2 in
            // 计算静态路径段数量（字面量匹配的组件数）
            let staticComponents1 = pattern1.components.filter {
                if case .literal(_) = $0 { return true }
                return false
            }.count
            let staticComponents2 = pattern2.components.filter {
                if case .literal(_) = $0 { return true }
                return false
            }.count

            // 静态路径段多的优先
            if staticComponents1 != staticComponents2 {
                return staticComponents1 > staticComponents2
            }

            // 计算必需参数数量（非可选参数）
            let requiredParams1 = pattern1.components.filter {
                if case .parameter(_, false) = $0 { return true }
                return false
            }.count
            let requiredParams2 = pattern2.components.filter {
                if case .parameter(_, false) = $0 { return true }
                return false
            }.count

            // 必需参数少的优先
            if requiredParams1 != requiredParams2 {
                return requiredParams1 < requiredParams2
            }

            // 计算通配符数量
            let wildcards1 = pattern1.components.filter {
                if case .wildcard = $0 { return true }
                return false
            }.count
            let wildcards2 = pattern2.components.filter {
                if case .wildcard = $0 { return true }
                return false
            }.count

            // 通配符少的优先
            if wildcards1 != wildcards2 {
                return wildcards1 < wildcards2
            }

            // 路径段数多的优先
            let components1 = pattern1.pattern.components(separatedBy: "/").filter { !$0.isEmpty }.count
            let components2 = pattern2.pattern.components(separatedBy: "/").filter { !$0.isEmpty }.count

            return components1 > components2
        }
    }
    
    /// 获取当前顶层视图控制器
    private func topMostViewController() -> UIViewController {
        // 从keyWindow获取根控制器
        var topVC = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.rootViewController
        
        // 遍历找到最顶层的presented控制器
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        
        return topVC! // 确保有根控制器
    }
    
    // MARK: - 具体导航操作

    /// 执行push导航
    private func push(from source: UIViewController, to target: UIViewController, animated: Bool) throws {
        guard let nav = source.navigationController else {
            throw RouterError.navigationError("源控制器没有导航控制器，无法执行push")
        }
        nav.pushViewController(target, animated: animated)
    }
    
    /// 执行present导航
    private func present(from source: UIViewController, to target: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        // 如果目标不是导航控制器，则包装一层
        let vcToPresent = target is UINavigationController ? target : UINavigationController(rootViewController: target)
        source.present(vcToPresent, animated: animated, completion: completion)
    }
    
    /// 执行replace导航（替换当前页面）
    private func replace(from source: UIViewController, to target: UIViewController, animated: Bool) throws {
        guard let nav = source.navigationController else {
            throw RouterError.navigationError("源控制器没有导航控制器，无法执行replace")
        }
        
        // 获取当前导航栈并替换最后一个控制器
        var viewControllers = nav.viewControllers
        if viewControllers.isEmpty {
            viewControllers.append(target)
        } else {
            // 保留导航栈历史，替换最后一个控制器
            viewControllers[viewControllers.count - 1] = target
        }
        
        nav.setViewControllers(viewControllers, animated: animated)
    }
    
    /// 返回指定视图控制器
    private func popTo(target: UIViewController, from source: UIViewController, animated: Bool) {
        if let nav = source.navigationController {
            if nav.viewControllers.contains(target) {
                nav.popToViewController(target, animated: animated)
            } else {}
        }
    }
    
    /// 根据类名返回指定视图控制器
    private func popToViewController(withClassName className: String, from source: UIViewController, animated: Bool) {
        if let nav = source.navigationController {
            for vc in nav.viewControllers {
                if String(describing: type(of: vc)) == className {
                    nav.popToViewController(vc, animated: animated)
                    return
                }
            }
        }
    }
    
    /// 返回到根控制器
    private func popToRoot(from source: UIViewController, animated: Bool) {
        if let nav = source.navigationController {
            nav.popToRootViewController(animated: animated)
        } else if let presentingVC = source.presentingViewController {
            // 如果是模态展示，则dismiss
            presentingVC.dismiss(animated: animated)
        }
    }
    
    // MARK: - 转场动画代理（UIViewControllerTransitioningDelegate）

    /// 提供展示动画
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        guard let animation = currentAnimation else { return nil }
        return AnimationTransitionWrapper(animation: animation, isPresentation: true)
    }
    
    /// 提供消失动画
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let animation = currentAnimation else { return nil }
        return AnimationTransitionWrapper(animation: animation, isPresentation: false)
    }
}
