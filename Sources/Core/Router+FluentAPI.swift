//
//  Router+FluentAPI.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

#if canImport(UIKit)
import UIKit

/// 路由导航参数构建器，支持链式调用
public class NavigationBuilder {
    private let router: Router
    private let url: String
    private var parameters: RouterParameters = [:]
    private var sourceVC: UIViewController?
    private var type: NavigationType = .push
    private var animated: Bool = true
    private var animationId: String?
    private var completion: RouterCompletion?
    private var modalPresentationStyle: UIModalPresentationStyle?
    private var modalTransitionStyle: UIModalTransitionStyle?
    
    init(router: Router, url: String) {
        self.router = router
        self.url = url
    }
    
    /// 设置路由参数
    public func with(parameters: RouterParameters) -> Self {
        self.parameters = parameters
        return self
    }
    
    /// 添加单个参数
    public func addParameter(key: String, value: Any) -> Self {
        parameters[key] = value
        return self
    }
    
    /// 设置源视图控制器
    public func from(_ sourceVC: UIViewController) -> Self {
        self.sourceVC = sourceVC
        return self
    }
    
    /// 设置导航类型
    public func with(type: NavigationType) -> Self {
        self.type = type
        return self
    }
    
    /// 设置是否动画
    public func animated(_ animated: Bool) -> Self {
        self.animated = animated
        return self
    }
    
    /// 设置自定义动画
    public func using(animationId: String) -> Self {
        self.animationId = animationId
        return self
    }
    
    /// 设置完成回调
    public func completion(_ completion: @escaping RouterCompletion) -> Self {
        self.completion = completion
        return self
    }
    
    /// 设置模态展示样式
    public func presentationStyle(_ style: UIModalPresentationStyle) -> Self {
        self.modalPresentationStyle = style
        return self
    }
    
    /// 设置模态过渡样式
    public func transitionStyle(_ style: UIModalTransitionStyle) -> Self {
        self.modalTransitionStyle = style
        return self
    }
    
    /// 执行导航
    @MainActor public func navigate() {
        var options: [String: Any] = [:]
        if let presentationStyle = modalPresentationStyle {
            options["modalPresentationStyle"] = presentationStyle
        }
        if let transitionStyle = modalTransitionStyle {
            options["modalTransitionStyle"] = transitionStyle
        }
        
        router.navigate(
            to: url,
            parameters: parameters,
            from: sourceVC,
            type: type,
            animated: animated,
            animationId: animationId,
            completion: completion ?? { _ in }
        )
    }
}

/// 路由注册构建器
public class RouteRegistrationBuilder {
    private let router: Router
    private let pattern: String
    private let routableType: Routable.Type
    private var permission: RoutePermission?
    private var priority: Int = 0
    
    init(router: Router, pattern: String, routableType: Routable.Type) {
        self.router = router
        self.pattern = pattern
        self.routableType = routableType
    }
    
    /// 设置路由权限
    public func with(permission: RoutePermission) -> Self {
        self.permission = permission
        return self
    }
    
    /// 设置路由优先级
    public func with(priority: Int) -> Self {
        self.priority = priority
        return self
    }
    
    /// 完成注册
    public func register() async throws {
        try await router.registerRoute(pattern, for: routableType, permission: permission, priority: priority)
    }
}

// MARK: - 为Router添加链式调用支持
extension Router {
    /// 创建导航构建器，开始链式调用
    public func navigate(to url: String) -> NavigationBuilder {
        return NavigationBuilder(router: self, url: url)
    }
    
    /// 创建路由注册构建器
    public func register(_ pattern: String, for routableType: Routable.Type) -> RouteRegistrationBuilder {
        return RouteRegistrationBuilder(router: self, pattern: pattern, routableType: routableType)
    }
    
    /// 快速打开URL
    @MainActor public func open(_ url: URL, from sourceVC: UIViewController? = nil, animated: Bool = true) {
        navigate(to: url.absoluteString)
            .from(sourceVC ?? topMostViewController()!)
            .animated(animated)
            .navigate()
    }
    
    /// 获取当前最顶层的视图控制器
    public func topMostViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topVC = window.rootViewController
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        
        return topVC
    }
}

#endif
