//
//  AboutViewController.swift
//  SettingsModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

public class AboutViewController: UIViewController, Routable {

    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return AboutViewController()
    }

    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "getAppInfo":
            let info = [
                "appName": "RouterKit Example",
                "version": "1.0.0",
                "buildVersion": "100",
                "routerKitVersion": "2.0.0"
            ]
            completion(.success(info))
        case "openSupport":
            // 打开技术支持页面
            completion(.success("技术支持页面已打开"))
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // 应用信息
    private let appInfo = [
        ("应用名称", "RouterKit Example"),
        ("版本号", "1.0.0"),
        ("构建版本", "100"),
        ("RouterKit版本", "2.0.0"),
        ("最后更新", "2025年1月23日")
    ]

    // 开发团队信息
    private let teamInfo = [
        ("开发者", "RouterKit Team"),
        ("技术支持", "support@routerkit.com"),
        ("官方网站", "https://routerkit.com"),
        ("GitHub", "https://github.com/routerkit/RouterKit")
    ]

    // 法律信息
    private let legalInfo = [
        ("用户协议", "查看用户服务协议"),
        ("隐私政策", "查看隐私保护政策"),
        ("开源许可", "查看开源组件许可证"),
        ("版权声明", "© 2025 RouterKit Team")
    ]

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "关于应用"

        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        setupContent()
    }

    private func setupContent() {
        var lastView: UIView?

        // 应用图标和名称
        let headerView = createHeaderView()
        contentView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = headerView

        // 应用信息部分
        let appInfoView = createSectionView(title: "应用信息", items: appInfo, style: .info)
        contentView.addSubview(appInfoView)
        NSLayoutConstraint.activate([
            appInfoView.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: 30),
            appInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            appInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = appInfoView

        // 开发团队部分
        let teamInfoView = createSectionView(title: "开发团队", items: teamInfo, style: .contact)
        contentView.addSubview(teamInfoView)
        NSLayoutConstraint.activate([
            teamInfoView.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: 20),
            teamInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            teamInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = teamInfoView

        // 法律信息部分
        let legalInfoView = createSectionView(title: "法律信息", items: legalInfo, style: .legal)
        contentView.addSubview(legalInfoView)
        NSLayoutConstraint.activate([
            legalInfoView.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: 20),
            legalInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            legalInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastView = legalInfoView

        // 感谢信息
        let thanksView = createThanksView()
        contentView.addSubview(thanksView)
        NSLayoutConstraint.activate([
            thanksView.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: 30),
            thanksView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            thanksView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            thanksView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false

        // 应用图标
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "app.fill")
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 20
        iconImageView.layer.masksToBounds = true
        iconImageView.backgroundColor = .systemGray6
        headerView.addSubview(iconImageView)

        // 应用名称
        let appNameLabel = UILabel()
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.text = "RouterKit Example"
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 28)
        appNameLabel.textColor = .label
        appNameLabel.textAlignment = .center
        headerView.addSubview(appNameLabel)

        // 应用描述
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "一个展示RouterKit功能的示例应用"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        headerView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            // 图标约束
            iconImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),

            // 应用名称约束
            appNameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            appNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            appNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            // 描述约束
            descriptionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        return headerView
    }

    private func createSectionView(title: String, items: [(String, String)], style: SectionStyle) -> UIView {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        sectionView.backgroundColor = .systemBackground
        sectionView.layer.cornerRadius = 12
        sectionView.layer.shadowColor = UIColor.black.cgColor
        sectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        sectionView.layer.shadowRadius = 8
        sectionView.layer.shadowOpacity = 0.1

        // 标题
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        sectionView.addSubview(titleLabel)

        var lastView: UIView = titleLabel

        // 添加信息项
        for (index, item) in items.enumerated() {
            let itemView = createInfoItemView(title: item.0, value: item.1, style: style, isLast: index == items.count - 1)
            sectionView.addSubview(itemView)

            NSLayoutConstraint.activate([
                itemView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: index == 0 ? 16 : 12),
                itemView.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
                itemView.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16)
            ])

            lastView = itemView
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),

            lastView.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -16)
        ])

        return sectionView
    }

    private func createInfoItemView(title: String, value: String, style: SectionStyle, isLast: Bool) -> UIView {
        let itemView = UIView()
        itemView.translatesAutoresizingMaskIntoConstraints = false

        // 标题标签
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        itemView.addSubview(titleLabel)

        // 值标签
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = style == .contact ? .systemBlue : .label
        valueLabel.numberOfLines = 0
        itemView.addSubview(valueLabel)

        // 如果是联系方式，添加点击手势
        if style == .contact && (title.contains("网站") || title.contains("GitHub") || title.contains("支持")) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleContactTap(_:)))
            valueLabel.isUserInteractionEnabled = true
            valueLabel.addGestureRecognizer(tapGesture)
            valueLabel.tag = getContactTag(for: title)
        }

        // 如果是法律信息，添加点击手势
        if style == .legal && title != "版权声明" {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLegalTap(_:)))
            valueLabel.isUserInteractionEnabled = true
            valueLabel.addGestureRecognizer(tapGesture)
            valueLabel.tag = getLegalTag(for: title)
            valueLabel.textColor = .systemBlue
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: itemView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: itemView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: itemView.trailingAnchor),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: itemView.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: itemView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: itemView.bottomAnchor)
        ])

        return itemView
    }

    private func createThanksView() -> UIView {
        let thanksView = UIView()
        thanksView.translatesAutoresizingMaskIntoConstraints = false
        thanksView.backgroundColor = .systemBackground
        thanksView.layer.cornerRadius = 12
        thanksView.layer.shadowColor = UIColor.black.cgColor
        thanksView.layer.shadowOffset = CGSize(width: 0, height: 2)
        thanksView.layer.shadowRadius = 8
        thanksView.layer.shadowOpacity = 0.1

        // 感谢图标
        let heartIcon = UIImageView()
        heartIcon.translatesAutoresizingMaskIntoConstraints = false
        heartIcon.image = UIImage(systemName: "heart.fill")
        heartIcon.tintColor = .systemRed
        heartIcon.contentMode = .scaleAspectFit
        thanksView.addSubview(heartIcon)

        // 感谢文本
        let thanksLabel = UILabel()
        thanksLabel.translatesAutoresizingMaskIntoConstraints = false
        thanksLabel.text = "感谢您使用RouterKit Example！\n\n这个应用展示了RouterKit框架的强大功能，包括模块化路由、参数传递、拦截器、动画效果等特性。\n\n如果您在使用过程中遇到任何问题或有改进建议，欢迎通过上述联系方式与我们沟通。"
        thanksLabel.font = UIFont.systemFont(ofSize: 14)
        thanksLabel.textColor = .secondaryLabel
        thanksLabel.textAlignment = .center
        thanksLabel.numberOfLines = 0
        thanksView.addSubview(thanksLabel)

        NSLayoutConstraint.activate([
            heartIcon.topAnchor.constraint(equalTo: thanksView.topAnchor, constant: 20),
            heartIcon.centerXAnchor.constraint(equalTo: thanksView.centerXAnchor),
            heartIcon.widthAnchor.constraint(equalToConstant: 24),
            heartIcon.heightAnchor.constraint(equalToConstant: 24),

            thanksLabel.topAnchor.constraint(equalTo: heartIcon.bottomAnchor, constant: 16),
            thanksLabel.leadingAnchor.constraint(equalTo: thanksView.leadingAnchor, constant: 20),
            thanksLabel.trailingAnchor.constraint(equalTo: thanksView.trailingAnchor, constant: -20),
            thanksLabel.bottomAnchor.constraint(equalTo: thanksView.bottomAnchor, constant: -20)
        ])

        return thanksView
    }

    private func getContactTag(for title: String) -> Int {
        switch title {
        case "技术支持": return 1001
        case "官方网站": return 1002
        case "GitHub": return 1003
        default: return 0
        }
    }

    private func getLegalTag(for title: String) -> Int {
        switch title {
        case "用户协议": return 2001
        case "隐私政策": return 2002
        case "开源许可": return 2003
        default: return 0
        }
    }

    @objc private func handleContactTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }

        switch label.tag {
        case 1001: // 技术支持
            openEmail("support@routerkit.com")
        case 1002: // 官方网站
            openURL("https://routerkit.com")
        case 1003: // GitHub
            openURL("https://github.com/routerkit/RouterKit")
        default:
            break
        }
    }

    @objc private func handleLegalTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }

        let title: String
        let content: String

        switch label.tag {
        case 2001: // 用户协议
            title = "用户服务协议"
            content = "这里是用户服务协议的详细内容...\n\n1. 服务条款\n2. 用户权利和义务\n3. 隐私保护\n4. 免责声明\n\n详细内容请访问官方网站查看完整版本。"
        case 2002: // 隐私政策
            title = "隐私保护政策"
            content = "我们非常重视您的隐私保护...\n\n1. 信息收集\n2. 信息使用\n3. 信息共享\n4. 信息安全\n\n详细内容请访问官方网站查看完整版本。"
        case 2003: // 开源许可
            title = "开源组件许可证"
            content = "本应用使用了以下开源组件：\n\n• RouterKit - MIT License\n• UIKit - Apple License\n• Foundation - Apple License\n\n感谢开源社区的贡献！"
        default:
            return
        }

        showLegalDocument(title: title, content: content)
    }

    private func openEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "无法打开邮件", message: "请手动发送邮件到：\(email)")
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "无法打开链接", message: "请手动访问：\(urlString)")
        }
    }

    private func showLegalDocument(title: String, content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SectionStyle
private enum SectionStyle {
    case info
    case contact
    case legal
}
