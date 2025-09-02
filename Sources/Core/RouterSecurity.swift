//  RouterSecurity.swift
//  RouterKit
//
//  Created by fengming on 2025/8/4.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 参数验证和清理
/// 路由安全工具类，负责参数验证、清理和权限控制
public class RouterSecurity {
    // 单例实例
    public static let shared = RouterSecurity()
    private init() {}

    /// 验证并清理路由参数
    /// - Parameter parameters: 原始参数
    /// - Returns: 清理后的参数
    public func sanitizeParameters(_ parameters: RouterParameters?) -> RouterParameters? {
        guard var params = parameters else { return nil }

        // 清理字符串参数，防止XSS攻击
        for (key, value) in params {
            if let strValue = value as? String {
                params[key] = sanitizeString(strValue)
            }
        }

        return params
    }

    /// 清理字符串，移除潜在危险字符
    /// - Parameter string: 原始字符串
    /// - Returns: 清理后的字符串
    private func sanitizeString(_ string: String) -> String {
        // 移除HTML标签
        var sanitized = string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        // 转义特殊字符
        sanitized = sanitized
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")

        // 移除JavaScript代码
        sanitized = sanitized.replacingOccurrences(of: "javascript:[^'\"]*", with: "", options: .regularExpression)

        return sanitized
    }

    /// 验证路由参数是否符合要求
    /// - Parameters:
    ///   - parameters: 要验证的参数
    ///   - rules: 验证规则
    /// - Returns: 验证是否通过以及错误信息
    public func validateParameters(_ parameters: RouterParameters?, against rules: [String: ParameterRule]) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        guard let params = parameters else { return (true, errors) }

        for (key, rule) in rules {
            if let value = params[key] {
                // 类型验证
                if !rule.isValidType(value) {
                    errors.append("参数 '\(key)' 类型错误，期望 \(rule.type)，实际 \(type(of: value))")
                    continue
                }

                // 范围验证
                if let rangeRule = rule as? RangeParameterRule {
                    if !rangeRule.isInRange(value) {
                        errors.append("参数 '\(key)' 超出范围，\(rangeRule.rangeDescription)")
                    }
                }

                // 格式验证
                if let formatRule = rule as? FormatParameterRule {
                    if !formatRule.isValidFormat(value) {
                        errors.append("参数 '\(key)' 格式错误，\(formatRule.formatDescription)")
                    }
                }
            } else if rule.isRequired {
                errors.append("缺少必填参数 '\(key)'")
            }
        }

        return (errors.isEmpty, errors)
    }
}

// MARK: - 参数验证规则
/// 参数验证规则协议
public protocol ParameterRule {
    var type: Any.Type { get }
    var isRequired: Bool { get }
    /// 验证值是否符合规则定义的类型
    func isValidType(_ value: Any) -> Bool
}

/// 基础参数规则
public struct BasicParameterRule: ParameterRule {
    public let type: Any.Type
    public let isRequired: Bool
    private let typeChecker: (Any) -> Bool

    // 使用泛型初始化方法，创建类型检查闭包
    public init<T>(type: T.Type, isRequired: Bool = true) {
        self.type = type
        self.isRequired = isRequired
        // 存储一个类型检查闭包，用于验证值是否为指定类型
        self.typeChecker = { value in
            value is T
        }
    }

    public func isValidType(_ value: Any) -> Bool {
        // 使用闭包进行类型检查，避免直接比较Any.Type
        return typeChecker(value)
    }
}

/// 范围参数规则
public struct RangeParameterRule: ParameterRule {
    public let type: Any.Type
    public let isRequired: Bool
    private let minValue: Any?
    private let maxValue: Any?
    public let rangeDescription: String
    private let typeChecker: (Any) -> Bool
    // 存储比较闭包，处理具体类型的比较逻辑
    private let rangeChecker: (Any) -> Bool

    public init<T: Comparable>(type: T.Type, min: T? = nil, max: T? = nil, isRequired: Bool = true) {
        self.type = type
        self.isRequired = isRequired
        self.minValue = min
        self.maxValue = max
        self.typeChecker = { value in
            value is T
        }

        // 预定义范围检查逻辑，捕获泛型类型信息
        self.rangeChecker = { value in
            guard let value = value as? T else { return false }

            if let min = min, value < min {
                return false
            }

            if let max = max, value > max {
                return false
            }

            return true
        }

        var description = ""
        if let min = min, let max = max {
            description = "必须在 \(min) 到 \(max) 之间"
        } else if let min = min {
            description = "必须大于等于 \(min)"
        } else if let max = max {
            description = "必须小于等于 \(max)"
        }
        self.rangeDescription = description
    }

    public func isValidType(_ value: Any) -> Bool {
        return typeChecker(value)
    }

    /// 检查值是否在范围内
    public func isInRange(_ value: Any) -> Bool {
        // 使用初始化时创建的闭包进行范围检查
        // 闭包中已经捕获了具体的泛型类型信息，避免使用some关键字
        return rangeChecker(value)
    }
}

/// 格式参数规则
public struct FormatParameterRule: ParameterRule {
    public let type: Any.Type
    public let isRequired: Bool
    private let regex: String
    public let formatDescription: String

    public init(type: String.Type, regex: String, formatDescription: String, isRequired: Bool = true) {
        self.type = type
        self.isRequired = isRequired
        self.regex = regex
        self.formatDescription = formatDescription
    }

    public func isValidType(_ value: Any) -> Bool {
        return value is String
    }

    /// 检查值是否符合格式要求
    public func isValidFormat(_ value: Any) -> Bool {
        guard let stringValue = value as? String else { return false }
        return stringValue.range(of: regex, options: .regularExpression) != nil
    }
}

// MARK: - 权限控制
/// 路由权限级别
public enum RoutePermissionLevel: Int {
    case publicAccess = 0     // 公开访问
    case authenticated = 1    // 需要认证
    case admin = 2            // 管理员权限
    case custom = 3           // 自定义权限
}

/// 路由权限协议
public protocol RoutePermission {
    var permissionLevel: RoutePermissionLevel { get }
    var customPermission: String? { get }
}

/// 基础路由权限实现
public struct BasicRoutePermission: RoutePermission {
    public let permissionLevel: RoutePermissionLevel
    public let customPermission: String?

    public init(permissionLevel: RoutePermissionLevel, customPermission: String? = nil) {
        // 当权限级别为custom时，确保customPermission不为空
        if case .custom = permissionLevel {
            self.customPermission = customPermission ?? ""
        } else {
            self.customPermission = nil
        }
        self.permissionLevel = permissionLevel
    }
}

// MARK: - 权限验证器
/// 路由权限验证器协议
public protocol RoutePermissionValidator {
    /// 验证是否有权限访问路由
    /// - Parameter permission: 路由权限
    /// - Returns: 是否有权限
    func hasPermission(for permission: RoutePermission) -> Bool
}

/// 默认权限验证器
public class DefaultPermissionValidator: RoutePermissionValidator {
    public init() {}

    public func hasPermission(for permission: RoutePermission) -> Bool {
        switch permission.permissionLevel {
        case .publicAccess:
            return true
        case .authenticated:
            // 这里实现实际的认证检查逻辑
            return isUserAuthenticated()
        case .admin:
            // 这里实现管理员权限检查逻辑
            return isUserAuthenticated() && isUserAdmin()
        case .custom:
            // 这里实现自定义权限检查逻辑
            guard let customPermission = permission.customPermission, !customPermission.isEmpty else { return false }
            return hasCustomPermission(customPermission)
        }
    }

    // 模拟用户认证状态检查
    private func isUserAuthenticated() -> Bool {
        // 实际应用中，这里应该检查用户的登录状态
        return true
    }

    // 模拟管理员权限检查
    private func isUserAdmin() -> Bool {
        // 实际应用中，这里应该检查用户是否有管理员权限
        return false
    }

    // 模拟自定义权限检查
    private func hasCustomPermission(_ permission: String) -> Bool {
        // 实际应用中，这里应该检查用户是否有特定的自定义权限
        return false
    }
}
