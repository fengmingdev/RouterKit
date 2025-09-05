//
//  Router+StaticMethods.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/2.
//

import Foundation
#if canImport(UIKit)
import UIKit

// MARK: - 静态导航方法扩展

@MainActor
extension Router {
    /// 静态push方法，方便全局调用
    /// - Parameters:
    ///   - url: 目标URL字符串
    ///   - parameters: 路由参数
    public static func push(to url: String,
                            parameters: RouterParameters? = nil,
                            from sourceVC: UIViewController? = nil,
                            animated: Bool = true,
                            animationId: String? = nil,
                            completion: @escaping RouterCompletion = { _ in }) {
        shared.navigate(
            to: url,
            parameters: parameters,
            from: sourceVC,
            type: .push,
            animated: animated,
            animationId: animationId,
            completion: completion
        )
    }

    /// 静态present方法，方便全局调用
    /// - Parameters:
    ///   - url: 目标URL字符串
    ///   - parameters: 路由参数
    public static func present(to url: String,
                               parameters: RouterParameters? = nil,
                               from sourceVC: UIViewController? = nil,
                               animated: Bool = true,
                               animationId: String? = nil,
                               completion: @escaping RouterCompletion = { _ in }) {
        shared.navigate(
            to: url,
            parameters: parameters,
            from: sourceVC,
            type: .present,
            animated: animated,
            animationId: animationId,
            completion: completion
        )
    }

    /// 静态replace方法，替换当前页面
    /// - Parameters:
    ///   - url: 目标URL字符串
    ///   - parameters: 路由参数
    public static func replace(to url: String,
                               parameters: RouterParameters? = nil,
                               from sourceVC: UIViewController? = nil,
                               animated: Bool = true,
                               animationId: String? = nil,
                               completion: @escaping RouterCompletion = { _ in }) {
        shared.navigate(
            to: url,
            parameters: parameters,
            from: sourceVC,
            type: .replace,
            animated: animated,
            animationId: animationId,
            completion: completion
        )
    }

    /// 静态pop方法，返回上一级页面
    /// - Parameters:
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    public static func pop(animated: Bool = true,
                           completion: @escaping RouterCompletion = { _ in }) {
        shared.navigate(
            to: "",
            parameters: nil,
            from: nil,
            type: .pop,
            animated: animated,
            animationId: nil,
            completion: completion
        )
    }
    
    /// 静态popToRoot方法，返回根页面
    /// - Parameters:
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    public static func popToRoot(animated: Bool = true,
                                 completion: @escaping RouterCompletion = { _ in }) {
        shared.navigate(
            to: "",
            parameters: nil,
            from: nil,
            type: .popToRoot,
            animated: animated,
            animationId: nil,
            completion: completion
        )
    }

    /// 静态popTo方法，返回指定页面
    /// - Parameters:
    ///   - url: 目标URL字符串（用于匹配要返回的页面）
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    public static func popTo(url: String,
                             animated: Bool = true,
                             completion: @escaping RouterCompletion = { _ in }) {
        shared.navigate(
            to: url,
            parameters: nil,
            from: nil,
            type: .popTo,
            animated: animated,
            animationId: nil,
            completion: completion
        )
    }
}

#endif