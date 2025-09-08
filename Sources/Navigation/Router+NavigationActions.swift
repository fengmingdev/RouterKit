//
//  Router+NavigationActions.swift
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

// MARK: - 导航操作实现扩展

@MainActor
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    /// 获取最顶层的视图控制器
    /// - Returns: 当前最顶层的视图控制器
    internal func getTopMostViewController() -> PlatformViewController? {
        #if canImport(UIKit)
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            // 如果找不到根视图控制器，返回nil
            return nil
        }

        return findTopMostViewController(from: rootViewController)
        #elseif canImport(AppKit)
        // 在macOS上，返回一个默认的NSViewController
        return NSViewController()
        #else
        // 其他平台返回默认视图控制器
        return PlatformViewController()
        #endif
    }

    /// 递归查找最顶层的视图控制器
    /// - Parameter viewController: 起始视图控制器
    /// - Returns: 最顶层的视图控制器
    private func findTopMostViewController(from viewController: PlatformViewController) -> PlatformViewController {
        #if canImport(UIKit)
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
        #endif
        
        return viewController
    }

    /// Push导航操作
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - target: 目标视图控制器
    ///   - animated: 是否动画
    internal func push(from source: PlatformViewController, to target: PlatformViewController, animated: Bool) throws {
        #if canImport(UIKit)
        guard let navigationController = source.navigationController else {
            throw RouterError.navigationControllerNotFound()
        }
        navigationController.pushViewController(target, animated: animated)
        #elseif canImport(AppKit)
        // macOS上的简化实现，直接present
        source.presentAsSheet(target)
        #endif
    }

    /// Present导航操作
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - target: 目标视图控制器
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    internal func present(from source: PlatformViewController,
                         to target: PlatformViewController,
                         animated: Bool,
                         completion: @escaping () -> Void) {
        #if canImport(UIKit)
        source.present(target, animated: animated, completion: completion)
        #elseif canImport(AppKit)
        source.presentAsModalWindow(target)
        completion()
        #endif
    }

    /// Replace导航操作
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - target: 目标视图控制器
    ///   - animated: 是否动画
    internal func replace(from source: PlatformViewController, to target: PlatformViewController, animated: Bool) throws {
        #if canImport(UIKit)
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
        #elseif canImport(AppKit)
        // macOS上的简化实现，直接present
        source.presentAsSheet(target)
        #endif
    }

    /// PopTo导航操作
    /// - Parameters:
    ///   - target: 目标视图控制器
    ///   - source: 源视图控制器
    ///   - animated: 是否动画
    internal func popTo(target: PlatformViewController, from source: PlatformViewController, animated: Bool) {
        #if canImport(UIKit)
        guard let navigationController = source.navigationController else {
            return
        }

        navigationController.popToViewController(target, animated: animated)
        #elseif canImport(AppKit)
        // macOS上的简化实现，关闭当前视图
        source.dismiss(nil)
        #endif
    }

    /// 根据类名PopTo导航操作
    /// - Parameters:
    ///   - className: 目标视图控制器类名
    ///   - source: 源视图控制器
    ///   - animated: 是否动画
    internal func popToViewController(withClassName className: String, from source: PlatformViewController, animated: Bool) {
        #if canImport(UIKit)
        guard let navigationController = source.navigationController else {
            return
        }

        for viewController in navigationController.viewControllers {
            if String(describing: type(of: viewController)) == className {
                navigationController.popToViewController(viewController, animated: animated)
                return
            }
        }
        #elseif canImport(AppKit)
        // macOS上的简化实现，关闭当前视图
        source.dismiss(nil)
        #endif
    }

    /// PopToRoot导航操作
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - animated: 是否动画
    internal func popToRoot(from source: PlatformViewController, animated: Bool) {
        #if canImport(UIKit)
        guard let navigationController = source.navigationController else {
            return
        }

        navigationController.popToRootViewController(animated: animated)
        #elseif canImport(AppKit)
        // macOS上的简化实现，关闭当前视图
        source.dismiss(nil)
        #endif
    }

    /// Pop导航操作，返回上一级页面
    /// - Parameters:
    ///   - source: 源视图控制器
    ///   - animated: 是否动画
    internal func pop(from source: PlatformViewController, animated: Bool) {
        #if canImport(UIKit)
        guard let navigationController = source.navigationController else {
            return
        }

        navigationController.popViewController(animated: animated)
        #elseif canImport(AppKit)
        // macOS上的简化实现，关闭当前视图
        source.dismiss(nil)
        #endif
    }
}

// MARK: - 转场动画代理

#if canImport(UIKit)
@available(iOS 13.0, *)
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
        // 由于这是同步方法，无法使用异步的getCurrentAnimation()，返回nil使用默认动画
        return nil
    }

    /// Dismiss动画控制器
    /// - Parameter dismissed: 被关闭的视图控制器
    /// - Returns: 动画控制器
    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        // 由于这是同步方法，无法使用异步的getCurrentAnimation()，返回nil使用默认动画
        return nil
    }
}
#endif

#endif

// MARK: - 公开方法扩展
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    /// 获取最顶层的视图控制器
    /// - Returns: 当前最顶层的视图控制器
    @MainActor public func topMostViewController() -> PlatformViewController? {
        return getTopMostViewController()
    }
}
