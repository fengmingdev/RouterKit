//
//  AuthInterceptorViewController.swift
//  InterceptorModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 权限拦截器示例页面
class AuthInterceptorViewController: UIViewController, Routable {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let statusLabel = UILabel()
    private let logTextView = UITextView()

    // 测试按钮
    private let loginButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    private let testPublicRouteButton = UIButton(type: .system)
    private let testPrivateRouteButton = UIButton(type: .system)
    private let testAdminRouteButton = UIButton(type: .system)
    private let clearLogButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateLoginStatus()

        // 处理路由参数
        handleRouteParameters()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "权限拦截器"

        // 标题
        titleLabel.text = "权限拦截器示例"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center

        // 描述
        descriptionLabel.text = "演示如何使用权限拦截器检查用户登录状态和权限"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        // 状态标签
        statusLabel.font = .boldSystemFont(ofSize: 18)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true

        // 日志文本视图
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.backgroundColor = .systemGray6
        logTextView.layer.cornerRadius = 8
        logTextView.isEditable = false
        logTextView.text = "权限拦截器日志将显示在这里...\n"

        // 登录/登出按钮
        setupButton(loginButton, title: "模拟登录", backgroundColor: .systemGreen)
        setupButton(logoutButton, title: "模拟登出", backgroundColor: .systemRed)

        // 测试按钮
        setupButton(testPublicRouteButton, title: "访问公开路由", backgroundColor: .systemBlue)
        setupButton(testPrivateRouteButton, title: "访问私有路由", backgroundColor: .systemOrange)
        setupButton(testAdminRouteButton, title: "访问管理员路由", backgroundColor: .systemPurple)

        // 清空日志按钮
        setupButton(clearLogButton, title: "清空日志", backgroundColor: .systemGray)

        // 添加按钮事件
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        testPublicRouteButton.addTarget(self, action: #selector(testPublicRouteTapped), for: .touchUpInside)
        testPrivateRouteButton.addTarget(self, action: #selector(testPrivateRouteTapped), for: .touchUpInside)
        testAdminRouteButton.addTarget(self, action: #selector(testAdminRouteTapped), for: .touchUpInside)
        clearLogButton.addTarget(self, action: #selector(clearLogTapped), for: .touchUpInside)

        // 添加到视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, descriptionLabel, statusLabel, logTextView,
         loginButton, logoutButton, testPublicRouteButton,
         testPrivateRouteButton, testAdminRouteButton, clearLogButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupButton(_ button: UIButton, title: String, backgroundColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
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

            // Status
            statusLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statusLabel.heightAnchor.constraint(equalToConstant: 44),

            // Login/Logout buttons
            loginButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            loginButton.heightAnchor.constraint(equalToConstant: 44),

            logoutButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),

            // Test buttons
            testPublicRouteButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            testPublicRouteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testPublicRouteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testPublicRouteButton.heightAnchor.constraint(equalToConstant: 44),

            testPrivateRouteButton.topAnchor.constraint(equalTo: testPublicRouteButton.bottomAnchor, constant: 10),
            testPrivateRouteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testPrivateRouteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testPrivateRouteButton.heightAnchor.constraint(equalToConstant: 44),

            testAdminRouteButton.topAnchor.constraint(equalTo: testPrivateRouteButton.bottomAnchor, constant: 10),
            testAdminRouteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testAdminRouteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testAdminRouteButton.heightAnchor.constraint(equalToConstant: 44),

            // Log TextView
            logTextView.topAnchor.constraint(equalTo: testAdminRouteButton.bottomAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logTextView.heightAnchor.constraint(equalToConstant: 200),

            // Clear Log button
            clearLogButton.topAnchor.constraint(equalTo: logTextView.bottomAnchor, constant: 10),
            clearLogButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            clearLogButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            clearLogButton.heightAnchor.constraint(equalToConstant: 44),
            clearLogButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Route Parameters

    private func handleRouteParameters() {
        // 这里可以处理从路由传递过来的参数
        // 例如：预设的权限测试场景
    }

    // MARK: - Actions

    @objc private func loginTapped() {
        // 模拟登录
        MockUserSession.shared.login()
        updateLoginStatus()
        addLog("✅ 用户已登录")
    }

    @objc private func logoutTapped() {
        // 模拟登出
        MockUserSession.shared.logout()
        updateLoginStatus()
        addLog("❌ 用户已登出")
    }

    @objc private func testPublicRouteTapped() {
        addLog("🔍 测试公开路由访问...")

        // 使用RouterKit导航到公开路由
        Router.shared.navigate(to: "/InterceptorModule/public", config: NavigationConfig(
            parameters: [
                "testType": "public",
                "timestamp": Date().timeIntervalSince1970
            ]
        )) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.addLog("✅ 公开路由访问成功")
                case .failure(let error):
                    self?.addLog("❌ 公开路由访问失败: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func testPrivateRouteTapped() {
        addLog("🔍 测试私有路由访问...")

        // 使用RouterKit导航到需要登录的私有路由
        Router.shared.navigate(to: "/InterceptorModule/private", config: NavigationConfig(
            parameters: [
                "testType": "private",
                "requiredPermission": "read",
                "timestamp": Date().timeIntervalSince1970
            ]
        )) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.addLog("✅ 私有路由访问成功")
                case .failure(let error):
                    self?.addLog("❌ 私有路由访问失败: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func testAdminRouteTapped() {
        addLog("🔍 测试管理员路由访问...")

        // 使用RouterKit导航到需要管理员权限的路由
        Router.shared.navigate(to: "/InterceptorModule/admin", config: NavigationConfig(
            parameters: [
                "testType": "admin",
                "requiredPermission": "admin",
                "timestamp": Date().timeIntervalSince1970
            ]
        )) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.addLog("✅ 管理员路由访问成功")
                case .failure(let error):
                    self?.addLog("❌ 管理员路由访问失败: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func clearLogTapped() {
        logTextView.text = "权限拦截器日志将显示在这里...\n"
    }

    // MARK: - Helper Methods

    private func updateLoginStatus() {
        let isLoggedIn = MockUserSession.shared.isLoggedIn

        if isLoggedIn {
            statusLabel.text = "✅ 已登录"
            statusLabel.backgroundColor = .systemGreen
            statusLabel.textColor = .white
        } else {
            statusLabel.text = "❌ 未登录"
            statusLabel.backgroundColor = .systemRed
            statusLabel.textColor = .white
        }
    }

    private func addLog(_ message: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] \(message)\n"
        logTextView.text += logMessage

        // 滚动到底部
        let bottom = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(bottom)
    }

    // MARK: - Routable Protocol

    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return AuthInterceptorViewController()
    }

    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "login":
            MockUserSession.shared.login()
            completion(.success("登录成功"))
        case "logout":
            MockUserSession.shared.logout()
            completion(.success("登出成功"))
        case "grantAdmin":
            MockUserSession.shared.grantAdminPermission()
            completion(.success("管理员权限已授予"))
        case "clearLogs":
            completion(.success("日志已清除"))
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }
}

// MARK: - Mock User Session

/// 模拟用户会话（用于演示）
class MockUserSession {
    static let shared = MockUserSession()

    private init() {}

    private var _isLoggedIn = false
    private var _permissions: Set<String> = []

    var isLoggedIn: Bool {
        return _isLoggedIn
    }

    func login() {
        _isLoggedIn = true
        _permissions = ["read", "write"] // 普通用户权限
    }

    func logout() {
        _isLoggedIn = false
        _permissions = []
    }

    func hasPermission(_ permission: String) -> Bool {
        return _permissions.contains(permission)
    }

    func grantAdminPermission() {
        _permissions.insert("admin")
    }
}

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
