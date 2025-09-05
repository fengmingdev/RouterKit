//
//  DataPreloadViewController.swift
//  InterceptorModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 数据预加载拦截器示例页面
class DataPreloadViewController: UIViewController, Routable {
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let viewController = DataPreloadViewController()
        if let parameters = parameters,
           let preloadedData = parameters["preloadedData"] as? [String: Any] {
            viewController.preloadedData = preloadedData
        }
        return viewController
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "preloadUserData":
            completion(.success("用户数据预加载完成"))
        case "preloadProductData":
            completion(.success("产品数据预加载完成"))
        case "preloadMessageData":
            completion(.success("消息数据预加载完成"))
        case "clearData":
            completion(.success("数据已清除"))
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }
    
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let preloadedDataLabel = UILabel()
    private let dataDisplayTextView = UITextView()
    private let logTextView = UITextView()
    
    // 测试按钮
    private let preloadUserDataButton = UIButton(type: .system)
    private let preloadProductDataButton = UIButton(type: .system)
    private let preloadMessageDataButton = UIButton(type: .system)
    private let preloadAllDataButton = UIButton(type: .system)
    private let clearDataButton = UIButton(type: .system)
    private let clearLogButton = UIButton(type: .system)
    
    // MARK: - Properties
    
    private var preloadedData: [String: Any] = [:]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        // 处理路由参数
        handleRouteParameters()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "数据预加载拦截器"
        
        // 标题
        titleLabel.text = "数据预加载拦截器示例"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        
        // 描述
        descriptionLabel.text = "演示如何使用数据预加载拦截器在导航前预加载必要的数据"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        // 预加载数据标签
        preloadedDataLabel.text = "预加载的数据:"
        preloadedDataLabel.font = .boldSystemFont(ofSize: 18)
        
        // 数据显示文本视图
        dataDisplayTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        dataDisplayTextView.backgroundColor = .systemGray6
        dataDisplayTextView.layer.cornerRadius = 8
        dataDisplayTextView.isEditable = false
        dataDisplayTextView.text = "预加载的数据将显示在这里...\n"
        
        // 日志文本视图
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.backgroundColor = .systemGray6
        logTextView.layer.cornerRadius = 8
        logTextView.isEditable = false
        logTextView.text = "数据预加载日志将显示在这里...\n"
        
        // 测试按钮
        setupButton(preloadUserDataButton, title: "预加载用户数据", backgroundColor: .systemBlue)
        setupButton(preloadProductDataButton, title: "预加载产品数据", backgroundColor: .systemGreen)
        setupButton(preloadMessageDataButton, title: "预加载消息数据", backgroundColor: .systemOrange)
        setupButton(preloadAllDataButton, title: "预加载所有数据", backgroundColor: .systemPurple)
        setupButton(clearDataButton, title: "清空数据", backgroundColor: .systemRed)
        setupButton(clearLogButton, title: "清空日志", backgroundColor: .systemGray)
        
        // 添加按钮事件
        preloadUserDataButton.addTarget(self, action: #selector(preloadUserDataTapped), for: .touchUpInside)
        preloadProductDataButton.addTarget(self, action: #selector(preloadProductDataTapped), for: .touchUpInside)
        preloadMessageDataButton.addTarget(self, action: #selector(preloadMessageDataTapped), for: .touchUpInside)
        preloadAllDataButton.addTarget(self, action: #selector(preloadAllDataTapped), for: .touchUpInside)
        clearDataButton.addTarget(self, action: #selector(clearDataTapped), for: .touchUpInside)
        clearLogButton.addTarget(self, action: #selector(clearLogTapped), for: .touchUpInside)
        
        // 添加到视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, descriptionLabel, preloadedDataLabel, dataDisplayTextView, logTextView,
         preloadUserDataButton, preloadProductDataButton, preloadMessageDataButton,
         preloadAllDataButton, clearDataButton, clearLogButton].forEach {
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
            
            // Test buttons (2x2 grid)
            preloadUserDataButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            preloadUserDataButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            preloadUserDataButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            preloadUserDataButton.heightAnchor.constraint(equalToConstant: 44),
            
            preloadProductDataButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            preloadProductDataButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            preloadProductDataButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            preloadProductDataButton.heightAnchor.constraint(equalToConstant: 44),
            
            preloadMessageDataButton.topAnchor.constraint(equalTo: preloadUserDataButton.bottomAnchor, constant: 10),
            preloadMessageDataButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            preloadMessageDataButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            preloadMessageDataButton.heightAnchor.constraint(equalToConstant: 44),
            
            preloadAllDataButton.topAnchor.constraint(equalTo: preloadProductDataButton.bottomAnchor, constant: 10),
            preloadAllDataButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            preloadAllDataButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            preloadAllDataButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Clear buttons
            clearDataButton.topAnchor.constraint(equalTo: preloadMessageDataButton.bottomAnchor, constant: 20),
            clearDataButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            clearDataButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            clearDataButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearLogButton.topAnchor.constraint(equalTo: preloadAllDataButton.bottomAnchor, constant: 20),
            clearLogButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            clearLogButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            clearLogButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Preloaded Data Label
            preloadedDataLabel.topAnchor.constraint(equalTo: clearDataButton.bottomAnchor, constant: 20),
            preloadedDataLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            preloadedDataLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Data Display TextView
            dataDisplayTextView.topAnchor.constraint(equalTo: preloadedDataLabel.bottomAnchor, constant: 10),
            dataDisplayTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dataDisplayTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dataDisplayTextView.heightAnchor.constraint(equalToConstant: 150),
            
            // Log TextView
            logTextView.topAnchor.constraint(equalTo: dataDisplayTextView.bottomAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logTextView.heightAnchor.constraint(equalToConstant: 150),
            logTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Route Parameters
    
    private func handleRouteParameters() {
        // 检查是否有预加载的数据
        if !preloadedData.isEmpty {
            updateDataDisplay()
            addLog("✅ 检测到预加载数据: \(preloadedData.keys.joined(separator: ", "))")
        }
    }
    
    // MARK: - Actions
    
    @objc private func preloadUserDataTapped() {
        addLog("🔍 开始预加载用户数据...")
        
        // 使用RouterKit导航，并指定预加载用户数据
        Router.shared.navigate(to: "/InterceptorModule/dataPreload", parameters: [
            "preloadData": ["userProfile"],
            "testType": "userData",
            "timestamp": Date().timeIntervalSince1970
        ]) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.addLog("✅ 用户数据预加载成功")
                case .failure(let error):
                    self?.addLog("❌ 用户数据预加载失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func preloadProductDataTapped() {
        addLog("🔍 开始预加载产品数据...")
        
        Router.shared.navigate(to: "/InterceptorModule/dataPreload", parameters: [
            "preloadData": ["productList"],
            "testType": "productData",
            "timestamp": Date().timeIntervalSince1970
        ]) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.addLog("✅ 产品数据预加载成功")
                case .failure(let error):
                    self?.addLog("❌ 产品数据预加载失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func preloadMessageDataTapped() {
        addLog("🔍 开始预加载消息数据...")
        
        Router.shared.navigate(to: "/InterceptorModule/dataPreload", parameters: [
            "preloadData": ["messageList"],
            "testType": "messageData",
            "timestamp": Date().timeIntervalSince1970
        ]) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.addLog("✅ 消息数据预加载成功")
                case .failure(let error):
                    self?.addLog("❌ 消息数据预加载失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func preloadAllDataTapped() {
        addLog("🔍 开始预加载所有数据...")
        
        Router.shared.navigate(to: "/InterceptorModule/dataPreload", parameters: [
            "preloadData": ["userProfile", "userSettings", "productList", "messageList"],
            "testType": "allData",
            "timestamp": Date().timeIntervalSince1970
        ]) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.addLog("✅ 所有数据预加载成功")
                case .failure(let error):
                    self?.addLog("❌ 数据预加载失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func clearDataTapped() {
        preloadedData.removeAll()
        updateDataDisplay()
        addLog("🗑️ 已清空预加载数据")
    }
    
    @objc private func clearLogTapped() {
        logTextView.text = "数据预加载日志将显示在这里...\n"
    }
    
    // MARK: - Helper Methods
    
    private func updateDataDisplay() {
        if preloadedData.isEmpty {
            dataDisplayTextView.text = "预加载的数据将显示在这里...\n"
        } else {
            var displayText = ""
            for (key, value) in preloadedData {
                displayText += "\n[\(key)]\n"
                if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    displayText += jsonString + "\n"
                } else {
                    displayText += "\(value)\n"
                }
                displayText += "\n" + String(repeating: "-", count: 40) + "\n"
            }
            dataDisplayTextView.text = displayText
        }
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] \(message)\n"
        logTextView.text += logMessage
        
        // 滚动到底部
        let bottom = NSMakeRange(logTextView.text.count - 1, 1)
        logTextView.scrollRangeToVisible(bottom)
    }
}

// MARK: - Extensions

extension TimeInterval {
    var milliseconds: String {
        return String(format: "%.1fms", self * 1000)
    }
}
