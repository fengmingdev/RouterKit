//
//  RouteContext.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/23.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// 路由上下文
/// 包含导航过程中的所有相关信息
public struct RouteContext {
    /// 原始URL字符串
    public let url: String
    
    /// 路由参数（包括动态参数和查询参数）
    public var parameters: RouterParameters
    
    /// 模块名称
    public let moduleName: String
    
    /// 自定义用户信息
    public var userInfo: [AnyHashable: Any] = [:]
    
    /// 导航选项
    public var options: [String: Any] = [:]
    
    /// 初始化路由上下文
    /// - Parameters:
    ///   - url: URL字符串
    ///   - parameters: 路由参数
    ///   - moduleName: 模块名称
    public init(url: String, parameters: RouterParameters, moduleName: String) {
        self.url = url
        self.parameters = parameters
        self.moduleName = moduleName
    }
    
    /// 获取参数值
    /// - Parameter key: 参数键
    /// - Returns: 参数值
    public func value(forKey key: String) -> Any? {
        return parameters[key]
    }
    
    /// 设置参数值
    /// - Parameters:
    ///   - value: 参数值
    ///   - key: 参数键
    public mutating func setValue(_ value: Any?, forKey key: String) {
        parameters[key] = value
    }
}