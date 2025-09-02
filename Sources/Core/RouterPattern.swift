//
//  RouterPattern.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

// MARK: - 路由模式
/// 路由模式结构，用于解析和匹配URL
public struct RoutePattern: Hashable {
    /// 路由模式的组件类型
    enum Component: Hashable {
        case literal(String)                  // 字面量匹配（如"profile"）
        case parameter(String, Bool)          // 参数匹配（名称，是否可选）
        case wildcard                         // 通配符匹配（*）
        case regex(NSRegularExpression, [String]) // 正则表达式匹配（含捕获组名称）
    }

    let pattern: String              // 原始模式字符串（如"/UserModule/profile/:id"）
    let components: [Component]      // 解析后的组件数组
    let moduleName: String           // 所属模块名（模式的第一个组件）
    private let cachedHashValue: Int // 缓存哈希值（优化性能）

    /// 初始化并解析路由模式
    /// - Parameter pattern: 原始模式字符串
    /// - Throws: 模式语法错误时抛出异常
    public init(_ pattern: String) throws {
        self.pattern = pattern
        self.cachedHashValue = pattern.hashValue

        let pathComponents = pattern.components(separatedBy: "/").filter { !$0.isEmpty }
        guard !pathComponents.isEmpty else {
            throw RouterError.patternSyntaxError("路由模式不能为空: \(pattern)")
        }

        // 第一个组件作为模块名
        self.moduleName = pathComponents[0]
        var components: [Component] = []

        for component in pathComponents {
            switch component {
            case "*":
                // 通配符匹配
                components.append(.wildcard)

            case let param where param.hasPrefix(":"):
                // 参数匹配（如:id 或 :name?）
                let paramName = String(param.dropFirst())
                let isOptional = paramName.hasSuffix("?")
                let cleanedName = isOptional ? String(paramName.dropLast()) : paramName
                components.append(.parameter(cleanedName, isOptional))

            case let regex where regex.hasPrefix("(") && regex.hasSuffix(")"):
                // 正则表达式匹配（如(\d{4})）
                let regexPattern = String(regex.dropFirst().dropLast())
                do {
                    let regex = try NSRegularExpression(pattern: regexPattern)
                    let paramNames = regexPattern.capturedGroups()  // 提取捕获组名称
                    components.append(.regex(regex, paramNames))
                } catch {
                    throw RouterError.patternSyntaxError("无效的正则表达式: \(regexPattern)")
                }

            default:
                // 字面量匹配
                components.append(.literal(component))
            }
        }

        self.components = components
    }

    // 哈希实现（使用缓存值优化）
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cachedHashValue)
    }

    // 相等性判断
    public static func == (lhs: RoutePattern, rhs: RoutePattern) -> Bool {
        return lhs.pattern == rhs.pattern
    }
}

// MARK: - 参数类型转换协议
/// 定义参数类型转换的协议
public protocol RouteParameterConvertible {
    /// 从字符串转换为当前类型
    /// - Parameter string: 原始字符串
    /// - Returns: 转换后的实例（可选）
    static func fromRouteString(_ string: String) -> Self?
}

// 基本类型的参数转换实现
extension String: RouteParameterConvertible {
    public static func fromRouteString(_ string: String) -> String? {
        return string
    }
}

extension Int: RouteParameterConvertible {
    public static func fromRouteString(_ string: String) -> Int? {
        return Int(string)
    }
}

extension Double: RouteParameterConvertible {
    public static func fromRouteString(_ string: String) -> Double? {
        return Double(string)
    }
}

extension Bool: RouteParameterConvertible {
    public static func fromRouteString(_ string: String) -> Bool? {
        if string.lowercased() == "true" || string == "1" {
            return true
        } else if string.lowercased() == "false" || string == "0" {
            return false
        }
        return nil
    }
}

extension UUID: RouteParameterConvertible {
    public static func fromRouteString(_ string: String) -> UUID? {
        return UUID(uuidString: string)
    }
}

// MARK: - 路由模式扩展
 extension RoutePattern {
    /// 匹配URL并提取参数
    /// - Parameter url: 要匹配的URL
    /// - Returns: 匹配结果（包含参数和是否完全匹配）
    func match(_ url: URL) -> (parameters: [String: Any], isExactMatch: Bool) {
        let pathComponents = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        guard !pathComponents.isEmpty else { return ([String: Any](), false) }

        // 检查模块名是否匹配
        if pathComponents[0] != moduleName {
            return ([String: Any](), false)
        }

        var parameters = [String: Any]()
        var isExactMatch = true
        var componentIndex = 0

        // 提取查询参数
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                parameters[item.name] = item.value
            }
        }
        
        // 提取fragment参数
        if let fragment = url.fragment {
            parameters["fragment"] = fragment
        }

        for component in components {
            // 跳过第一个组件（模块名）
            if componentIndex == 0 {
                componentIndex += 1
                continue
            }

            // 检查是否超出URL组件范围
            if componentIndex >= pathComponents.count {
                // 检查当前组件是否可选
                if case .parameter(_, true) = component {
                    // 可选参数缺失，继续匹配
                    componentIndex += 1
                    continue
                } else {
                    // 必需参数缺失，匹配失败
                    isExactMatch = false
                    break
                }
            }

            let urlComponent = pathComponents[componentIndex]
            switch component {
            case .literal(let literal):
                if literal != urlComponent {
                    isExactMatch = false
                    break
                }

            case .parameter(let name, _):
                parameters[name] = urlComponent

            case .wildcard:
                // 通配符匹配剩余所有组件
                let remainingComponents = pathComponents[componentIndex...]
                parameters["*"] = remainingComponents.joined(separator: "/")
                componentIndex = pathComponents.count // 跳转到末尾
                continue

            case .regex(let regex, let paramNames):
                let matches = regex.matches(in: urlComponent, range: NSRange(urlComponent.startIndex..., in: urlComponent))
                if let match = matches.first {
                    for (i, paramName) in paramNames.enumerated() {
                        let rangeIndex = i + 1
                        if rangeIndex < match.numberOfRanges {
                            let range = match.range(at: rangeIndex)
                            if let swiftRange = Range(range, in: urlComponent) {
                                parameters[paramName] = String(urlComponent[swiftRange])
                            }
                        }
                    }
                } else {
                    isExactMatch = false
                    break
                }
            }

            componentIndex += 1
        }

        // 检查是否有未匹配的URL组件
        if componentIndex < pathComponents.count {
            isExactMatch = false
        }

        return (parameters, isExactMatch)
    }
}

// MARK: - 字符串扩展（正则捕获组提取）
extension String {
    /// 提取正则表达式中的命名捕获组（如(?P<name>...)）
    /// - Returns: 捕获组名称数组
    func capturedGroups() -> [String] {
        let pattern = #"\(\?P<([a-zA-Z0-9_]+)>"#  // 匹配命名捕获组的正则
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: self, range: NSRange(startIndex..., in: self))
            return matches.compactMap { match in
                guard let range = Range(match.range(at: 1), in: self) else { return nil }
                return String(self[range])
            }
        } catch {
            return []
        }
    }
}
