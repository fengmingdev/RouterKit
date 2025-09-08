//
//  RouterStateRouteManager.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation

/// 路由状态路由管理器
/// 负责管理所有路由的注册、匹配和清理
@available(iOS 13.0, macOS 10.15, *)
actor RouterStateRouteManager {
    
    // MARK: - 存储容器
    
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
    
    /// 路由匹配器
    /// 键: 模式前缀，值: 对应的匹配器实例
    private var matchers: [String: RouteMatcher] = ["": DefaultRouteMatcher()]
    
    // MARK: - 路由注册
    
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
        routesByModule[routePattern.moduleName, default: []].append(routePattern)
        routesByScheme[scheme, default: []].append(routePattern)
        await routeTrie.insert(routePattern)
        
        if let permission = permission {
            routePermissions[routePattern] = permission
        }
    }
    
    /// 卸载动态路由
    /// - Parameter routePattern: 要卸载的路由模式
    /// - Throws: 当路由不存在时抛出错误
    func unregisterDynamicRoute(_ routePattern: RoutePattern) async throws {
        guard routes[routePattern] != nil else {
            throw RouterError.routeNotFound(routePattern.pattern)
        }
        
        routes.removeValue(forKey: routePattern)
        await routeTrie.remove(routePattern)
        routePermissions.removeValue(forKey: routePattern)
        
        // 从模块路由列表中移除
        if var moduleRoutes = routesByModule[routePattern.moduleName] {
            moduleRoutes.removeAll { $0 == routePattern }
            if moduleRoutes.isEmpty {
                routesByModule.removeValue(forKey: routePattern.moduleName)
            } else {
                routesByModule[routePattern.moduleName] = moduleRoutes
            }
        }
        
        // 从命名空间路由列表中移除
        if let routeEntry = routes[routePattern] {
            let scheme = routeEntry.scheme
            if var schemeRoutes = routesByScheme[scheme] {
                schemeRoutes.removeAll { $0 == routePattern }
                if schemeRoutes.isEmpty {
                    routesByScheme.removeValue(forKey: scheme)
                } else {
                    routesByScheme[scheme] = schemeRoutes
                }
            }
        }
    }
    
    // MARK: - 路由查询
    
    /// 获取指定模块的所有路由
    /// - Parameter moduleName: 模块名称
    /// - Returns: 路由模式数组
    func getRoutesByModule(_ moduleName: String) -> [RoutePattern] {
        return routesByModule[moduleName] ?? []
    }
    
    /// 获取指定路由模式对应的可路由类型
    /// - Parameter pattern: 路由模式
    /// - Returns: 可路由类型（可选）
    func getRoutableType(for pattern: RoutePattern) -> Routable.Type? {
        return routes[pattern]?.routableType
    }
    
    /// 获取所有已注册的路由
    /// - Returns: 路由模式到可路由类型的映射
    func getAllRoutes() -> [RoutePattern: Routable.Type] {
        return routes.mapValues { $0.routableType }
    }
    
    /// 匹配路由
    /// - Parameter url: 要匹配的URL
    /// - Returns: 匹配结果（路由模式、类型和参数）
    func matchRoute(_ url: URL) async -> (pattern: RoutePattern, type: Routable.Type, parameters: RouterParameters)? {
        // 将URL路径转换为组件数组
        let pathComponents = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        
        // 使用Trie树进行快速匹配
        if let (matchedPattern, parameters) = await routeTrie.find(pathComponents) {
            guard let routeEntry = routes[matchedPattern] else {
                return nil
            }
            
            return (matchedPattern, routeEntry.routableType, parameters)
        }
        
        return nil
    }
    
    // MARK: - 路由清理
    
    /// 清理指定命名空间的所有路由
    /// - Parameter scheme: 命名空间名称
    func cleanupRoutes(forScheme scheme: String) async {
        guard let schemeRoutes = routesByScheme[scheme] else {
            return
        }
        
        for routePattern in schemeRoutes {
            routes.removeValue(forKey: routePattern)
            await routeTrie.remove(routePattern)
            routePermissions.removeValue(forKey: routePattern)
            
            // 从模块路由列表中移除
            if var moduleRoutes = routesByModule[routePattern.moduleName] {
                moduleRoutes.removeAll { $0 == routePattern }
                if moduleRoutes.isEmpty {
                    routesByModule.removeValue(forKey: routePattern.moduleName)
                } else {
                    routesByModule[routePattern.moduleName] = moduleRoutes
                }
            }
        }
        
        routesByScheme.removeValue(forKey: scheme)
    }
    
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
    }
    
    // MARK: - 权限管理
    
    /// 获取指定路由的权限配置
    /// - Parameter routePattern: 路由模式
    /// - Returns: 权限配置（可选）
    func getRoutePermission(for routePattern: RoutePattern) -> RoutePermission? {
        return routePermissions[routePattern]
    }
    
    /// 设置路由权限
    /// - Parameters:
    ///   - permission: 权限配置
    ///   - routePattern: 路由模式
    func setRoutePermission(_ permission: RoutePermission, for routePattern: RoutePattern) {
        routePermissions[routePattern] = permission
    }
    
    // MARK: - 匹配器管理
    
    /// 注册路由匹配器
    /// - Parameters:
    ///   - matcher: 匹配器实例
    ///   - patternPrefix: 模式前缀
    func registerMatcher(_ matcher: RouteMatcher, for patternPrefix: String) {
        matchers[patternPrefix] = matcher
    }
    
    /// 查找适用的路由匹配器
    /// - Parameter pattern: 路由模式字符串
    /// - Returns: 匹配器实例
    func findMatcher(for pattern: String) -> RouteMatcher {
        for (prefix, matcher) in matchers {
            if pattern.hasPrefix(prefix) {
                return matcher
            }
        }
        return matchers[""]! // 默认匹配器
    }
    
    /// 获取所有匹配器
    /// - Returns: 匹配器字典
    func getMatchers() -> [String: RouteMatcher] {
        return matchers
    }
    
    // MARK: - 状态重置
    
    /// 重置所有路由数据
    func reset() async {
        routes.removeAll()
        routesByModule.removeAll()
        routesByScheme.removeAll()
        routeTrie = RouteTrie()
        routePermissions.removeAll()
        matchers = ["": DefaultRouteMatcher()]
    }
}