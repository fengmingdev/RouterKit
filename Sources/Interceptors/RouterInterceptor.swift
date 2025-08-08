//
//  RouterInterceptor.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

// MARK: - 拦截器优先级
/// 定义拦截器的优先级级别
public enum InterceptorPriority: Int, Comparable {
    case lowest = 0
    case low = 25
    case normal = 50
    case high = 75
    case highest = 100

    public static func < (lhs: InterceptorPriority, rhs: InterceptorPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 拦截器完成回调
/// 拦截路由请求完成后的回调
/// - Parameters:
///   - allow: 是否允许路由
///   - redirectUrl: 重定向URL
///   - errorMsg: 错误消息
///   - newParams: 新的路由参数
///   - presentationStyle: 自定义弹出方式
public typealias InterceptorCompletion = (Bool, String?, String?, RouterParameters?, NavigationPresentationStyle?) -> Void

// MARK: - 导航弹出方式
/// 定义路由跳转时的弹出方式
public enum NavigationPresentationStyle {
    case push            // 默认push方式
    case present         // 模态展示
    case presentWithNavigation  // 模态展示带导航栏
    case replace         // 替换当前页面
    case custom(String)  // 自定义动画ID
}

// MARK: - 拦截器协议
/// 路由拦截器协议，用于在路由跳转前进行检查（如登录验证）
public protocol RouterInterceptor: AnyObject {
    var priority: InterceptorPriority { get set }  // 拦截器优先级
    var isAsync: Bool { get }                      // 是否异步执行
    /// 拦截路由请求
    /// - Parameters:
    ///   - url: 目标URL
    ///   - parameters: 路由参数
    ///   - completion: 拦截完成回调
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion)
}

// MARK: - 基础拦截器
/// 拦截器基类，提供默认实现
open class BaseInterceptor: RouterInterceptor {
    open var priority: InterceptorPriority = .normal  // 默认优先级
    open var isAsync: Bool = false                    // 默认同步执行
    
    public init(priority: InterceptorPriority = .normal, isAsync: Bool = false) {
        self.priority = priority
        self.isAsync = isAsync
    }
    
    /// 日志打印方法（供子类使用）
    open func log(_ message: String) {
        RouterLogger.shared.log(message, level: .info)
    }
    
    /// 默认实现：允许所有路由
    open func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        completion(true, nil, nil, nil, nil)
    }
}
