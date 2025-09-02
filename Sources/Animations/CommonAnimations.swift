//
//  CommonAnimations.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

#if canImport(UIKit)
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import QuartzCore

// 定义跨平台类型别名
#if os(iOS) || os(tvOS)
typealias PlatformViewController = UIViewController
typealias PlatformView = UIView
typealias PlatformScreen = UIScreen
typealias PlatformContextTransitioning = UIViewControllerContextTransitioning
#elseif os(macOS)
typealias PlatformViewController = NSViewController
typealias PlatformView = NSView
typealias PlatformScreen = NSScreen
typealias PlatformContextTransitioning = NSViewControllerContextTransitioning
#endif

// MARK: - 滑动动画
/// 从右侧滑入的转场动画
class SlideInFromRightAnimation: NavigationAnimatable {
    let identifier: String = "SlideInFromRightAnimation"
    let transitionDuration: TimeInterval = 0.35

    func animatePresentation(using transitionContext: PlatformContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        // 初始位置：屏幕右侧
        let screenWidth = PlatformScreen.main.bounds.width
        toView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: toView.frame.height)
        containerView.addSubview(toView)

        // 执行滑动动画
        #if os(iOS) || os(tvOS)
        UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveEaseOut, animations: {
            toView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: toView.frame.height)
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
                       
        #elseif os(macOS)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = transitionDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            toView.animator().frame = CGRect(x: 0, y: 0, width: screenWidth, height: toView.frame.height)
        }, completionHandler: {
            transitionContext.completeTransition(true)
        })
        #endif
    }

    func animateDismissal(using transitionContext: PlatformContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        // 执行滑动动画：滑出到右侧
        let screenWidth = PlatformScreen.main.bounds.width
        #if os(iOS) || os(tvOS)
        UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveEaseIn, animations: {
            fromView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: fromView.frame.height)
        }, completion: { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })

        #elseif os(macOS)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = transitionDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            fromView.animator().frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: fromView.frame.height)
        }, completionHandler: {
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
        #endif
    }
    
}

/// 从左侧滑入的转场动画
class SlideInFromLeftAnimation: NavigationAnimatable {
    let identifier: String = "SlideInFromLeftAnimation"
    let transitionDuration: TimeInterval = 0.35

    func animatePresentation(using transitionContext: PlatformContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        // 初始位置：屏幕左侧
        let screenWidth = PlatformScreen.main.bounds.width
        toView.frame = CGRect(x: -screenWidth, y: 0, width: screenWidth, height: toView.frame.height)
        containerView.addSubview(toView)

        // 执行滑动动画
        #if os(iOS) || os(tvOS)
        UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveEaseOut) {
            toView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: toView.frame.height)
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
        #elseif os(macOS)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = transitionDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            toView.animator().frame = CGRect(x: 0, y: 0, width: screenWidth, height: toView.frame.height)
        }, completionHandler: {
            transitionContext.completeTransition(true)
        })
        #endif
    }

    func animateDismissal(using transitionContext: PlatformContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        // 执行滑动动画：滑出到左侧
        let screenWidth = PlatformScreen.main.bounds.width
        #if os(iOS) || os(tvOS)
        UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveEaseIn) {
            fromView.frame = CGRect(x: -screenWidth, y: 0, width: screenWidth, height: fromView.frame.height)
        } completion: { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        #elseif os(macOS)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = transitionDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            fromView.animator().frame = CGRect(x: -screenWidth, y: 0, width: screenWidth, height: fromView.frame.height)
        }, completionHandler: {
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
        #endif
    }
}

// MARK: - 缩放动画
/// 缩放转场动画
class ScaleAnimation: NavigationAnimatable {
    let identifier: String = "ScaleAnimation"
    let transitionDuration: TimeInterval = 0.3

    func animatePresentation(using transitionContext: PlatformContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        // 初始状态：缩小并透明
        toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        toView.alpha = 0.0
        containerView.addSubview(toView)

        // 执行缩放动画
        #if os(iOS) || os(tvOS)
        UIView.animate(withDuration: transitionDuration) {
            toView.transform = .identity
            toView.alpha = 1.0
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
        #elseif os(macOS)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = transitionDuration
            toView.animator().transform = .identity
            toView.animator().alphaValue = 1.0
        }, completionHandler: {
            transitionContext.completeTransition(true)
        })
        #endif
    }

    func animateDismissal(using transitionContext: PlatformContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        // 执行缩放动画：缩小并透明
        #if os(iOS) || os(tvOS)
        UIView.animate(withDuration: transitionDuration) {
            fromView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            fromView.alpha = 0.0
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
        #elseif os(macOS)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = transitionDuration
            fromView.animator().transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            fromView.animator().alphaValue = 0.0
        }, completionHandler: {
            transitionContext.completeTransition(true)
        })
        #endif
    }
}

// MARK: - 翻转动画
/// 翻转转场动画
class FlipAnimation: NavigationAnimatable {
    let identifier: String = "FlipAnimation"
    let transitionDuration: TimeInterval = 0.5

    func animatePresentation(using transitionContext: PlatformContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        // 配置3D变换
        containerView.addSubview(toView)
        toView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        fromView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)

        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 500.0
        containerView.layer.sublayerTransform = perspective

        // 初始状态：旋转90度
        toView.transform = CGAffineTransform(rotationAngle: -.pi/2)

        // 执行翻转动画
        #if os(iOS) || os(tvOS)
        UIView.animate(withDuration: transitionDuration, animations: {
            fromView.transform = CGAffineTransform(rotationAngle: .pi/2)
            toView.transform = .identity
        }) { _ in
            fromView.transform = .identity
            transitionContext.completeTransition(true)
        }
        #elseif os(macOS)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = transitionDuration
            fromView.animator().transform = CGAffineTransform(rotationAngle: .pi/2)
            toView.animator().transform = .identity
        }, completionHandler: {
            fromView.transform = .identity
            transitionContext.completeTransition(true)
        })
        #endif
    }

    func animateDismissal(using transitionContext: PlatformContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        // 配置3D变换
        containerView.insertSubview(toView, belowSubview: fromView)
        toView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        fromView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)

        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 500.0
        containerView.layer.sublayerTransform = perspective

        // 初始状态：旋转-90度
        toView.transform = CGAffineTransform(rotationAngle: -.pi/2)

        // 执行翻转动画
        #if os(iOS) || os(tvOS)
        UIView.animate(withDuration: transitionDuration, animations: {
            fromView.transform = CGAffineTransform(rotationAngle: .pi/2)
            toView.transform = .identity
        }) { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        #elseif os(macOS)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = transitionDuration
            fromView.animator().transform = CGAffineTransform(rotationAngle: .pi/2)
            toView.animator().transform = .identity
        }, completionHandler: {
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
        #endif
    }
}

// MARK: - 动画工厂
/// 提供常用动画的工厂类
class AnimationFactory {
    /// 获取指定类型的动画
    /// - Parameter type: 动画类型
    /// - Returns: 动画实例
    static func getAnimation(ofType type: AnimationType) -> NavigationAnimatable {
        switch type {
        case .fade:
            return FadeAnimation()
        case .slideRight:
            return SlideInFromRightAnimation()
        case .slideLeft:
            return SlideInFromLeftAnimation()
        case .scale:
            return ScaleAnimation()
        case .flip:
            return FlipAnimation()
        }
    }
}

/// 动画类型枚举
enum AnimationType {
    case fade        // 淡入淡出
    case slideRight  // 从右侧滑入
    case slideLeft   // 从左侧滑入
    case scale       // 缩放
    case flip        // 翻转
}
#endif
