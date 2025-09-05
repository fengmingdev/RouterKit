//
//  ParameterPassingViewController.swift
//  ParameterPassingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 参数传递示例主页面
class ParameterPassingViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol Implementation
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = ParameterPassingViewController()
        vc.routeContext = RouteContext(url: "/parameter-passing", parameters: parameters ?? [:], moduleName: "ParameterPassingModule")
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.failure(RouterError.actionNotFound(action)))
    }
    
    var routeContext: RouteContext?
    private var buttonActions: [() -> Void] = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupExampleSections()
        processReceivedParameters()
    }
    
    private func setupUI() {
        title = "参数传递示例"
        view.backgroundColor = .systemBackground
        
        // 设置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 20
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
    
    private func setupExampleSections() {
        // 页面标题和描述
        let titleLabel = createTitleLabel("RouterKit 参数传递示例")
        stackView.addArrangedSubview(titleLabel)
        
        let descriptionLabel = createDescriptionLabel(
            "本页面展示了RouterKit中各种参数传递方式的使用示例，包括基础参数、复杂对象、回调函数、全局状态和数据流等。"
        )
        stackView.addArrangedSubview(descriptionLabel)
        
        stackView.addArrangedSubview(createSeparator())
        
        // 基础参数传递
        let basicSection = createExampleSection(
            title: "基础参数传递",
            description: "展示字符串、数字、布尔值、数组、字典等基础数据类型的传递",
            icon: "📝",
            route: "/ParameterPassingModule/basicParameter",
            examples: [
                "字符串参数传递",
                "数字和布尔值传递",
                "数组和字典传递",
                "URL查询参数",
                "路径参数解析"
            ]
        )
        stackView.addArrangedSubview(basicSection)
        
        // 复杂对象传递
        let complexSection = createExampleSection(
            title: "复杂对象传递",
            description: "展示自定义对象、模型数据、嵌套结构等复杂数据的传递",
            icon: "🏗️",
            route: "/ParameterPassingModule/complexObject",
            examples: [
                "用户信息对象",
                "产品详情数据",
                "订单信息传递",
                "JSON序列化传递",
                "Base64编码传递"
            ]
        )
        stackView.addArrangedSubview(complexSection)
        
        // 回调函数传递
        let callbackSection = createExampleSection(
            title: "回调函数传递",
            description: "展示成功、失败、完成、进度等各种回调函数的传递和执行",
            icon: "🔄",
            route: "/ParameterPassingModule/callback",
            examples: [
                "成功和失败回调",
                "完成回调处理",
                "进度更新回调",
                "数据选择回调",
                "导航回调链"
            ]
        )
        stackView.addArrangedSubview(callbackSection)
        
        // 全局状态传递
        let globalStateSection = createExampleSection(
            title: "全局状态传递",
            description: "展示通过全局状态管理器进行跨页面数据共享和状态同步",
            icon: "🌐",
            route: "/ParameterPassingModule/globalState",
            examples: [
                "用户状态管理",
                "应用配置状态",
                "数据缓存状态",
                "状态观察者模式",
                "状态持久化"
            ]
        )
        stackView.addArrangedSubview(globalStateSection)
        
        // 数据流传递
        let dataFlowSection = createExampleSection(
            title: "数据流传递",
            description: "展示实时数据流、事件流、响应式数据传递等高级功能",
            icon: "🌊",
            route: "/ParameterPassingModule/dataFlow",
            examples: [
                "实时数据流",
                "事件流处理",
                "数据流过滤",
                "数据流合并",
                "跨页面数据流"
            ]
        )
        stackView.addArrangedSubview(dataFlowSection)
        
        stackView.addArrangedSubview(createSeparator())
        
        // 综合测试区域
        let testSection = createTestSection()
        stackView.addArrangedSubview(testSection)
    }
    
    private func processReceivedParameters() {
        guard let context = routeContext else { return }
        
        print("\n=== ParameterPassingViewController 接收到的参数 ===")
        for (key, value) in context.parameters {
            print("\(key): \(value)")
        }
        print("=== 参数显示结束 ===\n")
        
        // 如果有特定的示例类型参数，直接导航到对应页面
        if let exampleType = context.parameters["exampleType"] as? String {
            navigateToExample(exampleType)
        }
    }
    
    // MARK: - UI Helper Methods
    
    private func createTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
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
    
    private func createExampleSection(title: String, description: String, icon: String, route: String, examples: [String]) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题行
        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.spacing = 8
        titleStackView.alignment = .center
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 24)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        
        titleStackView.addArrangedSubview(iconLabel)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(UIView()) // Spacer
        
        // 描述
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        
        // 示例列表
        let examplesLabel = UILabel()
        let exampleText = examples.map { "• \($0)" }.joined(separator: "\n")
        examplesLabel.text = "包含示例:\n\(exampleText)"
        examplesLabel.font = .systemFont(ofSize: 12)
        examplesLabel.textColor = .tertiaryLabel
        examplesLabel.numberOfLines = 0
        
        // 导航按钮
        let button = UIButton(type: .system)
        button.setTitle("查看示例 →", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.tag = buttonActions.count
        buttonActions.append {
            Router.push(to: route)
        }
        
        stackView.addArrangedSubview(titleStackView)
        stackView.addArrangedSubview(descLabel)
        stackView.addArrangedSubview(examplesLabel)
        stackView.addArrangedSubview(button)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        return containerView
    }
    
    private func createTestSection() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = 12
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "🧪 综合测试"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        // 测试按钮
        let testButtons = [
            ("测试所有基础参数", { self.testAllBasicParameters() }),
            ("测试复杂对象传递", { self.testComplexObjectPassing() }),
            ("测试回调函数链", { self.testCallbackChain() }),
            ("测试全局状态同步", { self.testGlobalStateSync() }),
            ("测试数据流传递", { self.testDataFlowPassing() })
        ]
        
        stackView.addArrangedSubview(titleLabel)
        
        for (title, action) in testButtons {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
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
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.tag = buttonActions.count
        buttonActions.append(action)
        
        return button
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    // MARK: - Navigation Methods
    
    private func navigateToExample(_ exampleType: String) {
        let route: String
        switch exampleType {
        case "basic":
            route = "/ParameterPassingModule/basicParameter"
        case "complex":
            route = "/ParameterPassingModule/complexObject"
        case "callback":
            route = "/ParameterPassingModule/callback"
        case "globalState":
            route = "/ParameterPassingModule/globalState"
        case "dataFlow":
            route = "/ParameterPassingModule/dataFlow"
        default:
            print("未知的示例类型: \(exampleType)")
            return
        }
        
        Router.push(to: route)
    }
    
    // MARK: - Test Methods
    
    private func testAllBasicParameters() {
        let parameters: [String: Any] = [
            "testMode": true,
            "testString": "综合测试字符串",
            "testNumber": 12345,
            "testArray": ["item1", "item2", "item3"],
            "testDict": ["key1": "value1", "key2": 42],
            "testBool": true,
            "source": "ParameterPassingViewController"
        ]
        
        Router.push(to: "/ParameterPassingModule/basicParameter", parameters: parameters)
    }
    
    private func testComplexObjectPassing() {
        let userInfo = UserInfo(
            id: 999,
            name: "测试用户",
            email: "test@example.com",
            avatar: "https://example.com/avatar.jpg"
        )
        
        let productInfo = ProductInfo(
            id: "TEST_PRODUCT_001",
            title: "测试商品",
            description: "这是一个用于测试的商品",
            price: 299.99,
            category: "测试分类",
            images: ["image1.jpg", "image2.jpg"]
        )
        
        let parameters: [String: Any] = [
            "testMode": true,
            "userInfo": ParameterPassingUtils.encode(userInfo) ?? [:],
            "productInfo": ParameterPassingUtils.encode(productInfo) ?? [:],
            "source": "ParameterPassingViewController"
        ]
        
        Router.push(to: "/ParameterPassingModule/complexObject", parameters: parameters)
    }
    
    private func testCallbackChain() {
        let successCallback: SuccessCallback = { result in
            print("综合测试 - 成功回调: \(result)")
        }
        
        let failureCallback: FailureCallback = { error in
            print("综合测试 - 失败回调: \(error)")
        }
        
        let completionCallback: CompletionCallback = {
            print("综合测试 - 完成回调")
        }
        
        let parameters: [String: Any] = [
            "testMode": true,
            "callbackChain": true,
            "source": "ParameterPassingViewController"
        ]
        
        // 注册回调
        CallbackManager.shared.registerCallback("test_success", callback: successCallback)
        CallbackManager.shared.registerCallback("test_failure", callback: failureCallback)
        CallbackManager.shared.registerCallback("test_completion", callback: completionCallback)
        
        Router.push(to: "/ParameterPassingModule/callback", parameters: parameters)
    }
    
    private func testGlobalStateSync() {
        // 设置测试用的全局状态
        GlobalStateManager.shared.setUserState([
            "userId": 999,
            "userName": "综合测试用户",
            "testMode": true,
            "syncTime": Date().timeIntervalSince1970
        ])
        
        GlobalStateManager.shared.setAppState([
            "testSession": UUID().uuidString,
            "testStartTime": Date().timeIntervalSince1970,
            "testType": "comprehensive"
        ])
        
        let parameters: [String: Any] = [
            "testMode": true,
            "syncTest": true,
            "source": "ParameterPassingViewController"
        ]
        
        Router.push(to: "/ParameterPassingModule/globalState", parameters: parameters)
    }
    
    private func testDataFlowPassing() {
        let testStreamId = "comprehensiveTestStream"
        
        // 创建测试数据流
        let testData = [
            "testId": UUID().uuidString,
            "testType": "comprehensive",
            "message": "综合测试数据流",
            "timestamp": Date().timeIntervalSince1970,
            "source": "ParameterPassingViewController"
        ] as [String : Any]
        
        DataFlowManager.shared.publish(to: testStreamId, data: testData)
        
        let parameters: [String: Any] = [
            "testMode": true,
            "streamId": testStreamId,
            "streamAction": "subscribe_test_stream",
            "source": "ParameterPassingViewController"
        ]
        
        Router.push(to: "/ParameterPassingModule/dataFlow", parameters: parameters)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender.tag < buttonActions.count {
            buttonActions[sender.tag]()
        }
    }
}
