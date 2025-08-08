//
//  RouterCore.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Combine
import Foundation
import UIKit
// MARK: - 可路由协议

/// 视图控制器需要遵循的协议，用于路由创建实例
public protocol Routable: AnyObject {
    /// 根据参数创建视图控制器
    /// - Parameter parameters: 传递的参数
    /// - Returns: 视图控制器实例（可选）
    static func viewController(with parameters: RouterParameters?) -> UIViewController?
    /// 执行指定动作
    /// - Parameters:
    ///   - action: 动作名称
    ///   - parameters: 动作参数
    ///   - completion: 完成回调
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion)
}

// MARK: - 路由管理器核心

/// 路由管理器单例，负责模块管理、路由注册和分发
public final class Router: NSObject, @unchecked Sendable {
    // 单例实例
    static let shared = Router()
    override private init() {
        super.init()
        startModuleCleanupTimer()
        Task {
            await RouterMetrics.shared.initialize()
        }
    }
    
    // 使用Actor管理状态，替代原来的锁机制
    public var state = RouterState()

    // 内部状态
    public var currentAnimation: NavigationAnimatable?
    private var cleanupTimer: Timer?
    private var isCleanupPaused: Bool = false
    private var lastCleanupTime: Date = .init()
    private var lifecycleObservers = WeakArray<AnyObject>()
    /// 命名空间缓存
    public var namespaces: [String: RouterNamespace] = [:]
    // 用于标识正在进行的导航任务
    public var currentNavigationTask: Task<Void, Error>?
    
    // MARK: - 配置参数外部访问接口
        
    /// 获取最大重试次数
    public func getMaxRetryCount() async -> Int {
        await state.getMaxRetryCount()
    }
    
    /// 设置最大重试次数
    public func setMaxRetryCount(_ value: Int) async {
        await state.setMaxRetryCount(value)
    }
    
    /// 获取重试延迟时间（秒）
    public func getRetryDelay() async -> TimeInterval {
        await state.getRetryDelay()
    }
    
    /// 设置重试延迟时间（秒）
    public func setRetryDelay(_ value: TimeInterval) async {
        await state.setRetryDelay(value)
    }
    
    /// 获取模块过期时间（秒）
    public func getModuleExpirationTime() async -> TimeInterval {
        await state.getModuleExpirationTime()
    }
    
    /// 设置模块过期时间（秒）
    public func setModuleExpirationTime(_ value: TimeInterval) async {
        await state.setModuleExpirationTime(value)
    }
    
    /// 获取日志启用状态
    public func getEnableLogging() async -> Bool {
        await state.getEnableLogging()
    }
    
    /// 设置日志启用状态
    public func setEnableLogging(_ value: Bool) async {
        await state.setEnableLogging(value)
    }
    
    /// 获取清理间隔时间（秒）
    public func getCleanupInterval() async -> TimeInterval {
        await state.getCleanupInterval()
    }
    
    /// 设置清理间隔时间（秒）
    public func setCleanupInterval(_ value: TimeInterval) async {
        await state.setCleanupInterval(value)
        // 重新启动定时器以应用新的间隔
        startModuleCleanupTimer()
    }
    
    /// 获取路由缓存大小
    public func getCacheSize() async -> Int {
        await state.getCacheSize()
    }
    
    /// 设置路由缓存大小
    public func setCacheSize(_ value: Int) async {
        await state.setCacheSize(value)
    }
    
    /// 获取参数清理启用状态
    public func getEnableParameterSanitization() async -> Bool {
        await state.getEnableParameterSanitization()
    }
    
    /// 设置参数清理启用状态
    public func setEnableParameterSanitization(_ value: Bool) async {
        await state.setEnableParameterSanitization(value)
    }
    
    /// 设置权限验证器
    public func setPermissionValidator(_ validator: RoutePermissionValidator) async {
        await state.setPermissionValidator(validator)
    }
    
    /// 获取当前权限验证器
    public func getPermissionValidator() async -> RoutePermissionValidator {
        await state.getPermissionValidator()
    }
    
    // MARK: - 模块管理
    /// 存储模块依赖关系: 键为被依赖模块名称，值为依赖它的模块列表
    private var dependentModules: [String: [Weak<AnyObject>]] = [:]

    /// 注册模块
    /// - Parameter module: 模块实例
    func registerModule<T: ModuleProtocol>(_ module: T) async {
        await state.registerModule(module)
        log("模块注册成功: \(module.moduleName)")
        notifyModuleStateChanged(module, .willLoad)

        // 解析并加载依赖模块
        let dependenciesResolved = await resolveDependencies(for: module)
        if !dependenciesResolved {
            log("模块\(module.moduleName)依赖解析失败", level: .error)
        }

        // 加载模块 - 开始计时
        let timerToken = await RouterMetrics.shared.startTiming()

        module.load { [weak self, weak module] success in
            guard let self = self, let module = module else { return }
            Task {
                // 结束计时并记录性能
                await RouterMetrics.shared.endTiming(timerToken, type: .moduleLoading, moduleName: module.moduleName)
                
                if success {
                    self.log("模块加载成功: \(module.moduleName)")
                    self.notifyModuleStateChanged(module, .didLoad)
                    await RouterMetrics.shared.recordModuleRegistered(moduleName: module.moduleName)
                    
                    // 触发依赖此模块的其他模块重试注册
                    self.retryDependentModules(for: module.moduleName)
                } else {
                    self.log("模块加载失败: \(module.moduleName)", level: .error)
                    Task {
                        await self.unregisterModule(module.moduleName)
                    }
                }
            }
        }
    }
    
    /// 卸载模块
    /// - Parameter moduleName: 模块名称
    func unregisterModule(_ moduleName: String) async {
        guard let module = await state.unregisterModule(moduleName) else {
            log("模块未注册: \(moduleName)", level: .warning)
            return
        }
        
        notifyModuleStateChanged(module, .willUnload)
        module.unload()
        
        // 清理模块关联的路由
        await state.cleanupRoutes(for: moduleName)
        
        // 清理缓存
        await state.cleanupRouteCache()
        
        // 记录事件
        await RouterMetrics.shared.recordModuleUnloaded(moduleName: moduleName)
        log("模块卸载成功: \(moduleName)")
        
        // 通知卸载完成
        DispatchQueue.main.async { [weak self, weak module] in
            guard let self = self, let module = module else { return }
            self.notifyModuleStateChanged(module, .didUnload)
        }
    }
    
    /// 检查模块是否已加载
    /// - Parameter moduleName: 模块名称
    /// - Returns: 是否已加载
    func isModuleLoaded(_ moduleName: String) async -> Bool {
        return await state.isModuleLoaded(moduleName)
    }
    
    /// 获取模块实例（任意模块协议类型）
    /// - Parameter name: 模块名称
    /// - Returns: 模块实例（可选）
    func getModule(_ name: String) async -> (any ModuleProtocol)? {
        return await state.getModule(name)
    }
    
    /// 获取指定类型的模块实例
    /// - Parameter type: 模块类型
    /// - Returns: 模块实例（可选）
    func getModule<T: ModuleProtocol>(_ type: T.Type) async -> T? {
        return await state.getModule(type)
    }
    
    /// 重试注册依赖指定模块的其他模块
    /// - Parameter moduleName: 被依赖的模块名称
    private func retryDependentModules(for moduleName: String) {
        guard let dependents = dependentModules[moduleName] else { return }
        
        // 过滤出仍然有效的模块
        let validModules = dependents.compactMap { $0.value as? any ModuleProtocol }
        
        // 移除已处理的依赖关系
        dependentModules.removeValue(forKey: moduleName)
        
        // 重新注册依赖模块
        for module in validModules {
            Task {
                await self.registerModule(module)
            }
        }
    }
    
    /// 自动解析并加载模块依赖
    /// - Returns: 依赖是否成功解析
    private func resolveDependencies(for module: ModuleProtocol) async -> Bool {
        for dependency in module.dependencies {
            let isLoaded = await state.isModuleLoaded(dependency.moduleName)
            guard !isLoaded else {
                continue
            }

            let dependencyModule = createModule(named: dependency.moduleName)

            if let dependencyModule = dependencyModule {
                // 记录依赖关系
                let weakModule = Weak(value: module as AnyObject)
                if dependentModules[dependency.moduleName] == nil {
                    dependentModules[dependency.moduleName] = []
                }
                dependentModules[dependency.moduleName]?.append(weakModule)
                await registerModule(dependencyModule)
            } else if dependency.isRequired {
                log("模块\(module.moduleName)的必需依赖\(dependency.moduleName)未找到", level: .error)
                return false
            }
        }
        return true
    }
    
    /// 通过模块名反射创建实例
    public func createModule(named moduleName: String) -> (any ModuleProtocol)? {
        // 反射方式创建模块
        // 添加模块名前缀以匹配实际类名
        let fullClassName = moduleName
        guard let moduleClass = NSClassFromString(fullClassName) as? ModuleProtocol.Type else {
            return nil
        }

        let moduleInstance = moduleClass.init()
        log("成功创建模块实例: \(moduleName)", level: .info)
        return moduleInstance
    }
    
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
    func registerRoute(_ pattern: String, for routableType: Routable.Type, permission: RoutePermission? = nil, priority: Int = 0, scheme: String = "") async throws {
        let routePattern = try RoutePattern(pattern)
        
        // 检查模块是否已注册
        if !(await state.isModuleLoaded(routePattern.moduleName)) {
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
    func registerDynamicRoute(_ pattern: String, for routableType: Routable.Type, permission: RoutePermission? = nil, priority: Int = 0, scheme: String = "") async throws {
        let routePattern = try RoutePattern(pattern)
        try await state.registerDynamicRoute(routePattern, routableType: routableType, permission: permission, priority: priority, scheme: scheme)
        log("动态路由注册成功: \(pattern) -> \(routableType), 优先级: \(priority), 命名空间: \(scheme.isEmpty ? "全局" : scheme)")
    }
    
    /// 动态移除已注册的路由
    /// - Parameter pattern: 要移除的路由模式
    /// - Throws: 路由不存在时抛出错误
    func unregisterDynamicRoute(_ pattern: String) async throws {
        let routePattern = try RoutePattern(pattern)
        try await state.unregisterDynamicRoute(routePattern)
        log("动态路由移除成功: \(pattern)")
    }
    
    // MARK: - 拦截器管理
    
    /// 添加拦截器（自动按优先级排序）
    /// - Parameter interceptor: 拦截器实例
    func addInterceptor(_ interceptor: RouterInterceptor) async {
        await state.addInterceptor(interceptor)
    }
    
    /// 移除拦截器
    /// - Parameter interceptor: 拦截器实例
    func removeInterceptor(_ interceptor: RouterInterceptor) async {
        await state.removeInterceptor(interceptor)
    }
    
    // MARK: - 动画管理
    
    /// 注册转场动画
    /// - Parameter animation: 动画实例
    func registerAnimation(_ animation: NavigationAnimatable) async {
        await state.registerAnimation(animation)
    }
    
    /// 移除转场动画
    /// - Parameter identifier: 动画标识
    func unregisterAnimation(_ identifier: String) async {
        await state.unregisterAnimation(identifier)
    }
    
    /// 获取转场动画
    /// - Parameter identifier: 动画标识
    /// - Returns: 动画实例（可选）
    func getAnimation(_ identifier: String) async -> NavigationAnimatable? {
        return await state.getAnimation(identifier)
    }
    
    // MARK: - 观察者管理
    
    /// 添加模块生命周期观察者
    /// - Parameter observer: 观察者实例
    func addLifecycleObserver(_ observer: ModuleLifecycleObserver) {
        lifecycleObservers.append(observer)
    }
    
    /// 移除模块生命周期观察者
    /// - Parameter observer: 观察者实例
    func removeLifecycleObserver(_ observer: ModuleLifecycleObserver) {
        lifecycleObservers.remove(observer)
    }
    
    /// 通知所有观察者模块状态变化
    /// - Parameters:
    ///   - module: 模块实例
    ///   - state: 新状态
    private func notifyModuleStateChanged(_ module: ModuleProtocol, _ state: ModuleState) {
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
                    function: String = #function)
    {
        // 这里需要获取enableLogging状态，可能需要通过异步方法
        // 为简单起见，我们假设日志总是启用，或者添加一个获取状态的异步方法
        RouterLogger.shared.log(message, level: level, file: file, line: line, function: function)
    }
    
    /// 启动模块清理定时器
    public func startModuleCleanupTimer() {
        cleanupTimer?.invalidate()
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self, !self.isCleanupPaused else { return }
            Task {
                await self.cleanupUnusedModules()
            }
        }
    }
    
    /// 暂停模块清理
    public func pauseCleanup() {
        isCleanupPaused = true
        log("模块清理已暂停")
    }
    
    /// 恢复模块清理
    public func resumeCleanup() {
        isCleanupPaused = false
        let now = Date()
        if now.timeIntervalSince(lastCleanupTime) > 60 {
            Task {
                await self.cleanupUnusedModules()
            }
        }
        log("模块清理已恢复")
    }
    
    /// 强制清理过期模块
    public func forceCleanup() async {
        await cleanupUnusedModules()
    }
    
    /// 清理未使用的过期模块
    public func cleanupUnusedModules() async {
        let now = Date()
        lastCleanupTime = now
        
        let expiredModuleNames = await state.getExpiredModules(currentTime: now)
        
        for moduleName in expiredModuleNames {
            log("清理过期模块: \(moduleName)")
            await unregisterModule(moduleName)
        }
        
        await state.cleanupRouteCache()
    }
    
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
