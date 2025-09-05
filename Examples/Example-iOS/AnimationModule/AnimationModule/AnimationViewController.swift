//
//  AnimationViewController.swift
//  AnimationModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 动画示例主页面
class AnimationViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return AnimationViewController()
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "setAnimationSpeed":
            if let speed = parameters?["speed"] as? Double {
                AnimationManager.shared.setGlobalAnimationSpeed(speed)
                completion(.success("动画速度已设置为 \(speed)"))
            } else {
                completion(.failure(RouterError.parameterError("Invalid speed parameter")))
            }
        case "toggleAnimations":
            if let enabled = parameters?["enabled"] as? Bool {
                // 设置动画开关状态
                completion(.success(enabled ? "动画已启用" : "动画已禁用"))
            } else {
                completion(.failure(RouterError.parameterError("Invalid enabled parameter")))
            }
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // 示例部分
    private var exampleSections: [ExampleSection] = []
    
    // 统计信息
    private let statsContainerView = UIView()
    private let totalAnimationsLabel = UILabel()
    private let performanceLabel = UILabel()
    
    // 全局控制
    private let globalControlsView = UIView()
    private let enableAnimationsSwitch = UISwitch()
    private let animationSpeedSlider = UISlider()
    private let speedLabel = UILabel()
    
    // MARK: - Properties
    
    private var animationCount = 0
    private var totalAnimationTime: TimeInterval = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupExampleSections()
        setupConstraints()
        handleRouteParameters()
        updateStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "动画示例"
        
        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 配置标题
        titleLabel.text = "RouterKit 动画效果演示"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 配置描述
        descriptionLabel.text = "探索各种动画效果，包括基础动画、自定义转场、交互式动画、3D效果等。体验流畅的用户界面动画。"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // 配置统计信息容器
        statsContainerView.backgroundColor = .systemGray6
        statsContainerView.layer.cornerRadius = 12
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsContainerView)
        
        setupStatsView()
        setupGlobalControls()
    }
    
    private func setupStatsView() {
        let statsTitle = UILabel()
        statsTitle.text = "动画统计"
        statsTitle.font = .boldSystemFont(ofSize: 18)
        statsTitle.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(statsTitle)
        
        totalAnimationsLabel.text = "总动画次数: 0"
        totalAnimationsLabel.font = .systemFont(ofSize: 16)
        totalAnimationsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(totalAnimationsLabel)
        
        performanceLabel.text = "平均动画时长: 0.00s"
        performanceLabel.font = .systemFont(ofSize: 16)
        performanceLabel.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(performanceLabel)
        
        let resetStatsButton = UIButton(type: .system)
        resetStatsButton.setTitle("重置统计", for: .normal)
        resetStatsButton.backgroundColor = .systemOrange
        resetStatsButton.setTitleColor(.white, for: .normal)
        resetStatsButton.layer.cornerRadius = 6
        resetStatsButton.translatesAutoresizingMaskIntoConstraints = false
        resetStatsButton.addTarget(self, action: #selector(resetStatsTapped), for: .touchUpInside)
        statsContainerView.addSubview(resetStatsButton)
        
        NSLayoutConstraint.activate([
            statsTitle.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 16),
            statsTitle.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 16),
            statsTitle.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -16),
            
            totalAnimationsLabel.topAnchor.constraint(equalTo: statsTitle.bottomAnchor, constant: 12),
            totalAnimationsLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 16),
            totalAnimationsLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -16),
            
            performanceLabel.topAnchor.constraint(equalTo: totalAnimationsLabel.bottomAnchor, constant: 8),
            performanceLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 16),
            performanceLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -16),
            
            resetStatsButton.topAnchor.constraint(equalTo: performanceLabel.bottomAnchor, constant: 12),
            resetStatsButton.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -16),
            resetStatsButton.widthAnchor.constraint(equalToConstant: 80),
            resetStatsButton.heightAnchor.constraint(equalToConstant: 32),
            resetStatsButton.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupGlobalControls() {
        globalControlsView.backgroundColor = .systemGray6
        globalControlsView.layer.cornerRadius = 12
        globalControlsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(globalControlsView)
        
        let controlsTitle = UILabel()
        controlsTitle.text = "全局动画控制"
        controlsTitle.font = .boldSystemFont(ofSize: 18)
        controlsTitle.translatesAutoresizingMaskIntoConstraints = false
        globalControlsView.addSubview(controlsTitle)
        
        let enableLabel = UILabel()
        enableLabel.text = "启用动画"
        enableLabel.font = .systemFont(ofSize: 16)
        enableLabel.translatesAutoresizingMaskIntoConstraints = false
        globalControlsView.addSubview(enableLabel)
        
        enableAnimationsSwitch.isOn = true
        enableAnimationsSwitch.translatesAutoresizingMaskIntoConstraints = false
        enableAnimationsSwitch.addTarget(self, action: #selector(animationsToggled), for: .valueChanged)
        globalControlsView.addSubview(enableAnimationsSwitch)
        
        let speedTitleLabel = UILabel()
        speedTitleLabel.text = "动画速度"
        speedTitleLabel.font = .systemFont(ofSize: 16)
        speedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        globalControlsView.addSubview(speedTitleLabel)
        
        animationSpeedSlider.minimumValue = 0.5
        animationSpeedSlider.maximumValue = 2.0
        animationSpeedSlider.value = 1.0
        animationSpeedSlider.translatesAutoresizingMaskIntoConstraints = false
        animationSpeedSlider.addTarget(self, action: #selector(speedChanged), for: .valueChanged)
        globalControlsView.addSubview(animationSpeedSlider)
        
        speedLabel.text = "1.0x"
        speedLabel.font = .systemFont(ofSize: 16)
        speedLabel.textAlignment = .center
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        globalControlsView.addSubview(speedLabel)
        
        NSLayoutConstraint.activate([
            controlsTitle.topAnchor.constraint(equalTo: globalControlsView.topAnchor, constant: 16),
            controlsTitle.leadingAnchor.constraint(equalTo: globalControlsView.leadingAnchor, constant: 16),
            controlsTitle.trailingAnchor.constraint(equalTo: globalControlsView.trailingAnchor, constant: -16),
            
            enableLabel.topAnchor.constraint(equalTo: controlsTitle.bottomAnchor, constant: 16),
            enableLabel.leadingAnchor.constraint(equalTo: globalControlsView.leadingAnchor, constant: 16),
            
            enableAnimationsSwitch.centerYAnchor.constraint(equalTo: enableLabel.centerYAnchor),
            enableAnimationsSwitch.trailingAnchor.constraint(equalTo: globalControlsView.trailingAnchor, constant: -16),
            
            speedTitleLabel.topAnchor.constraint(equalTo: enableLabel.bottomAnchor, constant: 16),
            speedTitleLabel.leadingAnchor.constraint(equalTo: globalControlsView.leadingAnchor, constant: 16),
            speedTitleLabel.trailingAnchor.constraint(equalTo: globalControlsView.trailingAnchor, constant: -16),
            
            animationSpeedSlider.topAnchor.constraint(equalTo: speedTitleLabel.bottomAnchor, constant: 8),
            animationSpeedSlider.leadingAnchor.constraint(equalTo: globalControlsView.leadingAnchor, constant: 16),
            animationSpeedSlider.trailingAnchor.constraint(equalTo: globalControlsView.trailingAnchor, constant: -16),
            
            speedLabel.topAnchor.constraint(equalTo: animationSpeedSlider.bottomAnchor, constant: 8),
            speedLabel.centerXAnchor.constraint(equalTo: globalControlsView.centerXAnchor),
            speedLabel.bottomAnchor.constraint(equalTo: globalControlsView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupExampleSections() {
        exampleSections = [
            ExampleSection(
                title: "基础动画",
                description: "淡入淡出、缩放、滑动、旋转等基础动画效果",
                examples: [
                    ExampleItem(title: "基础动画演示", description: "体验各种基础动画效果", route: "/AnimationModule/basic", color: .systemBlue),
                    ExampleItem(title: "自动播放演示", description: "自动播放动画序列", route: "/AnimationModule/basic?autoPlay=true", color: .systemIndigo)
                ]
            ),
            ExampleSection(
                title: "转场动画",
                description: "页面间的自定义转场动画效果",
                examples: [
                    ExampleItem(title: "自定义转场", description: "滑动、淡入、缩放、翻转转场", route: "/AnimationModule/transition", color: .systemGreen),
                    ExampleItem(title: "交互式转场", description: "手势驱动的交互式转场", route: "/AnimationModule/interactive", color: .systemTeal)
                ]
            ),
            ExampleSection(
                title: "高级动画",
                description: "3D变换、弹簧动画、关键帧动画等高级效果",
                examples: [
                    ExampleItem(title: "3D动画", description: "立体变换和透视效果", route: "/AnimationModule/3d", color: .systemPurple),
                    ExampleItem(title: "弹簧动画", description: "物理弹簧动画效果", route: "/AnimationModule/spring", color: .systemPink),
                    ExampleItem(title: "关键帧动画", description: "复杂的关键帧动画序列", route: "/AnimationModule/keyframe", color: .systemOrange)
                ]
            ),
            ExampleSection(
                title: "特效动画",
                description: "粒子效果、动画链、性能优化等特殊动画",
                examples: [
                    ExampleItem(title: "粒子动画", description: "粒子系统和特效动画", route: "/AnimationModule/particle", color: .systemRed),
                    ExampleItem(title: "动画链", description: "连续动画和动画组合", route: "/AnimationModule/chain", color: .systemYellow),
                    ExampleItem(title: "性能优化", description: "高性能动画技巧", route: "/AnimationModule/performance", color: .systemGray)
                ]
            )
        ]
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
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 统计信息约束
            statsContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            statsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 全局控制约束
            globalControlsView.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 20),
            globalControlsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            globalControlsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        setupExampleSectionViews()
    }
    
    private func setupExampleSectionViews() {
        var previousView: UIView = globalControlsView
        
        for section in exampleSections {
            let sectionView = createSectionView(for: section)
            contentView.addSubview(sectionView)
            
            NSLayoutConstraint.activate([
                sectionView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 30),
                sectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                sectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
            
            previousView = sectionView
        }
        
        // 设置最后一个视图的底部约束
        previousView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
    }
    
    private func createSectionView(for section: ExampleSection) -> UIView {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = section.title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = section.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionView.addSubview(descriptionLabel)
        
        var previousButton: UIView = descriptionLabel
        
        for example in section.examples {
            let button = createExampleButton(for: example)
            sectionView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: previousButton.bottomAnchor, constant: 12),
                button.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
                button.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            previousButton = button
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            
            previousButton.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor)
        ])
        
        return sectionView
    }
    
    private func createExampleButton(for example: ExampleItem) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = example.color
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = example.title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = example.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .white
        descriptionLabel.alpha = 0.8
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -12)
        ])
        
        button.addTarget(self, action: #selector(exampleButtonTapped(_:)), for: .touchUpInside)
        button.tag = exampleSections.flatMap { $0.examples }.firstIndex { $0.route == example.route } ?? 0
        
        return button
    }
    
    private func handleRouteParameters() {
        // 处理路由参数 - Router没有currentContext属性，这里移除相关代码
        // 如果需要处理路由参数，应该在viewController(with:)方法中处理
        // 暂时设置默认行为
    }
    
    private func scrollToSection(_ sectionName: String) {
        // 实现滚动到指定部分的逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 这里可以添加滚动逻辑
        }
    }
    
    private func updateStats() {
        totalAnimationsLabel.text = "总动画次数: \(animationCount)"
        let averageTime = animationCount > 0 ? totalAnimationTime / Double(animationCount) : 0
        performanceLabel.text = String(format: "平均动画时长: %.2fs", averageTime)
    }
    
    // MARK: - Action Methods
    
    @objc private func exampleButtonTapped(_ sender: UIButton) {
        let allExamples = exampleSections.flatMap { $0.examples }
        guard sender.tag < allExamples.count else { return }
        
        let example = allExamples[sender.tag]
        
        // 记录动画统计
        animationCount += 1
        totalAnimationTime += 0.35 // 假设平均动画时长
        updateStats()
        
        // 导航到示例页面
        Router.shared.navigate(to: example.route) { result in
            switch result {
            case .success:
                print("导航成功: \(example.route)")
            case .failure(let error):
                print("导航失败: \(example.route), 错误: \(error)")
            }
        }
    }
    
    @objc private func resetStatsTapped() {
        animationCount = 0
        totalAnimationTime = 0
        updateStats()
    }
    
    @objc private func animationsToggled() {
        UIView.setAnimationsEnabled(enableAnimationsSwitch.isOn)
    }
    
    @objc private func speedChanged() {
        let speed = animationSpeedSlider.value
        speedLabel.text = String(format: "%.1fx", speed)
        
        // 设置全局动画速度（这是一个概念性的实现）
        // 在实际应用中，你需要在动画管理器中实现这个功能
        AnimationManager.shared.setGlobalAnimationSpeed(Double(speed))
    }
}

// MARK: - Data Models

struct ExampleSection {
    let title: String
    let description: String
    let examples: [ExampleItem]
}

struct ExampleItem {
    let title: String
    let description: String
    let route: String
    let color: UIColor
}

// MARK: - AnimationManager Extension

extension AnimationManager {
    private static var globalAnimationSpeed: Double = 1.0
    
    func setGlobalAnimationSpeed(_ speed: Double) {
        AnimationManager.globalAnimationSpeed = speed
    }
    
    func getGlobalAnimationSpeed() -> Double {
        return AnimationManager.globalAnimationSpeed
    }
    
    func adjustedDuration(_ duration: TimeInterval) -> TimeInterval {
        return duration / AnimationManager.globalAnimationSpeed
    }
}
