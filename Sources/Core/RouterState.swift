//
//  RouterState.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Combine
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// 路由状态管理器
/// 作为各个专门管理器的协调器，提供统一的接口
@available(iOS 13.0, macOS 10.15, *)
public actor RouterState {
    
    // MARK: - 管理器实例
    
    /// 模块管理器
    private let moduleManager = RouterStateModuleManager()
    
    /// 路由管理器
    private let routeManager = RouterStateRouteManager()
    
    /// 拦截器管理器
    private let interceptorManager = RouterStateInterceptorManager()
    
    /// 配置管理器
    private let configurationManager = RouterStateConfigurationManager()
    
    /// 缓存管理器
    private let cacheManager = RouterStateCacheManager()
    
    // MARK: - 模块管理代理方法
    
    /// 注册模块
    /// - Parameter module: 要注册的模块实例
    public func registerModule(_ module: any ModuleProtocol) async {
        await moduleManager.registerModule(module)
    }
    
    /// 卸载模块
    /// - Parameter moduleName: 模块名称
    /// - Returns: 被卸载的模块实例
    func unregisterModule(_ moduleName: String) async -> (any ModuleProtocol)? {
        return await moduleManager.unregisterModule(moduleName)
    }
    
    /// 检查模块是否已加载
    /// - Parameter moduleName: 模块名称
    /// - Returns: 模块是否已加载
    func isModuleLoaded(_ moduleName: String) async -> Bool {
        return await moduleManager.isModuleLoaded(moduleName)
    }
    
    /// 获取模块实例
    /// - Parameter name: 模块名称
    /// - Returns: 模块实例
    func getModule(_ name: String) async -> (any ModuleProtocol)? {
        return await moduleManager.getModule(name)
    }
    
    /// 获取指定类型的模块实例
    /// - Parameter type: 模块类型
    /// - Returns: 模块实例
    func getModule<T: ModuleProtocol>(_ type: T.Type) async -> T? {
        return await moduleManager.getModule(type)
    }
    
    /// 获取所有模块
    func getModules() async -> [String: Weak<AnyObject>] {
        return await moduleManager.getModules()
    }
    
    /// 获取关键模块列表
    func getCriticalModules() async -> Set<String> {
        return await moduleManager.getCriticalModules()
    }
    
    /// 通知模块状态变化
    /// - Parameters:
    ///   - module: 模块实例
    ///   - state: 新状态
    func notifyModuleStateChanged(_ module: ModuleProtocol, _ state: ModuleState) async {
        // 这里可以添加状态变化的通知逻辑
        print("RouterState: 模块 \(module.moduleName) 状态变化为 \(state)")
    }
    
    // MARK: - 路由管理代理方法
    
    /// 注册路由模式
    func registerRoute(_ routePattern: RoutePattern, routableType: Routable.Type, permission: RoutePermission?, priority: Int, scheme: String) async throws {
        try await routeManager.registerRoute(routePattern, routableType: routableType, permission: permission, priority: priority, scheme: scheme)
    }
    
    /// 注册动态路由
    func registerDynamicRoute(_ routePattern: RoutePattern, routableType: Routable.Type, permission: RoutePermission?, priority: Int, scheme: String) async throws {
        try await routeManager.registerDynamicRoute(routePattern, routableType: routableType, permission: permission, priority: priority, scheme: scheme)
    }
    
    /// 卸载动态路由
    func unregisterDynamicRoute(_ routePattern: RoutePattern) async throws {
        try await routeManager.unregisterDynamicRoute(routePattern)
    }
    
    /// 清理指定命名空间的所有路由
    func cleanupRoutes(forScheme scheme: String) async {
        await routeManager.cleanupRoutes(forScheme: scheme)
    }
    
    /// 获取指定模块的所有路由
    func getRoutesByModule(_ moduleName: String) async -> [RoutePattern] {
        return await routeManager.getRoutesByModule(moduleName)
    }
    
    /// 获取指定路由模式对应的可路由类型
    func getRoutableType(for pattern: RoutePattern) async -> Routable.Type? {
        return await routeManager.getRoutableType(for: pattern)
    }
    
    /// 获取所有已注册的路由
    public func getAllRoutes() async -> [RoutePattern: Routable.Type] {
        return await routeManager.getAllRoutes()
    }
    
    /// 匹配路由
    func matchRoute(_ url: URL) async -> (pattern: RoutePattern, type: Routable.Type, parameters: RouterParameters)? {
        let enableParameterSanitization = await configurationManager.getEnableParameterSanitization()
        return await cacheManager.matchRoute(url, enableParameterSanitization: enableParameterSanitization, routeManager: routeManager)
    }
    
    /// 获取路由权限
    func getRoutePermission(for routePattern: RoutePattern) async -> RoutePermission? {
        return await routeManager.getRoutePermission(for: routePattern)
    }
    
    /// 注册路由匹配器
    func registerMatcher(_ matcher: RouteMatcher, for patternPrefix: String) async {
        await routeManager.registerMatcher(matcher, for: patternPrefix)
    }
    
    /// 查找适用的路由匹配器
    func findMatcher(for pattern: String) async -> RouteMatcher {
        return await routeManager.findMatcher(for: pattern)
    }
    
    // MARK: - 拦截器管理代理方法
    
    /// 添加路由拦截器
    func addInterceptor(_ interceptor: RouterInterceptor) async {
        await interceptorManager.addInterceptor(interceptor)
    }
    
    /// 移除路由拦截器
    func removeInterceptor(_ interceptor: RouterInterceptor) async {
        await interceptorManager.removeInterceptor(interceptor)
    }
    
    /// 获取所有拦截器
    func getInterceptors() async -> [RouterInterceptor] {
        return await interceptorManager.getInterceptors()
    }
    
    #if canImport(UIKit)
    /// 注册导航动画
    func registerAnimation(_ animation: NavigationAnimatable) async {
        await interceptorManager.registerAnimation(animation)
    }
    
    /// 卸载导航动画
    func unregisterAnimation(_ identifier: String) async {
        await interceptorManager.unregisterAnimation(identifier)
    }
    
    /// 获取指定的导航动画
    func getAnimation(_ identifier: String) async -> NavigationAnimatable? {
        return await interceptorManager.getAnimation(identifier)
    }
    
    /// 设置当前动画
    func setCurrentAnimation(_ animation: NavigationAnimatable?) async {
        await interceptorManager.setCurrentAnimation(animation)
    }
    #endif
    
    #if canImport(UIKit)
    /// 获取当前动画
    func getCurrentAnimation() async -> NavigationAnimatable? {
        return await interceptorManager.getCurrentAnimation()
    }
    #endif
    
    // MARK: - 缓存管理代理方法
    
    /// 清理路由缓存
    func cleanupRouteCache() async {
        await cacheManager.cleanupRouteCache()
    }
    
    /// 获取缓存统计信息
    func getCacheStatistics() async -> RouterCacheStatistics {
        return await cacheManager.getCacheStatistics()
    }
    
    /// 重置缓存统计信息
    func resetCacheStatistics() async {
        await cacheManager.resetCacheStatistics()
    }
    
    /// 清空所有缓存
    func clearRouteCache() async {
        await cacheManager.clearRouteCache()
    }
    
    /// 设置路由缓存最大大小
    func setRouteCacheMaxSize(_ size: Int) async {
        await cacheManager.setRouteCacheMaxSize(size)
    }
    
    /// 设置热点缓存大小
    func setHotCacheSize(_ size: Int) async {
        await cacheManager.setHotCacheSize(size)
    }
    
    /// 设置热点阈值
    func setHotThreshold(_ threshold: Int) async {
        await cacheManager.setHotThreshold(threshold)
    }
    
    /// 设置缓存过期时间
    func setCacheExpirationTime(_ time: TimeInterval) async {
        await cacheManager.setCacheExpirationTime(time)
    }
    
    // MARK: - 配置管理代理方法
    
    /// 获取最大重试次数
    func getMaxRetryCount() async -> Int {
        return await configurationManager.getMaxRetryCount()
    }
    
    /// 设置最大重试次数
    func setMaxRetryCount(_ value: Int) async {
        await configurationManager.setMaxRetryCount(value)
    }
    
    /// 获取重试延迟时间
    func getRetryDelay() async -> TimeInterval {
        return await configurationManager.getRetryDelay()
    }
    
    /// 设置重试延迟时间
    func setRetryDelay(_ value: TimeInterval) async {
        await configurationManager.setRetryDelay(value)
    }
    
    /// 获取模块过期时间
    func getModuleExpirationTime() async -> TimeInterval {
        return await configurationManager.getModuleExpirationTime()
    }
    
    /// 设置模块过期时间
    func setModuleExpirationTime(_ value: TimeInterval) async {
        await configurationManager.setModuleExpirationTime(value)
        await moduleManager.setModuleExpirationTime(value)
    }
    
    /// 获取日志启用状态
    func getEnableLogging() async -> Bool {
        return await configurationManager.getEnableLogging()
    }
    
    /// 设置日志启用状态
    func setEnableLogging(_ value: Bool) async {
        await configurationManager.setEnableLogging(value)
    }
    
    /// 获取清理间隔时间
    func getCleanupInterval() async -> TimeInterval {
        return await configurationManager.getCleanupInterval()
    }
    
    /// 设置清理间隔时间
    func setCleanupInterval(_ value: TimeInterval) async {
        await configurationManager.setCleanupInterval(value)
    }
    
    /// 获取路由缓存大小
    func getCacheSize() async -> Int {
        return await configurationManager.getCacheSize()
    }
    
    /// 设置路由缓存大小
    func setCacheSize(_ value: Int) async {
        await configurationManager.setCacheSize(value)
    }
    
    /// 获取参数清理启用状态
    func getEnableParameterSanitization() async -> Bool {
        return await configurationManager.getEnableParameterSanitization()
    }
    
    /// 设置参数清理启用状态
    func setEnableParameterSanitization(_ value: Bool) async {
        await configurationManager.setEnableParameterSanitization(value)
    }
    
    /// 设置权限验证器
    func setPermissionValidator(_ validator: RoutePermissionValidator) async {
        await configurationManager.setPermissionValidator(validator)
    }
    
    /// 获取当前权限验证器
    func getPermissionValidator() async -> RoutePermissionValidator {
        return await configurationManager.getPermissionValidator()
    }
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// 获取当前导航任务
    @available(iOS 13.0, macOS 10.15, *)
    func getCurrentNavigationTask() async -> Task<Void, Error>? {
        return await configurationManager.getCurrentNavigationTask()
    }
    
    /// 设置当前导航任务
    @available(iOS 13.0, macOS 10.15, *)
    func setCurrentNavigationTask(_ task: Task<Void, Error>?) async {
        await configurationManager.setCurrentNavigationTask(task)
    }
    #endif
    
    // MARK: - 模块清理辅助
    
    /// 获取所有过期模块的名称
    func getExpiredModules(currentTime: Date) async -> [String] {
        return await moduleManager.getExpiredModules(currentTime: currentTime)
    }
    
    /// 清理指定模块的所有关联路由
    func cleanupRoutes(for moduleName: String) async {
        await routeManager.cleanupRoutes(for: moduleName)
        await cacheManager.clearCacheForModule(moduleName)
    }
    
    // MARK: - 状态重置
    
    /// 重置所有状态数据
    func reset() async {
        await moduleManager.reset()
        await routeManager.reset()
        await interceptorManager.reset()
        await configurationManager.reset()
        await cacheManager.reset()
    }
}