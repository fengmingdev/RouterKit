//
//  RouterCore.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Combine
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
// MARK: - 缓存统计信息结构体

/// 缓存统计信息
public struct RouterCacheStatistics {
    public let hitCount: Int
    public let missCount: Int
    public let hitRate: Double
    public let cacheSize: Int
    public let hotCacheSize: Int
    public let precompiledCacheSize: Int
}

// MARK: - 可路由协议

/// 视图控制器需要遵循的协议，用于路由创建实例
public protocol Routable: AnyObject {
    #if canImport(UIKit) || canImport(AppKit)
    /// 根据路由上下文创建视图控制器
    /// - Parameter context: 路由上下文
    /// - Returns: 视图控制器实例
    static func createViewController(context: RouteContext) async throws -> PlatformViewController

    /// 根据参数创建视图控制器（兼容性方法）
    /// - Parameter parameters: 传递的参数
    /// - Returns: 视图控制器实例（可选）
    static func viewController(with parameters: RouterParameters?) -> PlatformViewController?
    #endif
    /// 执行指定动作
    /// - Parameters:
    ///   - action: 动作名称
    ///   - parameters: 动作参数
    ///   - completion: 完成回调
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion)
}

// MARK: - Routable协议默认实现
extension Routable {
    #if canImport(UIKit)
    /// 默认的createViewController实现，使用兼容性方法
    public static func createViewController(context: RouteContext) async throws -> UIViewController {
        return try await MainActor.run {
            guard let viewController = viewController(with: context.parameters) else {
                throw RouterError.viewControllerNotFound(context.url)
            }
            return viewController
        }
    }
    #endif
}

// MARK: - 路由管理器核心

/// 路由管理器单例，负责模块管理、路由注册和分发
@available(iOS 13.0, macOS 10.15, *)
public final class Router: NSObject, @unchecked Sendable {
    // 单例实例
    public static let shared = Router()
    override private init() {
        super.init()
        startModuleCleanupTimer()
        DispatchQueue.main.async {
            Task {
                await RouterMetrics.shared.initialize()
            }
        }
    }

    // 使用Actor管理状态，替代原来的锁机制
    public var state = RouterState()

    // 内部状态
    #if canImport(UIKit)
    public var currentAnimation: NavigationAnimatable?
    #endif
    internal var cleanupTimer: Timer?
    internal var isCleanupPaused: Bool = false
    internal var lastCleanupTime: Date = .init()
    internal var lifecycleObservers = WeakArray<AnyObject>()
    /// 命名空间缓存
    public var namespaces: [String: RouterNamespace] = [:]

    // MARK: - Configuration Properties
    // Configuration methods moved to RouterConfiguration.swift

    // MARK: - 导航任务管理

    #if swift(>=5.5) && canImport(_Concurrency)
    /// 获取当前导航任务
    @available(iOS 13.0, macOS 10.15, *)
    public func getCurrentNavigationTask() async -> Task<Void, Error>? {
        await state.getCurrentNavigationTask()
    }

    /// 设置当前导航任务
    @available(iOS 13.0, macOS 10.15, *)
    public func setCurrentNavigationTask(_ task: Task<Void, Error>?) async {
        await state.setCurrentNavigationTask(task)
    }
    #endif

    // MARK: - Module Management
    // Module management methods moved to RouterModuleManagement.swift
    
    /// 存储模块依赖关系: 键为被依赖模块名称，值为依赖它的模块列表
    internal var dependentModules: [String: [Weak<AnyObject>]] = [:]

    // MARK: - 重置路由

    /// 重置路由管理器状态（用于测试）
    public func reset() async {
        await state.reset()
        log("路由管理器已重置")
    }

    // MARK: - 权限访问

    /// 获取指定路由的权限配置
    /// - Parameter routePattern: 路由模式
    /// - Returns: 路由权限配置（可选）
    public func getRoutePermission(for routePattern: RoutePattern) async -> RoutePermission? {
        return await state.getRoutePermission(for: routePattern)
    }

    // MARK: - 路由注册

    /// 注册路由模式与对应的可路由类型
    /// - Parameters:
    ///   - pattern: 路由模式（如"/UserModule/profile/:id"）
    ///   - routableType: 可路由类型（遵循Routable协议的视图控制器）
    ///   - permission: 路由访问权限（可选）
    ///   - priority: 路由优先级，数值越大优先级越高（默认为0）
    ///   - scheme: 路由命名空间（默认为空，表示全局命名空间）
    /// - Throws: 路由模式无效、已存在或模块未注册时抛出错误
    public func registerRoute(_ pattern: String, for routableType: Routable.Type, permission: RoutePermission? = nil, priority: Int = 0, scheme: String = "") async throws {
        let routePattern = try RoutePattern(pattern)

        // 检查模块是否已注册
        if !(await state.isModuleLoaded(routePattern.moduleName)) {
            log("路由注册失败：模块未注册 - \(routePattern.moduleName)", level: .error)
            throw RouterError.moduleNotRegistered(routePattern.moduleName)
        }

        try await state.registerRoute(routePattern, routableType: routableType, permission: permission, priority: priority, scheme: scheme)
        log("路由注册成功: \(pattern) -> \(routableType), 优先级: \(priority), 命名空间: \(scheme.isEmpty ? "全局" : scheme)")
    }

    /// 动态注册路由模式与对应的可路由类型（无需模块已注册）
    /// - Parameters:
    ///   - pattern: 路由模式（如"/Dynamic/profile/:id"）
    ///   - routableType: 可路由类型（遵循Routable协议的视图控制器）
    ///   - permission: 路由访问权限（可选）
    ///   - priority: 路由优先级，数值越大优先级越高（默认为0）
    ///   - scheme: 路由命名空间（默认为空，表示全局命名空间）
    /// - Throws: 路由模式无效或已存在时抛出错误
    public func registerDynamicRoute(_ pattern: String, for routableType: Routable.Type, permission: RoutePermission? = nil, priority: Int = 0, scheme: String = "") async throws {
        let routePattern = try RoutePattern(pattern)
        try await state.registerDynamicRoute(routePattern, routableType: routableType, permission: permission, priority: priority, scheme: scheme)
        log("动态路由注册成功: \(pattern) -> \(routableType), 优先级: \(priority), 命名空间: \(scheme.isEmpty ? "全局" : scheme)")
    }

    /// 动态移除已注册的路由
    /// - Parameter pattern: 要移除的路由模式
    /// - Throws: 路由不存在时抛出错误
    public func unregisterDynamicRoute(_ pattern: String) async throws {
        let routePattern = try RoutePattern(pattern)
        try await state.unregisterDynamicRoute(routePattern)
        log("动态路由移除成功: \(pattern)")
    }

    // MARK: - 拦截器管理

    /// 添加拦截器（自动按优先级排序）
    /// - Parameter interceptor: 拦截器实例
    public func addInterceptor(_ interceptor: RouterInterceptor) async {
        await state.addInterceptor(interceptor)
    }

    /// 移除拦截器
    /// - Parameter interceptor: 拦截器实例
    public func removeInterceptor(_ interceptor: RouterInterceptor) async {
        await state.removeInterceptor(interceptor)
    }

    // MARK: - 动画管理

    #if canImport(UIKit)
    /// 注册转场动画
    /// - Parameter animation: 动画实例
    public func registerAnimation(_ animation: NavigationAnimatable) async {
        await state.registerAnimation(animation)
    }

    /// 移除转场动画
    /// - Parameter identifier: 动画标识
    public func unregisterAnimation(_ identifier: String) async {
        await state.unregisterAnimation(identifier)
    }

    /// 获取转场动画
    /// - Parameter identifier: 动画标识
    /// - Returns: 动画实例（可选）
    public func getAnimation(_ identifier: String) async -> NavigationAnimatable? {
        return await state.getAnimation(identifier)
    }
    #endif

    // MARK: - 观察者管理

    /// 添加模块生命周期观察者
    /// - Parameter observer: 观察者实例
    public func addLifecycleObserver(_ observer: ModuleLifecycleObserver) {
        lifecycleObservers.append(observer)
    }

    /// 移除模块生命周期观察者
    /// - Parameter observer: 观察者实例
    public func removeLifecycleObserver(_ observer: ModuleLifecycleObserver) {
        lifecycleObservers.remove(observer)
    }

    /// 通知所有观察者模块状态变化
    /// - Parameters:
    ///   - module: 模块实例
    ///   - state: 新状态
    internal func notifyModuleStateChanged(_ module: ModuleProtocol, _ state: ModuleState) {
        DispatchQueue.main.async { [weak self, weak module] in
            guard let self = self, let module = module else { return }

            let validObservers = self.lifecycleObservers.aliveObjects
                .compactMap { $0 as? ModuleLifecycleObserver }

            validObservers.forEach { $0.module(module, didChangeState: state) }
        }
    }

    // MARK: - 路由匹配器管理

    /// 注册自定义路由匹配器
    /// - Parameters:
    ///   - matcher: 匹配器实例
    ///   - patternPrefix: 匹配器适用的模式前缀
    func registerMatcher(_ matcher: RouteMatcher, for patternPrefix: String) async {
        await state.registerMatcher(matcher, for: patternPrefix)
        log("已注册路由匹配器，前缀: \(patternPrefix)")
    }

    /// 查找适合的路由匹配器
    public func findMatcher(for pattern: String) async -> RouteMatcher {
        return await state.findMatcher(for: pattern)
    }

    // MARK: - 工具方法

    /// 打印日志（带开关控制）
    public func log(_ message: String,
                    level: LogLevel = .info,
                    file: String = #file,
                    line: Int = #line,
                    function: String = #function) {
        DispatchQueue.main.async { [weak self] in
            Task {
                guard let self = self else { return }
                let enableLogging = await self.state.getEnableLogging()
                if enableLogging {
                    await RouterLogger.shared.log(message, level: level, file: file, line: line, function: function)
                }
            }
        }
    }

    // MARK: - Cleanup Management
    // Cleanup methods moved to RouterCleanupManagement.swift

    // MARK: - 优化的路由匹配方法

    public func matchRoute(_ url: URL) async -> (pattern: RoutePattern, type: Routable.Type, parameters: RouterParameters)? {
        let result = await state.matchRoute(url)

        // 记录路由结果
        if let pattern = result?.pattern {
            await RouterMetrics.shared.recordRouteSuccess(routePattern: pattern.pattern, moduleName: pattern.moduleName)
        } else {
            await RouterMetrics.shared.recordRouteFailure(routePattern: url.absoluteString, moduleName: nil, error: RouterError.routeNotFound(url.absoluteString))
        }

        return result
    }
}
