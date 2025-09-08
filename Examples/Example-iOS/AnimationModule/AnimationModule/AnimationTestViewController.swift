//
//  AnimationTestViewController.swift
//  AnimationModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 动画测试页面
class AnimationTestViewController: UIViewController, Routable {
    static func viewController(with parameters: RouterKit.RouterParameters?) -> UIViewController? {
        let viewController = AnimationTestViewController()

        // 根据参数设置不同的动画类型
        if let animationType = parameters?["animationType"] as? String {
            viewController.animationType = animationType
        }

        return viewController
    }

    static func performAction(_ action: String, parameters: RouterKit.RouterParameters?, completion: @escaping RouterKit.RouterCompletion) {
        completion(.success("Action \(action) performed"))
    }

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel()
    private let animationTypeLabel = UILabel()
    private let descriptionLabel = UILabel()

    // 测试区域
    private let testContainerView = UIView()
    private let testView = UIView()

    // 控制按钮
    private let startAnimationButton = UIButton(type: .system)
    private let stopAnimationButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)

    // 动画配置
    private let configStackView = UIStackView()
    private let durationSlider = UISlider()
    private let durationLabel = UILabel()
    private let repeatSwitch = UISwitch()
    private let reverseSwitch = UISwitch()

    // 性能监控
    private let performanceLabel = UILabel()
    private let fpsLabel = UILabel()

    // MARK: - Properties

    var animationType: String = "slide"
    private var isAnimating = false
    private var animationDuration: TimeInterval = 0.35
    private var shouldRepeat = false
    private var shouldReverse = false

    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastTimestamp: CFTimeInterval = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        handleRouteParameters()
        startPerformanceMonitoring()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPerformanceMonitoring()
        stopAnimation()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "动画测试"

        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 配置标题
        titleLabel.text = "动画效果测试"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // 配置动画类型标签
        animationTypeLabel.text = "动画类型: \(getAnimationTypeName())"
        animationTypeLabel.font = .boldSystemFont(ofSize: 18)
        animationTypeLabel.textAlignment = .center
        animationTypeLabel.textColor = .systemBlue
        animationTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animationTypeLabel)

        // 配置描述
        descriptionLabel.text = getAnimationDescription()
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        setupTestArea()
        setupConfigurationControls()
        setupControlButtons()
        setupPerformanceMonitor()
    }

    private func setupTestArea() {
        let testLabel = UILabel()
        testLabel.text = "测试区域"
        testLabel.font = .boldSystemFont(ofSize: 18)
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testLabel)

        testContainerView.backgroundColor = .systemGray6
        testContainerView.layer.cornerRadius = 12
        testContainerView.layer.borderWidth = 1
        testContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        testContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testContainerView)

        testView.backgroundColor = .systemBlue
        testView.layer.cornerRadius = 12
        testView.translatesAutoresizingMaskIntoConstraints = false
        testContainerView.addSubview(testView)

        // 添加测试视图的标签
        let testViewLabel = UILabel()
        testViewLabel.text = "TEST"
        testViewLabel.font = .boldSystemFont(ofSize: 14)
        testViewLabel.textColor = .white
        testViewLabel.textAlignment = .center
        testViewLabel.translatesAutoresizingMaskIntoConstraints = false
        testView.addSubview(testViewLabel)

        NSLayoutConstraint.activate([
            testLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            testLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            testContainerView.topAnchor.constraint(equalTo: testLabel.bottomAnchor, constant: 12),
            testContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testContainerView.heightAnchor.constraint(equalToConstant: 200),

            testView.leadingAnchor.constraint(equalTo: testContainerView.leadingAnchor, constant: 20),
            testView.centerYAnchor.constraint(equalTo: testContainerView.centerYAnchor),
            testView.widthAnchor.constraint(equalToConstant: 60),
            testView.heightAnchor.constraint(equalToConstant: 60),

            testViewLabel.centerXAnchor.constraint(equalTo: testView.centerXAnchor),
            testViewLabel.centerYAnchor.constraint(equalTo: testView.centerYAnchor)
        ])
    }

    private func setupConfigurationControls() {
        let configLabel = UILabel()
        configLabel.text = "动画配置"
        configLabel.font = .boldSystemFont(ofSize: 18)
        configLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(configLabel)

        configStackView.axis = .vertical
        configStackView.spacing = 16
        configStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(configStackView)

        // 持续时间控制
        let durationContainer = UIView()
        let durationTitleLabel = UILabel()
        durationTitleLabel.text = "持续时间"
        durationTitleLabel.font = .systemFont(ofSize: 16)
        durationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        durationContainer.addSubview(durationTitleLabel)

        durationSlider.minimumValue = 0.1
        durationSlider.maximumValue = 3.0
        durationSlider.value = Float(animationDuration)
        durationSlider.translatesAutoresizingMaskIntoConstraints = false
        durationSlider.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
        durationContainer.addSubview(durationSlider)

        durationLabel.text = String(format: "%.2f秒", animationDuration)
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textAlignment = .right
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationContainer.addSubview(durationLabel)

        NSLayoutConstraint.activate([
            durationTitleLabel.leadingAnchor.constraint(equalTo: durationContainer.leadingAnchor),
            durationTitleLabel.centerYAnchor.constraint(equalTo: durationContainer.centerYAnchor),
            durationTitleLabel.widthAnchor.constraint(equalToConstant: 80),

            durationSlider.leadingAnchor.constraint(equalTo: durationTitleLabel.trailingAnchor, constant: 12),
            durationSlider.centerYAnchor.constraint(equalTo: durationContainer.centerYAnchor),
            durationSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -12),

            durationLabel.trailingAnchor.constraint(equalTo: durationContainer.trailingAnchor),
            durationLabel.centerYAnchor.constraint(equalTo: durationContainer.centerYAnchor),
            durationLabel.widthAnchor.constraint(equalToConstant: 60),

            durationContainer.heightAnchor.constraint(equalToConstant: 44)
        ])

        // 重复开关
        let repeatContainer = UIView()
        let repeatTitleLabel = UILabel()
        repeatTitleLabel.text = "重复播放"
        repeatTitleLabel.font = .systemFont(ofSize: 16)
        repeatTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        repeatContainer.addSubview(repeatTitleLabel)

        repeatSwitch.isOn = shouldRepeat
        repeatSwitch.translatesAutoresizingMaskIntoConstraints = false
        repeatSwitch.addTarget(self, action: #selector(repeatSwitchChanged), for: .valueChanged)
        repeatContainer.addSubview(repeatSwitch)

        NSLayoutConstraint.activate([
            repeatTitleLabel.leadingAnchor.constraint(equalTo: repeatContainer.leadingAnchor),
            repeatTitleLabel.centerYAnchor.constraint(equalTo: repeatContainer.centerYAnchor),

            repeatSwitch.trailingAnchor.constraint(equalTo: repeatContainer.trailingAnchor),
            repeatSwitch.centerYAnchor.constraint(equalTo: repeatContainer.centerYAnchor),

            repeatContainer.heightAnchor.constraint(equalToConstant: 44)
        ])

        // 反向开关
        let reverseContainer = UIView()
        let reverseTitleLabel = UILabel()
        reverseTitleLabel.text = "反向播放"
        reverseTitleLabel.font = .systemFont(ofSize: 16)
        reverseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        reverseContainer.addSubview(reverseTitleLabel)

        reverseSwitch.isOn = shouldReverse
        reverseSwitch.translatesAutoresizingMaskIntoConstraints = false
        reverseSwitch.addTarget(self, action: #selector(reverseSwitchChanged), for: .valueChanged)
        reverseContainer.addSubview(reverseSwitch)

        NSLayoutConstraint.activate([
            reverseTitleLabel.leadingAnchor.constraint(equalTo: reverseContainer.leadingAnchor),
            reverseTitleLabel.centerYAnchor.constraint(equalTo: reverseContainer.centerYAnchor),

            reverseSwitch.trailingAnchor.constraint(equalTo: reverseContainer.trailingAnchor),
            reverseSwitch.centerYAnchor.constraint(equalTo: reverseContainer.centerYAnchor),

            reverseContainer.heightAnchor.constraint(equalToConstant: 44)
        ])

        configStackView.addArrangedSubview(durationContainer)
        configStackView.addArrangedSubview(repeatContainer)
        configStackView.addArrangedSubview(reverseContainer)

        NSLayoutConstraint.activate([
            configLabel.topAnchor.constraint(equalTo: testContainerView.bottomAnchor, constant: 30),
            configLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            configLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            configStackView.topAnchor.constraint(equalTo: configLabel.bottomAnchor, constant: 12),
            configStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            configStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupControlButtons() {
        let controlLabel = UILabel()
        controlLabel.text = "控制按钮"
        controlLabel.font = .boldSystemFont(ofSize: 18)
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(controlLabel)

        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStackView)

        // 开始动画按钮
        startAnimationButton.setTitle("开始动画", for: .normal)
        startAnimationButton.backgroundColor = .systemGreen
        startAnimationButton.setTitleColor(.white, for: .normal)
        startAnimationButton.layer.cornerRadius = 8
        startAnimationButton.translatesAutoresizingMaskIntoConstraints = false
        startAnimationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // 停止动画按钮
        stopAnimationButton.setTitle("停止动画", for: .normal)
        stopAnimationButton.backgroundColor = .systemRed
        stopAnimationButton.setTitleColor(.white, for: .normal)
        stopAnimationButton.layer.cornerRadius = 8
        stopAnimationButton.translatesAutoresizingMaskIntoConstraints = false
        stopAnimationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stopAnimationButton.isEnabled = false

        // 重置按钮
        resetButton.setTitle("重置", for: .normal)
        resetButton.backgroundColor = .systemOrange
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // 返回按钮
        backButton.setTitle("返回", for: .normal)
        backButton.backgroundColor = .systemGray
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 8
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        buttonStackView.addArrangedSubview(startAnimationButton)
        buttonStackView.addArrangedSubview(stopAnimationButton)
        buttonStackView.addArrangedSubview(resetButton)
        buttonStackView.addArrangedSubview(backButton)

        NSLayoutConstraint.activate([
            controlLabel.topAnchor.constraint(equalTo: configStackView.bottomAnchor, constant: 30),
            controlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            controlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            buttonStackView.topAnchor.constraint(equalTo: controlLabel.bottomAnchor, constant: 12),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupPerformanceMonitor() {
        let performanceLabel = UILabel()
        performanceLabel.text = "性能监控"
        performanceLabel.font = .boldSystemFont(ofSize: 18)
        performanceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(performanceLabel)

        let performanceStackView = UIStackView()
        performanceStackView.axis = .vertical
        performanceStackView.spacing = 8
        performanceStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(performanceStackView)

        self.performanceLabel.text = "CPU使用率: 0%"
        self.performanceLabel.font = .systemFont(ofSize: 14)
        self.performanceLabel.textColor = .secondaryLabel
        self.performanceLabel.translatesAutoresizingMaskIntoConstraints = false

        fpsLabel.text = "FPS: 60"
        fpsLabel.font = .systemFont(ofSize: 14)
        fpsLabel.textColor = .secondaryLabel
        fpsLabel.translatesAutoresizingMaskIntoConstraints = false

        performanceStackView.addArrangedSubview(self.performanceLabel)
        performanceStackView.addArrangedSubview(fpsLabel)

        NSLayoutConstraint.activate([
            performanceLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 30),
            performanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            performanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            performanceStackView.topAnchor.constraint(equalTo: performanceLabel.bottomAnchor, constant: 12),
            performanceStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            performanceStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            performanceStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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

            // 动画类型标签约束
            animationTypeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            animationTypeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            animationTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 描述约束
            descriptionLabel.topAnchor.constraint(equalTo: animationTypeLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        startAnimationButton.addTarget(self, action: #selector(startAnimationTapped), for: .touchUpInside)
        stopAnimationButton.addTarget(self, action: #selector(stopAnimationTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    private func handleRouteParameters() {
        // 处理路由参数 - Router没有currentContext属性，这里移除相关代码
        // 如果需要处理路由参数，应该在viewController(with:)方法中处理
        // 暂时设置默认行为
    }

    // MARK: - Helper Methods

    private func getAnimationTypeName() -> String {
        switch animationType {
        case "slide":
            return "滑动动画"
        case "fade":
            return "淡入淡出"
        case "scale":
            return "缩放动画"
        case "flip":
            return "翻转动画"
        case "bounce":
            return "弹跳动画"
        case "swing":
            return "摇摆动画"
        case "pulse":
            return "脉冲动画"
        default:
            return "未知动画"
        }
    }

    private func getAnimationDescription() -> String {
        switch animationType {
        case "slide":
            return "测试视图将从左侧滑动到右侧，展示平滑的位移动画效果。"
        case "fade":
            return "测试视图将逐渐淡出然后淡入，展示透明度变化的动画效果。"
        case "scale":
            return "测试视图将放大缩小，展示尺寸变化的动画效果。"
        case "flip":
            return "测试视图将进行翻转，展示3D变换的动画效果。"
        case "bounce":
            return "测试视图将进行弹跳运动，展示弹性动画效果。"
        case "swing":
            return "测试视图将左右摇摆，展示旋转动画效果。"
        case "pulse":
            return "测试视图将进行脉冲变化，展示周期性动画效果。"
        default:
            return "测试各种动画效果的性能和视觉表现。"
        }
    }

    // MARK: - Animation Methods

    private func performAnimation() {
        guard !isAnimating else { return }

        isAnimating = true
        startAnimationButton.isEnabled = false
        stopAnimationButton.isEnabled = true

        switch animationType {
        case "slide":
            performSlideAnimation()
        case "fade":
            performFadeAnimation()
        case "scale":
            performScaleAnimation()
        case "flip":
            performFlipAnimation()
        case "bounce":
            performBounceAnimation()
        case "swing":
            performSwingAnimation()
        case "pulse":
            performPulseAnimation()
        default:
            performSlideAnimation()
        }
    }

    private func performSlideAnimation() {
        let originalCenter = testView.center
        let targetCenter = CGPoint(x: testContainerView.bounds.width - 80, y: originalCenter.y)

        let animation = {
            self.testView.center = targetCenter
        }

        let completion: (Bool) -> Void = { _ in
            if self.shouldReverse {
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.testView.center = originalCenter
                }, completion: { _ in
                    if self.shouldRepeat && self.isAnimating {
                        self.performSlideAnimation()
                    } else {
                        self.animationCompleted()
                    }
                })
            } else if self.shouldRepeat && self.isAnimating {
                self.testView.center = originalCenter
                self.performSlideAnimation()
            } else {
                self.animationCompleted()
            }
        }

        UIView.animate(withDuration: animationDuration, animations: animation, completion: completion)
    }

    private func performFadeAnimation() {
        let animation = {
            self.testView.alpha = 0.1
        }

        let completion: (Bool) -> Void = { _ in
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.testView.alpha = 1.0
            }, completion: { _ in
                if self.shouldRepeat && self.isAnimating {
                    self.performFadeAnimation()
                } else {
                    self.animationCompleted()
                }
            })
        }

        UIView.animate(withDuration: animationDuration, animations: animation, completion: completion)
    }

    private func performScaleAnimation() {
        let animation = {
            self.testView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }

        let completion: (Bool) -> Void = { _ in
            if self.shouldReverse {
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.testView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }, completion: { _ in
                    UIView.animate(withDuration: self.animationDuration, animations: {
                        self.testView.transform = CGAffineTransform.identity
                    }, completion: { _ in
                        if self.shouldRepeat && self.isAnimating {
                            self.performScaleAnimation()
                        } else {
                            self.animationCompleted()
                        }
                    })
                })
            } else {
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.testView.transform = CGAffineTransform.identity
                }, completion: { _ in
                    if self.shouldRepeat && self.isAnimating {
                        self.performScaleAnimation()
                    } else {
                        self.animationCompleted()
                    }
                })
            }
        }

        UIView.animate(withDuration: animationDuration, animations: animation, completion: completion)
    }

    private func performFlipAnimation() {
        UIView.transition(with: testView, duration: animationDuration, options: .transitionFlipFromLeft, animations: {
            self.testView.backgroundColor = .systemRed
        }, completion: { _ in
            if self.shouldReverse {
                UIView.transition(with: self.testView, duration: self.animationDuration, options: .transitionFlipFromRight, animations: {
                    self.testView.backgroundColor = .systemBlue
                }, completion: { _ in
                    if self.shouldRepeat && self.isAnimating {
                        self.performFlipAnimation()
                    } else {
                        self.animationCompleted()
                    }
                })
            } else if self.shouldRepeat && self.isAnimating {
                self.testView.backgroundColor = .systemBlue
                self.performFlipAnimation()
            } else {
                self.animationCompleted()
            }
        })
    }

    private func performBounceAnimation() {
        let originalCenter = testView.center
        let bounceHeight: CGFloat = 50

        UIView.animate(withDuration: animationDuration / 2, animations: {
            self.testView.center = CGPoint(x: originalCenter.x, y: originalCenter.y - bounceHeight)
        }, completion: { _ in
            UIView.animate(withDuration: self.animationDuration / 2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8, options: [], animations: {
                self.testView.center = originalCenter
            }, completion: { _ in
                if self.shouldRepeat && self.isAnimating {
                    self.performBounceAnimation()
                } else {
                    self.animationCompleted()
                }
            })
        })
    }

    private func performSwingAnimation() {
        let animation = {
            self.testView.transform = CGAffineTransform(rotationAngle: .pi / 6)
        }

        let completion: (Bool) -> Void = { _ in
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.testView.transform = CGAffineTransform(rotationAngle: -.pi / 6)
            }, completion: { _ in
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.testView.transform = CGAffineTransform.identity
                }, completion: { _ in
                    if self.shouldRepeat && self.isAnimating {
                        self.performSwingAnimation()
                    } else {
                        self.animationCompleted()
                    }
                })
            })
        }

        UIView.animate(withDuration: animationDuration, animations: animation, completion: completion)
    }

    private func performPulseAnimation() {
        let animation = {
            self.testView.alpha = 0.3
            self.testView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }

        let completion: (Bool) -> Void = { _ in
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.testView.alpha = 1.0
                self.testView.transform = CGAffineTransform.identity
            }, completion: { _ in
                if self.shouldRepeat && self.isAnimating {
                    self.performPulseAnimation()
                } else {
                    self.animationCompleted()
                }
            })
        }

        UIView.animate(withDuration: animationDuration, animations: animation, completion: completion)
    }

    private func stopAnimation() {
        isAnimating = false
        testView.layer.removeAllAnimations()
        startAnimationButton.isEnabled = true
        stopAnimationButton.isEnabled = false
    }

    private func resetTestView() {
        stopAnimation()
        testView.center = CGPoint(x: 50, y: testContainerView.bounds.height / 2)
        testView.transform = CGAffineTransform.identity
        testView.alpha = 1.0
        testView.backgroundColor = .systemBlue
    }

    private func animationCompleted() {
        isAnimating = false
        startAnimationButton.isEnabled = true
        stopAnimationButton.isEnabled = false
    }

    // MARK: - Performance Monitoring

    private func startPerformanceMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(updatePerformanceMetrics))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopPerformanceMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updatePerformanceMetrics() {
        guard let displayLink = displayLink else { return }

        let currentTime = displayLink.timestamp
        if lastTimestamp > 0 {
            let deltaTime = currentTime - lastTimestamp
            let fps = 1.0 / deltaTime

            DispatchQueue.main.async {
                self.fpsLabel.text = String(format: "FPS: %.1f", fps)

                // 简单的CPU使用率模拟（实际应用中需要使用系统API）
                let cpuUsage = self.isAnimating ? Double.random(in: 10...30) : Double.random(in: 1...5)
                self.performanceLabel.text = String(format: "CPU使用率: %.1f%%", cpuUsage)
            }
        }

        lastTimestamp = currentTime
        frameCount += 1
    }

    // MARK: - Action Methods

    @objc private func durationChanged() {
        animationDuration = TimeInterval(durationSlider.value)
        durationLabel.text = String(format: "%.2f秒", animationDuration)
    }

    @objc private func repeatSwitchChanged() {
        shouldRepeat = repeatSwitch.isOn
    }

    @objc private func reverseSwitchChanged() {
        shouldReverse = reverseSwitch.isOn
    }

    @objc private func startAnimationTapped() {
        performAnimation()
    }

    @objc private func stopAnimationTapped() {
        stopAnimation()
    }

    @objc private func resetTapped() {
        resetTestView()
    }

    @objc private func backTapped() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
