//
//  RouterAnimation.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import UIKit

// MARK: - 导航动画协议
/// 自定义转场动画协议
public protocol NavigationAnimatable: AnyObject {
    var identifier: String { get }               // 动画唯一标识
    var transitionDuration: TimeInterval { get } // 动画时长
    /// 展示动画
    /// - Parameter transitionContext: 转场上下文
    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning)
    /// 消失动画
    /// - Parameter transitionContext: 转场上下文
    func animateDismissal(using transitionContext: UIViewControllerContextTransitioning)
}

// MARK: - 动画包装器（适配系统转场协议）
/// 将NavigationAnimatable适配为系统转场动画协议
public class AnimationTransitionWrapper: NSObject, UIViewControllerAnimatedTransitioning {
    private let animation: NavigationAnimatable  // 自定义动画
    private let isPresentation: Bool             // 是否为展示动画（true）或消失动画（false）
    
    /// 初始化动画包装器
    /// - Parameters:
    ///   - animation: 自定义动画实例
    ///   - isPresentation: 是否为展示动画
    init(animation: NavigationAnimatable, isPresentation: Bool) {
        self.animation = animation
        self.isPresentation = isPresentation
        super.init()
    }
    
    /// 动画时长
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animation.transitionDuration
    }
    
    /// 执行动画
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresentation {
            animation.animatePresentation(using: transitionContext)
        } else {
            animation.animateDismissal(using: transitionContext)
        }
    }
}

// MARK: - 淡入淡出动画示例
/// 淡入淡出转场动画
class FadeAnimation: NavigationAnimatable {
    let identifier: String = "FadeAnimation"  // 动画标识
    let transitionDuration: TimeInterval = 0.3  // 动画时长0.3秒
    
    /// 展示动画：淡入
    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        // 初始状态：透明
        toView.alpha = 0.0
        containerView.addSubview(toView)
        
        // 执行淡入动画
        UIView.animate(withDuration: transitionDuration) {
            toView.alpha = 1.0
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }
    
    /// 消失动画：淡出
    func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        // 执行淡出动画
        UIView.animate(withDuration: transitionDuration) {
            fromView.alpha = 0.0
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }
}
