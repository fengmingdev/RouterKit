//
//  TabBarController.swift
//  MyMainProject
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit
import ObjectiveC

// MARK: - Associated Keys
private struct AssociatedKeys {
    static var routeKey: UInt8 = 0
}

class TabBarController: UITabBarController {
    
    // Tab配置
    private let tabConfigs: [(title: String, icon: String, selectedIcon: String, route: String)] = [
        ("首页", "house", "house.fill", "/"),
        ("消息", "message", "message.fill", "/MessageModule/message"),
        ("资料", "person", "person.fill", "/ProfileModule/profile"),
        ("参数", "arrow.left.arrow.right", "arrow.left.arrow.right.circle.fill", "/ParameterPassingModule/parameterPassing"),
        ("拦截器", "shield", "shield.fill", "/InterceptorModule/interceptor"),
        ("动画", "sparkles", "sparkles.circle.fill", "/AnimationModule/animation"),
        ("错误处理", "exclamationmark.triangle", "exclamationmark.triangle.fill", "/ErrorHandlingModule/errorhandling"),
        ("设置", "gearshape", "gearshape.fill", "/SettingsModule/settings")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
        setupTabBarAppearance()
        
        // 设置默认选中第一个tab
        selectedIndex = 0
    }
    
    private func setupTabBar() {
        // 设置TabBar样式
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        // 添加分隔线
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.separator.cgColor
        
        // 设置阴影
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 8
        tabBar.layer.shadowOpacity = 0.1
    }
    
    private func setupViewControllers() {
        var controllers: [UIViewController] = []
        
        for (index, config) in tabConfigs.enumerated() {
            let navController = createNavigationController(for: config, at: index)
            controllers.append(navController)
        }
        
        viewControllers = controllers
    }
    
    private func createNavigationController(for config: (title: String, icon: String, selectedIcon: String, route: String), at index: Int) -> UINavigationController {
        
        // 根据路由创建对应的视图控制器
        let viewController: UIViewController
        
        switch config.route {
        case "/":
            viewController = createHomeViewController()
        case "/MessageModule/message":
            viewController = createPlaceholderViewController(title: "消息", route: config.route)
        case "/ProfileModule/profile":
            viewController = createPlaceholderViewController(title: "资料", route: config.route)
        case "/ParameterPassingModule/parameterPassing":
            viewController = createPlaceholderViewController(title: "参数", route: config.route)
        case "/InterceptorModule/interceptor":
            viewController = createPlaceholderViewController(title: "拦截器", route: config.route)
        case "/AnimationModule/animation":
            viewController = createPlaceholderViewController(title: "动画", route: config.route)
        case "/ErrorHandlingModule/errorhandling":
            viewController = createPlaceholderViewController(title: "错误处理", route: config.route)
        case "/SettingsModule/settings":
            viewController = createPlaceholderViewController(title: "设置", route: config.route)
        default:
            viewController = createPlaceholderViewController(title: config.title, route: config.route)
        }
        
        // 创建导航控制器
        let navController = UINavigationController(rootViewController: viewController)
        
        // 设置TabBarItem
        let tabBarItem = UITabBarItem(
            title: config.title,
            image: UIImage(systemName: config.icon),
            selectedImage: UIImage(systemName: config.selectedIcon)
        )
        
        // 设置badge（示例）
        if config.title == "消息" {
            tabBarItem.badgeValue = "3"
            tabBarItem.badgeColor = .systemRed
        }
        
        navController.tabBarItem = tabBarItem
        navController.navigationBar.prefersLargeTitles = true
        
        return navController
    }
    
    private func createHomeViewController() -> UIViewController {
        let homeVC = UIViewController()
        homeVC.title = "首页"
        homeVC.view.backgroundColor = .systemBackground
        
        // 创建滚动视图
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        homeVC.view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 欢迎标题
        let welcomeLabel = UILabel()
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.text = "欢迎使用 RouterKit Example"
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 24)
        welcomeLabel.textColor = .label
        welcomeLabel.textAlignment = .center
        contentView.addSubview(welcomeLabel)
        
        // 描述文本
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "这是一个展示RouterKit功能的示例应用\n通过底部标签栏可以访问不同的功能模块"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        // 功能卡片容器
        let cardContainer = createFeatureCards()
        contentView.addSubview(cardContainer)
        
        // 快速导航按钮
        let quickNavContainer = createQuickNavigation()
        contentView.addSubview(quickNavContainer)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.topAnchor.constraint(equalTo: homeVC.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: homeVC.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: homeVC.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: homeVC.view.bottomAnchor),
            
            // 内容视图约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 欢迎标题约束
            welcomeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 描述文本约束
            descriptionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 功能卡片约束
            cardContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 快速导航约束
            quickNavContainer.topAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: 30),
            quickNavContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quickNavContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quickNavContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        return homeVC
    }
    
    private func createFeatureCards() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let features = [
            ("模块化路由", "arrow.triangle.branch", "支持模块化的路由管理"),
            ("参数传递", "arrow.left.arrow.right", "灵活的参数传递机制"),
            ("拦截器", "shield", "强大的路由拦截功能"),
            ("动画效果", "sparkles", "丰富的转场动画")
        ]
        
        var lastView: UIView?
        
        for (index, feature) in features.enumerated() {
            let cardView = createFeatureCard(title: feature.0, icon: feature.1, description: feature.2)
            container.addSubview(cardView)
            
            if index % 2 == 0 {
                // 左侧卡片
                NSLayoutConstraint.activate([
                    cardView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    cardView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.48)
                ])
            } else {
                // 右侧卡片
                NSLayoutConstraint.activate([
                    cardView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                    cardView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.48)
                ])
            }
            
            if index < 2 {
                // 第一行
                cardView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            } else {
                // 第二行
                cardView.topAnchor.constraint(equalTo: container.topAnchor, constant: 140).isActive = true
            }
            
            cardView.heightAnchor.constraint(equalToConstant: 120).isActive = true
            lastView = cardView
        }
        
        // 设置容器高度
        container.heightAnchor.constraint(equalToConstant: 280).isActive = true
        
        return container
    }
    
    private func createFeatureCard(title: String, icon: String, description: String) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.1
        
        // 图标
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        cardView.addSubview(iconView)
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        cardView.addSubview(titleLabel)
        
        // 描述
        let descLabel = UILabel()
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.text = description
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 2
        cardView.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12)
        ])
        
        return cardView
    }
    
    private func createQuickNavigation() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "快速导航"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        container.addSubview(titleLabel)
        
        // 导航按钮
        let navButtons = [
            ("登录模块", "/LoginModule/login"),
            ("消息模块", "/MessageModule/message"),
            ("用户资料", "/ProfileModule/profile"),
            ("应用设置", "/SettingsModule/settings")
        ]
        
        var lastButton: UIButton?
        
        for (index, nav) in navButtons.enumerated() {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(nav.0, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            
            // 添加点击事件
            button.addTarget(self, action: #selector(quickNavButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
            
            container.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 44),
                button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
            
            if let lastButton = lastButton {
                button.topAnchor.constraint(equalTo: lastButton.bottomAnchor, constant: 12).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
            }
            
            lastButton = button
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            lastButton!.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createPlaceholderViewController(title: String, route: String) -> UIViewController {
        // 为设置页面返回深度链接测试页面
        if title == "设置" {
            return DeepLinkTestViewController()
        }
        
        let vc = UIViewController()
        vc.title = title
        vc.view.backgroundColor = .systemBackground
        
        // 占位内容
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(title)页面\n\n路由: \(route)\n\n点击TabBar其他标签可以切换页面\n\n实际应用中，这里会通过RouterKit\n导航到对应的模块页面"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        vc.view.addSubview(label)
        
        // 导航按钮
        let navButton = UIButton(type: .system)
        navButton.translatesAutoresizingMaskIntoConstraints = false
        navButton.setTitle("使用RouterKit导航", for: .normal)
        navButton.backgroundColor = .systemBlue
        navButton.setTitleColor(.white, for: .normal)
        navButton.layer.cornerRadius = 8
        navButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // 使用iOS 13兼容的方式
        navButton.addTarget(self, action: #selector(navButtonTapped(_:)), for: .touchUpInside)
        // 存储路由信息到按钮
        objc_setAssociatedObject(navButton, &AssociatedKeys.routeKey, route, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        vc.view.addSubview(navButton)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor, constant: -50),
            label.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -40),
            
            navButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            navButton.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            navButton.widthAnchor.constraint(equalToConstant: 200),
            navButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return vc
    }
    
    private func setupTabBarAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            // 设置选中和未选中状态的颜色
            appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
            appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    @objc private func quickNavButtonTapped(_ sender: UIButton) {
        let routes = [
            "/LoginModule/login",
            "/MessageModule/message",
            "/ProfileModule/profile",
            "/SettingsModule/settings"
        ]
        
        let route = routes[sender.tag]
        print("TabBarController: 快速导航到 \(route)")
        Router.push(to: route)
    }
    
    @objc private func navButtonTapped(_ sender: UIButton) {
        if let route = objc_getAssociatedObject(sender, &AssociatedKeys.routeKey) as? String {
            print("TabBarController: 导航到 \(route)")
            Router.push(to: route)
        }
    }
    
    // MARK: - TabBar Delegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        
        // 添加选中动画
        if let index = tabBar.items?.firstIndex(of: item) {
            animateTabSelection(at: index)
        }
    }
    
    private func animateTabSelection(at index: Int) {
        guard let tabBarItems = tabBar.items,
              index < tabBarItems.count,
              let view = tabBar.subviews.first(where: { $0.frame.origin.x > 0 }) else {
            return
        }
        
        // 简单的缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = CGAffineTransform.identity
            }
        }
    }
}