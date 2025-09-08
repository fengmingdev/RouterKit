//
//  InterceptorViewController.swift
//  InterceptorModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 拦截器示例主页面
class InterceptorViewController: UIViewController, Routable {

    // 路由参数
    var routeParameters: RouterParameters?

    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let viewController = InterceptorViewController()
        viewController.routeParameters = parameters
        return viewController
    }

    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "enableAuthInterceptor":
            InterceptorManager.shared.enableInterceptor("auth")
            completion(.success("认证拦截器已启用"))
        case "disableAuthInterceptor":
            InterceptorManager.shared.disableInterceptor("auth")
            completion(.success("认证拦截器已禁用"))
        case "clearLogs":
            InterceptorLogger.shared.clearLogs()
            completion(.success("拦截器日志已清除"))
        case "resetStats":
            InterceptorStats.shared.reset()
            completion(.success("拦截器统计已重置"))
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let statsView = UIView()
    private let statsLabel = UILabel()
    private let refreshStatsButton = UIButton(type: .system)

    // 拦截器示例按钮
    private let authInterceptorButton = UIButton(type: .system)
    private let dataPreloadButton = UIButton(type: .system)
    private let loggingButton = UIButton(type: .system)
    private let performanceButton = UIButton(type: .system)
    private let securityButton = UIButton(type: .system)
    private let cacheButton = UIButton(type: .system)
    private let chainButton = UIButton(type: .system)

    // 管理按钮
    private let viewLogsButton = UIButton(type: .system)
    private let clearLogsButton = UIButton(type: .system)
    private let resetStatsButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateStats()

        // 处理路由参数
        handleRouteParameters()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "拦截器示例"

        // 标题
        titleLabel.text = "RouterKit 拦截器示例"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center

        // 描述
        descriptionLabel.text = "探索各种拦截器的功能和使用场景"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        // 统计视图
        setupStatsView()

        // 拦截器示例按钮
        setupInterceptorButton(authInterceptorButton,
                             title: "🔐 权限拦截器",
                             subtitle: "用户登录和权限检查",
                             backgroundColor: .systemBlue)

        setupInterceptorButton(dataPreloadButton,
                             title: "📊 数据预加载拦截器",
                             subtitle: "导航前预加载必要数据",
                             backgroundColor: .systemGreen)

        setupInterceptorButton(loggingButton,
                             title: "📝 日志拦截器",
                             subtitle: "记录导航和操作日志",
                             backgroundColor: .systemOrange)

        setupInterceptorButton(performanceButton,
                             title: "⚡ 性能监控拦截器",
                             subtitle: "监控导航性能和内存使用",
                             backgroundColor: .systemPurple)

        setupInterceptorButton(securityButton,
                             title: "🛡️ 安全拦截器",
                             subtitle: "安全检查和速率限制",
                             backgroundColor: .systemRed)

        setupInterceptorButton(cacheButton,
                             title: "💾 缓存拦截器",
                             subtitle: "缓存路由结果和数据",
                             backgroundColor: .systemTeal)

        setupInterceptorButton(chainButton,
                             title: "🔗 拦截器链",
                             subtitle: "多个拦截器组合使用",
                             backgroundColor: .systemIndigo)

        // 管理按钮
        setupManagementButton(viewLogsButton, title: "查看日志", backgroundColor: .systemGray)
        setupManagementButton(clearLogsButton, title: "清空日志", backgroundColor: .systemGray2)
        setupManagementButton(resetStatsButton, title: "重置统计", backgroundColor: .systemGray3)

        // 添加按钮事件
        authInterceptorButton.addTarget(self, action: #selector(authInterceptorTapped), for: .touchUpInside)
        dataPreloadButton.addTarget(self, action: #selector(dataPreloadTapped), for: .touchUpInside)
        loggingButton.addTarget(self, action: #selector(loggingTapped), for: .touchUpInside)
        performanceButton.addTarget(self, action: #selector(performanceTapped), for: .touchUpInside)
        securityButton.addTarget(self, action: #selector(securityTapped), for: .touchUpInside)
        cacheButton.addTarget(self, action: #selector(cacheTapped), for: .touchUpInside)
        chainButton.addTarget(self, action: #selector(chainTapped), for: .touchUpInside)

        viewLogsButton.addTarget(self, action: #selector(viewLogsTapped), for: .touchUpInside)
        clearLogsButton.addTarget(self, action: #selector(clearLogsTapped), for: .touchUpInside)
        resetStatsButton.addTarget(self, action: #selector(resetStatsTapped), for: .touchUpInside)
        refreshStatsButton.addTarget(self, action: #selector(refreshStatsTapped), for: .touchUpInside)

        // 添加到视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, descriptionLabel, statsView,
         authInterceptorButton, dataPreloadButton, loggingButton, performanceButton,
         securityButton, cacheButton, chainButton,
         viewLogsButton, clearLogsButton, resetStatsButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupStatsView() {
        statsView.backgroundColor = .systemGray6
        statsView.layer.cornerRadius = 12

        statsLabel.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        statsLabel.numberOfLines = 0
        statsLabel.textAlignment = .left

        refreshStatsButton.setTitle("刷新", for: .normal)
        refreshStatsButton.setTitleColor(.systemBlue, for: .normal)
        refreshStatsButton.titleLabel?.font = .boldSystemFont(ofSize: 14)

        statsView.addSubview(statsLabel)
        statsView.addSubview(refreshStatsButton)

        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        refreshStatsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            statsLabel.topAnchor.constraint(equalTo: statsView.topAnchor, constant: 12),
            statsLabel.leadingAnchor.constraint(equalTo: statsView.leadingAnchor, constant: 12),
            statsLabel.trailingAnchor.constraint(equalTo: refreshStatsButton.leadingAnchor, constant: -8),
            statsLabel.bottomAnchor.constraint(equalTo: statsView.bottomAnchor, constant: -12),

            refreshStatsButton.topAnchor.constraint(equalTo: statsView.topAnchor, constant: 12),
            refreshStatsButton.trailingAnchor.constraint(equalTo: statsView.trailingAnchor, constant: -12),
            refreshStatsButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupInterceptorButton(_ button: UIButton, title: String, subtitle: String, backgroundColor: UIColor) {
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 12
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        // 创建标题和副标题的属性字符串
        let attributedTitle = NSMutableAttributedString()

        // 主标题
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.white
        ]
        attributedTitle.append(NSAttributedString(string: title, attributes: titleAttributes))

        // 副标题
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        attributedTitle.append(NSAttributedString(string: "\n\(subtitle)", attributes: subtitleAttributes))

        button.setAttributedTitle(attributedTitle, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
    }

    private func setupManagementButton(_ button: UIButton, title: String, backgroundColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Stats View
            statsView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            statsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Interceptor buttons
            authInterceptorButton.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 20),
            authInterceptorButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            authInterceptorButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            authInterceptorButton.heightAnchor.constraint(equalToConstant: 70),

            dataPreloadButton.topAnchor.constraint(equalTo: authInterceptorButton.bottomAnchor, constant: 12),
            dataPreloadButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dataPreloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dataPreloadButton.heightAnchor.constraint(equalToConstant: 70),

            loggingButton.topAnchor.constraint(equalTo: dataPreloadButton.bottomAnchor, constant: 12),
            loggingButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loggingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loggingButton.heightAnchor.constraint(equalToConstant: 70),

            performanceButton.topAnchor.constraint(equalTo: loggingButton.bottomAnchor, constant: 12),
            performanceButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            performanceButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            performanceButton.heightAnchor.constraint(equalToConstant: 70),

            securityButton.topAnchor.constraint(equalTo: performanceButton.bottomAnchor, constant: 12),
            securityButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            securityButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            securityButton.heightAnchor.constraint(equalToConstant: 70),

            cacheButton.topAnchor.constraint(equalTo: securityButton.bottomAnchor, constant: 12),
            cacheButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cacheButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cacheButton.heightAnchor.constraint(equalToConstant: 70),

            chainButton.topAnchor.constraint(equalTo: cacheButton.bottomAnchor, constant: 12),
            chainButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chainButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chainButton.heightAnchor.constraint(equalToConstant: 70),

            // Management buttons (3 in a row)
            viewLogsButton.topAnchor.constraint(equalTo: chainButton.bottomAnchor, constant: 20),
            viewLogsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            viewLogsButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            viewLogsButton.heightAnchor.constraint(equalToConstant: 44),

            clearLogsButton.topAnchor.constraint(equalTo: chainButton.bottomAnchor, constant: 20),
            clearLogsButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            clearLogsButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            clearLogsButton.heightAnchor.constraint(equalToConstant: 44),

            resetStatsButton.topAnchor.constraint(equalTo: chainButton.bottomAnchor, constant: 20),
            resetStatsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resetStatsButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            resetStatsButton.heightAnchor.constraint(equalToConstant: 44),
            resetStatsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Route Parameters

    private func handleRouteParameters() {
        // 处理从路由传递过来的参数
        if let parameters = routeParameters {
            // 检查是否有特定的拦截器测试请求
            if let testType = parameters["testType"] as? String {
                switch testType {
                case "auth":
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.authInterceptorTapped()
                    }
                case "dataPreload":
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dataPreloadTapped()
                    }
                case "performance":
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.performanceTapped()
                    }
                default:
                    break
                }
            }
        }
    }

    // MARK: - Actions

    @objc private func authInterceptorTapped() {
        Router.push(to: "/InterceptorModule/auth", parameters: [
            "source": "interceptorMain",
            "timestamp": Date().timeIntervalSince1970
        ], completion: { _ in })
    }

    @objc private func dataPreloadTapped() {
        Router.push(to: "/InterceptorModule/dataPreload", parameters: [
            "source": "interceptorMain",
            "timestamp": Date().timeIntervalSince1970
        ], completion: { _ in })
    }

    @objc private func loggingTapped() {
        Router.push(to: "/InterceptorModule/logging", parameters: [
            "source": "interceptorMain",
            "timestamp": Date().timeIntervalSince1970
        ], completion: { _ in })
    }

    @objc private func performanceTapped() {
        Router.push(to: "/InterceptorModule/performance", parameters: [
            "source": "interceptorMain",
            "timestamp": Date().timeIntervalSince1970
        ], completion: { _ in })
    }

    @objc private func securityTapped() {
        Router.push(to: "/InterceptorModule/security", parameters: [
            "source": "interceptorMain",
            "timestamp": Date().timeIntervalSince1970
        ], completion: { _ in })
    }

    @objc private func cacheTapped() {
        Router.push(to: "/InterceptorModule/cache", parameters: [
            "source": "interceptorMain",
            "timestamp": Date().timeIntervalSince1970
        ], completion: { _ in })
    }

    @objc private func chainTapped() {
        Router.push(to: "/InterceptorModule/chain", parameters: [
            "source": "interceptorMain",
            "timestamp": Date().timeIntervalSince1970
        ], completion: { _ in })
    }

    @objc private func viewLogsTapped() {
        let logs = InterceptorManager.shared.getLogs()
        let alert = UIAlertController(title: "拦截器日志", message: "共 \(logs.count) 条日志", preferredStyle: .alert)

        if logs.isEmpty {
            alert.message = "暂无日志记录"
        } else {
            let recentLogs = Array(logs.suffix(5))
            let logMessages = recentLogs.map { log in
                "[\(log.interceptorName)] \(log.action): \(log.message)"
            }.joined(separator: "\n")
            alert.message = "最近 \(recentLogs.count) 条日志:\n\n\(logMessages)"
        }

        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    @objc private func clearLogsTapped() {
        InterceptorManager.shared.clearLogs()
        updateStats()

        let alert = UIAlertController(title: "清空完成", message: "所有拦截器日志已清空", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    @objc private func resetStatsTapped() {
        InterceptorStats.shared.reset()
        updateStats()

        let alert = UIAlertController(title: "重置完成", message: "所有统计数据已重置", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    @objc private func refreshStatsTapped() {
        updateStats()
    }

    // MARK: - Helper Methods

    private func updateStats() {
        let manager = InterceptorManager.shared
        let logs = manager.getLogs()
        let metrics = manager.getPerformanceMetrics()
        let securityEvents = manager.getSecurityEvents()

        let statsText = """
        📊 拦截器统计信息

        📝 日志记录: \(logs.count) 条
        ⚡ 性能指标: \(metrics.count) 条
        🛡️ 安全事件: \(securityEvents.count) 条
        💾 缓存条目: \(manager.getCacheSize()) 个

        最后更新: \(DateFormatter.statsFormatter.string(from: Date()))
        """

        statsLabel.text = statsText
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let statsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
