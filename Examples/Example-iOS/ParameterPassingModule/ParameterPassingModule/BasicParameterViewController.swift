//
//  BasicParameterViewController.swift
//  ParameterPassingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 基础参数传递示例页面
class BasicParameterViewController: UIViewController, Routable {

    var routeContext: RouteContext?
    private var buttonActions: [() -> Void] = []

    // MARK: - Routable Protocol
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = BasicParameterViewController()
        vc.routeContext = RouteContext(url: "/basic-parameter", parameters: parameters ?? [:], moduleName: "ParameterPassingModule")
        return vc
    }

    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.failure(RouterError.actionNotFound(action)))
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupParameterDisplay()
        setupTestButtons()
        displayReceivedParameters()
    }

    private func setupUI() {
        title = "基础参数传递"
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

    private func setupParameterDisplay() {
        // 标题
        let titleLabel = createTitleLabel("接收到的参数")
        stackView.addArrangedSubview(titleLabel)

        // 参数显示区域
        let parametersView = createParametersDisplayView()
        stackView.addArrangedSubview(parametersView)

        stackView.addArrangedSubview(createSeparator())
    }

    private func setupTestButtons() {
        // 测试按钮区域标题
        let testTitleLabel = createTitleLabel("参数传递测试")
        stackView.addArrangedSubview(testTitleLabel)

        // 基础类型参数传递
        let basicSection = createSectionView("基础类型参数")
        stackView.addArrangedSubview(basicSection)

        let basicTests = [
            ("传递字符串参数", { self.testStringParameter() }),
            ("传递数字参数", { self.testNumberParameter() }),
            ("传递布尔参数", { self.testBooleanParameter() }),
            ("传递多个参数", { self.testMultipleParameters() })
        ]

        for (title, action) in basicTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }

        stackView.addArrangedSubview(createSeparator())

        // 集合类型参数传递
        let collectionSection = createSectionView("集合类型参数")
        stackView.addArrangedSubview(collectionSection)

        let collectionTests = [
            ("传递数组参数", { self.testArrayParameter() }),
            ("传递字典参数", { self.testDictionaryParameter() }),
            ("传递嵌套数据", { self.testNestedDataParameter() })
        ]

        for (title, action) in collectionTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }

        stackView.addArrangedSubview(createSeparator())

        // URL参数传递
        let urlSection = createSectionView("URL参数传递")
        stackView.addArrangedSubview(urlSection)

        let urlTests = [
            ("查询参数传递", { self.testQueryParameters() }),
            ("路径参数传递", { self.testPathParameters() }),
            ("混合参数传递", { self.testMixedParameters() })
        ]

        for (title, action) in urlTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
    }

    private func displayReceivedParameters() {
        guard let context = routeContext else { return }

        print("\n=== BasicParameterViewController 接收到的参数 ===")
        print("路由: \(context.url)")
        print("参数: \(context.parameters)")
        print("=== 参数显示结束 ===\n")
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

    private func createParametersDisplayView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.separator.cgColor

        let textView = UITextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false

        // 显示接收到的参数
        var displayText = "接收到的参数信息:\n\n"

        if let context = routeContext {
            displayText += "路由: \(context.url)\n\n"

            if !context.parameters.isEmpty {
                displayText += "参数 (parameters):\n"
                for (key, value) in context.parameters {
                    displayText += "  \(key): \(value) (\(type(of: value)))\n"
                }
                displayText += "\n"
            }

            if context.parameters.isEmpty {
                displayText += "没有接收到任何参数"
            }
        } else {
            displayText += "没有路由上下文信息"
        }

        textView.text = displayText

        containerView.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
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

    // MARK: - Test Methods

    func testStringParameter() {
        let parameters = [
            "message": "Hello, RouterKit!",
            "title": "字符串参数测试",
            "description": "这是一个字符串参数传递的示例"
        ]

        Router.push(to: "/ParameterPassingModule/basic", parameters: parameters)
    }

    func testNumberParameter() {
        let parameters: [String: Any] = [
            "userId": 12345,
            "score": 98.5,
            "level": 10,
            "progress": 0.75
        ]

        Router.push(to: "/ParameterPassingModule/basic", parameters: parameters)
    }

    func testBooleanParameter() {
        let parameters: [String: Any] = [
            "isVIP": true,
            "hasNotification": false,
            "isOnline": true,
            "isDarkMode": false
        ]

        Router.push(to: "/ParameterPassingModule/basic", parameters: parameters)
    }

    func testMultipleParameters() {
        let parameters: [String: Any] = [
            "name": "张三",
            "age": 25,
            "isStudent": true,
            "gpa": 3.8,
            "courses": ["数学", "物理", "化学"],
            "address": [
                "city": "北京",
                "district": "朝阳区",
                "zipCode": "100000"
            ]
        ]

        Router.push(to: "/ParameterPassingModule/basic", parameters: parameters)
    }

    func testArrayParameter() {
        let parameters: [String: Any] = [
            "tags": ["iOS", "Swift", "RouterKit", "移动开发"],
            "scores": [85, 92, 78, 96, 88],
            "features": [true, false, true, true, false],
            "mixed": ["text", 123, true, 45.6]
        ]

        Router.push(to: "/ParameterPassingModule/basic", parameters: parameters)
    }

    func testDictionaryParameter() {
        let parameters: [String: Any] = [
            "userInfo": [
                "id": 123,
                "name": "李四",
                "email": "lisi@example.com"
            ],
            "settings": [
                "theme": "dark",
                "language": "zh-CN",
                "notifications": true
            ],
            "metadata": [
                "version": "1.0.0",
                "buildNumber": 100,
                "timestamp": Date().timeIntervalSince1970
            ]
        ]

        Router.push(to: "/ParameterPassingModule/basic", parameters: parameters)
    }

    func testNestedDataParameter() {
        let parameters: [String: Any] = [
            "company": [
                "name": "科技公司",
                "employees": [
                    [
                        "id": 1,
                        "name": "王五",
                        "department": "开发部",
                        "skills": ["Swift", "iOS", "UIKit"]
                    ],
                    [
                        "id": 2,
                        "name": "赵六",
                        "department": "设计部",
                        "skills": ["Sketch", "Figma", "Photoshop"]
                    ]
                ],
                "location": [
                    "country": "中国",
                    "city": "上海",
                    "address": [
                        "street": "南京路",
                        "number": "123号",
                        "floor": 15
                    ]
                ]
            ]
        ]

        Router.push(to: "/ParameterPassingModule/basic", parameters: parameters)
    }

    func testQueryParameters() {
        // 模拟URL查询参数
        let route = "/ParameterPassingModule/basic?name=测试用户&id=999&active=true&score=95.5"
        Router.push(to: route)
    }

    func testPathParameters() {
        // 模拟路径参数（需要在路由注册时支持）
        let parameters = [
            "pathParam1": "value1",
            "pathParam2": "value2",
            "simulatedPath": "/users/123/profile"
        ]

        Router.push(to: "/ParameterPassingModule/basic", parameters: parameters)
    }

    func testMixedParameters() {
        // 混合参数传递：路径参数 + 查询参数 + 普通参数
        let route = "/ParameterPassingModule/basic?category=electronics&sort=price&order=asc"
        let parameters: [String: Any] = [
            "userId": 456,
            "sessionId": "abc123def456",
            "preferences": [
                "currency": "CNY",
                "language": "zh-CN",
                "timezone": "Asia/Shanghai"
            ],
            "filters": [
                "priceRange": [100, 1000],
                "brands": ["Apple", "Samsung", "Huawei"],
                "inStock": true
            ]
        ]

        Router.push(to: route, parameters: parameters)
    }
}

// MARK: - BasicParameterViewController Extension
extension BasicParameterViewController {

    /// 显示参数详情弹窗
    private func showParameterDetails(_ parameters: [String: Any], title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        var message = ""
        for (key, value) in parameters {
            message += "\(key): \(value)\n"
        }

        alertController.message = message
        alertController.addAction(UIAlertAction(title: "确定", style: .default))

        present(alertController, animated: true)
    }

    /// 复制参数到剪贴板
    private func copyParametersToClipboard() {
        guard let context = routeContext else { return }

        var text = "路由: \(context.url)\n\n"

        if !context.parameters.isEmpty {
            text += "参数:\n"
            for (key, value) in context.parameters {
                text += "\(key): \(value)\n"
            }
            text += "\n"
        }

        UIPasteboard.general.string = text

        let alert = UIAlertController(title: "提示", message: "参数信息已复制到剪贴板", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
