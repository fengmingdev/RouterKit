//
//  Router+RouteMatching.swift
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

#if canImport(UIKit) || canImport(AppKit)

// MARK: - 路由匹配和解析扩展

@MainActor
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    /// 创建视图控制器
    /// - Parameters:
    ///   - url: 目标URL
    ///   - parameters: 路由参数
    /// - Returns: 创建的视图控制器
    internal func createViewController(for url: URL, parameters: RouterParameters) async throws -> PlatformViewController {
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
        guard let url = URL(string: "http://localhost" + path) else {
            log("Invalid URL path: \(path)", level: .error)
            return nil
        }
        
        if let cachedResult = await state.matchRoute(url) {
            return (cachedResult.type, cachedResult.parameters, cachedResult.pattern.moduleName)
        }

        // 获取所有路由进行匹配
        let allRoutes = await state.getAllRoutes()

        for (pattern, routableType) in allRoutes {
            let url = URL(string: "http://localhost" + path) ?? URL(string: "http://localhost/")!
            let matchResult = pattern.match(url)
            if matchResult.isExactMatch {
                let parameters = matchResult.parameters.compactMapValues { $0 as? String } ?? [:]
                let result = (routableType, parameters, pattern.moduleName)

                return result
            }
        }

        return nil
    }

    /// 加载模块并获取路由模式
    /// - Parameter moduleName: 模块名称
    /// - Returns: 路由模式数组
    internal func loadModuleAndGetPatterns(_ moduleName: String) async throws -> [RoutePattern] {
        // 从已注册的路由中获取该模块的路由模式
        let moduleRoutes = await state.getRoutesByModule(moduleName)
        return moduleRoutes
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
