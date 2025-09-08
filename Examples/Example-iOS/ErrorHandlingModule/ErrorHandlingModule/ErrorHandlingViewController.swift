//
//  ErrorHandlingViewController.swift
//  ErrorHandlingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 错误处理示例主页面
class ErrorHandlingViewController: UIViewController, Routable {

    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = ErrorHandlingViewController()
        vc.routeParameters = parameters
        return vc
    }

    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "clearErrorLogs":
            ErrorManager.shared.clearErrorLogs()
            completion(.success("错误日志已清除"))
        case "exportErrorLogs":
            let logs = ErrorManager.shared.getErrorLogs()
            completion(.success("已导出 \(logs.count) 条错误日志"))
        case "generateTestError":
            let testError = RouterKit.RouterError.routeNotFound("test://error", debugInfo: "Test error generation")
            ErrorManager.shared.handleError(testError, context: nil)
            completion(.success("测试错误已生成"))
        default:
            completion(.failure(RouterKit.RouterError.actionNotFound(action, debugInfo: "Action not supported in ErrorHandlingViewController")))
        }
    }

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    // 错误统计
    private let statsContainerView = UIView()
    private let totalErrorsLabel = UILabel()
    private let recentErrorsLabel = UILabel()
    private let errorTypesLabel = UILabel()

    // 示例按钮
    private let examplesStackView = UIStackView()

    // 错误日志
    private let logsContainerView = UIView()
    private let logsTableView = UITableView()
    private let clearLogsButton = UIButton(type: .system)
    private let exportLogsButton = UIButton(type: .system)

    // MARK: - Properties

    private var errorLogs: [ErrorLog] = []
    private var routeParameters: RouterParameters?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupNotifications()
        handleRouteParameters()
        updateErrorStats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateErrorStats()
        reloadErrorLogs()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "错误处理"

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
        titleLabel.text = "错误处理示例"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // 配置描述
        descriptionLabel.text = "演示RouterKit中各种错误处理场景，包括路由错误、模块错误、网络错误等，以及相应的错误恢复策略。"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        setupStatsSection()
        setupExamplesSection()
        setupLogsSection()
    }

    private func setupStatsSection() {
        let statsLabel = UILabel()
        statsLabel.text = "错误统计"
        statsLabel.font = .boldSystemFont(ofSize: 18)
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsLabel)

        statsContainerView.backgroundColor = .systemGray6
        statsContainerView.layer.cornerRadius = 12
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsContainerView)

        let statsStackView = UIStackView()
        statsStackView.axis = .vertical
        statsStackView.spacing = 8
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(statsStackView)

        totalErrorsLabel.text = "总错误数: 0"
        totalErrorsLabel.font = .systemFont(ofSize: 16)
        totalErrorsLabel.translatesAutoresizingMaskIntoConstraints = false

        recentErrorsLabel.text = "最近24小时: 0"
        recentErrorsLabel.font = .systemFont(ofSize: 16)
        recentErrorsLabel.translatesAutoresizingMaskIntoConstraints = false

        errorTypesLabel.text = "错误类型: 0种"
        errorTypesLabel.font = .systemFont(ofSize: 16)
        errorTypesLabel.translatesAutoresizingMaskIntoConstraints = false

        statsStackView.addArrangedSubview(totalErrorsLabel)
        statsStackView.addArrangedSubview(recentErrorsLabel)
        statsStackView.addArrangedSubview(errorTypesLabel)

        NSLayoutConstraint.activate([
            statsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            statsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            statsContainerView.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 12),
            statsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            statsStackView.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -16)
        ])
    }

    private func setupExamplesSection() {
        let examplesLabel = UILabel()
        examplesLabel.text = "错误处理示例"
        examplesLabel.font = .boldSystemFont(ofSize: 18)
        examplesLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(examplesLabel)

        examplesStackView.axis = .vertical
        examplesStackView.spacing = 12
        examplesStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(examplesStackView)

        let examples = [
            ("路由错误", "演示路由未找到、模块未注册等错误", "/ErrorHandlingModule/routeError", UIColor.systemRed),
            ("模块错误", "演示模块加载失败、初始化错误等", "/ErrorHandlingModule/moduleError", UIColor.systemOrange),
            ("网络错误", "演示网络连接、超时、服务器错误等", "/ErrorHandlingModule/networkError", UIColor.systemBlue),
            ("参数错误", "演示无效参数、类型错误等", "/ErrorHandlingModule/parameterError", UIColor.systemGreen),
            ("权限错误", "演示认证失败、权限不足等", "/ErrorHandlingModule/permissionError", UIColor.systemPurple),
            ("自定义错误", "演示自定义错误类型和处理", "/ErrorHandlingModule/customError", UIColor.systemTeal),
            ("错误恢复", "演示错误恢复策略和重试机制", "/ErrorHandlingModule/errorRecovery", UIColor.systemIndigo),
            ("错误日志", "演示错误日志记录和分析", "/ErrorHandlingModule/errorLogging", UIColor.systemBrown)
        ]

        for (title, description, route, color) in examples {
            let button = createExampleButton(title: title, description: description, route: route, color: color)
            examplesStackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            examplesLabel.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 30),
            examplesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            examplesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            examplesStackView.topAnchor.constraint(equalTo: examplesLabel.bottomAnchor, constant: 12),
            examplesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            examplesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupLogsSection() {
        let logsLabel = UILabel()
        logsLabel.text = "错误日志"
        logsLabel.font = .boldSystemFont(ofSize: 18)
        logsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logsLabel)

        logsContainerView.backgroundColor = .systemGray6
        logsContainerView.layer.cornerRadius = 12
        logsContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logsContainerView)

        logsTableView.backgroundColor = .clear
        logsTableView.separatorStyle = .none
        logsTableView.delegate = self
        logsTableView.dataSource = self
        logsTableView.register(ErrorLogCell.self, forCellReuseIdentifier: "ErrorLogCell")
        logsTableView.translatesAutoresizingMaskIntoConstraints = false
        logsContainerView.addSubview(logsTableView)

        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        logsContainerView.addSubview(buttonStackView)

        clearLogsButton.setTitle("清空日志", for: .normal)
        clearLogsButton.backgroundColor = .systemRed
        clearLogsButton.setTitleColor(.white, for: .normal)
        clearLogsButton.layer.cornerRadius = 8
        clearLogsButton.translatesAutoresizingMaskIntoConstraints = false
        clearLogsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        exportLogsButton.setTitle("导出日志", for: .normal)
        exportLogsButton.backgroundColor = .systemBlue
        exportLogsButton.setTitleColor(.white, for: .normal)
        exportLogsButton.layer.cornerRadius = 8
        exportLogsButton.translatesAutoresizingMaskIntoConstraints = false
        exportLogsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        buttonStackView.addArrangedSubview(clearLogsButton)
        buttonStackView.addArrangedSubview(exportLogsButton)

        NSLayoutConstraint.activate([
            logsLabel.topAnchor.constraint(equalTo: examplesStackView.bottomAnchor, constant: 30),
            logsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            logsContainerView.topAnchor.constraint(equalTo: logsLabel.bottomAnchor, constant: 12),
            logsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logsContainerView.heightAnchor.constraint(equalToConstant: 300),
            logsContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            logsTableView.topAnchor.constraint(equalTo: logsContainerView.topAnchor, constant: 16),
            logsTableView.leadingAnchor.constraint(equalTo: logsContainerView.leadingAnchor, constant: 16),
            logsTableView.trailingAnchor.constraint(equalTo: logsContainerView.trailingAnchor, constant: -16),
            logsTableView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -12),

            buttonStackView.leadingAnchor.constraint(equalTo: logsContainerView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: logsContainerView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: logsContainerView.bottomAnchor, constant: -16)
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
        clearLogsButton.addTarget(self, action: #selector(clearLogsTapped), for: .touchUpInside)
        exportLogsButton.addTarget(self, action: #selector(exportLogsTapped), for: .touchUpInside)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(errorOccurred(_:)),
            name: .errorOccurred,
            object: nil
        )
    }

    private func handleRouteParameters() {
        // 处理路由参数
        if let parameters = routeParameters {
            if let action = parameters["action"] as? String {
                switch action {
                case "clearLogs":
                    clearLogs()
                case "exportLogs":
                    exportLogs()
                case "generateTestError":
                    generateTestError()
                default:
                    break
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func createExampleButton(title: String, description: String, route: String, color: UIColor) -> UIView {
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
        button.addTarget(self, action: #selector(exampleButtonTapped(_:)), for: .touchUpInside)
        button.tag = route.hashValue
        containerView.addSubview(button)

        // 存储路由信息
        objc_setAssociatedObject(button, "route", route, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),

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

    private func updateErrorStats() {
        let logs = ErrorManager.shared.getErrorLogs()
        errorLogs = logs

        totalErrorsLabel.text = "总错误数: \(logs.count)"

        // 计算最近24小时的错误数
        let yesterday = Date().addingTimeInterval(-24 * 60 * 60)
        let recentErrors = logs.filter { $0.timestamp > yesterday }
        recentErrorsLabel.text = "最近24小时: \(recentErrors.count)"

        // 计算错误类型数
        let errorTypes = Set(logs.map { $0.errorType })
        errorTypesLabel.text = "错误类型: \(errorTypes.count)种"
    }

    private func reloadErrorLogs() {
        errorLogs = ErrorManager.shared.getErrorLogs()
        logsTableView.reloadData()
    }

    private func clearLogs() {
        ErrorManager.shared.clearErrorLogs()
        updateErrorStats()
        reloadErrorLogs()
    }

    private func exportLogs() {
        let logString = ErrorManager.shared.exportErrorLogs()

        let activityVC = UIActivityViewController(activityItems: [logString], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = exportLogsButton
        present(activityVC, animated: true)
    }

    private func generateTestError() {
        // 生成一个测试错误
        let testError = RouterKit.RouterError.routeNotFound("/test/route", debugInfo: "Generated test error")
        ErrorManager.shared.handleError(testError, context: nil)
    }

    // MARK: - Action Methods

    @objc private func backButtonTapped() {
        Router.pop()
    }

    @objc private func exampleButtonTapped(_ sender: UIButton) {
        guard let route = objc_getAssociatedObject(sender, "route") as? String else { return }

        Router.shared.navigate(to: route) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("导航到 \(route) 失败: \(error.localizedDescription)")
            }
        }
    }

    @objc private func clearLogsTapped() {
        let alert = UIAlertController(title: "清空日志", message: "确定要清空所有错误日志吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            self.clearLogs()
        })
        present(alert, animated: true)
    }

    @objc private func exportLogsTapped() {
        exportLogs()
    }

    @objc private func errorOccurred(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateErrorStats()
            self.reloadErrorLogs()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ErrorHandlingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(errorLogs.count, 10) // 最多显示10条
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorLogCell", for: indexPath) as! ErrorLogCell
        let errorLog = errorLogs[indexPath.row]

        // 将ErrorLog转换为SimpleErrorLog
        let level: LogLevel
        switch errorLog.errorType {
        case .router, .network, .auth, .module:
            level = .error
        case .interceptor:
            level = .warning
        case .general:
            level = .info
        }

        let simpleLog = SimpleErrorLog(
            level: level,
            message: errorLog.error.localizedDescription,
            module: errorLog.errorType.rawValue,
            timestamp: errorLog.timestamp,
            userInfo: nil
        )

        cell.configure(with: simpleLog)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let errorLog = errorLogs[indexPath.row]
        showErrorDetails(errorLog)
    }

    private func showErrorDetails(_ errorLog: ErrorLog) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var message = "时间: \(formatter.string(from: errorLog.timestamp))\n"
        message += "类型: \(errorLog.errorType.rawValue)\n"
        message += "错误: \(errorLog.error.localizedDescription)\n"

        if let context = errorLog.context {
            message += "路由: \(context.url)\n"
            if !context.parameters.isEmpty {
                message += "参数: \(context.parameters)"
            }
        }

        let alert = UIAlertController(title: "错误详情", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "重试", style: .default) { _ in
            ErrorManager.shared.retryOperation(for: errorLog) { success in
                DispatchQueue.main.async {
                    let resultMessage = success ? "重试成功" : "重试失败"
                    let resultAlert = UIAlertController(title: "重试结果", message: resultMessage, preferredStyle: .alert)
                    resultAlert.addAction(UIAlertAction(title: "确定", style: .default))
                    self.present(resultAlert, animated: true)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "关闭", style: .cancel))
        present(alert, animated: true)
    }
}
