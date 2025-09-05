//
//  DeepLinkTestViewController.swift
//  MyMainProject
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 深度链接测试页面
class DeepLinkTestViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return DeepLinkTestViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTestButtons()
    }
    
    private func setupUI() {
        title = "深度链接测试"
        view.backgroundColor = .systemBackground
        
        // 设置导航栏
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "生成链接",
            style: .plain,
            target: self,
            action: #selector(generateLinksButtonTapped)
        )
        
        // 设置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTestButtons() {
        // 添加说明标签
        let titleLabel = createTitleLabel("深度链接测试")
        let descriptionLabel = createDescriptionLabel("点击下方按钮测试不同的深度链接功能")
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(createSeparator())
        
        // URL Scheme 测试
        let urlSchemeSection = createSectionView("URL Scheme 测试")
        stackView.addArrangedSubview(urlSchemeSection)
        
        let urlSchemeTests = [
            ("登录页面", "routerkit-example://login"),
            ("消息页面", "routerkit-example://message"),
            ("个人资料", "routerkit-example://profile"),
            ("编辑资料", "routerkit-example://profile/edit"),
            ("设置页面", "routerkit-example://settings"),
            ("主题设置", "routerkit-example://settings/theme"),
            ("通知设置", "routerkit-example://settings/notification")
        ]
        
        for (title, urlString) in urlSchemeTests {
            let button = createTestButton(title: title) {
                self.testURLScheme(urlString)
            }
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // Universal Links 测试
        let universalLinkSection = createSectionView("Universal Links 测试")
        stackView.addArrangedSubview(universalLinkSection)
        
        let universalLinkTests = [
            ("登录页面", "https://routerkit.example.com/login"),
            ("消息页面", "https://routerkit.example.com/message"),
            ("个人资料", "https://routerkit.example.com/profile"),
            ("编辑资料", "https://routerkit.example.com/profile/edit"),
            ("设置页面", "https://routerkit.example.com/settings"),
            ("主题设置", "https://routerkit.example.com/settings/theme")
        ]
        
        for (title, urlString) in universalLinkTests {
            let button = createTestButton(title: title) {
                self.testUniversalLink(urlString)
            }
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 参数测试
        let parameterSection = createSectionView("参数传递测试")
        stackView.addArrangedSubview(parameterSection)
        
        let parameterTests = [
            ("消息详情 (ID=123)", "routerkit-example://message?id=123&title=测试消息"),
            ("用户资料 (ID=456)", "routerkit-example://profile?userId=456&tab=info"),
            ("主题设置 (深色)", "routerkit-example://settings/theme?theme=dark"),
            ("通知设置 (启用)", "routerkit-example://settings/notification?enabled=true")
        ]
        
        for (title, urlString) in parameterTests {
            let button = createTestButton(title: title) {
                self.testURLScheme(urlString)
            }
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 工具按钮
        let toolsSection = createSectionView("测试工具")
        stackView.addArrangedSubview(toolsSection)
        
        let runAllTestsButton = createTestButton(title: "运行所有测试") {
            self.runAllTests()
        }
        runAllTestsButton.backgroundColor = .systemBlue
        stackView.addArrangedSubview(runAllTestsButton)
        
        let clearConsoleButton = createTestButton(title: "清空控制台") {
            self.clearConsole()
        }
        clearConsoleButton.backgroundColor = .systemGray
        stackView.addArrangedSubview(clearConsoleButton)
    }
    
    // MARK: - UI Helper Methods
    
    private func createTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }
    
    private func createDescriptionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }
    
    private func createSectionView(_ title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 8
        
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    private func createTestButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        // Store action in button's tag or use objc_setAssociatedObject for iOS 13 compatibility
        let actionWrapper = ActionWrapper(action: action)
        objc_setAssociatedObject(button, &AssociatedKeys.actionKey, actionWrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if let actionWrapper = objc_getAssociatedObject(sender, &AssociatedKeys.actionKey) as? ActionWrapper {
            actionWrapper.action()
        }
    }
    
    private class ActionWrapper {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
    }
    
    private struct AssociatedKeys {
        static var actionKey: UInt8 = 0
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    // MARK: - Test Methods
    
    private func testURLScheme(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            showAlert(title: "错误", message: "无效的URL: \(urlString)")
            return
        }
        
        print("\n=== 测试URL Scheme ===")
        print("URL: \(urlString)")
        
        let success = DeepLinkHandler.shared.handleURLScheme(url)
        
        let message = success ? "URL Scheme处理成功" : "URL Scheme处理失败"
        showAlert(title: "测试结果", message: "\(message)\n\nURL: \(urlString)")
        
        print("结果: \(message)")
        print("=== 测试结束 ===\n")
    }
    
    private func testUniversalLink(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            showAlert(title: "错误", message: "无效的URL: \(urlString)")
            return
        }
        
        print("\n=== 测试Universal Link ===")
        print("URL: \(urlString)")
        
        let success = DeepLinkHandler.shared.handleUniversalLink(url)
        
        let message = success ? "Universal Link处理成功" : "Universal Link处理失败"
        showAlert(title: "测试结果", message: "\(message)\n\nURL: \(urlString)")
        
        print("结果: \(message)")
        print("=== 测试结束 ===\n")
    }
    
    private func runAllTests() {
        showAlert(title: "运行测试", message: "开始运行所有深度链接测试，请查看控制台输出") {
            DeepLinkHandler.shared.testDeepLinks()
        }
    }
    
    private func clearConsole() {
        print("\n" + String(repeating: "=", count: 50))
        print("控制台已清空")
        print(String(repeating: "=", count: 50) + "\n")
        
        showAlert(title: "提示", message: "控制台已清空")
    }
    
    @objc private func generateLinksButtonTapped() {
        let links = DeepLinkHandler.shared.generateTestLinks()
        let message = links.joined(separator: "\n\n")
        
        let alertController = UIAlertController(
            title: "生成的测试链接",
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "复制全部", style: .default) { _ in
            UIPasteboard.general.string = message
            self.showAlert(title: "提示", message: "链接已复制到剪贴板")
        })
        
        alertController.addAction(UIAlertAction(title: "关闭", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            completion?()
        })
        present(alertController, animated: true)
    }
}

// MARK: - DeepLinkTestViewController Extension
extension DeepLinkTestViewController {
    
    /// 添加分享功能测试
    private func setupShareTests() {
        let shareSection = createSectionView("分享功能测试")
        stackView.addArrangedSubview(shareSection)
        
        let shareButton = createTestButton(title: "分享当前页面") {
            self.testShareFunction()
        }
        shareButton.backgroundColor = .systemOrange
        stackView.addArrangedSubview(shareButton)
    }
    
    private func testShareFunction() {
        DeepLinkHandler.shared.shareDeepLink(
            route: "/ProfileModule/profile",
            parameters: ["userId": 123, "tab": "info"],
            from: self,
            useUniversalLink: true
        )
    }
}
