//
//  Router+RouteMatching.swift
//  RouterKit
//
//  Created by fengming on 2025/8/4.
//

import Foundation
#if canImport(UIKit)
import UIKit

// MARK: - 路由匹配和解析扩展

@MainActor
extension Router {
    /// 创建视图控制器
    /// - Parameters:
    ///   - url: 目标URL
    ///   - parameters: 路由参数
    /// - Returns: 创建的视图控制器
    internal func createViewController(for url: URL, parameters: RouterParameters) async throws -> UIViewController {
        let (path, urlParameters) = parseURL(url)
        let mergedParameters = parameters.merging(urlParameters) { (_, new) in new }
        
        guard let (routeType, routeParameters, moduleName) = await findMatchingRoute(for: path) else {
            throw RouterError.routeNotFound(path)
        }
        
        let finalParameters = mergedParameters.merging(routeParameters) { (_, new) in new }
        let context = RouteContext(url: url.absoluteString, parameters: finalParameters, moduleName: moduleName)
        
        return try await routeType.createViewController(context: context)
    }
    
    /// 解析URL
    /// - Parameter url: 要解析的URL
    /// - Returns: 路径和参数的元组
    internal func parseURL(_ url: URL) -> (path: String, parameters: RouterParameters) {
        var parameters: RouterParameters = [:]
        
        // 解析查询参数
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                parameters[item.name] = item.value ?? ""
            }
        }
        
        // 解析fragment参数
        if let fragment = url.fragment {
            let fragmentComponents = fragment.components(separatedBy: "&")
            for component in fragmentComponents {
                let keyValue = component.components(separatedBy: "=")
                if keyValue.count == 2 {
                    parameters[keyValue[0]] = keyValue[1]
                }
            }
        }
        
        return (url.path, parameters)
    }
    
    /// 查找匹配的路由
    /// - Parameter path: 路径
    /// - Returns: 路由类型、参数和模块名的元组
    internal func findMatchingRoute(for path: String) async -> (Routable.Type, RouterParameters, String)? {
        // 首先检查缓存
        if let cached = routeCache.getCachedRoute(for: path) {
            return cached
        }
        
        // 遍历所有已注册的模块
        for (moduleName, moduleType) in modules {
            do {
                let patterns = try await loadModuleAndGetPatterns(moduleName)
                let sortedPatterns = sortPatternsByPriority(patterns)
                
                for pattern in sortedPatterns {
                    if let (routeType, parameters) = await routeTrie.match(path: path, pattern: pattern.pattern) {
                        let result = (routeType, parameters, moduleName)
                        
                        // 缓存结果
                        routeCache.cacheRoute(path: path, result: result)
                        
                        return result
                    }
                }
            } catch {
                logger.log("Failed to load patterns for module \(moduleName): \(error)", level: .error)
                continue
            }
        }
        
        return nil
    }
    
    /// 加载模块并获取路由模式
    /// - Parameter moduleName: 模块名称
    /// - Returns: 路由模式数组
    internal func loadModuleAndGetPatterns(_ moduleName: String) async throws -> [RoutePattern] {
        guard let moduleType = modules[moduleName] else {
            throw RouterError.moduleNotFound(moduleName)
        }
        
        do {
            let module = try await moduleType.createModule()
            return module.routes
        } catch {
            // 记录错误但不中断整个匹配过程
            logger.log("Failed to create module \(moduleName): \(error)", level: .error)
            
            // 如果是关键模块，重新抛出错误
            if criticalModules.contains(moduleName) {
                throw error
            }
            
            // 对于非关键模块，返回空数组
            return []
        }
    }
    
    /// 按优先级排序路由模式
    /// - Parameter patterns: 原始路由模式数组
    /// - Returns: 排序后的路由模式数组
    internal func sortPatternsByPriority(_ patterns: [RoutePattern]) -> [RoutePattern] {
        return patterns.sorted { pattern1, pattern2 in
            let priority1 = calculatePatternPriority(pattern1.pattern)
            let priority2 = calculatePatternPriority(pattern2.pattern)
            
            // 优先级高的排在前面
            if priority1 != priority2 {
                return priority1 > priority2
            }
            
            // 优先级相同时，按路径段数量排序（更具体的排在前面）
            let segments1 = pattern1.pattern.components(separatedBy: "/").filter { !$0.isEmpty }
            let segments2 = pattern2.pattern.components(separatedBy: "/").filter { !$0.isEmpty }
            
            return segments1.count > segments2.count
        }
    }
    
    /// 计算路由模式的优先级
    /// - Parameter pattern: 路由模式
    /// - Returns: 优先级分数（越高越优先）
    private func calculatePatternPriority(_ pattern: String) -> Int {
        let segments = pattern.components(separatedBy: "/").filter { !$0.isEmpty }
        var priority = 0
        
        for segment in segments {
            if segment.hasPrefix(":") {
                // 参数段，优先级较低
                priority += 1
            } else if segment == "*" || segment == "**" {
                // 通配符段，优先级最低
                priority += 0
            } else {
                // 静态段，优先级最高
                priority += 10
            }
        }
        
        return priority
    }
}

#endif