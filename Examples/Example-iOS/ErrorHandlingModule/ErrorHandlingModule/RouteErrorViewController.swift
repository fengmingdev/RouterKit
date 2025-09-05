//
//  RouteErrorViewController.swift
//  ErrorHandlingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 路由错误示例页面
class RouteErrorViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = RouteErrorViewController()
        vc.routeParameters = parameters
        return vc
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "testRouteNotFound":
            Router.push(to: "/nonexistent/route")
            completion(.success("已触发路由未找到错误"))
        case "testInvalidRoute":
            Router.push(to: "invalid-route-format")
            completion(.success("已触发无效路由格式错误"))
        case "clearErrors":
            completion(.success("错误已清除"))
        default:
            completion(.failure(RouterKit.RouterError.actionNotFound(action, debugInfo: "Action not supported in RouteErrorViewController")))
        }
    }
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // 错误测试按钮
    private let testStackView = UIStackView()
    
    // 错误信息显示
    private let errorInfoView = UIView()
    private let errorTitleLabel = UILabel()
    private let errorMessageLabel = UILabel()
    private let errorDetailsLabel = UILabel()
    
    // 恢复策略
    private let recoveryStackView = UIStackView()
    
    // MARK: - Properties
    
    private var lastError: Error?
    private var lastContext: RouteContext?
    private var routeParameters: RouterParameters?
    
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
        title = "路由错误"
        
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
        titleLabel.text = "路由错误示例"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 配置描述
        descriptionLabel.text = "演示各种路由错误场景，包括路由未找到、模块未注册、参数错误等，以及相应的错误处理和恢复策略。"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        setupTestSection()
        setupErrorInfoSection()
        setupRecoverySection()
    }
    
    private func setupTestSection() {
        let testLabel = UILabel()
        testLabel.text = "错误测试"
        testLabel.font = .boldSystemFont(ofSize: 18)
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testLabel)
        
        testStackView.axis = .vertical
        testStackView.spacing = 12
        testStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testStackView)
        
        let tests = [
            ("路由未找到", "测试访问不存在的路由", "testRouteNotFound", UIColor.systemRed),
            ("模块未注册", "测试访问未注册模块的路由", "testModuleNotRegistered", UIColor.systemOrange),
            ("无效路由格式", "测试格式错误的路由", "testInvalidRouteFormat", UIColor.systemYellow),
            ("循环路由", "测试循环引用的路由", "testCircularRoute", UIColor.systemPink),
            ("权限不足", "测试访问需要权限的路由", "testPermissionDenied", UIColor.systemPurple),
            ("参数缺失", "测试缺少必需参数的路由", "testMissingParameters", UIColor.systemBlue),
            ("参数类型错误", "测试参数类型不匹配的路由", "testInvalidParameterType", UIColor.systemGreen),
            ("路由超时", "测试路由处理超时", "testRouteTimeout", UIColor.systemIndigo)
        ]
        
        for (title, description, action, color) in tests {
            let button = createTestButton(title: title, description: description, action: action, color: color)
            testStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            testLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            testLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            testStackView.topAnchor.constraint(equalTo: testLabel.bottomAnchor, constant: 12),
            testStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupErrorInfoSection() {
        let errorLabel = UILabel()
        errorLabel.text = "错误信息"
        errorLabel.font = .boldSystemFont(ofSize: 18)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(errorLabel)
        
        errorInfoView.backgroundColor = .systemRed.withAlphaComponent(0.1)
        errorInfoView.layer.cornerRadius = 12
        errorInfoView.layer.borderWidth = 1
        errorInfoView.layer.borderColor = UIColor.systemRed.cgColor
        errorInfoView.isHidden = true
        errorInfoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(errorInfoView)
        
        errorTitleLabel.text = "暂无错误"
        errorTitleLabel.font = .boldSystemFont(ofSize: 16)
        errorTitleLabel.textColor = .systemRed
        errorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        errorInfoView.addSubview(errorTitleLabel)
        
        errorMessageLabel.text = ""
        errorMessageLabel.font = .systemFont(ofSize: 14)
        errorMessageLabel.textColor = .label
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorInfoView.addSubview(errorMessageLabel)
        
        errorDetailsLabel.text = ""
        errorDetailsLabel.font = .systemFont(ofSize: 12)
        errorDetailsLabel.textColor = .secondaryLabel
        errorDetailsLabel.numberOfLines = 0
        errorDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        errorInfoView.addSubview(errorDetailsLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: testStackView.bottomAnchor, constant: 30),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            errorInfoView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            errorInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            errorTitleLabel.topAnchor.constraint(equalTo: errorInfoView.topAnchor, constant: 16),
            errorTitleLabel.leadingAnchor.constraint(equalTo: errorInfoView.leadingAnchor, constant: 16),
            errorTitleLabel.trailingAnchor.constraint(equalTo: errorInfoView.trailingAnchor, constant: -16),
            
            errorMessageLabel.topAnchor.constraint(equalTo: errorTitleLabel.bottomAnchor, constant: 8),
            errorMessageLabel.leadingAnchor.constraint(equalTo: errorInfoView.leadingAnchor, constant: 16),
            errorMessageLabel.trailingAnchor.constraint(equalTo: errorInfoView.trailingAnchor, constant: -16),
            
            errorDetailsLabel.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 8),
            errorDetailsLabel.leadingAnchor.constraint(equalTo: errorInfoView.leadingAnchor, constant: 16),
            errorDetailsLabel.trailingAnchor.constraint(equalTo: errorInfoView.trailingAnchor, constant: -16),
            errorDetailsLabel.bottomAnchor.constraint(equalTo: errorInfoView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupRecoverySection() {
        let recoveryLabel = UILabel()
        recoveryLabel.text = "错误恢复"
        recoveryLabel.font = .boldSystemFont(ofSize: 18)
        recoveryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recoveryLabel)
        
        recoveryStackView.axis = .horizontal
        recoveryStackView.spacing = 12
        recoveryStackView.distribution = .fillEqually
        recoveryStackView.isHidden = true
        recoveryStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recoveryStackView)
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("重试", for: .normal)
        retryButton.backgroundColor = .systemBlue
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 8
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let fallbackButton = UIButton(type: .system)
        fallbackButton.setTitle("备用路由", for: .normal)
        fallbackButton.backgroundColor = .systemGreen
        fallbackButton.setTitleColor(.white, for: .normal)
        fallbackButton.layer.cornerRadius = 8
        fallbackButton.addTarget(self, action: #selector(fallbackButtonTapped), for: .touchUpInside)
        fallbackButton.translatesAutoresizingMaskIntoConstraints = false
        fallbackButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除错误", for: .normal)
        clearButton.backgroundColor = .systemGray
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.addTarget(self, action: #selector(clearErrorButtonTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        recoveryStackView.addArrangedSubview(retryButton)
        recoveryStackView.addArrangedSubview(fallbackButton)
        recoveryStackView.addArrangedSubview(clearButton)
        
        NSLayoutConstraint.activate([
            recoveryLabel.topAnchor.constraint(equalTo: errorInfoView.bottomAnchor, constant: 30),
            recoveryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recoveryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            recoveryStackView.topAnchor.constraint(equalTo: recoveryLabel.bottomAnchor, constant: 12),
            recoveryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recoveryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recoveryStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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
            if let errorType = parameters["errorType"] as? String {
                // 根据参数自动触发相应的错误测试
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performErrorTest(errorType)
                }
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
    
    private func performErrorTest(_ errorType: String) {
        switch errorType {
        case "testRouteNotFound":
            testRouteNotFound()
        case "testModuleNotRegistered":
            testModuleNotRegistered()
        case "testInvalidRouteFormat":
            testInvalidRouteFormat()
        case "testCircularRoute":
            testCircularRoute()
        case "testPermissionDenied":
            testPermissionDenied()
        case "testMissingParameters":
            testMissingParameters()
        case "testInvalidParameterType":
            testInvalidParameterType()
        case "testRouteTimeout":
            testRouteTimeout()
        default:
            break
        }
    }
    
    private func showError(_ error: Error, context: RouteContext? = nil) {
        lastError = error
        lastContext = context
        
        errorInfoView.isHidden = false
        recoveryStackView.isHidden = false
        
        if let routerError = error as? RouterKit.RouterError {
            switch routerError {
            case .routeNotFound(let route):
                errorTitleLabel.text = "路由未找到"
                errorMessageLabel.text = "无法找到路由: \(route)"
                errorDetailsLabel.text = "请检查路由是否正确注册，或者路由路径是否拼写正确。"
            case .moduleNotRegistered(let module):
                errorTitleLabel.text = "模块未注册"
                errorMessageLabel.text = "模块 \(module) 未注册"
                errorDetailsLabel.text = "请确保在AppDelegate中正确注册了该模块。"
            case .invalidURL(let url, _):
                errorTitleLabel.text = "无效URL"
                errorMessageLabel.text = "URL格式无效: \(url)"
                errorDetailsLabel.text = "URL格式应为 /ModuleName/routeName 的形式。"
            case .navigationError(let message, _):
                errorTitleLabel.text = "导航错误"
                errorMessageLabel.text = "导航错误: \(message)"
                errorDetailsLabel.text = "请检查路由配置或网络连接。"
            case .permissionDenied(let route):
                errorTitleLabel.text = "权限不足"
                errorMessageLabel.text = "访问 \(route) 需要权限"
                errorDetailsLabel.text = "请先登录或获取相应权限后再访问。"
            case .viewControllerNotFound(let path, _):
                errorTitleLabel.text = "视图控制器未找到"
                errorMessageLabel.text = "未找到视图控制器: \(path)"
                errorDetailsLabel.text = "请确认路由已正确注册。"
            case .parameterError(let message, _, _):
                errorTitleLabel.text = "参数错误"
                errorMessageLabel.text = "参数错误: \(message)"
                errorDetailsLabel.text = "请检查传递的参数是否正确。"
            case .timeoutError(let message, _):
                errorTitleLabel.text = "超时错误"
                errorMessageLabel.text = "超时: \(message)"
                errorDetailsLabel.text = "操作超时，请稍后重试。"
            case .actionNotFound(let action, _):
                errorTitleLabel.text = "动作未找到"
                errorMessageLabel.text = "未找到动作: \(action)"
                errorDetailsLabel.text = "请检查动作名称是否正确。"
            case .moduleDependencyError(let message, _):
                errorTitleLabel.text = "模块依赖错误"
                errorMessageLabel.text = "模块依赖错误: \(message)"
                errorDetailsLabel.text = "请检查模块依赖关系。"
            case .unsupportedAction(let action, _):
                errorTitleLabel.text = "不支持的操作"
                errorMessageLabel.text = "不支持的操作: \(action)"
                errorDetailsLabel.text = "该操作当前不被支持。"
            case .navigationControllerNotFound(_):
                errorTitleLabel.text = "导航控制器未找到"
                errorMessageLabel.text = "未找到导航控制器"
                errorDetailsLabel.text = "请确保当前视图在导航控制器中。"
            case .interceptorRejected(let message, _):
                errorTitleLabel.text = "路由被拦截"
                errorMessageLabel.text = "路由被拦截: \(message)"
                errorDetailsLabel.text = "请检查拦截器逻辑。"
            case .configError(let message, _):
                errorTitleLabel.text = "配置错误"
                errorMessageLabel.text = "配置错误: \(message)"
                errorDetailsLabel.text = "请检查配置文件。"
            case .patternSyntaxError(let pattern, _):
                errorTitleLabel.text = "路由模式语法错误"
                errorMessageLabel.text = "语法错误: \(pattern)"
                errorDetailsLabel.text = "请检查路由模式语法。"
            case .animationNotFound(let animation, _):
                errorTitleLabel.text = "动画未找到"
                errorMessageLabel.text = "未找到动画: \(animation)"
                errorDetailsLabel.text = "请检查动画名称。"
            case .moduleLoadFailed(let module, _, _):
                errorTitleLabel.text = "模块加载失败"
                errorMessageLabel.text = "模块加载失败: \(module)"
                errorDetailsLabel.text = "请检查模块配置。"
            case .routeAlreadyExists(let route, _):
                errorTitleLabel.text = "路由已存在"
                errorMessageLabel.text = "路由已存在: \(route)"
                errorDetailsLabel.text = "该路由已经注册。"
            case .maxRetriesExceeded(_, _):
                errorTitleLabel.text = "重试次数超限"
                errorMessageLabel.text = "重试次数已达上限"
                errorDetailsLabel.text = "请稍后再试。"
            case .interceptorReleased(_):
                errorTitleLabel.text = "拦截器已释放"
                errorMessageLabel.text = "拦截器已释放"
                errorDetailsLabel.text = "拦截器对象已被释放。"
            case .networkError(let message, _):
                errorTitleLabel.text = "网络错误"
                errorMessageLabel.text = "网络错误: \(message)"
                errorDetailsLabel.text = "请检查网络连接。"
            case .memoryError(let message, _):
                errorTitleLabel.text = "内存错误"
                errorMessageLabel.text = "内存错误: \(message)"
                errorDetailsLabel.text = "内存不足，请释放资源。"
            case .concurrencyError(let message, _):
                errorTitleLabel.text = "并发错误"
                errorMessageLabel.text = "并发错误: \(message)"
                errorDetailsLabel.text = "检测到并发冲突。"
            }
        } else {
            errorTitleLabel.text = "未知错误"
            errorMessageLabel.text = error.localizedDescription
            errorDetailsLabel.text = "发生了未知错误，请联系开发者。"
        }
        
        // 记录错误到ErrorManager
        ErrorManager.shared.handleError(error, context: context)
        
        // 滚动到错误信息区域
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollView.scrollRectToVisible(self.errorInfoView.frame, animated: true)
        }
    }
    
    private func clearError() {
        lastError = nil
        lastContext = nil
        errorInfoView.isHidden = true
        recoveryStackView.isHidden = true
    }
    
    // MARK: - Error Test Methods
    
    private func testRouteNotFound() {
        let route = "/NonExistentModule/nonExistentRoute"
        let error = RouterKit.RouterError.routeNotFound(route, debugInfo: "Test route not found")
        let context = RouteContext(url: route, parameters: [:], moduleName: "ErrorHandlingModule")
        showError(error, context: context)
    }
    
    private func testModuleNotRegistered() {
        let route = "/UnregisteredModule/someRoute"
        let error = RouterKit.RouterError.moduleNotRegistered("UnregisteredModule", debugInfo: "Test module not registered")
        let context = RouteContext(url: route, parameters: [:], moduleName: "UnregisteredModule")
        showError(error, context: context)
    }
    
    private func testInvalidRouteFormat() {
        let route = "invalid-route-format"
        let error = RouterKit.RouterError.invalidURL(route, debugInfo: "Invalid route format test")
        let context = RouteContext(url: route, parameters: [:], moduleName: "Unknown")
        showError(error, context: context)
    }
    
    private func testCircularRoute() {
        let route = "/TestModule/circularRoute"
        let error = RouterKit.RouterError.navigationError("循环依赖: \(route)", debugInfo: "Test circular dependency")
        let context = RouteContext(url: route, parameters: [:], moduleName: "TestModule")
        showError(error, context: context)
    }
    
    private func testPermissionDenied() {
        let route = "/AdminModule/adminPanel"
        let error = RouterKit.RouterError.permissionDenied(route, debugInfo: "Test permission denied")
        let context = RouteContext(url: route, parameters: [:], moduleName: "AdminModule")
        showError(error, context: context)
    }
    
    private func testMissingParameters() {
        let route = "/UserModule/profile"
        let error = RouterKit.RouterError.parameterError("缺少必需参数: userId", suggestion: "请提供有效的userId参数", debugInfo: "Test missing parameter")
        let context = RouteContext(url: route, parameters: [:], moduleName: "UserModule")
        showError(error, context: context)
    }
    
    private func testInvalidParameterType() {
        let route = "/ProductModule/detail"
        let error = RouterKit.RouterError.parameterError("参数 productId 类型错误，期望 Int 类型", suggestion: "请提供正确类型的productId", debugInfo: "Test invalid parameter type")
        let context = RouteContext(url: route, parameters: ["productId": "invalid_id"], moduleName: "ProductModule")
        showError(error, context: context)
    }
    
    private func testRouteTimeout() {
        let route = "/SlowModule/slowRoute"
        let error = RouterKit.RouterError.timeoutError("路由处理超时: \(route)", debugInfo: "Test timeout error")
        let context = RouteContext(url: route, parameters: [:], moduleName: "SlowModule")
        showError(error, context: context)
    }
    
    // MARK: - Action Methods
    
    @objc private func backButtonTapped() {
        Router.pop()
    }
    
    @objc private func testButtonTapped(_ sender: UIButton) {
        guard let action = objc_getAssociatedObject(sender, "action") as? String else { return }
        performErrorTest(action)
    }
    
    @objc private func retryButtonTapped() {
        guard let _ = lastError, let _ = lastContext else { return }
        
        // 模拟重试逻辑
        let alert = UIAlertController(title: "重试中...", message: "正在重试路由操作", preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true) {
                // 模拟重试结果（随机成功或失败）
                let success = Bool.random()
                let resultTitle = success ? "重试成功" : "重试失败"
                let resultMessage = success ? "路由操作已成功完成" : "重试仍然失败，请尝试其他解决方案"
                
                let resultAlert = UIAlertController(title: resultTitle, message: resultMessage, preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                    if success {
                        self.clearError()
                    }
                })
                self.present(resultAlert, animated: true)
            }
        }
    }
    
    @objc private func fallbackButtonTapped() {
        // 使用备用路由
        let fallbackRoute = "/ErrorHandlingModule/errorHandling"
        
        Router.shared.navigate(to: fallbackRoute) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let alert = UIAlertController(title: "已跳转", message: "已跳转到备用路由", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self.present(alert, animated: true)
                    self.clearError()
                case .failure:
                    let alert = UIAlertController(title: "跳转失败", message: "备用路由也无法访问", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func clearErrorButtonTapped() {
        clearError()
        
        let alert = UIAlertController(title: "已清除", message: "错误信息已清除", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
