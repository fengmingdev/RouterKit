//
//  ComplexObjectViewController.swift
//  ParameterPassingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 复杂对象参数传递示例页面
class ComplexObjectViewController: UIViewController, Routable {
    
    var routeContext: RouteContext?
    
    // MARK: - Routable Protocol
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = ComplexObjectViewController()
        vc.routeContext = RouteContext(url: "/complex-object", parameters: parameters ?? [:], moduleName: "ParameterPassingModule")
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
        setupObjectDisplay()
        setupTestButtons()
        displayReceivedObjects()
    }
    
    private func setupUI() {
        title = "复杂对象传递"
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
    
    private func setupObjectDisplay() {
        // 标题
        let titleLabel = createTitleLabel("接收到的对象")
        stackView.addArrangedSubview(titleLabel)
        
        // 对象显示区域
        let objectsView = createObjectsDisplayView()
        stackView.addArrangedSubview(objectsView)
        
        stackView.addArrangedSubview(createSeparator())
    }
    
    private func setupTestButtons() {
        // 测试按钮区域标题
        let testTitleLabel = createTitleLabel("对象传递测试")
        stackView.addArrangedSubview(testTitleLabel)
        
        // 用户信息对象
        let userSection = createSectionView("用户信息对象")
        stackView.addArrangedSubview(userSection)
        
        let userTests = [
            ("传递用户信息", { self.testUserInfoObject() }),
            ("传递用户列表", { self.testUserListObject() }),
            ("传递用户详情", { self.testUserDetailObject() })
        ]
        
        for (title, action) in userTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 产品信息对象
        let productSection = createSectionView("产品信息对象")
        stackView.addArrangedSubview(productSection)
        
        let productTests = [
            ("传递产品信息", { self.testProductInfoObject() }),
            ("传递产品列表", { self.testProductListObject() }),
            ("传递购物车", { self.testShoppingCartObject() })
        ]
        
        for (title, action) in productTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // 订单信息对象
        let orderSection = createSectionView("订单信息对象")
        stackView.addArrangedSubview(orderSection)
        
        let orderTests = [
            ("传递订单信息", { self.testOrderInfoObject() }),
            ("传递订单历史", { self.testOrderHistoryObject() }),
            ("传递复杂订单", { self.testComplexOrderObject() })
        ]
        
        for (title, action) in orderTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(createSeparator())
        
        // JSON 序列化测试
        let jsonSection = createSectionView("JSON 序列化测试")
        stackView.addArrangedSubview(jsonSection)
        
        let jsonTests = [
            ("JSON 编码传递", { self.testJSONEncodedObject() }),
            ("Base64 编码传递", { self.testBase64EncodedObject() }),
            ("自定义编码传递", { self.testCustomEncodedObject() })
        ]
        
        for (title, action) in jsonTests {
            let button = createTestButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func displayReceivedObjects() {
        guard let context = routeContext else { return }
        
        print("\n=== ComplexObjectViewController 接收到的对象 ===")
        print("路由: \(context.url)")
        
        // 尝试解析各种对象类型
        if let userInfo = ParameterPassingUtils.getObject(from: context.parameters, key: "userInfo", type: UserInfo.self) {
            print("用户信息: \(userInfo)")
        }
        
        if let productInfo = ParameterPassingUtils.getObject(from: context.parameters, key: "productInfo", type: ProductInfo.self) {
            print("产品信息: \(productInfo)")
        }
        
        if let orderInfo = ParameterPassingUtils.getObject(from: context.parameters, key: "orderInfo", type: OrderInfo.self) {
            print("订单信息: \(orderInfo)")
        }
        
        print("所有参数: \(context.parameters)")
        print("=== 对象显示结束 ===\n")
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
    
    private func createObjectsDisplayView() -> UIView {
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
        
        // 显示接收到的对象
        var displayText = "接收到的对象信息:\n\n"
        
        if let context = routeContext {
            displayText += "路由: \(context.url)\n\n"
            
            // 尝试解析和显示各种对象
            if let userInfo = ParameterPassingUtils.getObject(from: context.parameters, key: "userInfo", type: UserInfo.self) {
                displayText += "用户信息对象:\n"
                displayText += "  ID: \(userInfo.id)\n"
                displayText += "  姓名: \(userInfo.name)\n"
                displayText += "  邮箱: \(userInfo.email)\n"
                displayText += "  年龄: \(userInfo.age)\n"
                displayText += "  VIP: \(userInfo.isVIP)\n"
                if let address = userInfo.address {
                    displayText += "  地址: \(address.city), \(address.street)\n"
                }
                displayText += "\n"
            }
            
            if let productInfo = ParameterPassingUtils.getObject(from: context.parameters, key: "productInfo", type: ProductInfo.self) {
                displayText += "产品信息对象:\n"
                displayText += "  ID: \(productInfo.id)\n"
                displayText += "  名称: \(productInfo.name)\n"
                displayText += "  价格: ¥\(productInfo.price)\n"
                displayText += "  描述: \(productInfo.description)\n"
                displayText += "  库存: \(productInfo.stock)\n"
                displayText += "  分类: \(productInfo.category)\n"
                displayText += "  标签: \(productInfo.tags.joined(separator: ", "))\n"
                displayText += "\n"
            }
            
            if let orderInfo = ParameterPassingUtils.getObject(from: context.parameters, key: "orderInfo", type: OrderInfo.self) {
                displayText += "订单信息对象:\n"
                displayText += "  订单号: \(orderInfo.orderId)\n"
                displayText += "  用户ID: \(orderInfo.userId)\n"
                displayText += "  总金额: ¥\(orderInfo.totalAmount)\n"
                displayText += "  状态: \(orderInfo.status)\n"
                displayText += "  商品数量: \(orderInfo.products.count)\n"
                if let address = orderInfo.shippingAddress {
                    displayText += "  收货地址: \(address.city), \(address.street)\n"
                }
                displayText += "\n"
            }
            
            // 显示其他参数
            let objectKeys = ["userInfo", "productInfo", "orderInfo"]
            let otherParams = context.parameters.filter { !objectKeys.contains($0.key) }
            
            if !otherParams.isEmpty {
                displayText += "其他参数:\n"
                for (key, value) in otherParams {
                    displayText += "  \(key): \(value) (\(type(of: value)))\n"
                }
                displayText += "\n"
            }
            
            if context.parameters.isEmpty {
                displayText += "没有接收到任何对象"
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
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
        
        return containerView
    }
    
    private var buttonActions: [() -> Void] = []
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender.tag < buttonActions.count {
            buttonActions[sender.tag]()
        }
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
    
    // MARK: - Test Methods
    
    private func testUserInfoObject() {
        let userInfo = UserInfo(
            id: 1001,
            name: "张三",
            email: "zhangsan@example.com",
            age: 28,
            isVIP: true,
            address: Address(
                street: "建国路88号",
                city: "北京",
                state: "朝阳区",
                zipCode: "100020",
                country: "中国"
            )
        )
        
        let parameters = ParameterPassingUtils.encodeObject(userInfo) ?? [:]
        Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
    }
    
    private func testUserListObject() {
        let users = [
            UserInfo(id: 1, name: "用户1", email: "user1@example.com", age: 25, isVIP: false),
            UserInfo(id: 2, name: "用户2", email: "user2@example.com", age: 30, isVIP: true),
            UserInfo(id: 3, name: "用户3", email: "user3@example.com", age: 22, isVIP: false)
        ]
        
        var parameters = ParameterPassingUtils.encodeObject(users) ?? [:]
        parameters["listType"] = "users"
        parameters["count"] = users.count
        
        Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
    }
    
    private func testUserDetailObject() {
        let userInfo = UserInfo(
            id: 2001,
            name: "李四",
            email: "lisi@example.com",
            age: 32,
            isVIP: true,
            address: Address(
                street: "陆家嘴环路1000号",
                city: "上海",
                state: "浦东新区",
                zipCode: "200120",
                country: "中国"
            )
        )
        
        var parameters = ParameterPassingUtils.encodeObject(userInfo) ?? [:]
        parameters["viewType"] = "detail"
        parameters["showEditButton"] = true
        parameters["allowDelete"] = false
        
        Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
    }
    
    private func testProductInfoObject() {
        let productInfo = ProductInfo(
            id: "P001",
            title: "iPhone 15 Pro",
            description: "最新款iPhone，配备A17 Pro芯片，钛金属设计",
            price: 7999.0,
            category: "手机",
            name: "iPhone 15 Pro",
            stock: 50,
            tags: ["Apple", "iPhone", "5G", "钛金属"]
        )
        
        let parameters = ParameterPassingUtils.encodeObject(productInfo) ?? [:]
        Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
    }
    
    private func testProductListObject() {
        let products = [
            ProductInfo(id: "P001", title: "iPhone 15", description: "标准版iPhone", price: 5999.0, category: "手机", name: "iPhone 15", stock: 100, tags: ["Apple"]),
            ProductInfo(id: "P002", title: "MacBook Pro", description: "专业笔记本电脑", price: 14999.0, category: "电脑", name: "MacBook Pro", stock: 30, tags: ["Apple", "MacBook"]),
            ProductInfo(id: "P003", title: "AirPods Pro", description: "无线降噪耳机", price: 1999.0, category: "耳机", name: "AirPods Pro", stock: 200, tags: ["Apple", "无线"])
        ]
        
        var parameters = ParameterPassingUtils.encodeObject(products) ?? [:]
        parameters["listType"] = "products"
        parameters["category"] = "Apple产品"
        parameters["sortBy"] = "price"
        
        Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
    }
    
    private func testShoppingCartObject() {
        let cartItems = [
            (product: ProductInfo(id: "P001", title: "iPhone 15", description: "手机", price: 5999.0, category: "手机", name: "iPhone 15", stock: 100, tags: []), quantity: 1),
            (product: ProductInfo(id: "P003", title: "AirPods Pro", description: "耳机", price: 1999.0, category: "耳机", name: "AirPods Pro", stock: 200, tags: []), quantity: 2)
        ]
        
        let cartData = cartItems.map { item in
            return [
                "product": ParameterPassingUtils.objectToDictionary(item.product) ?? [:],
                "quantity": item.quantity
            ]
        }
        
        let parameters: [String: Any] = [
            "cartItems": cartData,
            "totalItems": cartItems.reduce(0) { $0 + $1.quantity },
            "totalAmount": cartItems.reduce(0.0) { $0 + ($1.product.price * Double($1.quantity)) },
            "cartId": "CART_\(UUID().uuidString.prefix(8))"
        ]
        
        Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
    }
    
    private func testOrderInfoObject() {
        let orderInfo = OrderInfo(
            orderId: "ORDER_\(Int.random(in: 10000...99999))",
            userId: 1001,
            products: [
                ProductInfo(id: "P001", title: "iPhone 15", description: "手机", price: 5999.0, category: "手机", name: "iPhone 15", stock: 100, tags: []),
                ProductInfo(id: "P002", title: "保护壳", description: "手机保护壳", price: 199.0, category: "配件", name: "保护壳", stock: 500, tags: [])
            ],
            totalAmount: 6198.0,
            status: "已支付",
            createdAt: Date(),
            shippingAddress: Address(
                street: "科技园南区",
                city: "深圳",
                state: "南山区",
                zipCode: "518000",
                country: "中国"
            )
        )
        
        let parameters = ParameterPassingUtils.encodeObject(orderInfo) ?? [:]
        Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
    }
    
    private func testOrderHistoryObject() {
        let orders = (1...5).map { index in
            OrderInfo(
                orderId: "ORDER_\(Int.random(in: 10000...99999))",
                userId: 1001,
                products: [
                    ProductInfo(id: "P\(String(format: "%03d", index))", title: "商品\(index)", description: "描述\(index)", price: Double(index * 100), category: "分类\(index)", name: "商品\(index)", stock: 10, tags: [])
                ],
                totalAmount: Double(index * 100),
                status: ["待支付", "已支付", "已发货", "已完成", "已取消"].randomElement()!,
                createdAt: Date().addingTimeInterval(-Double(index * 86400)),
                shippingAddress: Address(street: "街道\(index)", city: "城市\(index)", state: "区域\(index)", zipCode: "\(100000 + index)", country: "中国")
            )
        }
        
        var parameters = ParameterPassingUtils.encodeObject(orders) ?? [:]
        parameters["userId"] = 1001
        parameters["pageSize"] = 5
        parameters["totalCount"] = orders.count
        
        Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
    }
    
    private func testComplexOrderObject() {
        // 创建复杂的嵌套订单对象
        let complexOrder = [
            "order": ParameterPassingUtils.objectToDictionary(OrderInfo(
                orderId: "COMPLEX_ORDER_001",
                userId: 2001,
                products: [
                    ProductInfo(id: "P001", title: "复杂商品1", description: "复杂描述", price: 1299.0, category: "电子产品", name: "复杂商品1", stock: 10, tags: ["热销", "推荐"]),
                    ProductInfo(id: "P002", title: "复杂商品2", description: "另一个复杂描述", price: 899.0, category: "配件", name: "复杂商品2", stock: 5, tags: ["限量", "新品"])
                ],
                totalAmount: 2198.0,
                status: "处理中",
                createdAt: Date(),
                shippingAddress: Address(street: "珠江新城", city: "广州", state: "天河区", zipCode: "510000", country: "中国")
            )) ?? [:],
            "customer": ParameterPassingUtils.objectToDictionary(UserInfo(
                id: 2001,
                name: "王五",
                email: "wangwu@example.com",
                age: 35,
                isVIP: true,
                address: Address(street: "珠江新城", city: "广州", state: "天河区", zipCode: "510000", country: "中国")
            )) ?? [:],
            "payment": [
                "method": "支付宝",
                "transactionId": "TXN_\(UUID().uuidString.prefix(10))",
                "amount": 2198.0,
                "currency": "CNY",
                "timestamp": Date().timeIntervalSince1970
            ],
            "logistics": [
                "company": "顺丰快递",
                "trackingNumber": "SF\(Int.random(in: 100000000...999999999))",
                "estimatedDelivery": Date().addingTimeInterval(3 * 86400).timeIntervalSince1970,
                "status": "已揽收"
            ],
            "metadata": [
                "source": "iOS App",
                "version": "1.0.0",
                "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
                "timestamp": Date().timeIntervalSince1970
            ]
        ]
        
        Router.push(to: "/ParameterPassingModule/complex", parameters: complexOrder)
    }
    
    private func testJSONEncodedObject() {
        let userInfo = UserInfo(
            id: 3001,
            name: "JSON测试用户",
            email: "json@example.com",
            age: 26,
            isVIP: false,
            address: Address(street: "文三路", city: "杭州", state: "西湖区", zipCode: "310000", country: "中国")
        )
        
        // 使用JSON编码
        if let jsonData = try? JSONEncoder().encode(userInfo),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let parameters: [String: Any] = [
                "jsonEncodedUser": jsonString,
                "encodingType": "JSON",
                "originalType": "UserInfo"
            ]
            Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
        }
    }
    
    private func testBase64EncodedObject() {
        let productInfo = ProductInfo(
            id: "BASE64_P001",
            title: "Base64编码商品",
            description: "使用Base64编码传递的商品信息",
            price: 999.0,
            category: "测试",
            name: "Base64编码商品",
            stock: 20,
            tags: ["Base64", "编码测试"]
        )
        
        // 使用Base64编码
        if let jsonData = try? JSONEncoder().encode(productInfo),
           let base64String = jsonData.base64EncodedString() as String? {
            let parameters: [String: Any] = [
                "base64EncodedProduct": base64String,
                "encodingType": "Base64",
                "originalType": "ProductInfo"
            ]
            Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
        }
    }
    
    private func testCustomEncodedObject() {
        let orderInfo = OrderInfo(
            orderId: "CUSTOM_ENCODED_001",
            userId: 4001,
            products: [
                ProductInfo(id: "CE001", title: "自定义编码商品", description: "测试", price: 599.0, category: "测试", name: "自定义编码商品", stock: 15, tags: [])
            ],
            totalAmount: 599.0,
            status: "自定义状态",
            createdAt: Date(),
            shippingAddress: Address(street: "天府大道", city: "成都", state: "高新区", zipCode: "610000", country: "中国")
        )
        
        // 自定义编码：使用属性列表格式
        if let plistData = try? PropertyListEncoder().encode(orderInfo),
           let plistString = String(data: plistData, encoding: .utf8) {
            let parameters: [String: Any] = [
                "customEncodedOrder": plistString,
                "encodingType": "PropertyList",
                "originalType": "OrderInfo",
                "customNote": "使用PropertyListEncoder进行自定义编码"
            ]
            Router.push(to: "/ParameterPassingModule/complex", parameters: parameters)
        }
    }
}

// MARK: - ComplexObjectViewController Extension
extension ComplexObjectViewController {
    
    /// 显示对象详情弹窗
    private func showObjectDetails<T: Codable>(_ object: T, title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        if let jsonData = try? JSONEncoder().encode(object),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            alertController.message = jsonString
        } else {
            alertController.message = "无法序列化对象"
        }
        
        alertController.addAction(UIAlertAction(title: "确定", style: .default))
        present(alertController, animated: true)
    }
    
    /// 导出对象为JSON文件
    private func exportObjectAsJSON<T: Codable>(_ object: T, filename: String) {
        guard let jsonData = try? JSONEncoder().encode(object) else { return }
        
        let activityController = UIActivityViewController(activityItems: [jsonData], applicationActivities: nil)
        present(activityController, animated: true)
    }
}
