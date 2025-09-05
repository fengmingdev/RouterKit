//
//  NetworkErrorViewController.swift
//  ErrorHandlingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 网络错误示例页面
class NetworkErrorViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let viewController = NetworkErrorViewController()
        viewController.routeParameters = parameters
        return viewController
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // 网络状态
    private let statusContainerView = UIView()
    private let networkStatusLabel = UILabel()
    private let connectionTypeLabel = UILabel()
    private let latencyLabel = UILabel()
    
    // 错误测试按钮
    private let testStackView = UIStackView()
    
    // 请求信息显示
    private let requestInfoView = UIView()
    private let requestTitleLabel = UILabel()
    private let requestDetailsLabel = UILabel()
    private let responseLabel = UILabel()
    
    // 重试配置
    private let retryConfigView = UIView()
    private let maxRetriesSlider = UISlider()
    private let retryDelaySlider = UISlider()
    private let maxRetriesLabel = UILabel()
    private let retryDelayLabel = UILabel()
    
    // MARK: - Properties
    
    private var currentRequest: NetworkRequest?
    private var retryCount = 0
    private var maxRetries = 3
    private var retryDelay: TimeInterval = 1.0
    private var routeParameters: RouterParameters?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        updateNetworkStatus()
        handleRouteParameters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNetworkStatus()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "网络错误"
        
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
        titleLabel.text = "网络错误示例"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 配置描述
        descriptionLabel.text = "演示各种网络错误场景，包括连接超时、服务器错误、网络不可用等，以及相应的重试策略和错误恢复机制。"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        setupStatusSection()
        setupTestSection()
        setupRequestInfoSection()
        setupRetryConfigSection()
    }
    
    private func setupStatusSection() {
        let statusLabel = UILabel()
        statusLabel.text = "网络状态"
        statusLabel.font = .boldSystemFont(ofSize: 18)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        statusContainerView.backgroundColor = .systemGray6
        statusContainerView.layer.cornerRadius = 12
        statusContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusContainerView)
        
        let statusStackView = UIStackView()
        statusStackView.axis = .vertical
        statusStackView.spacing = 8
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        statusContainerView.addSubview(statusStackView)
        
        networkStatusLabel.text = "网络状态: 检测中..."
        networkStatusLabel.font = .systemFont(ofSize: 16)
        networkStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        connectionTypeLabel.text = "连接类型: 未知"
        connectionTypeLabel.font = .systemFont(ofSize: 16)
        connectionTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        latencyLabel.text = "延迟: 未测试"
        latencyLabel.font = .systemFont(ofSize: 16)
        latencyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusStackView.addArrangedSubview(networkStatusLabel)
        statusStackView.addArrangedSubview(connectionTypeLabel)
        statusStackView.addArrangedSubview(latencyLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusContainerView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            statusContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusStackView.topAnchor.constraint(equalTo: statusContainerView.topAnchor, constant: 16),
            statusStackView.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor, constant: 16),
            statusStackView.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor, constant: -16),
            statusStackView.bottomAnchor.constraint(equalTo: statusContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTestSection() {
        let testLabel = UILabel()
        testLabel.text = "网络错误测试"
        testLabel.font = .boldSystemFont(ofSize: 18)
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testLabel)
        
        testStackView.axis = .vertical
        testStackView.spacing = 12
        testStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testStackView)
        
        let tests = [
            ("连接超时", "模拟网络连接超时", "testConnectionTimeout", UIColor.systemRed),
            ("请求超时", "模拟请求处理超时", "testRequestTimeout", UIColor.systemOrange),
            ("网络不可用", "模拟网络连接不可用", "testNetworkUnavailable", UIColor.systemYellow),
            ("服务器错误 (500)", "模拟服务器内部错误", "testServerError", UIColor.systemPink),
            ("未找到资源 (404)", "模拟资源未找到错误", "testNotFound", UIColor.systemPurple),
            ("未授权 (401)", "模拟认证失败错误", "testUnauthorized", UIColor.systemBlue),
            ("请求过于频繁 (429)", "模拟请求限流错误", "testTooManyRequests", UIColor.systemGreen),
            ("DNS解析失败", "模拟域名解析失败", "testDNSFailure", UIColor.systemIndigo),
            ("SSL证书错误", "模拟SSL证书验证失败", "testSSLError", UIColor.systemBrown)
        ]
        
        for (title, description, action, color) in tests {
            let button = createTestButton(title: title, description: description, action: action, color: color)
            testStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            testLabel.topAnchor.constraint(equalTo: statusContainerView.bottomAnchor, constant: 30),
            testLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            testStackView.topAnchor.constraint(equalTo: testLabel.bottomAnchor, constant: 12),
            testStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupRequestInfoSection() {
        let requestLabel = UILabel()
        requestLabel.text = "请求信息"
        requestLabel.font = .boldSystemFont(ofSize: 18)
        requestLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(requestLabel)
        
        requestInfoView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        requestInfoView.layer.cornerRadius = 12
        requestInfoView.layer.borderWidth = 1
        requestInfoView.layer.borderColor = UIColor.systemBlue.cgColor
        requestInfoView.isHidden = true
        requestInfoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(requestInfoView)
        
        requestTitleLabel.text = "暂无请求"
        requestTitleLabel.font = .boldSystemFont(ofSize: 16)
        requestTitleLabel.textColor = .systemBlue
        requestTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        requestInfoView.addSubview(requestTitleLabel)
        
        requestDetailsLabel.text = ""
        requestDetailsLabel.font = .systemFont(ofSize: 14)
        requestDetailsLabel.textColor = .label
        requestDetailsLabel.numberOfLines = 0
        requestDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        requestInfoView.addSubview(requestDetailsLabel)
        
        responseLabel.text = ""
        responseLabel.font = .systemFont(ofSize: 12)
        responseLabel.textColor = .secondaryLabel
        responseLabel.numberOfLines = 0
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        requestInfoView.addSubview(responseLabel)
        
        NSLayoutConstraint.activate([
            requestLabel.topAnchor.constraint(equalTo: testStackView.bottomAnchor, constant: 30),
            requestLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            requestLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            requestInfoView.topAnchor.constraint(equalTo: requestLabel.bottomAnchor, constant: 12),
            requestInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            requestInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            requestTitleLabel.topAnchor.constraint(equalTo: requestInfoView.topAnchor, constant: 16),
            requestTitleLabel.leadingAnchor.constraint(equalTo: requestInfoView.leadingAnchor, constant: 16),
            requestTitleLabel.trailingAnchor.constraint(equalTo: requestInfoView.trailingAnchor, constant: -16),
            
            requestDetailsLabel.topAnchor.constraint(equalTo: requestTitleLabel.bottomAnchor, constant: 8),
            requestDetailsLabel.leadingAnchor.constraint(equalTo: requestInfoView.leadingAnchor, constant: 16),
            requestDetailsLabel.trailingAnchor.constraint(equalTo: requestInfoView.trailingAnchor, constant: -16),
            
            responseLabel.topAnchor.constraint(equalTo: requestDetailsLabel.bottomAnchor, constant: 8),
            responseLabel.leadingAnchor.constraint(equalTo: requestInfoView.leadingAnchor, constant: 16),
            responseLabel.trailingAnchor.constraint(equalTo: requestInfoView.trailingAnchor, constant: -16),
            responseLabel.bottomAnchor.constraint(equalTo: requestInfoView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupRetryConfigSection() {
        let retryLabel = UILabel()
        retryLabel.text = "重试配置"
        retryLabel.font = .boldSystemFont(ofSize: 18)
        retryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(retryLabel)
        
        retryConfigView.backgroundColor = .systemGray6
        retryConfigView.layer.cornerRadius = 12
        retryConfigView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(retryConfigView)
        
        // 最大重试次数
        maxRetriesLabel.text = "最大重试次数: 3"
        maxRetriesLabel.font = .systemFont(ofSize: 16)
        maxRetriesLabel.translatesAutoresizingMaskIntoConstraints = false
        retryConfigView.addSubview(maxRetriesLabel)
        
        maxRetriesSlider.minimumValue = 1
        maxRetriesSlider.maximumValue = 10
        maxRetriesSlider.value = 3
        maxRetriesSlider.addTarget(self, action: #selector(maxRetriesChanged(_:)), for: .valueChanged)
        maxRetriesSlider.translatesAutoresizingMaskIntoConstraints = false
        retryConfigView.addSubview(maxRetriesSlider)
        
        // 重试延迟
        retryDelayLabel.text = "重试延迟: 1.0秒"
        retryDelayLabel.font = .systemFont(ofSize: 16)
        retryDelayLabel.translatesAutoresizingMaskIntoConstraints = false
        retryConfigView.addSubview(retryDelayLabel)
        
        retryDelaySlider.minimumValue = 0.5
        retryDelaySlider.maximumValue = 5.0
        retryDelaySlider.value = 1.0
        retryDelaySlider.addTarget(self, action: #selector(retryDelayChanged(_:)), for: .valueChanged)
        retryDelaySlider.translatesAutoresizingMaskIntoConstraints = false
        retryConfigView.addSubview(retryDelaySlider)
        
        NSLayoutConstraint.activate([
            retryLabel.topAnchor.constraint(equalTo: requestInfoView.bottomAnchor, constant: 30),
            retryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            retryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            retryConfigView.topAnchor.constraint(equalTo: retryLabel.bottomAnchor, constant: 12),
            retryConfigView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            retryConfigView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            retryConfigView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            maxRetriesLabel.topAnchor.constraint(equalTo: retryConfigView.topAnchor, constant: 16),
            maxRetriesLabel.leadingAnchor.constraint(equalTo: retryConfigView.leadingAnchor, constant: 16),
            maxRetriesLabel.trailingAnchor.constraint(equalTo: retryConfigView.trailingAnchor, constant: -16),
            
            maxRetriesSlider.topAnchor.constraint(equalTo: maxRetriesLabel.bottomAnchor, constant: 8),
            maxRetriesSlider.leadingAnchor.constraint(equalTo: retryConfigView.leadingAnchor, constant: 16),
            maxRetriesSlider.trailingAnchor.constraint(equalTo: retryConfigView.trailingAnchor, constant: -16),
            
            retryDelayLabel.topAnchor.constraint(equalTo: maxRetriesSlider.bottomAnchor, constant: 16),
            retryDelayLabel.leadingAnchor.constraint(equalTo: retryConfigView.leadingAnchor, constant: 16),
            retryDelayLabel.trailingAnchor.constraint(equalTo: retryConfigView.trailingAnchor, constant: -16),
            
            retryDelaySlider.topAnchor.constraint(equalTo: retryDelayLabel.bottomAnchor, constant: 8),
            retryDelaySlider.leadingAnchor.constraint(equalTo: retryConfigView.leadingAnchor, constant: 16),
            retryDelaySlider.trailingAnchor.constraint(equalTo: retryConfigView.trailingAnchor, constant: -16),
            retryDelaySlider.bottomAnchor.constraint(equalTo: retryConfigView.bottomAnchor, constant: -16)
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
        if let parameters = routeParameters,
           let errorType = parameters["errorType"] as? String {
            // 根据参数自动触发相应的错误测试
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performNetworkTest(errorType)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestButton(title: String, description: String, action: String, color: UIColor) -> UIView {
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
        button.addTarget(self, action: #selector(testButtonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(button)
        
        // 存储动作信息
        objc_setAssociatedObject(button, "action", action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
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
    
    private func updateNetworkStatus() {
        // 模拟网络状态检测
        networkStatusLabel.text = "网络状态: 已连接"
        networkStatusLabel.textColor = .systemGreen
        
        connectionTypeLabel.text = "连接类型: WiFi"
        
        // 模拟延迟测试
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let latency = Int.random(in: 20...200)
            self.latencyLabel.text = "延迟: \(latency)ms"
            
            if latency < 50 {
                self.latencyLabel.textColor = .systemGreen
            } else if latency < 100 {
                self.latencyLabel.textColor = .systemOrange
            } else {
                self.latencyLabel.textColor = .systemRed
            }
        }
    }
    
    private func performNetworkTest(_ testType: String) {
        switch testType {
        case "testConnectionTimeout":
            testConnectionTimeout()
        case "testRequestTimeout":
            testRequestTimeout()
        case "testNetworkUnavailable":
            testNetworkUnavailable()
        case "testServerError":
            testServerError()
        case "testNotFound":
            testNotFound()
        case "testUnauthorized":
            testUnauthorized()
        case "testTooManyRequests":
            testTooManyRequests()
        case "testDNSFailure":
            testDNSFailure()
        case "testSSLError":
            testSSLError()
        default:
            break
        }
    }
    
    private func showNetworkError(_ error: NetworkError, request: NetworkRequest) {
        currentRequest = request
        retryCount = 0
        
        requestInfoView.isHidden = false
        
        requestTitleLabel.text = "网络请求失败"
        requestDetailsLabel.text = "URL: \(request.url)\nMethod: \(request.method)\nTimeout: \(request.timeout)s"
        
        switch error {
        case .noConnection:
            responseLabel.text = "错误: 无网络连接\n建议: 请检查网络连接"
            requestInfoView.layer.borderColor = UIColor.systemRed.cgColor
        case .timeout:
            responseLabel.text = "错误: 请求超时\n建议: 请稍后重试"
            requestInfoView.layer.borderColor = UIColor.systemOrange.cgColor
        case .invalidResponse:
            responseLabel.text = "错误: 无效的服务器响应\n建议: 服务器返回了无效数据"
            requestInfoView.layer.borderColor = UIColor.systemYellow.cgColor
        case .connectionTimeout:
            responseLabel.text = "错误: 连接超时\n建议: 检查网络连接或增加超时时间"
            requestInfoView.layer.borderColor = UIColor.systemRed.cgColor
        case .requestTimeout:
            responseLabel.text = "错误: 请求超时\n建议: 服务器响应缓慢，请稍后重试"
            requestInfoView.layer.borderColor = UIColor.systemOrange.cgColor
        case .networkUnavailable:
            responseLabel.text = "错误: 网络不可用\n建议: 请检查网络连接"
            requestInfoView.layer.borderColor = UIColor.systemRed.cgColor
        case .serverError(let code):
            responseLabel.text = "错误: 服务器错误 (\(code))\n建议: 服务器内部错误，请稍后重试"
            requestInfoView.layer.borderColor = UIColor.systemPink.cgColor
        case .clientError(let code):
            responseLabel.text = "错误: 客户端错误 (\(code))\n建议: 请检查请求参数"
            requestInfoView.layer.borderColor = UIColor.systemPurple.cgColor
        case .dnsFailure:
            responseLabel.text = "错误: DNS解析失败\n建议: 检查域名或DNS设置"
            requestInfoView.layer.borderColor = UIColor.systemIndigo.cgColor
        case .sslError:
            responseLabel.text = "错误: SSL证书验证失败\n建议: 检查证书配置"
            requestInfoView.layer.borderColor = UIColor.systemBrown.cgColor
        case .unknown(let message):
            responseLabel.text = "错误: \(message)\n建议: 联系技术支持"
            requestInfoView.layer.borderColor = UIColor.systemGray.cgColor
        }
        
        // 记录错误到ErrorManager
        ErrorManager.shared.handleError(error, context: nil)
        
        // 自动重试
        if retryCount < maxRetries {
            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                self.retryRequest()
            }
        }
        
        // 滚动到请求信息区域
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollView.scrollRectToVisible(self.requestInfoView.frame, animated: true)
        }
    }
    
    private func retryRequest() {
        guard let request = currentRequest else { return }
        
        retryCount += 1
        
        requestTitleLabel.text = "重试中... (\(retryCount)/\(maxRetries))"
        
        // 模拟重试结果
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let success = Bool.random()
            
            if success {
                self.requestTitleLabel.text = "请求成功"
                self.responseLabel.text = "重试第\(self.retryCount)次成功\n响应时间: \(Int.random(in: 200...800))ms"
                self.requestInfoView.layer.borderColor = UIColor.systemGreen.cgColor
            } else if self.retryCount < self.maxRetries {
                // 继续重试
                DispatchQueue.main.asyncAfter(deadline: .now() + self.retryDelay) {
                    self.retryRequest()
                }
            } else {
                self.requestTitleLabel.text = "重试失败"
                self.responseLabel.text = "已达到最大重试次数(\(self.maxRetries))\n建议: 检查网络或联系技术支持"
                self.requestInfoView.layer.borderColor = UIColor.systemRed.cgColor
            }
        }
    }
    
    // MARK: - Network Test Methods
    
    private func testConnectionTimeout() {
        let request = NetworkRequest(url: "https://httpbin.org/delay/10", method: "GET", timeout: 5.0)
        let error = NetworkError.connectionTimeout
        showNetworkError(error, request: request)
    }
    
    private func testRequestTimeout() {
        let request = NetworkRequest(url: "https://httpbin.org/delay/30", method: "GET", timeout: 10.0)
        let error = NetworkError.requestTimeout
        showNetworkError(error, request: request)
    }
    
    private func testNetworkUnavailable() {
        let request = NetworkRequest(url: "https://example.com/api", method: "GET", timeout: 10.0)
        let error = NetworkError.networkUnavailable
        showNetworkError(error, request: request)
    }
    
    private func testServerError() {
        let request = NetworkRequest(url: "https://httpbin.org/status/500", method: "GET", timeout: 10.0)
        let error = NetworkError.serverError(500)
        showNetworkError(error, request: request)
    }
    
    private func testNotFound() {
        let request = NetworkRequest(url: "https://httpbin.org/status/404", method: "GET", timeout: 10.0)
        let error = NetworkError.clientError(404)
        showNetworkError(error, request: request)
    }
    
    private func testUnauthorized() {
        let request = NetworkRequest(url: "https://httpbin.org/status/401", method: "GET", timeout: 10.0)
        let error = NetworkError.clientError(401)
        showNetworkError(error, request: request)
    }
    
    private func testTooManyRequests() {
        let request = NetworkRequest(url: "https://httpbin.org/status/429", method: "GET", timeout: 10.0)
        let error = NetworkError.clientError(429)
        showNetworkError(error, request: request)
    }
    
    private func testDNSFailure() {
        let request = NetworkRequest(url: "https://nonexistent-domain-12345.com/api", method: "GET", timeout: 10.0)
        let error = NetworkError.dnsFailure
        showNetworkError(error, request: request)
    }
    
    private func testSSLError() {
        let request = NetworkRequest(url: "https://self-signed.badssl.com", method: "GET", timeout: 10.0)
        let error = NetworkError.sslError
        showNetworkError(error, request: request)
    }
    
    // MARK: - Action Methods
    
    @objc private func backButtonTapped() {
        Router.pop()
    }
    
    @objc private func testButtonTapped(_ sender: UIButton) {
        guard let action = objc_getAssociatedObject(sender, "action") as? String else { return }
        performNetworkTest(action)
    }
    
    @objc private func maxRetriesChanged(_ sender: UISlider) {
        maxRetries = Int(sender.value)
        maxRetriesLabel.text = "最大重试次数: \(maxRetries)"
    }
    
    @objc private func retryDelayChanged(_ sender: UISlider) {
        retryDelay = TimeInterval(sender.value)
        retryDelayLabel.text = String(format: "重试延迟: %.1f秒", retryDelay)
    }
}

// MARK: - NetworkRequest

struct NetworkRequest {
    let url: String
    let method: String
    let timeout: TimeInterval
    let headers: [String: String]
    let body: Data?
    
    init(url: String, method: String, timeout: TimeInterval, headers: [String: String] = [:], body: Data? = nil) {
        self.url = url
        self.method = method
        self.timeout = timeout
        self.headers = headers
        self.body = body
    }
}
