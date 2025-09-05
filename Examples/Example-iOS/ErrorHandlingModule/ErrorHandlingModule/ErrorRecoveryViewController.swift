//
//  ErrorRecoveryViewController.swift
//  ErrorHandlingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 错误恢复示例页面
class ErrorRecoveryViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = ErrorRecoveryViewController()
        vc.routeParameters = parameters
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // 恢复策略选择
    private let strategyContainerView = UIView()
    private let strategySegmentedControl = UISegmentedControl(items: ["重试", "降级", "缓存", "用户引导"])
    private let strategyDescriptionLabel = UILabel()
    
    // 测试场景
    private let scenarioStackView = UIStackView()
    
    // 恢复状态显示
    private let statusContainerView = UIView()
    private let statusTitleLabel = UILabel()
    private let statusMessageLabel = UILabel()
    private let progressView = UIProgressView()
    private let progressLabel = UILabel()
    
    // 恢复历史
    private let historyContainerView = UIView()
    private let historyTableView = UITableView()
    
    // MARK: - Properties
    
    private var recoveryHistory: [RecoveryRecord] = []
    private var currentRecoveryStrategy: RecoveryStrategy = .retry
    private var isRecovering = false
    private var routeParameters: RouterParameters?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        updateStrategyDescription()
        handleRouteParameters()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "错误恢复"
        
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
        titleLabel.text = "错误恢复示例"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 配置描述
        descriptionLabel.text = "演示各种错误恢复策略，包括自动重试、服务降级、缓存回退、用户引导等，帮助应用在遇到错误时优雅地恢复正常功能。"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        setupStrategySection()
        setupScenarioSection()
        setupStatusSection()
        setupHistorySection()
    }
    
    private func setupStrategySection() {
        let strategyLabel = UILabel()
        strategyLabel.text = "恢复策略"
        strategyLabel.font = .boldSystemFont(ofSize: 18)
        strategyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(strategyLabel)
        
        strategyContainerView.backgroundColor = .systemGray6
        strategyContainerView.layer.cornerRadius = 12
        strategyContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(strategyContainerView)
        
        strategySegmentedControl.selectedSegmentIndex = 0
        strategySegmentedControl.addTarget(self, action: #selector(strategyChanged(_:)), for: .valueChanged)
        strategySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        strategyContainerView.addSubview(strategySegmentedControl)
        
        strategyDescriptionLabel.text = ""
        strategyDescriptionLabel.font = .systemFont(ofSize: 14)
        strategyDescriptionLabel.textColor = .secondaryLabel
        strategyDescriptionLabel.numberOfLines = 0
        strategyDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        strategyContainerView.addSubview(strategyDescriptionLabel)
        
        NSLayoutConstraint.activate([
            strategyLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            strategyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            strategyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            strategyContainerView.topAnchor.constraint(equalTo: strategyLabel.bottomAnchor, constant: 12),
            strategyContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            strategyContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            strategySegmentedControl.topAnchor.constraint(equalTo: strategyContainerView.topAnchor, constant: 16),
            strategySegmentedControl.leadingAnchor.constraint(equalTo: strategyContainerView.leadingAnchor, constant: 16),
            strategySegmentedControl.trailingAnchor.constraint(equalTo: strategyContainerView.trailingAnchor, constant: -16),
            
            strategyDescriptionLabel.topAnchor.constraint(equalTo: strategySegmentedControl.bottomAnchor, constant: 12),
            strategyDescriptionLabel.leadingAnchor.constraint(equalTo: strategyContainerView.leadingAnchor, constant: 16),
            strategyDescriptionLabel.trailingAnchor.constraint(equalTo: strategyContainerView.trailingAnchor, constant: -16),
            strategyDescriptionLabel.bottomAnchor.constraint(equalTo: strategyContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupScenarioSection() {
        let scenarioLabel = UILabel()
        scenarioLabel.text = "测试场景"
        scenarioLabel.font = .boldSystemFont(ofSize: 18)
        scenarioLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scenarioLabel)
        
        scenarioStackView.axis = .vertical
        scenarioStackView.spacing = 12
        scenarioStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scenarioStackView)
        
        let scenarios = [
            ("网络请求失败", "模拟网络请求失败后的恢复", "networkFailure", UIColor.systemRed),
            ("数据加载失败", "模拟数据加载失败后的恢复", "dataLoadFailure", UIColor.systemOrange),
            ("服务不可用", "模拟服务不可用时的恢复", "serviceUnavailable", UIColor.systemYellow),
            ("认证过期", "模拟认证过期后的恢复", "authExpired", UIColor.systemPink),
            ("存储空间不足", "模拟存储空间不足的恢复", "storageInsufficient", UIColor.systemPurple),
            ("版本不兼容", "模拟版本不兼容的恢复", "versionIncompatible", UIColor.systemBlue)
        ]
        
        for (title, description, scenario, color) in scenarios {
            let button = createScenarioButton(title: title, description: description, scenario: scenario, color: color)
            scenarioStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            scenarioLabel.topAnchor.constraint(equalTo: strategyContainerView.bottomAnchor, constant: 30),
            scenarioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scenarioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            scenarioStackView.topAnchor.constraint(equalTo: scenarioLabel.bottomAnchor, constant: 12),
            scenarioStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scenarioStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupStatusSection() {
        let statusLabel = UILabel()
        statusLabel.text = "恢复状态"
        statusLabel.font = .boldSystemFont(ofSize: 18)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        statusContainerView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        statusContainerView.layer.cornerRadius = 12
        statusContainerView.layer.borderWidth = 1
        statusContainerView.layer.borderColor = UIColor.systemBlue.cgColor
        statusContainerView.isHidden = true
        statusContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusContainerView)
        
        statusTitleLabel.text = "准备就绪"
        statusTitleLabel.font = .boldSystemFont(ofSize: 16)
        statusTitleLabel.textColor = .systemBlue
        statusTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusContainerView.addSubview(statusTitleLabel)
        
        statusMessageLabel.text = ""
        statusMessageLabel.font = .systemFont(ofSize: 14)
        statusMessageLabel.textColor = .label
        statusMessageLabel.numberOfLines = 0
        statusMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        statusContainerView.addSubview(statusMessageLabel)
        
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray4
        progressView.translatesAutoresizingMaskIntoConstraints = false
        statusContainerView.addSubview(progressView)
        
        progressLabel.text = "0%"
        progressLabel.font = .systemFont(ofSize: 12)
        progressLabel.textColor = .secondaryLabel
        progressLabel.textAlignment = .right
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        statusContainerView.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: scenarioStackView.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusContainerView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            statusContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusTitleLabel.topAnchor.constraint(equalTo: statusContainerView.topAnchor, constant: 16),
            statusTitleLabel.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor, constant: 16),
            statusTitleLabel.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor, constant: -16),
            
            statusMessageLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 8),
            statusMessageLabel.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor, constant: 16),
            statusMessageLabel.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: statusMessageLabel.bottomAnchor, constant: 12),
            progressView.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: progressLabel.leadingAnchor, constant: -8),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            progressLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor, constant: -16),
            progressLabel.widthAnchor.constraint(equalToConstant: 40),
            progressLabel.bottomAnchor.constraint(equalTo: statusContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupHistorySection() {
        let historyLabel = UILabel()
        historyLabel.text = "恢复历史"
        historyLabel.font = .boldSystemFont(ofSize: 18)
        historyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(historyLabel)
        
        historyContainerView.backgroundColor = .systemGray6
        historyContainerView.layer.cornerRadius = 12
        historyContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(historyContainerView)
        
        historyTableView.backgroundColor = .clear
        historyTableView.separatorStyle = .none
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(RecoveryHistoryCell.self, forCellReuseIdentifier: "RecoveryHistoryCell")
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyContainerView.addSubview(historyTableView)
        
        let clearHistoryButton = UIButton(type: .system)
        clearHistoryButton.setTitle("清空历史", for: .normal)
        clearHistoryButton.backgroundColor = .systemRed
        clearHistoryButton.setTitleColor(.white, for: .normal)
        clearHistoryButton.layer.cornerRadius = 8
        clearHistoryButton.addTarget(self, action: #selector(clearHistoryTapped), for: .touchUpInside)
        clearHistoryButton.translatesAutoresizingMaskIntoConstraints = false
        clearHistoryButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        historyContainerView.addSubview(clearHistoryButton)
        
        NSLayoutConstraint.activate([
            historyLabel.topAnchor.constraint(equalTo: statusContainerView.bottomAnchor, constant: 30),
            historyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            historyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            historyContainerView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 12),
            historyContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            historyContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            historyContainerView.heightAnchor.constraint(equalToConstant: 250),
            historyContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            historyTableView.topAnchor.constraint(equalTo: historyContainerView.topAnchor, constant: 16),
            historyTableView.leadingAnchor.constraint(equalTo: historyContainerView.leadingAnchor, constant: 16),
            historyTableView.trailingAnchor.constraint(equalTo: historyContainerView.trailingAnchor, constant: -16),
            historyTableView.bottomAnchor.constraint(equalTo: clearHistoryButton.topAnchor, constant: -12),
            
            clearHistoryButton.leadingAnchor.constraint(equalTo: historyContainerView.leadingAnchor, constant: 16),
            clearHistoryButton.trailingAnchor.constraint(equalTo: historyContainerView.trailingAnchor, constant: -16),
            clearHistoryButton.bottomAnchor.constraint(equalTo: historyContainerView.bottomAnchor, constant: -16)
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
        // Actions are set up in button creation methods
    }
    
    private func handleRouteParameters() {
        // 处理路由参数
        if let parameters = routeParameters {
            if let strategy = parameters["strategy"] as? String {
                switch strategy {
                case "retry":
                    strategySegmentedControl.selectedSegmentIndex = 0
                case "fallback":
                    strategySegmentedControl.selectedSegmentIndex = 1
                case "cache":
                    strategySegmentedControl.selectedSegmentIndex = 2
                case "guide":
                    strategySegmentedControl.selectedSegmentIndex = 3
                default:
                    break
                }
                strategyChanged(strategySegmentedControl)
            }
            
            if let scenario = parameters["scenario"] as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performRecoveryTest(scenario)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createScenarioButton(title: String, description: String, scenario: String, color: UIColor) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = color.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = color.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(scenarioButtonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(button)
        
        // 存储场景信息
        objc_setAssociatedObject(button, "scenario", scenario, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
            
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func updateStrategyDescription() {
        switch currentRecoveryStrategy {
        case .retry:
            strategyDescriptionLabel.text = "自动重试策略：当操作失败时，系统会自动重试指定次数，每次重试间隔递增，直到成功或达到最大重试次数。"
        case .fallback:
            strategyDescriptionLabel.text = "服务降级策略：当主要服务不可用时，自动切换到备用服务或简化功能，确保核心功能仍然可用。"
        case .cache:
            strategyDescriptionLabel.text = "缓存回退策略：当网络请求失败时，使用本地缓存的数据，虽然可能不是最新的，但能保证用户体验的连续性。"
        case .userGuide:
            strategyDescriptionLabel.text = "用户引导策略：当自动恢复无法解决问题时，向用户提供明确的操作指导，帮助用户手动解决问题。"
        }
    }
    
    private func performRecoveryTest(_ scenario: String) {
        guard !isRecovering else { return }
        
        isRecovering = true
        statusContainerView.isHidden = false
        
        let startTime = Date()
        
        switch scenario {
        case "networkFailure":
            performNetworkFailureRecovery(startTime: startTime)
        case "dataLoadFailure":
            performDataLoadFailureRecovery(startTime: startTime)
        case "serviceUnavailable":
            performServiceUnavailableRecovery(startTime: startTime)
        case "authExpired":
            performAuthExpiredRecovery(startTime: startTime)
        case "storageInsufficient":
            performStorageInsufficientRecovery(startTime: startTime)
        case "versionIncompatible":
            performVersionIncompatibleRecovery(startTime: startTime)
        default:
            break
        }
    }
    
    private func performNetworkFailureRecovery(startTime: Date) {
        statusTitleLabel.text = "网络请求失败恢复中..."
        statusMessageLabel.text = "检测到网络请求失败，正在执行\(currentRecoveryStrategy.description)策略"
        
        switch currentRecoveryStrategy {
        case .retry:
            performRetryRecovery(scenario: "网络请求", startTime: startTime)
        case .fallback:
            performFallbackRecovery(scenario: "网络请求", startTime: startTime)
        case .cache:
            performCacheRecovery(scenario: "网络请求", startTime: startTime)
        case .userGuide:
            performUserGuideRecovery(scenario: "网络请求", startTime: startTime)
        }
    }
    
    private func performDataLoadFailureRecovery(startTime: Date) {
        statusTitleLabel.text = "数据加载失败恢复中..."
        statusMessageLabel.text = "检测到数据加载失败，正在执行\(currentRecoveryStrategy.description)策略"
        
        switch currentRecoveryStrategy {
        case .retry:
            performRetryRecovery(scenario: "数据加载", startTime: startTime)
        case .fallback:
            performFallbackRecovery(scenario: "数据加载", startTime: startTime)
        case .cache:
            performCacheRecovery(scenario: "数据加载", startTime: startTime)
        case .userGuide:
            performUserGuideRecovery(scenario: "数据加载", startTime: startTime)
        }
    }
    
    private func performServiceUnavailableRecovery(startTime: Date) {
        statusTitleLabel.text = "服务不可用恢复中..."
        statusMessageLabel.text = "检测到服务不可用，正在执行\(currentRecoveryStrategy.description)策略"
        
        switch currentRecoveryStrategy {
        case .retry:
            performRetryRecovery(scenario: "服务访问", startTime: startTime)
        case .fallback:
            performFallbackRecovery(scenario: "服务访问", startTime: startTime)
        case .cache:
            performCacheRecovery(scenario: "服务访问", startTime: startTime)
        case .userGuide:
            performUserGuideRecovery(scenario: "服务访问", startTime: startTime)
        }
    }
    
    private func performAuthExpiredRecovery(startTime: Date) {
        statusTitleLabel.text = "认证过期恢复中..."
        statusMessageLabel.text = "检测到认证过期，正在执行\(currentRecoveryStrategy.description)策略"
        
        switch currentRecoveryStrategy {
        case .retry:
            performRetryRecovery(scenario: "认证刷新", startTime: startTime)
        case .fallback:
            performFallbackRecovery(scenario: "认证刷新", startTime: startTime)
        case .cache:
            performCacheRecovery(scenario: "认证刷新", startTime: startTime)
        case .userGuide:
            performUserGuideRecovery(scenario: "认证刷新", startTime: startTime)
        }
    }
    
    private func performStorageInsufficientRecovery(startTime: Date) {
        statusTitleLabel.text = "存储空间不足恢复中..."
        statusMessageLabel.text = "检测到存储空间不足，正在执行\(currentRecoveryStrategy.description)策略"
        
        switch currentRecoveryStrategy {
        case .retry:
            performRetryRecovery(scenario: "存储清理", startTime: startTime)
        case .fallback:
            performFallbackRecovery(scenario: "存储清理", startTime: startTime)
        case .cache:
            performCacheRecovery(scenario: "存储清理", startTime: startTime)
        case .userGuide:
            performUserGuideRecovery(scenario: "存储清理", startTime: startTime)
        }
    }
    
    private func performVersionIncompatibleRecovery(startTime: Date) {
        statusTitleLabel.text = "版本不兼容恢复中..."
        statusMessageLabel.text = "检测到版本不兼容，正在执行\(currentRecoveryStrategy.description)策略"
        
        switch currentRecoveryStrategy {
        case .retry:
            performRetryRecovery(scenario: "版本检查", startTime: startTime)
        case .fallback:
            performFallbackRecovery(scenario: "版本检查", startTime: startTime)
        case .cache:
            performCacheRecovery(scenario: "版本检查", startTime: startTime)
        case .userGuide:
            performUserGuideRecovery(scenario: "版本检查", startTime: startTime)
        }
    }
    
    private func performRetryRecovery(scenario: String, startTime: Date) {
        let maxRetries = 3
        var currentRetry = 0
        
        func retry() {
            currentRetry += 1
            let progress = Float(currentRetry) / Float(maxRetries)
            progressView.setProgress(progress, animated: true)
            progressLabel.text = "\(Int(progress * 100))%"
            
            statusMessageLabel.text = "正在重试\(scenario) (\(currentRetry)/\(maxRetries))..."
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let success = currentRetry >= 2 || Bool.random() // 模拟成功率
                
                if success {
                    self.completeRecovery(success: true, scenario: scenario, strategy: .retry, startTime: startTime, attempts: currentRetry)
                } else if currentRetry < maxRetries {
                    retry()
                } else {
                    self.completeRecovery(success: false, scenario: scenario, strategy: .retry, startTime: startTime, attempts: currentRetry)
                }
            }
        }
        
        retry()
    }
    
    private func performFallbackRecovery(scenario: String, startTime: Date) {
        progressView.setProgress(0.3, animated: true)
        progressLabel.text = "30%"
        statusMessageLabel.text = "正在切换到备用服务..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.progressView.setProgress(0.7, animated: true)
            self.progressLabel.text = "70%"
            self.statusMessageLabel.text = "正在验证备用服务可用性..."
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.progressView.setProgress(1.0, animated: true)
                self.progressLabel.text = "100%"
                self.completeRecovery(success: true, scenario: scenario, strategy: .fallback, startTime: startTime, attempts: 1)
            }
        }
    }
    
    private func performCacheRecovery(scenario: String, startTime: Date) {
        progressView.setProgress(0.5, animated: true)
        progressLabel.text = "50%"
        statusMessageLabel.text = "正在检查本地缓存..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.progressView.setProgress(1.0, animated: true)
            self.progressLabel.text = "100%"
            self.statusMessageLabel.text = "已从缓存加载数据"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.completeRecovery(success: true, scenario: scenario, strategy: .cache, startTime: startTime, attempts: 1)
            }
        }
    }
    
    private func performUserGuideRecovery(scenario: String, startTime: Date) {
        progressView.setProgress(1.0, animated: true)
        progressLabel.text = "100%"
        statusMessageLabel.text = "已生成用户操作指导"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = UIAlertController(title: "操作指导", message: "请按照以下步骤解决\(scenario)问题：\n1. 检查网络连接\n2. 重启应用\n3. 联系技术支持", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "我知道了", style: .default) { _ in
                self.completeRecovery(success: true, scenario: scenario, strategy: .userGuide, startTime: startTime, attempts: 1)
            })
            self.present(alert, animated: true)
        }
    }
    
    private func completeRecovery(success: Bool, scenario: String, strategy: RecoveryStrategy, startTime: Date, attempts: Int) {
        let duration = Date().timeIntervalSince(startTime)
        
        statusTitleLabel.text = success ? "恢复成功" : "恢复失败"
        statusMessageLabel.text = success ? "\(scenario)已成功恢复" : "\(scenario)恢复失败，请尝试其他策略"
        
        statusContainerView.layer.borderColor = success ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor
        statusTitleLabel.textColor = success ? .systemGreen : .systemRed
        
        // 记录恢复历史
        let record = RecoveryRecord(
            scenario: scenario,
            strategy: strategy,
            success: success,
            duration: duration,
            attempts: attempts,
            timestamp: Date()
        )
        recoveryHistory.insert(record, at: 0)
        historyTableView.reloadData()
        
        // 重置状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isRecovering = false
            self.statusContainerView.isHidden = true
            self.progressView.setProgress(0, animated: false)
            self.progressLabel.text = "0%"
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func backButtonTapped() {
        Router.pop()
    }
    
    @objc private func strategyChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentRecoveryStrategy = .retry
        case 1:
            currentRecoveryStrategy = .fallback
        case 2:
            currentRecoveryStrategy = .cache
        case 3:
            currentRecoveryStrategy = .userGuide
        default:
            break
        }
        updateStrategyDescription()
    }
    
    @objc private func scenarioButtonTapped(_ sender: UIButton) {
        guard let scenario = objc_getAssociatedObject(sender, "scenario") as? String else { return }
        performRecoveryTest(scenario)
    }
    
    @objc private func clearHistoryTapped() {
        let alert = UIAlertController(title: "清空历史", message: "确定要清空所有恢复历史记录吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            self.recoveryHistory.removeAll()
            self.historyTableView.reloadData()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ErrorRecoveryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(recoveryHistory.count, 10) // 最多显示10条
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecoveryHistoryCell", for: indexPath) as! RecoveryHistoryCell
        let record = recoveryHistory[indexPath.row]
        cell.configure(with: record)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - RecoveryStrategy

enum RecoveryStrategy {
    case retry
    case fallback
    case cache
    case userGuide
    
    var description: String {
        switch self {
        case .retry:
            return "重试"
        case .fallback:
            return "降级"
        case .cache:
            return "缓存"
        case .userGuide:
            return "用户引导"
        }
    }
}

// MARK: - RecoveryRecord

struct RecoveryRecord {
    let scenario: String
    let strategy: RecoveryStrategy
    let success: Bool
    let duration: TimeInterval
    let attempts: Int
    let timestamp: Date
}

// MARK: - RecoveryHistoryCell

class RecoveryHistoryCell: UITableViewCell {
    
    private let scenarioLabel = UILabel()
    private let strategyLabel = UILabel()
    private let statusLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        scenarioLabel.font = .boldSystemFont(ofSize: 14)
        scenarioLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scenarioLabel)
        
        strategyLabel.font = .systemFont(ofSize: 12)
        strategyLabel.textColor = .secondaryLabel
        strategyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(strategyLabel)
        
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textColor = .tertiaryLabel
        timeLabel.textAlignment = .right
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            scenarioLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            scenarioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            scenarioLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            
            strategyLabel.topAnchor.constraint(equalTo: scenarioLabel.bottomAnchor, constant: 4),
            strategyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            strategyLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            strategyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            statusLabel.widthAnchor.constraint(equalToConstant: 50),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            timeLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(with record: RecoveryRecord) {
        scenarioLabel.text = record.scenario
        strategyLabel.text = "策略: \(record.strategy.description) | 耗时: \(String(format: "%.1f", record.duration))s | 尝试: \(record.attempts)次"
        
        if record.success {
            statusLabel.text = "成功"
            statusLabel.backgroundColor = .systemGreen
            statusLabel.textColor = .white
        } else {
            statusLabel.text = "失败"
            statusLabel.backgroundColor = .systemRed
            statusLabel.textColor = .white
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timeLabel.text = formatter.string(from: record.timestamp)
    }
}
