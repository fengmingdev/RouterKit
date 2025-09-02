//
//  FadeNavigationAnimation.swift
//  MyMainProject
//
//  Created by fengming on 2025/8/8.
//

import RouterKit_Swift
import UIKit

// MARK: 创建自定义导航动画

/// 淡入淡出动画
class FadeNavigationAnimation: NSObject, NavigationAnimatable {
    var identifier: String = "fade"
    var transitionDuration: TimeInterval = 0.5

    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        toVC.view.alpha = 0

        UIView.animate(withDuration: transitionDuration, animations: {
            toVC.view.alpha = 1
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }

        UIView.animate(withDuration: transitionDuration, animations: {
            fromVC.view.alpha = 0
        }) { _ in
            fromVC.view.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
