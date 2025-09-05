//
//  GlobalStateViewController.swift
//  ParameterPassingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 全局状态参数传递示例页面
class GlobalStateViewController: UIViewController, Routable {
    
    var routeContext: RouteContext?
    
    // MARK: - Routable Protocol
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = GlobalStateViewController()
        vc.routeContext = RouteContext(url: "/global-state", parameters: parameters ?? [:], moduleName: "ParameterPassingModule")
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.failure(RouterError.actionNotFound(action)))
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let stateDisplayView = UIView()
    private let stateTextView = UITextView()
    
    // 状态观察者
    private var stateObservers: [NSObjectProtocol] = []
    
    // 按钮动作存储
    private var buttonActions: [() -> Void] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStateDisplay()
        setupTestButtons()
        setupStateObservers()
        displayCurrentState()
        processReceivedParameters()
    }
    
    deinit {
        // 移除观察者
        stateObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    private func setupUI() {
        title = "全局状态传递"
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
    
    private func setupStateDisplay() {
        // 标题
        let titleLabel = createTitleLabel("全局状态监控")
        stackView.addArrangedSubview(titleLabel)
        
        // 状态显示区域
        let stateView = createStateDisplayView()
        stackView.addArrangedSubview(stateView)
        
        stackView.addArrangedSubview(createSeparator())
    }
    
    private func setupTestButtons() {
        // 测试按钮区域标题
        let testTitleLabel = createTitleLabel("状态操作测试")
        stackView.addArrangedSubview(testTitleLabel)
        
        // 用户状态操作
        let userSection = createSectionView("用户状态")
        stackView.addArrangedSubview(userSection)
        
        let userTests = [
            ("登录用户", { self.testUserLogin() }),
            ("更新用户信息", { self.testUserUpdate() }),
            ("用户登出", { self.testUserLogout() }),
            ("切换VIP状态", { self.testToggleVIP() })
        ]
        
        for (title, action) in userTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 应用状态操作
        let appSection = createSectionView("应用状态")
        stackView.addArrangedSubview(appSection)
        
        let appTests = [
            ("切换主题", { self.testThemeToggle() }),
            ("更改语言", { self.testLanguageChange() }),
            ("更新设置", { self.testSettingsUpdate() }),
            ("清除缓存", { self.testClearCache() })
        ]
        
        for (title, action) in appTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 数据状态操作
        let dataSection = createSectionView("数据状态")
        stackView.addArrangedSubview(dataSection)
        
        let dataTests = [
            ("加载数据", { self.testDataLoading() }),
            ("更新购物车", { self.testCartUpdate() }),
            ("同步数据", { self.testDataSync() }),
            ("重置数据", { self.testDataReset() })
        ]
        
        for (title, action) in dataTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 导航状态测试
        let navigationSection = createSectionView("导航状态测试")
        stackView.addArrangedSubview(navigationSection)
        
        let navigationTests = [
            ("传递状态到新页面", { self.testStateToNewPage() }),
            ("状态同步导航", { self.testStateSyncNavigation() }),
            ("批量状态更新", { self.testBatchStateUpdate() })
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
            ("刷新状态显示", { self.refreshStateDisplay() }),
            ("导出状态", { self.exportState() }),
            ("重置所有状态", { self.resetAllStates() })
        ]
        
        for (title, action) in toolTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func setupStateObservers() {
        // 观察用户状态变化
        let userObserver = NotificationCenter.default.addObserver(
            forName: .globalStateUserChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleUserStateChange(notification)
        }
        stateObservers.append(userObserver)
        
        // 观察应用状态变化
        let appObserver = NotificationCenter.default.addObserver(
            forName: .globalStateAppChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppStateChange(notification)
        }
        stateObservers.append(appObserver)
        
        // 观察数据状态变化
        let dataObserver = NotificationCenter.default.addObserver(
            forName: .globalStateDataChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleDataStateChange(notification)
        }
        stateObservers.append(dataObserver)
    }
    
    private func processReceivedParameters() {
        guard let context = routeContext else { return }
        
        // 处理接收到的状态参数
        if let stateKey = context.parameters["stateKey"] as? String {
            print("接收到状态键: \(stateKey)")
            
            // 根据状态键获取对应的全局状态
            let state = GlobalStateManager.shared.getState(for: stateKey)
            print("对应的状态值: \(state ?? "nil")")
        }
        
        if let stateAction = context.parameters["stateAction"] as? String {
            print("接收到状态操作: \(stateAction)")
            executeStateAction(stateAction)
        }
        
        if let stateData = context.parameters["stateData"] as? [String: Any] {
            print("接收到状态数据: \(stateData)")
            GlobalStateManager.shared.updateStates(stateData)
        }
    }
    
    private func displayCurrentState() {
        print("\n=== GlobalStateViewController 当前全局状态 ===")
        let allStates = GlobalStateManager.shared.getAllStates()
        for (key, value) in allStates {
            print("\(key): \(value)")
        }
        print("=== 状态显示结束 ===\n")
        
        refreshStateDisplay()
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
    
    private func createStateDisplayView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.separator.cgColor
        
        stateTextView.isEditable = false
        stateTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        stateTextView.backgroundColor = .clear
        stateTextView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stateTextView)
        
        NSLayoutConstraint.activate([
            stateTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stateTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stateTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            stateTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            stateTextView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        return containerView
    }
    
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
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender.tag < buttonActions.count {
            buttonActions[sender.tag]()
        }
    }
    
    // MARK: - State Display Methods
    
    private func refreshStateDisplay() {
        let allStates = GlobalStateManager.shared.getAllStates()
        var displayText = "全局状态实时监控\n"
        displayText += "更新时间: \(DateFormatter.stateFormatter.string(from: Date()))\n\n"
        
        // 用户状态
        displayText += "=== 用户状态 ===\n"
        if let userState = allStates["user"] as? [String: Any] {
            for (key, value) in userState {
                displayText += "\(key): \(value)\n"
            }
        } else {
            displayText += "未登录\n"
        }
        displayText += "\n"
        
        // 应用状态
        displayText += "=== 应用状态 ===\n"
        if let appState = allStates["app"] as? [String: Any] {
            for (key, value) in appState {
                displayText += "\(key): \(value)\n"
            }
        } else {
            displayText += "默认设置\n"
        }
        displayText += "\n"
        
        // 数据状态
        displayText += "=== 数据状态 ===\n"
        if let dataState = allStates["data"] as? [String: Any] {
            for (key, value) in dataState {
                displayText += "\(key): \(value)\n"
            }
        } else {
            displayText += "无数据\n"
        }
        displayText += "\n"
        
        // 其他状态
        let knownKeys = ["user", "app", "data"]
        let otherStates = allStates.filter { !knownKeys.contains($0.key) }
        if !otherStates.isEmpty {
            displayText += "=== 其他状态 ===\n"
            for (key, value) in otherStates {
                displayText += "\(key): \(value)\n"
            }
        }
        
        stateTextView.text = displayText
    }
    
    // MARK: - State Change Handlers
    
    private func handleUserStateChange(_ notification: Notification) {
        print("用户状态变化: \(notification.userInfo ?? [:])")
        refreshStateDisplay()
    }
    
    private func handleAppStateChange(_ notification: Notification) {
        print("应用状态变化: \(notification.userInfo ?? [:])")
        refreshStateDisplay()
    }
    
    private func handleDataStateChange(_ notification: Notification) {
        print("数据状态变化: \(notification.userInfo ?? [:])")
        refreshStateDisplay()
    }
    
    // MARK: - Test Methods
    
    private func testUserLogin() {
        let userInfo = [
            "id": 1001,
            "name": "测试用户",
            "email": "test@example.com",
            "isVIP": false,
            "loginTime": Date().timeIntervalSince1970
        ] as [String : Any]
        
        GlobalStateManager.shared.setState(userInfo, for: "user")
        print("用户登录成功")
    }
    
    private func testUserUpdate() {
        var currentUser = GlobalStateManager.shared.getState(for: "user") as? [String: Any] ?? [:]
        currentUser["name"] = "更新后的用户名"
        currentUser["lastUpdate"] = Date().timeIntervalSince1970
        currentUser["profileComplete"] = true
        
        GlobalStateManager.shared.setState(currentUser, for: "user")
        print("用户信息更新成功")
    }
    
    private func testUserLogout() {
        GlobalStateManager.shared.removeState(for: "user")
        print("用户登出成功")
    }
    
    private func testToggleVIP() {
        var currentUser = GlobalStateManager.shared.getState(for: "user") as? [String: Any] ?? [:]
        let currentVIP = currentUser["isVIP"] as? Bool ?? false
        currentUser["isVIP"] = !currentVIP
        currentUser["vipChangeTime"] = Date().timeIntervalSince1970
        
        GlobalStateManager.shared.setState(currentUser, for: "user")
        print("VIP状态切换: \(!currentVIP)")
    }
    
    private func testThemeToggle() {
        var appState = GlobalStateManager.shared.getState(for: "app") as? [String: Any] ?? [:]
        let currentTheme = appState["theme"] as? String ?? "light"
        let newTheme = currentTheme == "light" ? "dark" : "light"
        
        appState["theme"] = newTheme
        appState["themeChangeTime"] = Date().timeIntervalSince1970
        
        GlobalStateManager.shared.setState(appState, for: "app")
        print("主题切换到: \(newTheme)")
    }
    
    private func testLanguageChange() {
        var appState = GlobalStateManager.shared.getState(for: "app") as? [String: Any] ?? [:]
        let languages = ["zh-CN", "en-US", "ja-JP"]
        let currentLanguage = appState["language"] as? String ?? "zh-CN"
        let currentIndex = languages.firstIndex(of: currentLanguage) ?? 0
        let newIndex = (currentIndex + 1) % languages.count
        let newLanguage = languages[newIndex]
        
        appState["language"] = newLanguage
        appState["languageChangeTime"] = Date().timeIntervalSince1970
        
        GlobalStateManager.shared.setState(appState, for: "app")
        print("语言切换到: \(newLanguage)")
    }
    
    private func testSettingsUpdate() {
        var appState = GlobalStateManager.shared.getState(for: "app") as? [String: Any] ?? [:]
        
        appState["notifications"] = Bool.random()
        appState["autoSync"] = Bool.random()
        appState["cacheSize"] = Int.random(in: 10...100)
        appState["settingsVersion"] = "1.\(Int.random(in: 0...9)).\(Int.random(in: 0...9))"
        appState["lastSettingsUpdate"] = Date().timeIntervalSince1970
        
        GlobalStateManager.shared.setState(appState, for: "app")
        print("应用设置更新完成")
    }
    
    private func testClearCache() {
        var appState = GlobalStateManager.shared.getState(for: "app") as? [String: Any] ?? [:]
        appState["cacheCleared"] = true
        appState["cacheSize"] = 0
        appState["lastCacheClear"] = Date().timeIntervalSince1970
        
        GlobalStateManager.shared.setState(appState, for: "app")
        print("缓存清理完成")
    }
    
    private func testDataLoading() {
        let dataState = [
            "isLoading": true,
            "loadingProgress": 0.0,
            "loadStartTime": Date().timeIntervalSince1970,
            "dataSource": "remote_api"
        ] as [String : Any]
        
        GlobalStateManager.shared.setState(dataState, for: "data")
        
        // 模拟加载进度
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var updatedState = GlobalStateManager.shared.getState(for: "data") as? [String: Any] ?? [:]
            updatedState["isLoading"] = false
            updatedState["loadingProgress"] = 1.0
            updatedState["loadEndTime"] = Date().timeIntervalSince1970
            updatedState["itemCount"] = Int.random(in: 50...200)
            
            GlobalStateManager.shared.setState(updatedState, for: "data")
            print("数据加载完成")
        }
        
        print("开始加载数据")
    }
    
    private func testCartUpdate() {
        var dataState = GlobalStateManager.shared.getState(for: "data") as? [String: Any] ?? [:]
        
        let cartItems = Int.random(in: 1...10)
        let cartTotal = Double.random(in: 100...1000)
        
        dataState["cartItems"] = cartItems
        dataState["cartTotal"] = cartTotal
        dataState["cartUpdateTime"] = Date().timeIntervalSince1970
        dataState["cartId"] = "CART_\(UUID().uuidString.prefix(8))"
        
        GlobalStateManager.shared.setState(dataState, for: "data")
        print("购物车更新: \(cartItems)件商品，总计¥\(String(format: "%.2f", cartTotal))")
    }
    
    private func testDataSync() {
        var dataState = GlobalStateManager.shared.getState(for: "data") as? [String: Any] ?? [:]
        
        dataState["isSyncing"] = true
        dataState["syncStartTime"] = Date().timeIntervalSince1970
        
        GlobalStateManager.shared.setState(dataState, for: "data")
        
        // 模拟同步过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            var updatedState = GlobalStateManager.shared.getState(for: "data") as? [String: Any] ?? [:]
            updatedState["isSyncing"] = false
            updatedState["syncEndTime"] = Date().timeIntervalSince1970
            updatedState["lastSyncResult"] = "success"
            updatedState["syncedItems"] = Int.random(in: 10...50)
            
            GlobalStateManager.shared.setState(updatedState, for: "data")
            print("数据同步完成")
        }
        
        print("开始数据同步")
    }
    
    private func testDataReset() {
        GlobalStateManager.shared.removeState(for: "data")
        print("数据状态重置完成")
    }
    
    // MARK: - Navigation State Tests
    
    private func testStateToNewPage() {
        // 创建要传递的状态
        let navigationState = [
            "sourcePageId": "global_state_page",
            "navigationTime": Date().timeIntervalSince1970,
            "stateSnapshot": GlobalStateManager.shared.getAllStates()
        ] as [String : Any]
        
        // 设置临时状态
        GlobalStateManager.shared.setState(navigationState, for: "navigation")
        
        let parameters: [String: Any] = [
            "stateKey": "navigation",
            "stateAction": "load_from_navigation",
            "message": "从全局状态页面导航而来"
        ]
        
        Router.push(to: "/ParameterPassingModule/globalState", parameters: parameters)
    }
    
    private func testStateSyncNavigation() {
        // 同步多个状态到新页面
        let syncStates = [
            "user": GlobalStateManager.shared.getState(for: "user"),
            "app": GlobalStateManager.shared.getState(for: "app"),
            "data": GlobalStateManager.shared.getState(for: "data")
        ]
        
        let parameters: [String: Any] = [
            "stateData": syncStates,
            "syncType": "full_sync",
            "syncTime": Date().timeIntervalSince1970
        ]
        
        Router.push(to: "/ParameterPassingModule/globalState", parameters: parameters)
    }
    
    private func testBatchStateUpdate() {
        let batchUpdates = [
            "user": [
                "batchUpdateId": UUID().uuidString,
                "batchUpdateTime": Date().timeIntervalSince1970
            ],
            "app": [
                "batchUpdateId": UUID().uuidString,
                "batchUpdateTime": Date().timeIntervalSince1970
            ],
            "data": [
                "batchUpdateId": UUID().uuidString,
                "batchUpdateTime": Date().timeIntervalSince1970
            ]
        ]
        
        GlobalStateManager.shared.updateStates(batchUpdates)
        print("批量状态更新完成")
    }
    
    // MARK: - Utility Methods
    
    private func executeStateAction(_ action: String) {
        switch action {
        case "load_from_navigation":
            if let navigationState = GlobalStateManager.shared.getState(for: "navigation") as? [String: Any] {
                print("从导航状态加载: \(navigationState)")
            }
        case "full_sync":
            print("执行完整状态同步")
        default:
            print("未知状态操作: \(action)")
        }
    }
    
    private func exportState() {
        let allStates = GlobalStateManager.shared.getAllStates()
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: allStates, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            
            UIPasteboard.general.string = jsonString
            
            let alert = UIAlertController(title: "导出成功", message: "状态数据已复制到剪贴板", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func resetAllStates() {
        let alert = UIAlertController(title: "重置确认", message: "确定要重置所有全局状态吗？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            GlobalStateManager.shared.clearAllStates()
            self.refreshStateDisplay()
            print("所有状态已重置")
        })
        
        present(alert, animated: true)
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let stateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

// MARK: - Notification Names
extension Notification.Name {
    static let globalStateUserChanged = Notification.Name("GlobalStateUserChanged")
    static let globalStateAppChanged = Notification.Name("GlobalStateAppChanged")
    static let globalStateDataChanged = Notification.Name("GlobalStateDataChanged")
}
