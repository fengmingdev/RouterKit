//
//  RouterStateInterceptorManager.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// 路由状态拦截器管理器
/// 负责管理所有路由拦截器和动画
@available(iOS 13.0, macOS 10.15, *)
actor RouterStateInterceptorManager {
    
    // MARK: - 存储容器
    
    /// 路由拦截器列表
    private var interceptors: [RouterInterceptor] = []
    
    #if canImport(UIKit)
    /// 导航动画配置
    /// 键: 动画标识符，值: 动画实例
    private var animations: [String: NavigationAnimatable] = [:]
    
    /// 当前动画实例
    var currentAnimation: NavigationAnimatable?
    #endif
    
    // MARK: - 拦截器管理
    
    /// 添加路由拦截器
    /// - Parameter interceptor: 拦截器实例
    func addInterceptor(_ interceptor: RouterInterceptor) {
        // 避免重复添加同一个拦截器
        if !interceptors.contains(where: { $0 === interceptor }) {
            interceptors.append(interceptor)
        }
    }
    
    /// 移除路由拦截器
    /// - Parameter interceptor: 要移除的拦截器实例
    func removeInterceptor(_ interceptor: RouterInterceptor) {
        interceptors.removeAll { $0 === interceptor }
    }
    
    /// 获取所有拦截器
    /// - Returns: 拦截器数组
    func getInterceptors() -> [RouterInterceptor] {
        return interceptors
    }
    
    /// 移除所有拦截器
    func removeAllInterceptors() {
        interceptors.removeAll()
    }
    
    /// 按优先级排序拦截器
    /// - Returns: 按优先级排序的拦截器数组
    func getSortedInterceptors() -> [RouterInterceptor] {
        return interceptors.sorted { lhs, rhs in
            // 假设拦截器有优先级属性，如果没有可以添加
            if let lhsPriority = lhs as? PriorityInterceptor,
               let rhsPriority = rhs as? PriorityInterceptor {
                return lhsPriority.priority > rhsPriority.priority
            }
            return false
        }
    }
    
    #if canImport(UIKit)
    // MARK: - 动画管理
    
    /// 注册导航动画
    /// - Parameter animation: 动画实例
    func registerAnimation(_ animation: NavigationAnimatable) {
        animations[animation.identifier] = animation
    }
    
    /// 卸载导航动画
    /// - Parameter identifier: 动画标识符
    func unregisterAnimation(_ identifier: String) {
        animations.removeValue(forKey: identifier)
    }
    
    /// 获取指定的导航动画
    /// - Parameter identifier: 动画标识符
    /// - Returns: 动画实例（可选）
    func getAnimation(_ identifier: String) -> NavigationAnimatable? {
        return animations[identifier]
    }
    
    /// 获取所有动画
    /// - Returns: 动画字典
    func getAllAnimations() -> [String: NavigationAnimatable] {
        return animations
    }
    
    /// 设置当前动画
    /// - Parameter animation: 动画实例
    func setCurrentAnimation(_ animation: NavigationAnimatable?) {
        currentAnimation = animation
    }
    
    /// 获取当前动画
    /// - Returns: 当前动画实例
    func getCurrentAnimation() -> NavigationAnimatable? {
        return currentAnimation
    }
    
    /// 清除当前动画
    func clearCurrentAnimation() {
        currentAnimation = nil
    }
    #endif
    
    // MARK: - 状态重置
    
    /// 重置所有拦截器和动画数据
    func reset() {
        interceptors.removeAll()
        #if canImport(UIKit)
        animations.removeAll()
        currentAnimation = nil
        #endif
    }
}

// MARK: - 辅助协议

/// 带优先级的拦截器协议
protocol PriorityInterceptor: RouterInterceptor {
    /// 拦截器优先级，数值越大优先级越高
    var priority: Int { get }
}