//
//  HomeViewController.swift
//  MyMainProject
//
//  Created by fengming on 2025/9/8.
//

import UIKit
import RouterKit

/// 首页视图控制器
class HomeViewController: UIViewController, Routable {
    
    // MARK: - UI组件
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "欢迎使用 RouterKit Example"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "这是一个展示RouterKit功能的示例应用\n通过底部标签栏可以访问不同的功能模块"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "首页"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(welcomeLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        // 创建功能卡片
        let featureCards = createFeatureCards()
        contentView.addSubview(featureCards)
        
        // 创建快速导航
        let quickNavigation = createQuickNavigation()
        contentView.addSubview(quickNavigation)
        
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
            
            // 欢迎标题约束
            welcomeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 描述文本约束
            descriptionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 功能卡片约束
            featureCards.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            featureCards.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featureCards.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 快速导航约束
            quickNavigation.topAnchor.constraint(equalTo: featureCards.bottomAnchor, constant: 30),
            quickNavigation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quickNavigation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quickNavigation.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - 功能卡片
    
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
    
    // MARK: - 快速导航
    
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
    
    @objc private func quickNavButtonTapped(_ sender: UIButton) {
        let routes = [
            "/LoginModule/login",
            "/MessageModule/message",
            "/ProfileModule/profile",
            "/SettingsModule/settings"
        ]
        
        let route = routes[sender.tag]
        print("HomeViewController: 快速导航到 \(route)")
        Router.push(to: route)
    }
    
    // MARK: - Routable协议实现
    
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return HomeViewController()
    }
    
    public static func createViewController(context: RouteContext) async throws -> PlatformViewController {
        return HomeViewController()
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.failure(RouterError.actionNotFound(action)))
    }
}
