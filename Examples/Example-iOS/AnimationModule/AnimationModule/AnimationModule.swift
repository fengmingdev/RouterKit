//
//  AnimationModule.swift
//  AnimationModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import Foundation
import RouterKit
import UIKit

/// 动画模块 - 展示各种自定义转场动画效果
public class AnimationModule: ModuleProtocol {
    public var moduleName: String = "AnimationModule"
    public var dependencies: [ModuleDependency] = []
    public var lastUsedTime: Date = Date()
    
    required public init() {}
    
    private var basePath: String = "/AnimationModule"
    
    public func load(completion: @escaping (Bool) -> Void) {
        register()
        completion(true)
    }
    
    public func unload() {
        // 清理资源
    }
    
    public func suspend() {
        // 暂停模块
    }
    
    public func resume() {
        // 恢复模块
    }
    
    private func register() {
        Task {
            do {
                // 注册动画示例主页面
                try await Router.shared.registerRoute("\(basePath)/animation", for: AnimationViewController.self)
                
                // 注册基础动画示例
                try await Router.shared.registerRoute("\(basePath)/basic", for: BasicAnimationViewController.self)
                
                // 注册自定义转场动画示例
                try await Router.shared.registerRoute("\(basePath)/transition", for: TransitionAnimationViewController.self)
                
                // 注册动画测试页面（用于演示不同的动画效果）
                try await Router.shared.registerRoute("\(basePath)/test", for: AnimationTestViewController.self)
                
                print("AnimationModule: 所有路由注册完成")
            } catch {
                print("AnimationModule: 路由注册失败 - \(error)")
            }
        }
    }
}

// MARK: - 动画管理器

/// 动画管理器 - 管理各种动画效果和配置
class AnimationManager {
    static let shared = AnimationManager()
    
    private init() {}
    
    // MARK: - 动画配置
    
    /// 动画持续时间配置
    struct Duration {
        static let fast: TimeInterval = 0.25
        static let normal: TimeInterval = 0.35
        static let slow: TimeInterval = 0.5
        static let verySlow: TimeInterval = 1.0
    }
    
    /// 动画缓动函数配置
    struct Easing {
        static let easeIn = UIView.AnimationOptions.curveEaseIn
        static let easeOut = UIView.AnimationOptions.curveEaseOut
        static let easeInOut = UIView.AnimationOptions.curveEaseInOut
        static let linear = UIView.AnimationOptions.curveLinear
    }
    
    // MARK: - 基础动画
    
    /// 淡入动画
    func fadeIn(view: UIView, duration: TimeInterval = Duration.normal, completion: (() -> Void)? = nil) {
        view.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }
    
    /// 淡出动画
    func fadeOut(view: UIView, duration: TimeInterval = Duration.normal, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
        }, completion: { _ in
            completion?()
        })
    }
    
    /// 缩放动画
    func scale(view: UIView, from: CGFloat = 0.1, to: CGFloat = 1.0, duration: TimeInterval = Duration.normal, completion: (() -> Void)? = nil) {
        view.transform = CGAffineTransform(scaleX: from, y: from)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            view.transform = CGAffineTransform(scaleX: to, y: to)
        }, completion: { _ in
            completion?()
        })
    }
    
    /// 滑动动画
    func slide(view: UIView, from: CGPoint, to: CGPoint, duration: TimeInterval = Duration.normal, completion: (() -> Void)? = nil) {
        view.center = from
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: [], animations: {
            view.center = to
        }, completion: { _ in
            completion?()
        })
    }
    
    /// 旋转动画
    func rotate(view: UIView, angle: CGFloat, duration: TimeInterval = Duration.normal, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            view.transform = CGAffineTransform(rotationAngle: angle)
        }, completion: { _ in
            completion?()
        })
    }
    
    // MARK: - 弹簧动画
    
    /// 弹跳动画
    func bounce(view: UIView, completion: (() -> Void)? = nil) {
        let originalTransform = view.transform
        
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                view.transform = originalTransform
            }
        }, completion: { _ in
            completion?()
        })
    }
    
    /// 摇摆动画
    func shake(view: UIView, completion: (() -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        view.layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
    
    /// 脉冲动画
    func pulse(view: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .repeat], animations: {
            view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            view.transform = CGAffineTransform.identity
            completion?()
        })
        
        // 停止脉冲动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            view.layer.removeAllAnimations()
            view.transform = CGAffineTransform.identity
        }
    }
    
    // MARK: - 3D动画
    
    /// 翻转动画
    func flip(view: UIView, direction: FlipDirection = .horizontal, completion: (() -> Void)? = nil) {
        let transitionOptions: UIView.AnimationOptions = direction == .horizontal ? .transitionFlipFromLeft : .transitionFlipFromTop
        
        UIView.transition(with: view, duration: Duration.normal, options: transitionOptions, animations: {
            // 可以在这里改变视图内容
        }, completion: { _ in
            completion?()
        })
    }
    
    /// 立方体旋转动画
    func cubeRotation(view: UIView, completion: (() -> Void)? = nil) {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0 // 透视效果
        transform = CATransform3DRotate(transform, .pi, 1, 1, 0)
        
        UIView.animate(withDuration: Duration.slow, animations: {
            view.layer.transform = transform
        }, completion: { _ in
            UIView.animate(withDuration: Duration.slow, animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: { _ in
                completion?()
            })
        })
    }
    
    // MARK: - 组合动画
    
    /// 入场动画组合
    func entranceAnimation(view: UIView, type: EntranceType = .slideUp, completion: (() -> Void)? = nil) {
        switch type {
        case .slideUp:
            let originalCenter = view.center
            view.center = CGPoint(x: originalCenter.x, y: originalCenter.y + 100)
            view.alpha = 0
            
            UIView.animate(withDuration: Duration.normal, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
                view.center = originalCenter
                view.alpha = 1
            }, completion: { _ in
                completion?()
            })
            
        case .scaleIn:
            view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            view.alpha = 0
            
            UIView.animate(withDuration: Duration.normal, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
                view.transform = CGAffineTransform.identity
                view.alpha = 1
            }, completion: { _ in
                completion?()
            })
            
        case .fadeIn:
            fadeIn(view: view, duration: Duration.normal, completion: completion)
        }
    }
    
    /// 退场动画组合
    func exitAnimation(view: UIView, type: ExitType = .slideDown, completion: (() -> Void)? = nil) {
        switch type {
        case .slideDown:
            UIView.animate(withDuration: Duration.normal, animations: {
                view.center = CGPoint(x: view.center.x, y: view.center.y + 100)
                view.alpha = 0
            }, completion: { _ in
                completion?()
            })
            
        case .scaleOut:
            UIView.animate(withDuration: Duration.normal, animations: {
                view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                view.alpha = 0
            }, completion: { _ in
                completion?()
            })
            
        case .fadeOut:
            fadeOut(view: view, duration: Duration.normal, completion: completion)
        }
    }
}

// MARK: - 动画类型枚举

enum FlipDirection {
    case horizontal
    case vertical
}

enum EntranceType {
    case slideUp
    case scaleIn
    case fadeIn
}

enum ExitType {
    case slideDown
    case scaleOut
    case fadeOut
}

// MARK: - 自定义转场动画器

/// 自定义推送转场动画器
class CustomPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    private let animationType: PushAnimationType
    
    init(duration: TimeInterval = 0.35, animationType: PushAnimationType = .slide) {
        self.duration = duration
        self.animationType = animationType
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        switch animationType {
        case .slide:
            animateSlideTransition(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .fade:
            animateFadeTransition(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .scale:
            animateScaleTransition(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .flip:
            animateFlipTransition(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        }
    }
    
    private func animateSlideTransition(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        toVC.view.frame = CGRect(x: container.bounds.width, y: 0, width: container.bounds.width, height: container.bounds.height)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: [], animations: {
            fromVC.view.frame = CGRect(x: -container.bounds.width, y: 0, width: container.bounds.width, height: container.bounds.height)
            toVC.view.frame = container.bounds
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateFadeTransition(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        toVC.view.frame = container.bounds
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.alpha = 0
            toVC.view.alpha = 1
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateScaleTransition(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        toVC.view.frame = container.bounds
        toVC.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
            fromVC.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            fromVC.view.alpha = 0
            toVC.view.transform = CGAffineTransform.identity
            toVC.view.alpha = 1
        }, completion: { _ in
            fromVC.view.transform = CGAffineTransform.identity
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateFlipTransition(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        toVC.view.frame = container.bounds
        
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        container.layer.sublayerTransform = transform
        
        let angle = CGFloat.pi
        fromVC.view.layer.transform = CATransform3DIdentity
        toVC.view.layer.transform = CATransform3DRotate(transform, angle, 0, 1, 0)
        
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.layer.transform = CATransform3DRotate(transform, -angle, 0, 1, 0)
            toVC.view.layer.transform = CATransform3DIdentity
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}

enum PushAnimationType {
    case slide
    case fade
    case scale
    case flip
}
