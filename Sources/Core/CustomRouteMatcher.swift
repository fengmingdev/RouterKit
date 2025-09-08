//
//  CustomRouteMatcher.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

/// 路由匹配器协议，定义匹配规则
public protocol RouteMatcher {
    /// 检查路径是否与模式匹配
    /// - Parameters:
    ///   - path: 实际路径
    ///   - pattern: 路由模式
    /// - Returns: (是否匹配, 提取的参数)
    func match(path: String, pattern: String) -> (Bool, RouterParameters)
}

/// 默认路由匹配器（原有的匹配逻辑）
class DefaultRouteMatcher: RouteMatcher {
    func match(path: String, pattern: String) -> (Bool, RouterParameters) {
        do {
            let routePattern = try RoutePattern(pattern)
            let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }

            var params: RouterParameters = [:]
            var isMatch = true

            var pIndex = 0
            var pathIndex = 0

            // 匹配逻辑
            while pIndex < routePattern.components.count && pathIndex < pathComponents.count {
                let pComponent = routePattern.components[pIndex]
                let pathComponent = pathComponents[pathIndex]

                switch pComponent {
                case .literal(let value):
                    if value != pathComponent {
                        isMatch = false
                        // 跳出整个循环
                        pIndex = routePattern.components.count
                        pathIndex = pathComponents.count
                        break
                    }
                    pIndex += 1
                    pathIndex += 1

                case .parameter(let name, let isOptional):
                    params[name] = pathComponent
                    pIndex += 1
                    pathIndex += 1

                    if isOptional && pathIndex >= pathComponents.count {
                        pIndex += 1
                    }

                case .wildcard:
                    params["*"] = Array(pathComponents[pathIndex...])
                    pIndex += 1
                    pathIndex = pathComponents.count

                case .regex(let regex, let paramNames):
                    let range = NSRange(location: 0, length: pathComponent.utf16.count)
                    guard regex.firstMatch(in: pathComponent, options: [], range: range) != nil else {
                        isMatch = false
                        break
                    }

                    if let match = regex.matches(in: pathComponent, options: [], range: range).first {
                        for (index, name) in paramNames.enumerated() {
                            let groupRange = match.range(at: index + 1)
                            if groupRange.location != NSNotFound,
                               let range = Range(groupRange, in: pathComponent) {
                                params[name] = String(pathComponent[range])
                            }
                        }
                    }

                    pIndex += 1
                    pathIndex += 1
                }
            }

            while pIndex < routePattern.components.count {
                let component = routePattern.components[pIndex]
                if case .parameter(_, true) = component {
                    pIndex += 1
                } else if case .wildcard = component {
                    params["*"] = []
                    pIndex += 1
                } else {
                    isMatch = false
                    break
                }
            }

            if pathIndex < pathComponents.count && pIndex >= routePattern.components.count {
                isMatch = false
            }

            return (isMatch, params)
        } catch {
            return (false, [:])
        }
    }
}

/// JSONPath风格路由匹配器（示例）
class JSONPathRouteMatcher: RouteMatcher {
    func match(path: String, pattern: String) -> (Bool, RouterParameters) {
        // 实现JSONPath风格的路由匹配
        // 例如: /UserModule/profile[id=123,name=张三]
        let params: RouterParameters = [:]
        // 实际项目中实现具体匹配逻辑...
        return (true, params)
    }
}
