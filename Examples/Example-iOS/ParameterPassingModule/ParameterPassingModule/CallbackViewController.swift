//
//  CallbackViewController.swift
//  ParameterPassingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 回调参数传递示例页面
class CallbackViewController: UIViewController, Routable {
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = CallbackViewController()
        vc.routeContext = RouteContext(url: "/callback", parameters: parameters ?? [:], moduleName: "ParameterPassingModule")
        return vc
    }

    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.failure(RouterError.actionNotFound(action)))
    }

    var routeContext: RouteContext?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let logTextView = UITextView()

    // 回调存储
    private var callbacks: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCallbackDisplay()
        setupTestButtons()
        extractCallbacks()
        displayReceivedCallbacks()
    }

    private func setupUI() {
        title = "回调参数传递"
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

    private func setupCallbackDisplay() {
        // 标题
        let titleLabel = createTitleLabel("回调执行日志")
        stackView.addArrangedSubview(titleLabel)

        // 日志显示区域
        let logView = createLogDisplayView()
        stackView.addArrangedSubview(logView)

        stackView.addArrangedSubview(createSeparator())
    }

    private func setupTestButtons() {
        // 测试按钮区域标题
        let testTitleLabel = createTitleLabel("回调测试")
        stackView.addArrangedSubview(testTitleLabel)

        // 基础回调测试
        let basicSection = createSectionView("基础回调")
        stackView.addArrangedSubview(basicSection)

        let basicTests = [
            ("执行成功回调", { self.executeSuccessCallback() }),
            ("执行失败回调", { self.executeFailureCallback() }),
            ("执行完成回调", { self.executeCompletionCallback() }),
            ("执行进度回调", { self.executeProgressCallback() })
        ]

        for (title, action) in basicTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }

        stackView.addArrangedSubview(createSeparator())

        // 数据回调测试
        let dataSection = createSectionView("数据回调")
        stackView.addArrangedSubview(dataSection)

        let dataTests = [
            ("执行数据选择回调", { self.executeDataSelectionCallback() }),
            ("执行数据更新回调", { self.executeDataUpdateCallback() }),
            ("执行数据删除回调", { self.executeDataDeletionCallback() })
        ]

        for (title, action) in dataTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }

        stackView.addArrangedSubview(createSeparator())

        // 导航回调测试
        let navigationSection = createSectionView("导航回调")
        stackView.addArrangedSubview(navigationSection)

        let navigationTests = [
            ("传递回调到新页面", { self.testCallbackToNewPage() }),
            ("返回时执行回调", { self.testReturnCallback() }),
            ("链式回调传递", { self.testChainedCallbacks() })
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
            ("清空日志", { self.clearLog() }),
            ("显示回调信息", { self.showCallbackInfo() }),
            ("测试所有回调", { self.testAllCallbacks() })
        ]

        for (title, action) in toolTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
    }

    private func extractCallbacks() {
        guard let context = routeContext else { return }

        // 从参数中提取回调
        callbacks = CallbackManager.shared.extractCallbacks(from: context.parameters)

        addLog("提取到 \(callbacks.count) 个回调")
        for (key, _) in callbacks {
            addLog("- \(key)")
        }
    }

    private func displayReceivedCallbacks() {
        guard let context = routeContext else { return }

        print("\n=== CallbackViewController 接收到的回调 ===")
        print("路由: \(context.url)")
        print("回调数量: \(callbacks.count)")
        for (key, _) in callbacks {
            print("回调: \(key)")
        }
        print("=== 回调显示结束 ===\n")
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

    private func createLogDisplayView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.separator.cgColor

        logTextView.isEditable = false
        logTextView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        logTextView.backgroundColor = .clear
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.text = "回调执行日志将显示在这里...\n\n"

        containerView.addSubview(logTextView)

        NSLayoutConstraint.activate([
            logTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            logTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            logTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            logTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            logTextView.heightAnchor.constraint(equalToConstant: 200)
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

    // 按钮动作数组和处理方法
    private var buttonActions: [() -> Void] = []

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

    // MARK: - Log Methods

    private func addLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timestamp = formatter.string(from: Date())
        let logMessage = "[\(timestamp)] \(message)\n"

        DispatchQueue.main.async {
            self.logTextView.text += logMessage

            // 滚动到底部
            let bottom = NSRange(location: self.logTextView.text.count - 1, length: 1)
            self.logTextView.scrollRangeToVisible(bottom)
        }
    }

    private func clearLog() {
        logTextView.text = "日志已清空\n\n"
    }

    // MARK: - Callback Execution Methods

    private func executeSuccessCallback() {
        addLog("执行成功回调...")

        if let successCallback = callbacks["onSuccess"] as? SuccessCallback {
            let result = "操作成功完成 - \(Date())"

            successCallback(result)
            addLog("✅ 成功回调已执行")
        } else {
            addLog("❌ 未找到成功回调")
        }
    }

    private func executeFailureCallback() {
        addLog("执行失败回调...")

        if let failureCallback = callbacks["onFailure"] as? FailureCallback {
            let error = NSError(domain: "TestDomain", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "测试错误：资源未找到",
                "errorCode": "E404",
                "timestamp": Date().timeIntervalSince1970
            ])

            failureCallback(error)
            addLog("❌ 失败回调已执行")
        } else {
            addLog("❌ 未找到失败回调")
        }
    }

    private func executeCompletionCallback() {
        addLog("执行完成回调...")

        if let completionCallback = callbacks["onCompletion"] as? CompletionCallback {
            completionCallback()
            addLog("✅ 完成回调已执行")
        } else {
            addLog("❌ 未找到完成回调")
        }
    }

    private func executeProgressCallback() {
        addLog("执行进度回调...")

        if let progressCallback = callbacks["onProgress"] as? ProgressCallback {
            // 模拟进度更新
            let progressValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]

            for (index, progress) in progressValues.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                    progressCallback(progress)
                    self.addLog("📊 进度更新: \(Int(progress * 100))%")
                }
            }
        } else {
            addLog("❌ 未找到进度回调")
        }
    }

    private func executeDataSelectionCallback() {
        addLog("执行数据选择回调...")

        if let selectionCallback = callbacks["onDataSelection"] as? DataSelectionCallback {
            let selectedData = [
                "id": "ITEM_001",
                "name": "选中的数据项",
                "type": "product",
                "value": 299.99,
                "selected": true
            ] as [String: Any]

            selectionCallback(selectedData)
            addLog("✅ 数据选择回调已执行")
        } else {
            addLog("❌ 未找到数据选择回调")
        }
    }

    private func executeDataUpdateCallback() {
        addLog("执行数据更新回调...")

        if let updateCallback = callbacks["onDataUpdate"] as? DataUpdateCallback {
            let updatedData = ["name": "新数据", "version": 2, "updatedAt": Date().timeIntervalSince1970] as [String: Any]

            updateCallback(updatedData)
            addLog("✅ 数据更新回调已执行")
        } else {
            addLog("❌ 未找到数据更新回调")
        }
    }

    private func executeDataDeletionCallback() {
        addLog("执行数据删除回调...")

        if let deletionCallback = callbacks["onDataDeletion"] as? DataDeletionCallback {
            let deletedId = "DELETED_001"

            deletionCallback(deletedId)
            addLog("✅ 数据删除回调已执行")
        } else {
            addLog("❌ 未找到数据删除回调")
        }
    }

    // MARK: - Navigation Callback Tests

    func testCallbackToNewPage() {
        addLog("传递回调到新页面...")

        // 创建新的回调
        let newPageCallback: SuccessCallback = { result in
            DispatchQueue.main.async {
                self.addLog("🔄 从新页面返回的回调: \(result)")
            }
        }

        let returnCallback: CompletionCallback = {
            DispatchQueue.main.async {
                self.addLog("🔙 页面返回回调已执行")
            }
        }

        var parameters = CallbackManager.shared.encodeCallbacks([
            "onNewPageResult": newPageCallback,
            "onReturn": returnCallback
        ])

        parameters["testType"] = "callback_to_new_page"
        parameters["message"] = "这是传递给新页面的消息"

        Router.push(to: "/ParameterPassingModule/callback", parameters: parameters)
    }

    func testReturnCallback() {
        addLog("测试返回回调...")

        // 模拟页面返回时的回调执行
        if let returnCallback = callbacks["onReturn"] as? CompletionCallback {
            returnCallback()
            addLog("✅ 返回回调已执行")
        } else {
            addLog("❌ 未找到返回回调")
        }

        // 如果有结果回调，也执行它
        if let resultCallback = callbacks["onNewPageResult"] as? SuccessCallback {
            let result = "从当前页面返回的数据 - \(Date())"

            resultCallback(result)
            addLog("✅ 结果回调已执行")
        }
    }

    func testChainedCallbacks() {
        addLog("测试链式回调...")

        // 创建链式回调
        let step1Callback: SuccessCallback = { result in
            DispatchQueue.main.async {
                self.addLog("🔗 步骤1完成: \(result)")

                // 执行步骤2
                let step2Callback: SuccessCallback = { result2 in
                    DispatchQueue.main.async {
                        self.addLog("🔗 步骤2完成: \(result2)")

                        // 执行步骤3
                        let step3Callback: CompletionCallback = {
                            DispatchQueue.main.async {
                                self.addLog("🔗 链式回调全部完成")
                            }
                        }

                        step3Callback()
                    }
                }

                step2Callback("步骤2数据")
            }
        }

        step1Callback("步骤1数据")
    }

    // MARK: - Utility Methods

    private func showCallbackInfo() {
        var info = "回调信息:\n\n"
        info += "总数: \(callbacks.count)\n\n"

        for (key, value) in callbacks {
            info += "\(key): \(type(of: value))\n"
        }

        if callbacks.isEmpty {
            info += "没有可用的回调"
        }

        let alert = UIAlertController(title: "回调信息", message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    func testAllCallbacks() {
        addLog("开始测试所有回调...")

        let testMethods = [
            executeSuccessCallback,
            executeFailureCallback,
            executeCompletionCallback,
            executeProgressCallback,
            executeDataSelectionCallback,
            executeDataUpdateCallback,
            executeDataDeletionCallback
        ]

        for (index, method) in testMethods.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.0) {
                method()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(testMethods.count) * 1.0) {
            self.addLog("🎉 所有回调测试完成")
        }
    }
}

// MARK: - CallbackViewController Extension
extension CallbackViewController {

    /// 创建测试回调并导航
    func createTestCallbacksAndNavigate() {
        let successCallback: SuccessCallback = { result in
            DispatchQueue.main.async {
                print("✅ 成功回调被调用: \(result)")
            }
        }

        let failureCallback: FailureCallback = { error in
            DispatchQueue.main.async {
                print("❌ 失败回调被调用: \(error.localizedDescription)")
            }
        }

        let progressCallback: ProgressCallback = { progress in
            DispatchQueue.main.async {
                print("📊 进度回调被调用: \(progress)")
            }
        }

        let completionCallback: CompletionCallback = {
            DispatchQueue.main.async {
                print("✅ 完成回调被调用")
            }
        }

        let parameters = CallbackManager.shared.encodeCallbacks([
            "onSuccess": successCallback,
            "onFailure": failureCallback,
            "onProgress": progressCallback,
            "onCompletion": completionCallback
        ])

        Router.push(to: "/ParameterPassingModule/callback", parameters: parameters)
    }
}
