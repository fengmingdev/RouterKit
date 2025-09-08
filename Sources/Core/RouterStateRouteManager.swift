//
//  RouterStateRouteManager.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation

/// 路由条目结构
struct RouteEntry {
    let routableType: Routable.Type
    let priority: Int
    let scheme: String
}

/// 路由管理器
@available(iOS 13.0, macOS 10.15, *)
actor RouterStateRouteManager {
    /// 存储已注册的路由
    private var routes: [RoutePattern: RouteEntry] = [:]
    
    /// 存储模块的路由
    private var routesByModule: [String: [RoutePattern]] = [:]
    
    /// 路由权限
    private var routePermissions: [RoutePattern: RoutePermission] = [:]
    
    /// 自定义路由匹配器
    private var customMatchers: [String: RouteMatcher] = [:]
    
    /// 路由Trie树
    private let routeTrie = RouteTrie()

    // MARK: - 路由注册方法

    /// 注册路由模式
    /// - Parameters:
    ///   - routePattern: 路由模式
    ///   - routableType: 可路由类型
    ///   - permission: 路由权限
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
        await routeTrie.insert(routePattern, priority: priority)
        
        if let permission = permission {
            routePermissions[routePattern] = permission
        }
        
        print("RouterStateRouteManager: 路由注册成功 - \(routePattern.pattern) -> \(routableType)")
    }

    /// 注册动态路由
    /// - Parameters:
    ///   - routePattern: 路由模式
    ///   - routableType: 可路由类型
    ///   - permission: 路由权限
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
        await routeTrie.insert(routePattern, priority: priority)
        
        if let permission = permission {
            routePermissions[routePattern] = permission
        }
        
        print("RouterStateRouteManager: 动态路由注册成功 - \(routePattern.pattern) -> \(routableType)")
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
        if let index = routesByModule[routePattern.moduleName]?.firstIndex(of: routePattern) {
            routesByModule[routePattern.moduleName]?.remove(at: index)
        }
        
        print("RouterStateRouteManager: 动态路由移除成功 - \(routePattern.pattern)")
    }

    /// 清理指定命名空间的所有路由
    func cleanupRoutes(forScheme scheme: String) async {
        let patternsToRemove = routes.compactMap { pattern, entry in
            entry.scheme == scheme ? pattern : nil
        }
        
        for pattern in patternsToRemove {
            routes.removeValue(forKey: pattern)
            await routeTrie.remove(pattern)
            routePermissions.removeValue(forKey: pattern)
        }
        
        print("RouterStateRouteManager: 清理命名空间路由 - \(scheme), 移除数量: \(patternsToRemove.count)")
    }

    /// 获取指定模块的所有路由
    func getRoutesByModule(_ moduleName: String) async -> [RoutePattern] {
        let moduleRoutes = routesByModule[moduleName] ?? []
        print("RouterStateRouteManager: 获取模块 \(moduleName) 的路由数量: \(moduleRoutes.count)")
        return moduleRoutes
    }

    /// 获取指定路由模式对应的可路由类型
    func getRoutableType(for pattern: RoutePattern) async -> Routable.Type? {
        let routableType = routes[pattern]?.routableType
        print("RouterStateRouteManager: 获取路由 \(pattern.pattern) 的类型: \(routableType != nil ? String(describing: routableType) : "nil")")
        return routableType
    }

    /// 获取所有已注册的路由
    public func getAllRoutes() async -> [RoutePattern: Routable.Type] {
        let allRoutes = routes.mapValues { $0.routableType }
        print("RouterStateRouteManager: 获取所有路由数量: \(allRoutes.count)")
        return allRoutes
    }

    /// 匹配路由
    func matchRoute(_ url: URL) async -> (pattern: RoutePattern, type: Routable.Type, parameters: RouterParameters)? {
        print("RouterStateRouteManager: 开始匹配路由 - \(url.absoluteString)")
        
        let pathComponents = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        print("RouterStateRouteManager: 路径组件 - \(pathComponents)")
        
        guard let result = await routeTrie.find(pathComponents) else {
            print("RouterStateRouteManager: 未找到匹配的路由")
            return nil
        }
        
        // 获取路由对应的类型
        guard let routeEntry = routes[result.pattern] else {
            print("RouterStateRouteManager: 未找到路由对应的类型 - \(result.pattern.pattern)")
            return nil
        }
        
        print("RouterStateRouteManager: 找到匹配的路由 - \(result.pattern.pattern)")
        return (result.pattern, routeEntry.routableType, result.parameters)
    }

    /// 获取路由权限
    func getRoutePermission(for routePattern: RoutePattern) async -> RoutePermission? {
        return routePermissions[routePattern]
    }

    /// 注册路由匹配器
    func registerMatcher(_ matcher: RouteMatcher, for patternPrefix: String) async {
        customMatchers[patternPrefix] = matcher
        print("RouterStateRouteManager: 注册匹配器 - \(patternPrefix)")
    }

    /// 查找适用的路由匹配器
    func findMatcher(for pattern: String) async -> RouteMatcher {
        for (prefix, matcher) in customMatchers {
            if pattern.hasPrefix(prefix) {
                print("RouterStateRouteManager: 找到匹配器 - \(prefix) for \(pattern)")
                return matcher
            }
        }
        
        // 返回默认匹配器
        print("RouterStateRouteManager: 使用默认匹配器 for \(pattern)")
        return DefaultRouteMatcher()
    }

    // MARK: - 清理方法

    /// 清理指定模块的所有路由
    func cleanupRoutes(for moduleName: String) async {
        guard let patterns = routesByModule[moduleName] else { return }
        
        for pattern in patterns {
            routes.removeValue(forKey: pattern)
            await routeTrie.remove(pattern)
            routePermissions.removeValue(forKey: pattern)
        }
        
        routesByModule.removeValue(forKey: moduleName)
        print("RouterStateRouteManager: 清理模块 \(moduleName) 的路由，数量: \(patterns.count)")
    }

    // MARK: - 状态重置

    /// 重置路由管理器状态
    func reset() async {
        routes.removeAll()
        routesByModule.removeAll()
        routePermissions.removeAll()
        customMatchers.removeAll()
        print("RouterStateRouteManager: 路由管理器状态已重置")
    }
}

// MARK: - 默认路由匹配器
class DefaultRouteMatcher: RouteMatcher {
    func match(path: String, pattern: String) -> (Bool, RouterParameters) {
        // 简单的字符串匹配实现
        let isMatch = path == pattern
        return (isMatch, [:])
    }
}