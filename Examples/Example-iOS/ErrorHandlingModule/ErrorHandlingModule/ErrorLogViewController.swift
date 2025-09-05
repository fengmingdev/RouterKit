//
//  ErrorLogViewController.swift
//  ErrorHandlingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 错误日志示例页面
class ErrorLogViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = ErrorLogViewController()
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
    
    // 日志统计
    private let statsContainerView = UIView()
    private var totalLogsLabel = UILabel()
    private var errorLogsLabel = UILabel()
    private var warningLogsLabel = UILabel()
    private var infoLogsLabel = UILabel()
    
    // 日志过滤
    private let filterContainerView = UIView()
    private let levelSegmentedControl = UISegmentedControl(items: ["全部", "错误", "警告", "信息"])
    private let timeSegmentedControl = UISegmentedControl(items: ["今天", "本周", "本月", "全部"])
    private let searchTextField = UITextField()
    
    // 日志列表
    private let logTableView = UITableView()
    
    // 操作按钮
    private let actionStackView = UIStackView()
    
    // MARK: - Properties
    
    private var allLogs: [SimpleErrorLog] = []
    private var filteredLogs: [SimpleErrorLog] = []
    private var currentLevelFilter: LogLevel? = nil
    private var currentTimeFilter: TimeFilter = .all
    private var searchText: String = ""
    private var routeParameters: RouterParameters?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadErrorLogs()
        handleRouteParameters()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "错误日志"
        
        // 添加返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "返回",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        // 添加导出按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "导出",
            style: .plain,
            target: self,
            action: #selector(exportButtonTapped)
        )
        
        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 配置标题
        titleLabel.text = "错误日志管理"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 配置描述
        descriptionLabel.text = "查看和管理应用的错误日志，包括错误统计、日志过滤、搜索和导出功能，帮助开发者快速定位和解决问题。"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        setupStatsSection()
        setupFilterSection()
        setupLogTableView()
        setupActionButtons()
    }
    
    private func setupStatsSection() {
        let statsLabel = UILabel()
        statsLabel.text = "日志统计"
        statsLabel.font = .boldSystemFont(ofSize: 18)
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsLabel)
        
        statsContainerView.backgroundColor = .systemGray6
        statsContainerView.layer.cornerRadius = 12
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsContainerView)
        
        let statsStackView = UIStackView()
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 1
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(statsStackView)
        
        // 总数
        let totalContainer = createStatContainer(title: "总数", value: "0", color: .systemBlue)
        totalLogsLabel = totalContainer.subviews.compactMap { $0 as? UILabel }.first { $0.font.pointSize > 16 }!
        statsStackView.addArrangedSubview(totalContainer)
        
        // 错误
        let errorContainer = createStatContainer(title: "错误", value: "0", color: .systemRed)
        errorLogsLabel = errorContainer.subviews.compactMap { $0 as? UILabel }.first { $0.font.pointSize > 16 }!
        statsStackView.addArrangedSubview(errorContainer)
        
        // 警告
        let warningContainer = createStatContainer(title: "警告", value: "0", color: .systemOrange)
        warningLogsLabel = warningContainer.subviews.compactMap { $0 as? UILabel }.first { $0.font.pointSize > 16 }!
        statsStackView.addArrangedSubview(warningContainer)
        
        // 信息
        let infoContainer = createStatContainer(title: "信息", value: "0", color: .systemGreen)
        infoLogsLabel = infoContainer.subviews.compactMap { $0 as? UILabel }.first { $0.font.pointSize > 16 }!
        statsStackView.addArrangedSubview(infoContainer)
        
        NSLayoutConstraint.activate([
            statsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            statsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statsContainerView.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 12),
            statsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            statsStackView.topAnchor.constraint(equalTo: statsContainerView.topAnchor),
            statsStackView.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor),
            statsStackView.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor),
            statsStackView.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor)
        ])
    }
    
    private func setupFilterSection() {
        let filterLabel = UILabel()
        filterLabel.text = "日志过滤"
        filterLabel.font = .boldSystemFont(ofSize: 18)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(filterLabel)
        
        filterContainerView.backgroundColor = .systemGray6
        filterContainerView.layer.cornerRadius = 12
        filterContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(filterContainerView)
        
        // 日志级别过滤
        let levelLabel = UILabel()
        levelLabel.text = "日志级别"
        levelLabel.font = .systemFont(ofSize: 14)
        levelLabel.textColor = .secondaryLabel
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        filterContainerView.addSubview(levelLabel)
        
        levelSegmentedControl.selectedSegmentIndex = 0
        levelSegmentedControl.addTarget(self, action: #selector(levelFilterChanged(_:)), for: .valueChanged)
        levelSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        filterContainerView.addSubview(levelSegmentedControl)
        
        // 时间过滤
        let timeLabel = UILabel()
        timeLabel.text = "时间范围"
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        filterContainerView.addSubview(timeLabel)
        
        timeSegmentedControl.selectedSegmentIndex = 3
        timeSegmentedControl.addTarget(self, action: #selector(timeFilterChanged(_:)), for: .valueChanged)
        timeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        filterContainerView.addSubview(timeSegmentedControl)
        
        // 搜索框
        let searchLabel = UILabel()
        searchLabel.text = "搜索关键词"
        searchLabel.font = .systemFont(ofSize: 14)
        searchLabel.textColor = .secondaryLabel
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        filterContainerView.addSubview(searchLabel)
        
        searchTextField.placeholder = "输入错误消息、模块名称等关键词"
        searchTextField.borderStyle = .roundedRect
        searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        filterContainerView.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            filterLabel.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 30),
            filterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            filterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            filterContainerView.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 12),
            filterContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            filterContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            levelLabel.topAnchor.constraint(equalTo: filterContainerView.topAnchor, constant: 16),
            levelLabel.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: 16),
            levelLabel.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor, constant: -16),
            
            levelSegmentedControl.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 8),
            levelSegmentedControl.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: 16),
            levelSegmentedControl.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: levelSegmentedControl.bottomAnchor, constant: 16),
            timeLabel.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor, constant: -16),
            
            timeSegmentedControl.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            timeSegmentedControl.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: 16),
            timeSegmentedControl.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor, constant: -16),
            
            searchLabel.topAnchor.constraint(equalTo: timeSegmentedControl.bottomAnchor, constant: 16),
            searchLabel.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: 16),
            searchLabel.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor, constant: -16),
            
            searchTextField.topAnchor.constraint(equalTo: searchLabel.bottomAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor, constant: -16),
            searchTextField.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupLogTableView() {
        let logLabel = UILabel()
        logLabel.text = "日志列表"
        logLabel.font = .boldSystemFont(ofSize: 18)
        logLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logLabel)
        
        logTableView.backgroundColor = .systemGray6
        logTableView.layer.cornerRadius = 12
        logTableView.separatorStyle = .none
        logTableView.delegate = self
        logTableView.dataSource = self
        logTableView.register(ErrorLogCell.self, forCellReuseIdentifier: "ErrorLogCell")
        logTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logTableView)
        
        NSLayoutConstraint.activate([
            logLabel.topAnchor.constraint(equalTo: filterContainerView.bottomAnchor, constant: 30),
            logLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            logTableView.topAnchor.constraint(equalTo: logLabel.bottomAnchor, constant: 12),
            logTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupActionButtons() {
        actionStackView.axis = .horizontal
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 12
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionStackView)
        
        let generateButton = createActionButton(title: "生成测试日志", color: .systemBlue, action: #selector(generateTestLogsTapped))
        let clearButton = createActionButton(title: "清空日志", color: .systemRed, action: #selector(clearLogsTapped))
        let refreshButton = createActionButton(title: "刷新", color: .systemGreen, action: #selector(refreshTapped))
        
        actionStackView.addArrangedSubview(generateButton)
        actionStackView.addArrangedSubview(clearButton)
        actionStackView.addArrangedSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            actionStackView.topAnchor.constraint(equalTo: logTableView.bottomAnchor, constant: 20),
            actionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionStackView.heightAnchor.constraint(equalToConstant: 44),
            actionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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
            if let level = parameters["level"] as? String {
                switch level {
                case "error":
                    levelSegmentedControl.selectedSegmentIndex = 1
                case "warning":
                    levelSegmentedControl.selectedSegmentIndex = 2
                case "info":
                    levelSegmentedControl.selectedSegmentIndex = 3
                default:
                    break
                }
                levelFilterChanged(levelSegmentedControl)
            }
            
            if let timeRange = parameters["timeRange"] as? String {
                switch timeRange {
                case "today":
                    timeSegmentedControl.selectedSegmentIndex = 0
                case "week":
                    timeSegmentedControl.selectedSegmentIndex = 1
                case "month":
                    timeSegmentedControl.selectedSegmentIndex = 2
                default:
                    break
                }
                timeFilterChanged(timeSegmentedControl)
            }
            
            if let search = routeParameters?["search"] as? String {
                searchTextField.text = search
                searchTextChanged(searchTextField)
            }
            
            if let autoGenerate = routeParameters?["autoGenerate"] as? Bool, autoGenerate {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.generateTestLogsTapped()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createStatContainer(title: String, value: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 20)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func createActionButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func loadErrorLogs() {
        // 从ErrorManager获取错误日志并转换为SimpleErrorLog
        let errorManagerLogs = ErrorManager.shared.getErrorLogs()
        let convertedLogs = errorManagerLogs.map { errorLog -> SimpleErrorLog in
            let level: LogLevel
            if errorLog.error is RouterKit.RouterError {
                level = .error
            } else if errorLog.error is NetworkError {
                level = .warning
            } else {
                level = .info
            }
            
            return SimpleErrorLog(
                level: level,
                message: errorLog.error.localizedDescription,
                module: errorLog.errorType.rawValue + "Module",
                timestamp: errorLog.timestamp,
                userInfo: nil
            )
        }
        
        allLogs = convertedLogs
        applyFilters()
        updateStats()
    }
    
    private func applyFilters() {
        filteredLogs = allLogs
        
        // 应用级别过滤
        if let levelFilter = currentLevelFilter {
            filteredLogs = filteredLogs.filter { $0.level == levelFilter }
        }
        
        // 应用时间过滤
        let now = Date()
        switch currentTimeFilter {
        case .today:
            let startOfDay = Calendar.current.startOfDay(for: now)
            filteredLogs = filteredLogs.filter { $0.timestamp >= startOfDay }
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now)!
            filteredLogs = filteredLogs.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            filteredLogs = filteredLogs.filter { $0.timestamp >= monthAgo }
        case .all:
            break
        }
        
        // 应用搜索过滤
        if !searchText.isEmpty {
            filteredLogs = filteredLogs.filter { log in
                log.message.localizedCaseInsensitiveContains(searchText) ||
                log.module.localizedCaseInsensitiveContains(searchText) ||
                (log.userInfo?.description.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // 按时间倒序排列
        filteredLogs.sort { $0.timestamp > $1.timestamp }
        
        logTableView.reloadData()
    }
    
    private func updateStats() {
        let total = allLogs.count
        let errors = allLogs.filter { $0.level == .error }.count
        let warnings = allLogs.filter { $0.level == .warning }.count
        let infos = allLogs.filter { $0.level == .info }.count
        
        totalLogsLabel.text = "\(total)"
        errorLogsLabel.text = "\(errors)"
        warningLogsLabel.text = "\(warnings)"
        infoLogsLabel.text = "\(infos)"
    }
    
    private func generateTestLogs() {
        let testLogs = [
            SimpleErrorLog(level: .error, message: "网络请求超时", module: "NetworkModule", timestamp: Date(), userInfo: ["url": "https://api.example.com/data"]),
            SimpleErrorLog(level: .warning, message: "缓存即将过期", module: "CacheModule", timestamp: Date(timeIntervalSinceNow: -300), userInfo: ["cacheKey": "user_profile"]),
            SimpleErrorLog(level: .info, message: "用户登录成功", module: "AuthModule", timestamp: Date(timeIntervalSinceNow: -600), userInfo: ["userId": "12345"]),
            SimpleErrorLog(level: .error, message: "路由解析失败", module: "RouterModule", timestamp: Date(timeIntervalSinceNow: -900), userInfo: ["route": "/invalid/path"]),
            SimpleErrorLog(level: .warning, message: "内存使用率过高", module: "SystemModule", timestamp: Date(timeIntervalSinceNow: -1200), userInfo: ["memoryUsage": "85%"]),
            SimpleErrorLog(level: .info, message: "数据同步完成", module: "SyncModule", timestamp: Date(timeIntervalSinceNow: -1500), userInfo: ["syncedItems": "150"]),
            SimpleErrorLog(level: .error, message: "数据库连接失败", module: "DatabaseModule", timestamp: Date(timeIntervalSinceNow: -1800), userInfo: ["error": "Connection timeout"]),
            SimpleErrorLog(level: .warning, message: "API调用频率过高", module: "APIModule", timestamp: Date(timeIntervalSinceNow: -2100), userInfo: ["rateLimit": "100/min"]),
            SimpleErrorLog(level: .info, message: "配置更新成功", module: "ConfigModule", timestamp: Date(timeIntervalSinceNow: -2400), userInfo: ["configVersion": "1.2.3"]),
            SimpleErrorLog(level: .error, message: "文件上传失败", module: "UploadModule", timestamp: Date(timeIntervalSinceNow: -2700), userInfo: ["fileName": "document.pdf", "size": "2.5MB"])
        ]
        
        allLogs.append(contentsOf: testLogs)
        
        for log in testLogs {
            // 创建一个测试错误并记录到ErrorManager
            let testError = RouterKit.RouterError.parameterError(log.message, suggestion: "请检查参数格式", debugInfo: "Generated from test log")
            ErrorManager.shared.handleError(testError, context: nil)
        }
        
        applyFilters()
        updateStats()
        logTableView.reloadData()
    }
    
    private func exportLogs() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var csvContent = "时间,级别,模块,消息,详细信息\n"
        
        for log in filteredLogs {
            let timestamp = formatter.string(from: log.timestamp)
            let level: String
            switch log.level {
            case .error:
                level = "ERROR"
            case .warning:
                level = "WARNING"
            case .info:
                level = "INFO"
            }
            let module = log.module
            let message = log.message.replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "\n", with: " ")
            let userInfo = log.userInfo?.description.replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "\n", with: " ") ?? ""
            
            csvContent += "\(timestamp),\(level),\(module),\(message),\(userInfo)\n"
        }
        
        let activityVC = UIActivityViewController(activityItems: [csvContent], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
    
    // MARK: - Action Methods
    
    @objc private func backButtonTapped() {
        Router.pop()
    }
    
    @objc private func exportButtonTapped() {
        exportLogs()
    }
    
    @objc private func levelFilterChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentLevelFilter = nil
        case 1:
            currentLevelFilter = .error
        case 2:
            currentLevelFilter = .warning
        case 3:
            currentLevelFilter = .info
        default:
            break
        }
        applyFilters()
    }
    
    @objc private func timeFilterChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentTimeFilter = .today
        case 1:
            currentTimeFilter = .week
        case 2:
            currentTimeFilter = .month
        case 3:
            currentTimeFilter = .all
        default:
            break
        }
        applyFilters()
    }
    
    @objc private func searchTextChanged(_ sender: UITextField) {
        searchText = sender.text ?? ""
        applyFilters()
    }
    
    @objc private func generateTestLogsTapped() {
        generateTestLogs()
    }
    
    @objc private func clearLogsTapped() {
        let alert = UIAlertController(title: "清空日志", message: "确定要清空所有错误日志吗？此操作不可撤销。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            ErrorManager.shared.clearErrorLogs()
            self.loadErrorLogs()
        })
        present(alert, animated: true)
    }
    
    @objc private func refreshTapped() {
        loadErrorLogs()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ErrorLogViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorLogCell", for: indexPath) as! ErrorLogCell
        let log = filteredLogs[indexPath.row]
        cell.configure(with: log)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let log = filteredLogs[indexPath.row]
        let alert = UIAlertController(title: "日志详情", message: nil, preferredStyle: .alert)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let details = """
        时间: \(formatter.string(from: log.timestamp))
        级别: \({
            switch log.level {
            case .error: return "错误"
            case .warning: return "警告"
            case .info: return "信息"
            }
        }())
        模块: \(log.module)
        消息: \(log.message)
        详细信息: \(log.userInfo?.description ?? "无")
        """
        
        alert.message = details
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - LogLevel

enum LogLevel {
    case error
    case warning
    case info
}

// MARK: - Simple ErrorLog for UI

struct SimpleErrorLog {
    let level: LogLevel
    let message: String
    let module: String
    let timestamp: Date
    let userInfo: [String: Any]?
}

// MARK: - TimeFilter

enum TimeFilter {
    case today
    case week
    case month
    case all
}

// MARK: - ErrorLogCell

class ErrorLogCell: UITableViewCell {
    
    private let levelIndicatorView = UIView()
    private let timestampLabel = UILabel()
    private let moduleLabel = UILabel()
    private let messageLabel = UILabel()
    private let detailLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        levelIndicatorView.layer.cornerRadius = 4
        levelIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(levelIndicatorView)
        
        timestampLabel.font = .systemFont(ofSize: 10)
        timestampLabel.textColor = .tertiaryLabel
        timestampLabel.textAlignment = .right
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timestampLabel)
        
        moduleLabel.font = .boldSystemFont(ofSize: 12)
        moduleLabel.textColor = .secondaryLabel
        moduleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(moduleLabel)
        
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 2
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        
        detailLabel.font = .systemFont(ofSize: 10)
        detailLabel.textColor = .tertiaryLabel
        detailLabel.numberOfLines = 1
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            levelIndicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            levelIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            levelIndicatorView.widthAnchor.constraint(equalToConstant: 8),
            levelIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            
            timestampLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            timestampLabel.widthAnchor.constraint(equalToConstant: 80),
            
            moduleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            moduleLabel.leadingAnchor.constraint(equalTo: levelIndicatorView.trailingAnchor, constant: 8),
            moduleLabel.trailingAnchor.constraint(equalTo: timestampLabel.leadingAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: moduleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: levelIndicatorView.trailingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            detailLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: levelIndicatorView.trailingAnchor, constant: 8),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            detailLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with log: SimpleErrorLog) {
        // 设置级别指示器颜色
        switch log.level {
        case .error:
            levelIndicatorView.backgroundColor = .systemRed
        case .warning:
            levelIndicatorView.backgroundColor = .systemOrange
        case .info:
            levelIndicatorView.backgroundColor = .systemGreen
        }
        
        // 设置时间戳
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timestampLabel.text = formatter.string(from: log.timestamp)
        
        // 设置模块名称
        moduleLabel.text = log.module
        
        // 设置消息
        messageLabel.text = log.message
        
        // 设置详细信息
        if let userInfo = log.userInfo, !userInfo.isEmpty {
            let details = userInfo.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            detailLabel.text = details
        } else {
            detailLabel.text = "无详细信息"
        }
    }
}
