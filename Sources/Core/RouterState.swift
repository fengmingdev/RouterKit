//
//  RouterState.swift
//  RouterKitDemo
//
//  Created by fengming on 2025/8/7.
//

import Combine
import Foundation
import UIKit

/// 路由状态管理Actor
/// 负责安全管理所有路由相关的共享状态和数据结构
/// 通过Actor的特性自动保证线程安全，替代传统的锁机制
public actor RouterState {
    // MARK: - 存储容器
    
    /// 模块存储（使用弱引用包装避免循环引用）
    /// 键: 模块名称，值: 弱引用包装的模块实例
    private var modules: [String: Weak<AnyObject>] = [:]
    
    /// 路由注册表项，包含可路由类型和优先级
    private struct RouteEntry {
        let routableType: Routable.Type
        let priority: Int
        let scheme: String
    }
    
    /// 路由注册表
    /// 键: 路由模式（RoutePattern），值: 路由注册表项
    private var routes: [RoutePattern: RouteEntry] = [:]
    
    /// 按模块分组的路由模式
    /// 键: 模块名称，值: 该模块下的所有路由模式数组
    private var routesByModule: [String: [RoutePattern]] = [:]
    
    /// 按命名空间分组的路由模式
    /// 键: 命名空间名称，值: 该命名空间下的所有路由模式数组
    private var routesByScheme: [String: [RoutePattern]] = [:]
    
    /// 路由Trie树（用于优化路由匹配性能）
    private var routeTrie = RouteTrie()
    
    /// 路由权限配置
    /// 键: 路由模式，值: 该路由的访问权限配置
    private var routePermissions: [RoutePattern: RoutePermission] = [:]
    
    /// 拦截器列表（已按优先级排序，降序）
    private var interceptors: [RouterInterceptor] = []
    
    /// 动画注册表
    /// 键: 动画标识，值: 对应的转场动画实例
    private var animations: [String: NavigationAnimatable] = [:]
    
    /// 路由匹配器注册表
    /// 键: 匹配器适用的模式前缀，值: 路由匹配器实例
    /// 默认包含空字符串前缀的默认匹配器
    private var matchers: [String: RouteMatcher] = ["": DefaultRouteMatcher()]
    
    /// 路由缓存
    /// 键: URL字符串，值: 匹配结果元组(路由模式, 可路由类型, 参数)
    private var routeCache: [String: (RoutePattern, Routable.Type, RouterParameters)] = [:]
    
    // MARK: - 配置参数
    
    /// 最大重试次数（当路由失败且可重试时）
    var maxRetryCount: Int = 3
    
    /// 重试延迟时间（秒）
    var retryDelay: TimeInterval = 0.5
    
    /// 模块过期时间（秒）
    /// 超过此时间未使用的模块将被自动清理
    var moduleExpirationTime: TimeInterval = 300 // 5分钟
    
    /// 是否启用日志输出
    var enableLogging: Bool = true
    
    /// 模块清理间隔时间（秒）
    var cleanupInterval: TimeInterval = 60 // 1分钟
    
    /// 路由缓存最大容量
    var cacheSize: Int = 100
    
    /// 是否启用参数清理（安全特性）
    /// 启用后会对路由参数进行安全清理，防止恶意内容
    var enableParameterSanitization: Bool = true
    
    /// 权限验证器实例
    /// 用于验证路由访问权限
    var permissionValidator: RoutePermissionValidator = DefaultPermissionValidator()
    
    // MARK: - 模块管理
    
    /// 注册模块
    /// - Parameter module: 要注册的模块实例（需遵循ModuleProtocol）
    func registerModule(_ module: any ModuleProtocol) {
        let weakWrapper = Weak(value: module as AnyObject)
        modules[module.moduleName] = weakWrapper
    }
    
    /// 卸载模块
    /// - Parameter moduleName: 模块名称
    /// - Returns: 被卸载的模块实例（如果存在）
    func unregisterModule(_ moduleName: String) -> (any ModuleProtocol)? {
        guard let weakWrapper = modules[moduleName],
              let module = weakWrapper.value as? any ModuleProtocol else {
            return nil
        }
        
        modules.removeValue(forKey: moduleName)
        return module
    }
    
    /// 检查模块是否已加载
    /// - Parameter moduleName: 模块名称
    /// - Returns: 模块是否已加载（弱引用仍然有效）
    func isModuleLoaded(_ moduleName: String) -> Bool {
        guard let weakWrapper = modules[moduleName] else {
            return false
        }
        return weakWrapper.value != nil
    }
    
    /// 获取模块实例
    /// - Parameter name: 模块名称
    /// - Returns: 模块实例（可选，弱引用可能已失效）
    func getModule(_ name: String) -> (any ModuleProtocol)? {
        guard let weakWrapper = modules[name] else {
            return nil
        }
        return weakWrapper.value as? any ModuleProtocol
    }
    
    /// 获取指定类型的模块实例
    /// - Parameter type: 模块类型（需遵循ModuleProtocol）
    /// - Returns: 模块实例（可选）
    func getModule<T: ModuleProtocol>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return modules[key]?.value as? T
    }
    
    // MARK: - 路由管理
    
    /// 注册路由模式
    /// - Parameters:
    ///   - routePattern: 路由模式
    ///   - routableType: 对应的可路由类型
    ///   - permission: 路由权限配置（可选）
    ///   - priority: 路由优先级，数值越大优先级越高
    ///   - scheme: 路由命名空间
    /// - Throws: 当路由已存在时抛出错误
    func registerRoute(_ routePattern: RoutePattern, routableType: Routable.Type, permission: RoutePermission?, priority: Int, scheme: String) async throws {
        if routes[routePattern] != nil {
            throw RouterError.routeAlreadyExists(routePattern.pattern)
        }
        
        let routeEntry = RouteEntry(routableType: routableType, priority: priority, scheme: scheme)
        routes[routePattern] = routeEntry
        routesByModule[routePattern.moduleName, default: []].append(routePattern)
        routesByScheme[scheme, default: []].append(routePattern)
        await routeTrie.insert(routePattern)
        
        if let permission = permission {
            routePermissions[routePattern] = permission
        }
    }
    
    /// 注册动态路由（无需模块预先注册）
    /// - Parameters:
    ///   - routePattern: 路由模式
    ///   - routableType: 对应的可路由类型
    ///   - permission: 路由权限配置（可选）
    ///   - priority: 路由优先级，数值越大优先级越高
    ///   - scheme: 路由命名空间
    /// - Throws: 当路由已存在时抛出错误
    func registerDynamicRoute(_ routePattern: RoutePattern, routableType: Routable.Type, permission: RoutePermission?, priority: Int, scheme: String) async throws {
        if routes[routePattern] != nil {
            throw RouterError.routeAlreadyExists(routePattern.pattern)
        }
        
        let routeEntry = RouteEntry(routableType: routableType, priority: priority, scheme: scheme)
        routes[routePattern] = routeEntry
        // 使用路由模式中的模块名
        routesByModule[routePattern.moduleName, default: []].append(routePattern)
        routesByScheme[scheme, default: []].append(routePattern)
        await routeTrie.insert(routePattern)
        
        if let permission = permission {
            routePermissions[routePattern] = permission
        }
    }
    
    /// 清理指定命名空间下的所有路由
    /// - Parameter scheme: 命名空间名称
    func cleanupRoutes(forScheme scheme: String) async {
        guard let schemeRoutes = routesByScheme[scheme] else {
            return
        }
        
        for routePattern in schemeRoutes {
            routes.removeValue(forKey: routePattern)
            routePermissions.removeValue(forKey: routePattern)
            await routeTrie.remove(routePattern)
            
            // 从routesByModule中移除
            for (moduleName, moduleRoutes) in routesByModule {
                var updatedRoutes = moduleRoutes
                updatedRoutes.removeAll { $0 == routePattern }
                if updatedRoutes.isEmpty {
                    routesByModule.removeValue(forKey: moduleName)
                } else {
                    routesByModule[moduleName] = updatedRoutes
                }
            }
        }
        
        routesByScheme.removeValue(forKey: scheme)
        // 清理相关缓存
        routeCache = routeCache.filter { !$0.key.starts(with: scheme + ":") }
    }
    
    /// 移除动态路由
    /// - Parameter routePattern: 要移除的路由模式
    /// - Throws: 当路由不存在时抛出错误
    func unregisterDynamicRoute(_ routePattern: RoutePattern) async throws {
        guard routes[routePattern] != nil else {
            throw RouterError.routeNotFound(routePattern.pattern)
        }
        
        guard let routeEntry = routes[routePattern] else {
            throw RouterError.routeNotFound(routePattern.pattern)
        }
        
        routes.removeValue(forKey: routePattern)
        let dynamicModuleName = "__DynamicRoutes__"
        
        // 从routesByModule中移除
        if var moduleRoutes = routesByModule[dynamicModuleName] {
            moduleRoutes.removeAll { $0 == routePattern }
            if moduleRoutes.isEmpty {
                routesByModule.removeValue(forKey: dynamicModuleName)
            } else {
                routesByModule[dynamicModuleName] = moduleRoutes
            }
        }
        
        // 从routesByScheme中移除
        if var schemeRoutes = routesByScheme[routeEntry.scheme] {
            schemeRoutes.removeAll { $0 == routePattern }
            if schemeRoutes.isEmpty {
                routesByScheme.removeValue(forKey: routeEntry.scheme)
            } else {
                routesByScheme[routeEntry.scheme] = schemeRoutes
            }
        }
        
        await routeTrie.remove(routePattern)
        routePermissions.removeValue(forKey: routePattern)
        routeCache = routeCache.filter { !$0.key.contains(routePattern.pattern) }
    }
    
    /// 获取指定模块下的所有路由模式
    /// - Parameter moduleName: 模块名称
    /// - Returns: 路由模式数组（可能为空）
    func getRoutesByModule(_ moduleName: String) -> [RoutePattern] {
        return routesByModule[moduleName] ?? []
    }
    
    /// 获取路由模式对应的可路由类型
    /// - Parameter pattern: 路由模式
    /// - Returns: 可路由类型（可选）
    func getRoutableType(for pattern: RoutePattern) -> Routable.Type? {
        return routes[pattern]?.routableType
    }
    
    // MARK: - 拦截器管理
    
    /// 添加拦截器（自动按优先级排序）
    /// - Parameter interceptor: 拦截器实例
    func addInterceptor(_ interceptor: RouterInterceptor) {
        interceptors.append(interceptor)
        // 按优先级降序排序（优先级值越大越先执行）
        interceptors.sort { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    /// 移除拦截器
    /// - Parameter interceptor: 要移除的拦截器实例（引用比较）
    func removeInterceptor(_ interceptor: RouterInterceptor) {
        interceptors.removeAll { $0 === interceptor }
    }
    
    /// 获取所有拦截器（按优先级排序）
    /// - Returns: 拦截器数组
    func getInterceptors() -> [RouterInterceptor] {
        return interceptors
    }
    
    // MARK: - 动画管理
    
    /// 注册转场动画
    /// - Parameter animation: 动画实例（需遵循NavigationAnimatable）
    func registerAnimation(_ animation: NavigationAnimatable) {
        animations[animation.identifier] = animation
    }
    
    /// 移除转场动画
    /// - Parameter identifier: 动画标识
    func unregisterAnimation(_ identifier: String) {
        animations.removeValue(forKey: identifier)
    }
    
    /// 获取转场动画
    /// - Parameter identifier: 动画标识
    /// - Returns: 动画实例（可选）
    func getAnimation(_ identifier: String) -> NavigationAnimatable? {
        return animations[identifier]
    }
    
    // MARK: - 匹配器管理
    
    /// 注册自定义路由匹配器
    /// - Parameters:
    ///   - matcher: 匹配器实例
    ///   - patternPrefix: 匹配器适用的路由模式前缀
    func registerMatcher(_ matcher: RouteMatcher, for patternPrefix: String) {
        matchers[patternPrefix] = matcher
    }
    
    /// 查找适合指定路由模式的匹配器
    /// - Parameter pattern: 路由模式
    /// - Returns: 最匹配的路由匹配器
    func findMatcher(for pattern: String) -> RouteMatcher {
        // 按前缀长度降序查找，优先匹配最长前缀
        let prefixes = matchers.keys.sorted { $0.count > $1.count }
        for prefix in prefixes {
            if pattern.hasPrefix(prefix) {
                return matchers[prefix]!
            }
        }
        // 未找到匹配的前缀时使用默认匹配器
        return matchers[""]!
    }
    /// 获取所有已注册的路由
    /// - Returns: 路由模式到可路由类型的字典
    func getAllRoutes() -> [RoutePattern: Routable.Type] {
        return routes.mapValues { $0.routableType }
    }
    // MARK: - 路由匹配与缓存
    
    /// 匹配URL对应的路由
    /// - Parameter url: 目标URL
    /// - Returns: 匹配结果元组(路由模式, 可路由类型, 参数)（可选）
    func matchRoute(_ url: URL) async -> (pattern: RoutePattern, type: Routable.Type, parameters: RouterParameters)? {
        let urlString = url.absoluteString
        // 先检查缓存
        if let cachedResult = routeCache[urlString] {
            return cachedResult
        }
        
        // 解析URL路径
        let path = url.path
        let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
        
        // 使用Trie树查找匹配的路由
        guard let (pattern, parameters) = await routeTrie.find(pathComponents),
              let routeEntry = routes[pattern] else {
            return nil
        }
        let routableType = routeEntry.routableType
        
        // 参数清理（如果启用）
        var sanitizedParameters = parameters
        if enableParameterSanitization {
            sanitizedParameters = RouterSecurity.shared.sanitizeParameters(parameters) ?? parameters
        }
        
        // 缓存匹配结果
        let result = (pattern, routableType, sanitizedParameters)
        routeCache[urlString] = result
        return result
    }
    
    /// 清理路由缓存（当缓存大小超过限制时）
    func cleanupRouteCache() {
        if routeCache.count > cacheSize {
            // 当缓存超过限制时，只保留一半
            let entriesToRemove = routeCache.count - (cacheSize / 2)
            let keysToRemove = Array(routeCache.keys.prefix(entriesToRemove))
            for key in keysToRemove {
                routeCache.removeValue(forKey: key)
            }
        }
    }
    
    // MARK: - 模块清理辅助
    
    /// 清理指定模块的所有关联路由
    /// - Parameter moduleName: 模块名称
    func cleanupRoutes(for moduleName: String) async {
        if let moduleRoutes = routesByModule[moduleName] {
            for route in moduleRoutes {
                routes.removeValue(forKey: route)
                await routeTrie.remove(route)
                routePermissions.removeValue(forKey: route)
            }
        }
        routesByModule.removeValue(forKey: moduleName)
        // 清理与该模块相关的缓存
        routeCache = routeCache.filter { !$0.value.0.moduleName.contains(moduleName) }
    }
    
    /// 获取所有过期模块的名称
    /// - Parameter currentTime: 当前时间
    /// - Returns: 过期模块名称数组
    func getExpiredModules(currentTime: Date) -> [String] {
        return modules.compactMap { name, weakWrapper in
            guard let module = weakWrapper.value as? any ModuleProtocol else {
                // 弱引用已失效的模块直接视为过期
                return name
            }
            
            // 检查是否超过过期时间
            if currentTime.timeIntervalSince(module.lastUsedTime) > moduleExpirationTime {
                return name
            }
            return nil
        }
    }
    
    // MARK: - 权限管理
    
    /// 获取指定路由的权限配置
    /// - Parameter routePattern: 路由模式
    /// - Returns: 权限配置（可选）
    func getRoutePermission(for routePattern: RoutePattern) -> RoutePermission? {
        return routePermissions[routePattern]
    }
    
    // MARK: - 状态重置（主要用于测试）
    
    /// 重置所有状态数据
    func reset() {
        modules.removeAll()
        routes.removeAll()
        routesByModule.removeAll()
        routeTrie = RouteTrie()
        routePermissions.removeAll()
        routeCache.removeAll()
        interceptors.removeAll()
        animations.removeAll()
        // 重置配置参数为默认值
        maxRetryCount = 3
        retryDelay = 0.5
        moduleExpirationTime = 300
        enableLogging = true
        cleanupInterval = 60
        cacheSize = 100
        enableParameterSanitization = true
        permissionValidator = DefaultPermissionValidator()
    }
    
    // MARK: - 配置参数访问器
    
    /// 获取最大重试次数
    func getMaxRetryCount() -> Int { maxRetryCount }
    /// 设置最大重试次数
    func setMaxRetryCount(_ value: Int) { maxRetryCount = value }
    
    /// 获取重试延迟时间（秒）
    func getRetryDelay() -> TimeInterval { retryDelay }
    /// 设置重试延迟时间（秒）
    func setRetryDelay(_ value: TimeInterval) { retryDelay = value }
    
    /// 获取模块过期时间（秒）
    func getModuleExpirationTime() -> TimeInterval { moduleExpirationTime }
    /// 设置模块过期时间（秒）
    func setModuleExpirationTime(_ value: TimeInterval) { moduleExpirationTime = value }
    
    /// 获取日志启用状态
    func getEnableLogging() -> Bool { enableLogging }
    /// 设置日志启用状态
    func setEnableLogging(_ value: Bool) { enableLogging = value }
    
    /// 获取清理间隔时间（秒）
    func getCleanupInterval() -> TimeInterval { cleanupInterval }
    /// 设置清理间隔时间（秒）
    func setCleanupInterval(_ value: TimeInterval) { cleanupInterval = value }
    
    /// 获取路由缓存大小
    func getCacheSize() -> Int { cacheSize }
    /// 设置路由缓存大小
    func setCacheSize(_ value: Int) { cacheSize = value }
    
    /// 获取参数清理启用状态
    func getEnableParameterSanitization() -> Bool { enableParameterSanitization }
    /// 设置参数清理启用状态
    func setEnableParameterSanitization(_ value: Bool) { enableParameterSanitization = value }
    
    /// 设置权限验证器
    func setPermissionValidator(_ validator: RoutePermissionValidator) {
        permissionValidator = validator
    }
    /// 获取当前权限验证器
    func getPermissionValidator() -> RoutePermissionValidator {
        return permissionValidator
    }
}
