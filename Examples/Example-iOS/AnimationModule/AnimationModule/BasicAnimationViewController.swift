//
//  BasicAnimationViewController.swift
//  AnimationModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 基础动画示例页面
class BasicAnimationViewController: UIViewController, Routable {
    static func viewController(with parameters: RouterKit.RouterParameters?) -> UIViewController? {
        return BasicAnimationViewController()
    }

    static func performAction(_ action: String, parameters: RouterKit.RouterParameters?, completion: @escaping RouterKit.RouterCompletion) {
        completion(.success("Action \(action) performed"))
    }

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    // 动画演示视图
    private let animationContainerView = UIView()
    private let animationView = UIView()

    // 控制按钮
    private let fadeInButton = UIButton(type: .system)
    private let fadeOutButton = UIButton(type: .system)
    private let scaleButton = UIButton(type: .system)
    private let slideButton = UIButton(type: .system)
    private let rotateButton = UIButton(type: .system)
    private let bounceButton = UIButton(type: .system)
    private let shakeButton = UIButton(type: .system)
    private let pulseButton = UIButton(type: .system)

    // 配置控件
    private let durationSlider = UISlider()
    private let durationLabel = UILabel()
    private let easingSegmentedControl = UISegmentedControl(items: ["EaseIn", "EaseOut", "EaseInOut", "Linear"])

    // 重置按钮
    private let resetButton = UIButton(type: .system)

    // MARK: - Properties

    private var currentDuration: TimeInterval = 0.35
    private var currentEasing: UIView.AnimationOptions = .curveEaseInOut

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
        title = "基础动画"

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
        titleLabel.text = "基础动画效果演示"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // 配置描述
        descriptionLabel.text = "体验各种基础动画效果，包括淡入淡出、缩放、滑动、旋转等。可以调整动画持续时间和缓动函数。"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        // 配置动画容器
        animationContainerView.backgroundColor = .systemGray6
        animationContainerView.layer.cornerRadius = 12
        animationContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animationContainerView)

        // 配置动画视图
        animationView.backgroundColor = .systemBlue
        animationView.layer.cornerRadius = 25
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationContainerView.addSubview(animationView)

        // 配置持续时间控件
        let durationTitleLabel = UILabel()
        durationTitleLabel.text = "动画持续时间"
        durationTitleLabel.font = .boldSystemFont(ofSize: 18)
        durationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(durationTitleLabel)

        durationSlider.minimumValue = 0.1
        durationSlider.maximumValue = 2.0
        durationSlider.value = Float(currentDuration)
        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
        contentView.addSubview(durationSlider)

        durationLabel.text = String(format: "%.2f秒", currentDuration)
        durationLabel.font = .systemFont(ofSize: 16)
        durationLabel.textAlignment = .center
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(durationLabel)

        // 配置缓动函数控件
        let easingTitleLabel = UILabel()
        easingTitleLabel.text = "缓动函数"
        easingTitleLabel.font = .boldSystemFont(ofSize: 18)
        easingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(easingTitleLabel)

        easingSegmentedControl.selectedSegmentIndex = 2 // EaseInOut
        easingSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        easingSegmentedControl.addTarget(self, action: #selector(easingChanged), for: .valueChanged)
        contentView.addSubview(easingSegmentedControl)

        // 配置动画按钮
        let animationTitleLabel = UILabel()
        animationTitleLabel.text = "动画效果"
        animationTitleLabel.font = .boldSystemFont(ofSize: 18)
        animationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animationTitleLabel)

        setupAnimationButtons()

        // 配置重置按钮
        resetButton.setTitle("重置动画视图", for: .normal)
        resetButton.backgroundColor = .systemRed
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetButton)

        // 添加约束
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
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 动画容器约束
            animationContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            animationContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            animationContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            animationContainerView.heightAnchor.constraint(equalToConstant: 200),

            // 动画视图约束
            animationView.centerXAnchor.constraint(equalTo: animationContainerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: animationContainerView.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 50),
            animationView.heightAnchor.constraint(equalToConstant: 50),

            // 持续时间控件约束
            durationTitleLabel.topAnchor.constraint(equalTo: animationContainerView.bottomAnchor, constant: 30),
            durationTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            durationTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            durationSlider.topAnchor.constraint(equalTo: durationTitleLabel.bottomAnchor, constant: 12),
            durationSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            durationSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            durationLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 8),
            durationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // 缓动函数控件约束
            easingTitleLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 20),
            easingTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            easingTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            easingSegmentedControl.topAnchor.constraint(equalTo: easingTitleLabel.bottomAnchor, constant: 12),
            easingSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            easingSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 动画按钮标题约束
            animationTitleLabel.topAnchor.constraint(equalTo: easingSegmentedControl.bottomAnchor, constant: 30),
            animationTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            animationTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupAnimationButtons() {
        let buttons = [
            (fadeInButton, "淡入", #selector(fadeInTapped)),
            (fadeOutButton, "淡出", #selector(fadeOutTapped)),
            (scaleButton, "缩放", #selector(scaleTapped)),
            (slideButton, "滑动", #selector(slideTapped)),
            (rotateButton, "旋转", #selector(rotateTapped)),
            (bounceButton, "弹跳", #selector(bounceTapped)),
            (shakeButton, "摇摆", #selector(shakeTapped)),
            (pulseButton, "脉冲", #selector(pulseTapped))
        ]

        for (button, title, action) in buttons {
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: action, for: .touchUpInside)
            contentView.addSubview(button)
        }
    }

    private func setupConstraints() {
        let buttonStackView1 = UIStackView(arrangedSubviews: [fadeInButton, fadeOutButton, scaleButton, slideButton])
        buttonStackView1.axis = .horizontal
        buttonStackView1.distribution = .fillEqually
        buttonStackView1.spacing = 12
        buttonStackView1.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStackView1)

        let buttonStackView2 = UIStackView(arrangedSubviews: [rotateButton, bounceButton, shakeButton, pulseButton])
        buttonStackView2.axis = .horizontal
        buttonStackView2.distribution = .fillEqually
        buttonStackView2.spacing = 12
        buttonStackView2.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStackView2)

        // 移除之前添加的按钮
        [fadeInButton, fadeOutButton, scaleButton, slideButton, rotateButton, bounceButton, shakeButton, pulseButton].forEach { $0.removeFromSuperview() }

        NSLayoutConstraint.activate([
            // 按钮组约束
            buttonStackView1.topAnchor.constraint(equalTo: contentView.subviews.last!.bottomAnchor, constant: 12),
            buttonStackView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView1.heightAnchor.constraint(equalToConstant: 44),

            buttonStackView2.topAnchor.constraint(equalTo: buttonStackView1.bottomAnchor, constant: 12),
            buttonStackView2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView2.heightAnchor.constraint(equalToConstant: 44),

            // 重置按钮约束
            resetButton.topAnchor.constraint(equalTo: buttonStackView2.bottomAnchor, constant: 30),
            resetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            resetButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
    }

    private func handleRouteParameters() {
        // 处理路由参数
//        if let context = Router.shared.currentContext {
//            if let autoPlay = context.parameters["autoPlay"] as? Bool, autoPlay {
//                // 自动播放动画演示
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    self.playAnimationSequence()
//                }
//            }
//        }
        // 处理路由参数 - Router没有currentContext属性，这里移除相关代码
        // 如果需要处理路由参数，应该在viewController(with:)方法中处理
    }

    // MARK: - Animation Methods

    private func playAnimationSequence() {
        let animations: [() -> Void] = [
            fadeInTapped, { DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.scaleTapped() } }, { DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self.rotateTapped() } }, { DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { self.bounceTapped() } }, { DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { self.resetTapped() } }
        ]

        for (index, animation) in animations.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(index)) {
                animation()
            }
        }
    }

    // MARK: - Action Methods

    @objc private func backButtonTapped() {
        Router.pop()
    }

    @objc private func durationChanged() {
        currentDuration = TimeInterval(durationSlider.value)
        durationLabel.text = String(format: "%.2f秒", currentDuration)
    }

    @objc private func easingChanged() {
        switch easingSegmentedControl.selectedSegmentIndex {
        case 0:
            currentEasing = .curveEaseIn
        case 1:
            currentEasing = .curveEaseOut
        case 2:
            currentEasing = .curveEaseInOut
        case 3:
            currentEasing = .curveLinear
        default:
            currentEasing = .curveEaseInOut
        }
    }

    @objc private func fadeInTapped() {
        animationView.alpha = 0
        UIView.animate(withDuration: currentDuration, delay: 0, options: currentEasing, animations: {
            self.animationView.alpha = 1
        })
    }

    @objc private func fadeOutTapped() {
        UIView.animate(withDuration: currentDuration, delay: 0, options: currentEasing, animations: {
            self.animationView.alpha = 0
        })
    }

    @objc private func scaleTapped() {
        animationView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: currentDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: currentEasing, animations: {
            self.animationView.transform = CGAffineTransform.identity
        })
    }

    @objc private func slideTapped() {
        let originalCenter = animationView.center
        animationView.center = CGPoint(x: originalCenter.x - 100, y: originalCenter.y)

        UIView.animate(withDuration: currentDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: currentEasing, animations: {
            self.animationView.center = originalCenter
        })
    }

    @objc private func rotateTapped() {
        UIView.animate(withDuration: currentDuration, delay: 0, options: currentEasing, animations: {
            self.animationView.transform = CGAffineTransform(rotationAngle: .pi * 2)
        }, completion: { _ in
            self.animationView.transform = CGAffineTransform.identity
        })
    }

    @objc private func bounceTapped() {
        AnimationManager.shared.bounce(view: animationView)
    }

    @objc private func shakeTapped() {
        AnimationManager.shared.shake(view: animationView)
    }

    @objc private func pulseTapped() {
        AnimationManager.shared.pulse(view: animationView)
    }

    @objc private func resetTapped() {
        animationView.layer.removeAllAnimations()
        animationView.transform = CGAffineTransform.identity
        animationView.alpha = 1
        animationView.center = CGPoint(x: animationContainerView.bounds.midX, y: animationContainerView.bounds.midY)
    }
}
