//
//  TransitionAnimationViewController.swift
//  AnimationModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 自定义转场动画示例页面
class TransitionAnimationViewController: UIViewController, Routable {
    static func viewController(with parameters: RouterKit.RouterParameters?) -> UIViewController? {
        return TransitionAnimationViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterKit.RouterParameters?, completion: @escaping RouterKit.RouterCompletion) {
        completion(.success("Action \(action) performed"))
    }
    
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // 转场类型选择
    private let transitionTypeSegmentedControl = UISegmentedControl(items: ["滑动", "淡入", "缩放", "翻转"])
    
    // 演示按钮
    private let presentModalButton = UIButton(type: .system)
    private let pushViewControllerButton = UIButton(type: .system)
    private let customTransitionButton = UIButton(type: .system)
    
    // 配置选项
    private let durationSlider = UISlider()
    private let durationLabel = UILabel()
    private let dampingSlider = UISlider()
    private let dampingLabel = UILabel()
    private let velocitySlider = UISlider()
    private let velocityLabel = UILabel()
    
    // 预览区域
    private let previewContainerView = UIView()
    private let previewView = UIView()
    
    // MARK: - Properties
    
    private var currentTransitionType: PushAnimationType = .slide
    private var transitionDuration: TimeInterval = 0.35
    private var springDamping: CGFloat = 0.8
    private var springVelocity: CGFloat = 0.5
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        handleRouteParameters()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "转场动画"
        
        // 添加返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "返回",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 配置标题
        titleLabel.text = "自定义转场动画演示"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 配置描述
        descriptionLabel.text = "体验各种自定义转场动画效果，包括模态展示、导航推送和自定义转场。可以调整动画参数来观察不同的效果。"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        setupTransitionTypeControl()
        setupConfigurationControls()
        setupPreviewArea()
        setupActionButtons()
    }
    
    private func setupTransitionTypeControl() {
        let transitionTypeLabel = UILabel()
        transitionTypeLabel.text = "转场类型"
        transitionTypeLabel.font = .boldSystemFont(ofSize: 18)
        transitionTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transitionTypeLabel)
        
        transitionTypeSegmentedControl.selectedSegmentIndex = 0
        transitionTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        transitionTypeSegmentedControl.addTarget(self, action: #selector(transitionTypeChanged), for: .valueChanged)
        contentView.addSubview(transitionTypeSegmentedControl)
        
        NSLayoutConstraint.activate([
            transitionTypeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            transitionTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            transitionTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            transitionTypeSegmentedControl.topAnchor.constraint(equalTo: transitionTypeLabel.bottomAnchor, constant: 12),
            transitionTypeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            transitionTypeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupConfigurationControls() {
        let configLabel = UILabel()
        configLabel.text = "动画配置"
        configLabel.font = .boldSystemFont(ofSize: 18)
        configLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(configLabel)
        
        // 持续时间控制
        let durationTitleLabel = UILabel()
        durationTitleLabel.text = "持续时间"
        durationTitleLabel.font = .systemFont(ofSize: 16)
        durationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(durationTitleLabel)
        
        durationSlider.minimumValue = 0.1
        durationSlider.maximumValue = 2.0
        durationSlider.value = Float(transitionDuration)
        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
        contentView.addSubview(durationSlider)
        
        durationLabel.text = String(format: "%.2f秒", transitionDuration)
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textAlignment = .center
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(durationLabel)
        
        // 弹簧阻尼控制
        let dampingTitleLabel = UILabel()
        dampingTitleLabel.text = "弹簧阻尼"
        dampingTitleLabel.font = .systemFont(ofSize: 16)
        dampingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dampingTitleLabel)
        
        dampingSlider.minimumValue = 0.1
        dampingSlider.maximumValue = 1.0
        dampingSlider.value = Float(springDamping)
        dampingSlider.translatesAutoresizingMaskIntoConstraints = false
        dampingSlider.addTarget(self, action: #selector(dampingChanged), for: .valueChanged)
        contentView.addSubview(dampingSlider)
        
        dampingLabel.text = String(format: "%.2f", springDamping)
        dampingLabel.font = .systemFont(ofSize: 14)
        dampingLabel.textAlignment = .center
        dampingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dampingLabel)
        
        // 弹簧速度控制
        let velocityTitleLabel = UILabel()
        velocityTitleLabel.text = "弹簧速度"
        velocityTitleLabel.font = .systemFont(ofSize: 16)
        velocityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(velocityTitleLabel)
        
        velocitySlider.minimumValue = 0.0
        velocitySlider.maximumValue = 2.0
        velocitySlider.value = Float(springVelocity)
        velocitySlider.translatesAutoresizingMaskIntoConstraints = false
        velocitySlider.addTarget(self, action: #selector(velocityChanged), for: .valueChanged)
        contentView.addSubview(velocitySlider)
        
        velocityLabel.text = String(format: "%.2f", springVelocity)
        velocityLabel.font = .systemFont(ofSize: 14)
        velocityLabel.textAlignment = .center
        velocityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(velocityLabel)
        
        NSLayoutConstraint.activate([
            configLabel.topAnchor.constraint(equalTo: transitionTypeSegmentedControl.bottomAnchor, constant: 30),
            configLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            configLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            durationTitleLabel.topAnchor.constraint(equalTo: configLabel.bottomAnchor, constant: 16),
            durationTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            durationTitleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            durationSlider.centerYAnchor.constraint(equalTo: durationTitleLabel.centerYAnchor),
            durationSlider.leadingAnchor.constraint(equalTo: durationTitleLabel.trailingAnchor, constant: 12),
            durationSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -12),
            
            durationLabel.centerYAnchor.constraint(equalTo: durationTitleLabel.centerYAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            durationLabel.widthAnchor.constraint(equalToConstant: 60),
            
            dampingTitleLabel.topAnchor.constraint(equalTo: durationTitleLabel.bottomAnchor, constant: 16),
            dampingTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dampingTitleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            dampingSlider.centerYAnchor.constraint(equalTo: dampingTitleLabel.centerYAnchor),
            dampingSlider.leadingAnchor.constraint(equalTo: dampingTitleLabel.trailingAnchor, constant: 12),
            dampingSlider.trailingAnchor.constraint(equalTo: dampingLabel.leadingAnchor, constant: -12),
            
            dampingLabel.centerYAnchor.constraint(equalTo: dampingTitleLabel.centerYAnchor),
            dampingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dampingLabel.widthAnchor.constraint(equalToConstant: 60),
            
            velocityTitleLabel.topAnchor.constraint(equalTo: dampingTitleLabel.bottomAnchor, constant: 16),
            velocityTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            velocityTitleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            velocitySlider.centerYAnchor.constraint(equalTo: velocityTitleLabel.centerYAnchor),
            velocitySlider.leadingAnchor.constraint(equalTo: velocityTitleLabel.trailingAnchor, constant: 12),
            velocitySlider.trailingAnchor.constraint(equalTo: velocityLabel.leadingAnchor, constant: -12),
            
            velocityLabel.centerYAnchor.constraint(equalTo: velocityTitleLabel.centerYAnchor),
            velocityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            velocityLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupPreviewArea() {
        let previewLabel = UILabel()
        previewLabel.text = "动画预览"
        previewLabel.font = .boldSystemFont(ofSize: 18)
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previewLabel)
        
        previewContainerView.backgroundColor = .systemGray6
        previewContainerView.layer.cornerRadius = 12
        previewContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previewContainerView)
        
        previewView.backgroundColor = .systemBlue
        previewView.layer.cornerRadius = 8
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewContainerView.addSubview(previewView)
        
        let previewButton = UIButton(type: .system)
        previewButton.setTitle("预览动画", for: .normal)
        previewButton.backgroundColor = .systemGreen
        previewButton.setTitleColor(.white, for: .normal)
        previewButton.layer.cornerRadius = 8
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.addTarget(self, action: #selector(previewAnimationTapped), for: .touchUpInside)
        previewContainerView.addSubview(previewButton)
        
        NSLayoutConstraint.activate([
            previewLabel.topAnchor.constraint(equalTo: velocityLabel.bottomAnchor, constant: 30),
            previewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            previewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            previewContainerView.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 12),
            previewContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            previewContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            previewContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            previewView.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: 20),
            previewView.centerYAnchor.constraint(equalTo: previewContainerView.centerYAnchor),
            previewView.widthAnchor.constraint(equalToConstant: 40),
            previewView.heightAnchor.constraint(equalToConstant: 40),
            
            previewButton.centerXAnchor.constraint(equalTo: previewContainerView.centerXAnchor),
            previewButton.bottomAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: -16),
            previewButton.widthAnchor.constraint(equalToConstant: 100),
            previewButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupActionButtons() {
        let actionsLabel = UILabel()
        actionsLabel.text = "转场演示"
        actionsLabel.font = .boldSystemFont(ofSize: 18)
        actionsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionsLabel)
        
        // 模态展示按钮
        presentModalButton.setTitle("模态展示", for: .normal)
        presentModalButton.backgroundColor = .systemBlue
        presentModalButton.setTitleColor(.white, for: .normal)
        presentModalButton.layer.cornerRadius = 8
        presentModalButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(presentModalButton)
        
        // 导航推送按钮
        pushViewControllerButton.setTitle("导航推送", for: .normal)
        pushViewControllerButton.backgroundColor = .systemGreen
        pushViewControllerButton.setTitleColor(.white, for: .normal)
        pushViewControllerButton.layer.cornerRadius = 8
        pushViewControllerButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pushViewControllerButton)
        
        // 自定义转场按钮
        customTransitionButton.setTitle("自定义转场", for: .normal)
        customTransitionButton.backgroundColor = .systemPurple
        customTransitionButton.setTitleColor(.white, for: .normal)
        customTransitionButton.layer.cornerRadius = 8
        customTransitionButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(customTransitionButton)
        
        NSLayoutConstraint.activate([
            actionsLabel.topAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: 30),
            actionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            presentModalButton.topAnchor.constraint(equalTo: actionsLabel.bottomAnchor, constant: 16),
            presentModalButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            presentModalButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            presentModalButton.heightAnchor.constraint(equalToConstant: 50),
            
            pushViewControllerButton.topAnchor.constraint(equalTo: presentModalButton.bottomAnchor, constant: 12),
            pushViewControllerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            pushViewControllerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            pushViewControllerButton.heightAnchor.constraint(equalToConstant: 50),
            
            customTransitionButton.topAnchor.constraint(equalTo: pushViewControllerButton.bottomAnchor, constant: 12),
            customTransitionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            customTransitionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            customTransitionButton.heightAnchor.constraint(equalToConstant: 50),
            customTransitionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 内容视图约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 标题约束
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 描述约束
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        presentModalButton.addTarget(self, action: #selector(presentModalTapped), for: .touchUpInside)
        pushViewControllerButton.addTarget(self, action: #selector(pushViewControllerTapped), for: .touchUpInside)
        customTransitionButton.addTarget(self, action: #selector(customTransitionTapped), for: .touchUpInside)
    }
    
    private func handleRouteParameters() {
        // 处理路由参数 - Router没有currentContext属性，这里移除相关代码
        // 如果需要处理路由参数，应该在viewController(with:)方法中处理
        // 暂时设置默认值
        transitionTypeSegmentedControl.selectedSegmentIndex = 0
        currentTransitionType = .slide
    }
    
    // MARK: - Animation Methods
    
    private func performPreviewAnimation() {
        let originalCenter = previewView.center
        let targetCenter = CGPoint(x: previewContainerView.bounds.width - 60, y: originalCenter.y)
        
        switch currentTransitionType {
        case .slide:
            UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: [], animations: {
                self.previewView.center = targetCenter
            }, completion: { _ in
                UIView.animate(withDuration: self.transitionDuration, delay: 0.5, usingSpringWithDamping: self.springDamping, initialSpringVelocity: self.springVelocity, options: [], animations: {
                    self.previewView.center = originalCenter
                })
            })
            
        case .fade:
            UIView.animate(withDuration: transitionDuration / 2, animations: {
                self.previewView.alpha = 0
            }, completion: { _ in
                self.previewView.center = targetCenter
                UIView.animate(withDuration: self.transitionDuration / 2, animations: {
                    self.previewView.alpha = 1
                }, completion: { _ in
                    UIView.animate(withDuration: self.transitionDuration / 2, delay: 0.5, animations: {
                        self.previewView.alpha = 0
                    }, completion: { _ in
                        self.previewView.center = originalCenter
                        UIView.animate(withDuration: self.transitionDuration / 2, animations: {
                            self.previewView.alpha = 1
                        })
                    })
                })
            })
            
        case .scale:
            UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: [], animations: {
                self.previewView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.previewView.center = targetCenter
            }, completion: { _ in
                UIView.animate(withDuration: self.transitionDuration, delay: 0.5, usingSpringWithDamping: self.springDamping, initialSpringVelocity: self.springVelocity, options: [], animations: {
                    self.previewView.transform = CGAffineTransform.identity
                    self.previewView.center = originalCenter
                })
            })
            
        case .flip:
            UIView.transition(with: previewView, duration: transitionDuration, options: .transitionFlipFromLeft, animations: {
                self.previewView.center = targetCenter
            }, completion: { _ in
                UIView.transition(with: self.previewView, duration: self.transitionDuration, options: .transitionFlipFromRight, animations: {
                    self.previewView.center = originalCenter
                })
            })
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func backButtonTapped() {
        Router.pop()
    }
    
    @objc private func transitionTypeChanged() {
        switch transitionTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            currentTransitionType = .slide
        case 1:
            currentTransitionType = .fade
        case 2:
            currentTransitionType = .scale
        case 3:
            currentTransitionType = .flip
        default:
            currentTransitionType = .slide
        }
    }
    
    @objc private func durationChanged() {
        transitionDuration = TimeInterval(durationSlider.value)
        durationLabel.text = String(format: "%.2f秒", transitionDuration)
    }
    
    @objc private func dampingChanged() {
        springDamping = CGFloat(dampingSlider.value)
        dampingLabel.text = String(format: "%.2f", springDamping)
    }
    
    @objc private func velocityChanged() {
        springVelocity = CGFloat(velocitySlider.value)
        velocityLabel.text = String(format: "%.2f", springVelocity)
    }
    
    @objc private func previewAnimationTapped() {
        performPreviewAnimation()
    }
    
    @objc private func presentModalTapped() {
        let testVC = AnimationTestViewController()
        testVC.animationType = currentTransitionType.rawValue
        testVC.modalPresentationStyle = .fullScreen
        
        // 设置自定义转场动画
        testVC.transitioningDelegate = self
        
        present(testVC, animated: true)
    }
    
    @objc private func pushViewControllerTapped() {
        Router.shared.navigate(to: "/AnimationModule/test?animationType=\(currentTransitionType.rawValue)") { result in
            switch result {
            case .success:
                print("导航成功")
            case .failure(let error):
                print("导航失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func customTransitionTapped() {
        let testVC = AnimationTestViewController()
        testVC.animationType = currentTransitionType.rawValue
        
        // 使用自定义导航控制器
        let navController = UINavigationController(rootViewController: testVC)
        navController.delegate = self
        navController.modalPresentationStyle = .fullScreen
        
        present(navController, animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TransitionAnimationViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPushAnimator(duration: transitionDuration, animationType: currentTransitionType)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissAnimator(duration: transitionDuration, animationType: currentTransitionType)
    }
}

// MARK: - UINavigationControllerDelegate

extension TransitionAnimationViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return CustomPushAnimator(duration: transitionDuration, animationType: currentTransitionType)
        case .pop:
            return CustomPopAnimator(duration: transitionDuration, animationType: currentTransitionType)
        default:
            return nil
        }
    }
}

// MARK: - Custom Dismiss Animator

class CustomDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        switch animationType {
        case .slide:
            animateSlideDismiss(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .fade:
            animateFadeDismiss(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .scale:
            animateScaleDismiss(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .flip:
            animateFlipDismiss(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        }
    }
    
    private func animateSlideDismiss(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.frame = CGRect(x: container.bounds.width, y: 0, width: container.bounds.width, height: container.bounds.height)
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateFadeDismiss(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.alpha = 0
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateScaleDismiss(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            fromVC.view.alpha = 0
        }, completion: { _ in
            fromVC.view.transform = CGAffineTransform.identity
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateFlipDismiss(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        UIView.transition(with: container, duration: duration, options: .transitionFlipFromRight, animations: {
            // 转场动画
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}

// MARK: - Custom Pop Animator

class CustomPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        switch animationType {
        case .slide:
            animateSlideBack(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .fade:
            animateFadeBack(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .scale:
            animateScaleBack(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        case .flip:
            animateFlipBack(from: fromVC, to: toVC, container: containerView, context: transitionContext)
        }
    }
    
    private func animateSlideBack(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        toVC.view.frame = CGRect(x: -container.bounds.width, y: 0, width: container.bounds.width, height: container.bounds.height)
        
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.frame = CGRect(x: container.bounds.width, y: 0, width: container.bounds.width, height: container.bounds.height)
            toVC.view.frame = container.bounds
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateFadeBack(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        toVC.view.frame = container.bounds
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.alpha = 0
            toVC.view.alpha = 1
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateScaleBack(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        toVC.view.frame = container.bounds
        toVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        toVC.view.alpha = 0.5
        
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            fromVC.view.alpha = 0
            toVC.view.transform = CGAffineTransform.identity
            toVC.view.alpha = 1
        }, completion: { _ in
            fromVC.view.transform = CGAffineTransform.identity
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func animateFlipBack(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        UIView.transition(with: container, duration: duration, options: .transitionFlipFromLeft, animations: {
            // 转场动画
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }
}

// MARK: - PushAnimationType Extension

extension PushAnimationType: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        switch rawValue {
        case "slide":
            self = .slide
        case "fade":
            self = .fade
        case "scale":
            self = .scale
        case "flip":
            self = .flip
        default:
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .slide:
            return "slide"
        case .fade:
            return "fade"
        case .scale:
            return "scale"
        case .flip:
            return "flip"
        }
    }
}
