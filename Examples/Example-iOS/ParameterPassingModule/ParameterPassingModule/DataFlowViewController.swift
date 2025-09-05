//
//  DataFlowViewController.swift
//  ParameterPassingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 数据流参数传递示例页面
class DataFlowViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = DataFlowViewController()
        vc.routeContext = RouteContext(url: "/data-flow", parameters: parameters ?? [:], moduleName: "ParameterPassingModule")
        return vc
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "publishUserData":
            DataFlowManager.shared.publish(to: "user_stream", data: ["userId": "123", "name": "测试用户"])
            completion(.success("用户数据已发布"))
        case "subscribeUserStream":
            DataFlowManager.shared.subscribe(streamId: "user_stream", subscriber: "DataFlowViewController") { data in
                print("接收到用户数据: \(data)")
            }
            completion(.success("已订阅用户数据流"))
        case "clearDataFlow":
            DataFlowManager.shared.clearAll()
            completion(.success("数据流已清除"))
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }
    
    var routeContext: RouteContext?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let dataFlowTextView = UITextView()
    
    // 数据流订阅
    private var dataFlowSubscriptions: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataFlowDisplay()
        setupTestButtons()
        setupDataFlowSubscriptions()
        displayCurrentDataFlow()
        processReceivedDataFlow()
    }
    
    deinit {
        // 清理数据流订阅
        DataFlowManager.shared.unsubscribeAll(for: self)
    }
    
    private func setupUI() {
        title = "数据流传递"
        view.backgroundColor = .systemBackground
        
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
    
    private func setupDataFlowDisplay() {
        // 标题
        let titleLabel = createTitleLabel("数据流实时监控")
        stackView.addArrangedSubview(titleLabel)
        
        // 数据流显示区域
        let dataFlowView = createDataFlowDisplayView()
        stackView.addArrangedSubview(dataFlowView)
        
        stackView.addArrangedSubview(createSeparator())
    }
    
    private func setupTestButtons() {
        // 测试按钮区域标题
        let testTitleLabel = createTitleLabel("数据流测试")
        stackView.addArrangedSubview(testTitleLabel)
        
        // 数据发布测试
        let publishSection = createSectionView("数据发布")
        stackView.addArrangedSubview(publishSection)
        
        let publishTests = [
            ("发布用户数据", { self.testPublishUserData() }),
            ("发布产品数据", { self.testPublishProductData() }),
            ("发布订单数据", { self.testPublishOrderData() }),
            ("发布实时消息", { self.testPublishRealtimeMessage() })
        ]
        
        for (title, action) in publishTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 数据订阅测试
        let subscribeSection = createSectionView("数据订阅")
        stackView.addArrangedSubview(subscribeSection)
        
        let subscribeTests = [
            ("订阅用户流", { self.testSubscribeUserStream() }),
            ("订阅产品流", { self.testSubscribeProductStream() }),
            ("订阅通知流", { self.testSubscribeNotificationStream() }),
            ("订阅系统事件", { self.testSubscribeSystemEvents() })
        ]
        
        for (title, action) in subscribeTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 数据流操作
        let operationSection = createSectionView("数据流操作")
        stackView.addArrangedSubview(operationSection)
        
        let operationTests = [
            ("过滤数据流", { self.testFilterDataStream() }),
            ("转换数据流", { self.testTransformDataStream() }),
            ("合并数据流", { self.testMergeDataStreams() }),
            ("缓存数据流", { self.testCacheDataStream() })
        ]
        
        for (title, action) in operationTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 导航数据流测试
        let navigationSection = createSectionView("导航数据流")
        stackView.addArrangedSubview(navigationSection)
        
        let navigationTests = [
            ("传递数据流到新页面", { self.testDataFlowToNewPage() }),
            ("跨页面数据流", { self.testCrossPageDataFlow() }),
            ("数据流链式传递", { self.testChainedDataFlow() })
        ]
        
        for (title, action) in navigationTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 工具按钮
        let toolSection = createSectionView("工具")
        stackView.addArrangedSubview(toolSection)
        
        let toolTests = [
            ("刷新数据流显示", { self.refreshDataFlowDisplay() }),
            ("清空数据流", { self.clearDataFlow() }),
            ("导出数据流日志", { self.exportDataFlowLog() })
        ]
        
        for (title, action) in toolTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func setupDataFlowSubscriptions() {
        // 订阅用户数据流
        DataFlowManager.shared.subscribe(streamId: "userDataStream", subscriber: "DataFlowViewController") { [weak self] data in
            self?.handleUserDataFlow(data)
        }
        
        // 订阅产品数据流
        DataFlowManager.shared.subscribe(streamId: "productDataStream", subscriber: "DataFlowViewController") { [weak self] data in
            self?.handleProductDataFlow(data)
        }
        
        // 订阅通知数据流
        DataFlowManager.shared.subscribe(streamId: "notificationStream", subscriber: "DataFlowViewController") { [weak self] data in
            self?.handleNotificationDataFlow(data)
        }
        
        // 订阅系统事件流
        DataFlowManager.shared.subscribe(streamId: "systemEventStream", subscriber: "DataFlowViewController") { [weak self] data in
            self?.handleSystemEventDataFlow(data)
        }
    }
    
    private func processReceivedDataFlow() {
        guard let context = routeContext else { return }
        
        // 处理接收到的数据流参数
        if let streamId = context.parameters["streamId"] as? String {
            print("接收到数据流ID: \(streamId)")
            
            // 订阅指定的数据流
            DataFlowManager.shared.subscribe(streamId: streamId, subscriber: "DataFlowViewController") { [weak self] data in
                self?.handleReceivedDataFlow(streamId, data: data)
            }
        }
        
        if let streamData = context.parameters["streamData"] as? [String: Any] {
            print("接收到数据流数据: \(streamData)")
            handleReceivedDataFlow("received", data: streamData)
        }
        
        if let streamAction = context.parameters["streamAction"] as? String {
            print("接收到数据流操作: \(streamAction)")
            executeStreamAction(streamAction)
        }
    }
    
    private func displayCurrentDataFlow() {
        print("\n=== DataFlowViewController 当前数据流 ===")
        // 注意：DataFlowManager没有getActiveStreams方法，这里简化处理
        print("数据流管理器已初始化")
        print("=== 数据流显示结束 ===\n")
        
        refreshDataFlowDisplay()
    }
    
    // MARK: - UI Helper Methods
    
    private func createTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }
    
    private func createSectionView(_ title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 8
        
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 16)
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
    
    private func createDataFlowDisplayView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.separator.cgColor
        
        dataFlowTextView.isEditable = false
        dataFlowTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        dataFlowTextView.backgroundColor = .clear
        dataFlowTextView.translatesAutoresizingMaskIntoConstraints = false
        dataFlowTextView.text = "数据流监控日志\n\n"
        
        containerView.addSubview(dataFlowTextView)
        
        NSLayoutConstraint.activate([
            dataFlowTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            dataFlowTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            dataFlowTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            dataFlowTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            dataFlowTextView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        return containerView
    }
    
    // Button actions storage
    private var buttonActions: [() -> Void] = []
    
    private func createTestButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.tag = buttonActions.count
        buttonActions.append(action)
        
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender.tag < buttonActions.count {
            buttonActions[sender.tag]()
        }
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    // MARK: - Data Flow Display Methods
    
    private func addDataFlowLog(_ message: String) {
        let timestamp = DateFormatter.dataFlowFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] \(message)\n"
        
        DispatchQueue.main.async {
            self.dataFlowTextView.text += logMessage
            
            // 滚动到底部
            let bottom = NSMakeRange(self.dataFlowTextView.text.count - 1, 1)
            self.dataFlowTextView.scrollRangeToVisible(bottom)
        }
    }
    
    private func refreshDataFlowDisplay() {
        var displayText = "数据流实时监控\n"
        displayText += "更新时间: \(DateFormatter.dataFlowFormatter.string(from: Date()))\n\n"
        
        displayText += "=== 数据流管理器状态 ===\n"
        displayText += "数据流管理器: 已初始化\n"
        displayText += "订阅管理: 活跃中\n"
        
        displayText += "\n=== 数据流日志 ===\n"
        
        dataFlowTextView.text = displayText + (dataFlowTextView.text.components(separatedBy: "=== 数据流日志 ===\n").last ?? "")
    }
    
    // MARK: - Data Flow Handlers
    
    private func handleUserDataFlow(_ data: [String: Any]) {
        addDataFlowLog("👤 用户数据流: \(data)")
    }
    
    private func handleProductDataFlow(_ data: [String: Any]) {
        addDataFlowLog("📦 产品数据流: \(data)")
    }
    
    private func handleNotificationDataFlow(_ data: [String: Any]) {
        addDataFlowLog("🔔 通知数据流: \(data)")
    }
    
    private func handleSystemEventDataFlow(_ data: [String: Any]) {
        addDataFlowLog("⚙️ 系统事件流: \(data)")
    }
    
    private func handleReceivedDataFlow(_ streamId: String, data: [String: Any]) {
        addDataFlowLog("📥 接收数据流[\(streamId)]: \(data)")
    }
    
    // MARK: - Test Methods - Data Publishing
    
    private func testPublishUserData() {
        let userData = [
            "userId": Int.random(in: 1000...9999),
            "action": "profile_update",
            "name": "用户\(Int.random(in: 1...100))",
            "timestamp": Date().timeIntervalSince1970,
            "source": "DataFlowViewController"
        ] as [String : Any]
        
        DataFlowManager.shared.publish(to: "userDataStream", data: userData)
        addDataFlowLog("📤 发布用户数据: \(userData["action"] ?? "unknown")")
    }
    
    private func testPublishProductData() {
        let productData = [
            "productId": "P\(Int.random(in: 1000...9999))",
            "action": "price_update",
            "name": "商品\(Int.random(in: 1...100))",
            "price": Double.random(in: 10...1000),
            "timestamp": Date().timeIntervalSince1970,
            "source": "DataFlowViewController"
        ] as [String : Any]
        
        DataFlowManager.shared.publish(to: "productDataStream", data: productData)
        addDataFlowLog("📤 发布产品数据: \(productData["name"] ?? "unknown")")
    }
    
    private func testPublishOrderData() {
        let orderData = [
            "orderId": "ORDER_\(Int.random(in: 10000...99999))",
            "action": "status_change",
            "status": ["pending", "paid", "shipped", "delivered"].randomElement()!,
            "amount": Double.random(in: 100...5000),
            "timestamp": Date().timeIntervalSince1970,
            "source": "DataFlowViewController"
        ] as [String : Any]
        
        DataFlowManager.shared.publish(to: "orderDataStream", data: orderData)
        addDataFlowLog("📤 发布订单数据: \(orderData["orderId"] ?? "unknown")")
    }
    
    private func testPublishRealtimeMessage() {
        let messageData = [
            "messageId": UUID().uuidString,
            "type": "realtime",
            "content": "实时消息 \(Int.random(in: 1...1000))",
            "priority": ["low", "normal", "high", "urgent"].randomElement()!,
            "timestamp": Date().timeIntervalSince1970,
            "source": "DataFlowViewController"
        ] as [String : Any]
        
        DataFlowManager.shared.publish(to: "realtimeMessageStream", data: messageData)
        addDataFlowLog("📤 发布实时消息: \(messageData["content"] ?? "unknown")")
    }
    
    // MARK: - Test Methods - Data Subscription
    
    private func testSubscribeUserStream() {
        DataFlowManager.shared.subscribe(streamId: "userDataStream", subscriber: "DataFlowViewController") { [weak self] data in
            self?.addDataFlowLog("📥 订阅用户流数据: \(data["action"] ?? "unknown")")
        }
        addDataFlowLog("✅ 已订阅用户数据流")
    }
    
    private func testSubscribeProductStream() {
        DataFlowManager.shared.subscribe(streamId: "productDataStream", subscriber: "DataFlowViewController") { [weak self] data in
            self?.addDataFlowLog("📥 订阅产品流数据: \(data["name"] ?? "unknown")")
        }
        addDataFlowLog("✅ 已订阅产品数据流")
    }
    
    private func testSubscribeNotificationStream() {
        DataFlowManager.shared.subscribe(streamId: "notificationStream", subscriber: "DataFlowViewController") { [weak self] data in
            self?.addDataFlowLog("📥 订阅通知流数据: \(data["message"] ?? "unknown")")
        }
        addDataFlowLog("✅ 已订阅通知数据流")
    }
    
    private func testSubscribeSystemEvents() {
        DataFlowManager.shared.subscribe(streamId: "systemEventStream", subscriber: "DataFlowViewController") { [weak self] data in
            self?.addDataFlowLog("📥 订阅系统事件: \(data["event"] ?? "unknown")")
        }
        addDataFlowLog("✅ 已订阅系统事件流")
    }
    
    // MARK: - Test Methods - Data Flow Operations
    
    private func testFilterDataStream() {
        // 创建过滤器：只接收高优先级消息
        DataFlowManager.shared.subscribe(streamId: "realtimeMessageStream", subscriber: "DataFlowViewController") { [weak self] data in
            if let priority = data["priority"] as? String, priority == "high" || priority == "urgent" {
                self?.addDataFlowLog("🔍 过滤后的高优先级消息: \(data["content"] ?? "unknown")")
            }
        }
        
        // 发布一些测试消息
        let priorities = ["low", "normal", "high", "urgent"]
        for priority in priorities {
            let messageData = [
                "messageId": UUID().uuidString,
                "content": "\(priority)优先级消息",
                "priority": priority,
                "timestamp": Date().timeIntervalSince1970
            ] as [String : Any]
            
            DataFlowManager.shared.publish(to: "realtimeMessageStream", data: messageData)
        }
        
        addDataFlowLog("🔍 已设置数据流过滤器（仅高优先级）")
    }
    
    private func testTransformDataStream() {
        // 创建转换器：将用户数据转换为显示格式
        DataFlowManager.shared.subscribe(streamId: "userDataStream", subscriber: "DataFlowViewController") { [weak self] data in
            let transformedData = [
                "displayName": "用户: \(data["name"] ?? "未知")",
                "displayAction": "操作: \(data["action"] ?? "未知")",
                "displayTime": DateFormatter.displayFormatter.string(from: Date()),
                "originalData": data
            ] as [String : Any]
            
            self?.addDataFlowLog("🔄 转换后的用户数据: \(transformedData["displayName"] ?? "unknown")")
        }
        
        // 发布测试用户数据
        testPublishUserData()
        
        addDataFlowLog("🔄 已设置数据流转换器")
    }
    
    private func testMergeDataStreams() {
        // 创建合并流：合并用户和产品数据
        let mergedStreamId = "mergedUserProductStream"
        
        DataFlowManager.shared.subscribe(streamId: "userDataStream", subscriber: "DataFlowViewController") { [weak self] data in
            var mergedData = data
            mergedData["streamType"] = "user"
            mergedData["mergedAt"] = Date().timeIntervalSince1970
            
            DataFlowManager.shared.publish(to: mergedStreamId, data: mergedData)
        }
        
        DataFlowManager.shared.subscribe(streamId: "productDataStream", subscriber: "DataFlowViewController") { [weak self] data in
            var mergedData = data
            mergedData["streamType"] = "product"
            mergedData["mergedAt"] = Date().timeIntervalSince1970
            
            DataFlowManager.shared.publish(to: mergedStreamId, data: mergedData)
        }
        
        // 订阅合并后的流
        DataFlowManager.shared.subscribe(streamId: mergedStreamId, subscriber: "DataFlowViewController") { [weak self] data in
            self?.addDataFlowLog("🔀 合并流数据[\(data["streamType"] ?? "unknown")]: \(data["name"] ?? data["action"] ?? "unknown")")
        }
        
        // 发布测试数据
        testPublishUserData()
        testPublishProductData()
        
        addDataFlowLog("🔀 已创建合并数据流")
    }
    
    private func testCacheDataStream() {
        let cachedStreamId = "cachedDataStream"
        var cache: [[String: Any]] = []
        let maxCacheSize = 5
        
        // 创建缓存流
        DataFlowManager.shared.subscribe(streamId: "userDataStream", subscriber: "DataFlowViewController") { [weak self] data in
            // 添加到缓存
            cache.append(data)
            if cache.count > maxCacheSize {
                cache.removeFirst()
            }
            
            let cachedData = [
                "cacheSize": cache.count,
                "maxSize": maxCacheSize,
                "latestData": data,
                "cachedAt": Date().timeIntervalSince1970
            ] as [String : Any]
            
            DataFlowManager.shared.publish(to: cachedStreamId, data: cachedData)
        }
        
        // 订阅缓存流
        DataFlowManager.shared.subscribe(streamId: cachedStreamId, subscriber: "DataFlowViewController") { [weak self] data in
            self?.addDataFlowLog("💾 缓存数据流[\(data["cacheSize"] ?? 0)/\(data["maxSize"] ?? 0)]: 最新数据已缓存")
        }
        
        // 发布多个测试数据
        for i in 1...7 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                self.testPublishUserData()
            }
        }
        
        addDataFlowLog("💾 已创建缓存数据流（最大缓存\(maxCacheSize)条）")
    }
    
    // MARK: - Test Methods - Navigation Data Flow
    
    private func testDataFlowToNewPage() {
        let navigationStreamId = "navigationDataFlow_\(UUID().uuidString.prefix(8))"
        
        // 创建导航专用数据流
        let navigationData = [
            "sourcePageId": "data_flow_page",
            "navigationTime": Date().timeIntervalSince1970,
            "streamId": navigationStreamId,
            "message": "从数据流页面传递的数据流"
        ] as [String : Any]
        
        DataFlowManager.shared.publish(to: navigationStreamId, data: navigationData)
        
        let parameters: [String: Any] = [
            "streamId": navigationStreamId,
            "streamAction": "subscribe_navigation_stream",
            "message": "导航到新页面并传递数据流"
        ]
        
        Router.push(to: "/ParameterPassingModule/dataFlow", parameters: parameters)
        addDataFlowLog("🚀 已传递数据流到新页面: \(navigationStreamId)")
    }
    
    private func testCrossPageDataFlow() {
        let crossPageStreamId = "crossPageDataFlow"
        
        // 创建跨页面数据流
        DataFlowManager.shared.subscribe(streamId: crossPageStreamId, subscriber: "DataFlowViewController") { [weak self] data in
            self?.addDataFlowLog("🌐 跨页面数据流: \(data["message"] ?? "unknown")")
        }
        
        // 发布跨页面数据
        let crossPageData = [
            "pageId": "DataFlowViewController",
            "message": "跨页面数据流消息",
            "timestamp": Date().timeIntervalSince1970,
            "sessionId": UUID().uuidString
        ] as [String : Any]
        
        DataFlowManager.shared.publish(to: crossPageStreamId, data: crossPageData)
        
        let parameters: [String: Any] = [
            "streamId": crossPageStreamId,
            "streamAction": "join_cross_page_stream",
            "message": "加入跨页面数据流"
        ]
        
        Router.push(to: "/ParameterPassingModule/dataFlow", parameters: parameters)
        addDataFlowLog("🌐 已创建跨页面数据流")
    }
    
    private func testChainedDataFlow() {
        let chainStreamIds = [
            "chainStep1Stream",
            "chainStep2Stream",
            "chainStep3Stream"
        ]
        
        // 创建链式数据流
        for (index, streamId) in chainStreamIds.enumerated() {
            DataFlowManager.shared.subscribe(streamId: streamId, subscriber: "DataFlowViewController") { [weak self] data in
                self?.addDataFlowLog("⛓️ 链式数据流步骤\(index + 1): \(data["message"] ?? "unknown")")
                
                // 如果不是最后一步，传递到下一步
                if index < chainStreamIds.count - 1 {
                    let nextStreamId = chainStreamIds[index + 1]
                    var nextData = data
                    nextData["step"] = index + 2
                    nextData["previousStep"] = index + 1
                    nextData["chainTime"] = Date().timeIntervalSince1970
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        DataFlowManager.shared.publish(to: nextStreamId, data: nextData)
                    }
                }
            }
        }
        
        // 启动链式数据流
        let initialData = [
            "message": "链式数据流开始",
            "step": 1,
            "chainId": UUID().uuidString,
            "startTime": Date().timeIntervalSince1970
        ] as [String : Any]
        
        DataFlowManager.shared.publish(to: chainStreamIds[0], data: initialData)
        addDataFlowLog("⛓️ 已启动链式数据流（3步）")
    }
    
    // MARK: - Utility Methods
    
    private func executeStreamAction(_ action: String) {
        switch action {
        case "subscribe_navigation_stream":
            addDataFlowLog("🔗 执行导航流订阅操作")
        case "join_cross_page_stream":
            addDataFlowLog("🔗 加入跨页面数据流")
        default:
            addDataFlowLog("🔗 执行未知流操作: \(action)")
        }
    }
    
    private func clearDataFlow() {
        DataFlowManager.shared.unsubscribeAll(for: self)
        dataFlowTextView.text = "数据流已清空\n\n"
        addDataFlowLog("🧹 数据流已清空")
        
        // 重新设置基础订阅
        setupDataFlowSubscriptions()
    }
    
    private func exportDataFlowLog() {
        let logContent = dataFlowTextView.text ?? ""
        UIPasteboard.general.string = logContent
        
        let alert = UIAlertController(title: "导出成功", message: "数据流日志已复制到剪贴板", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
        
        addDataFlowLog("📋 数据流日志已导出到剪贴板")
    }
}

// MARK: - DateFormatter Extensions
extension DateFormatter {
    static let dataFlowFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:ss"
        return formatter
    }()
}
