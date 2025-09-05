//
//  Router+NavigationActions.swift
//  RouterKit
//
//  Created by fengming on 2025/8/4.
//

import Foundation
#if canImport(UIKit)
import UIKit

// MARK: - 导航操作实现扩展

@MainActor
extension Router {
    /// 获取最顶层的视图控制器
    /// - Returns: 当前最顶层的视图控制器
    internal func topMostViewController() -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            fatalError("No root view controller found")
        }
        
        return findTopMostViewController(from: rootViewController)
    }
    
    /// 递归查找最顶层的视图控制器
    /// - Parameter viewController: 起始视图控制器
    /// - Returns: 最顶层的视图控制器
    private func findTopMostViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return findTopMostViewController(from: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            if let topViewController = navigationController.topViewController {
                return findTopMostViewController(from: topViewController)
            }
        }
        
        if let tabBarController = viewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return findTopMostViewController(from: selectedViewController)
            }
        }
        
        return viewController
    }
    
    /// Push导航操作
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - target: 目标视图控制器
    ///   - animated: 是否动画
    internal func push(from source: UIViewController, to target: UIViewController, animated: Bool) throws {
        guard let navigationController = source.navigationController else {
            throw RouterError.navigationControllerNotFound()
        }
        
        navigationController.pushViewController(target, animated: animated)
    }
    
    /// Present导航操作
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - target: 目标视图控制器
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    internal func present(from source: UIViewController,
                         to target: UIViewController,
                         animated: Bool,
                         completion: @escaping () -> Void) {
        source.present(target, animated: animated, completion: completion)
    }
    
    /// Replace导航操作
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - target: 目标视图控制器
    ///   - animated: 是否动画
    internal func replace(from source: UIViewController, to target: UIViewController, animated: Bool) throws {
        guard let navigationController = source.navigationController else {
            throw RouterError.navigationControllerNotFound()
        }
        
        var viewControllers = navigationController.viewControllers
        if let index = viewControllers.firstIndex(of: source) {
            viewControllers[index] = target
            navigationController.setViewControllers(viewControllers, animated: animated)
        } else {
            // 如果当前控制器不在导航栈中，直接push
            navigationController.pushViewController(target, animated: animated)
        }
    }
    
    /// PopTo导航操作
    /// - Parameters:
    ///   - target: 目标视图控制器
    ///   - source: 源视图控制器
    ///   - animated: 是否动画
    internal func popTo(target: UIViewController, from source: UIViewController, animated: Bool) {
        guard let navigationController = source.navigationController else {
            return
        }
        
        navigationController.popToViewController(target, animated: animated)
    }
    
    /// 根据类名PopTo导航操作
    /// - Parameters:
    ///   - className: 目标视图控制器类名
    ///   - source: 源视图控制器
    ///   - animated: 是否动画
    internal func popToViewController(withClassName className: String, from source: UIViewController, animated: Bool) {
        guard let navigationController = source.navigationController else {
            return
        }
        
        for viewController in navigationController.viewControllers {
            if String(describing: type(of: viewController)) == className {
                navigationController.popToViewController(viewController, animated: animated)
                return
            }
        }
    }
    
    /// PopToRoot导航操作
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - animated: 是否动画
    internal func popToRoot(from source: UIViewController, animated: Bool) {
        guard let navigationController = source.navigationController else {
            return
        }
        
        navigationController.popToRootViewController(animated: animated)
    }
    
    /// Pop导航操作，返回上一级页面
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - animated: 是否动画
    internal func pop(from source: UIViewController, animated: Bool) {
        guard let navigationController = source.navigationController else {
            return
        }
        
        navigationController.popViewController(animated: animated)
    }
}

// MARK: - 转场动画代理

extension Router: UIViewControllerTransitioningDelegate {
    /// Present动画控制器
    /// - Parameters:
    ///   - presented: 被展示的视图控制器
    ///   - presenting: 展示的视图控制器
    ///   - source: 源视图控制器
    /// - Returns: 动画控制器
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let animation = currentAnimation else { return nil }
        return AnimationTransitionWrapper(animation: animation, isPresentation: true)
    }
    
    /// Dismiss动画控制器
    /// - Parameter dismissed: 被关闭的视图控制器
    /// - Returns: 动画控制器
    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let animation = currentAnimation else { return nil }
        return AnimationTransitionWrapper(animation: animation, isPresentation: false)
    }
}

#endif