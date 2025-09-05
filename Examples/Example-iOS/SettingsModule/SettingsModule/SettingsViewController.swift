//
//  SettingsViewController.swift
//  SettingsModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

public class SettingsViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return SettingsViewController()
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "resetSettings":
            SettingsManager.shared.resetToDefaults()
            completion(.success("设置已重置"))
        case "exportSettings":
            // 导出设置逻辑
            completion(.success("设置导出成功"))
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var settings: AppSettings!
    
    // 设置项数据
    private struct SettingsSection {
        let title: String?
        let items: [SettingsItem]
    }
    
    struct SettingsItem {
        let title: String
        let subtitle: String?
        let icon: String?
        let accessoryType: UITableViewCell.AccessoryType
        let action: () -> Void
    }
    
    private var sections: [SettingsSection] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
        setupNotifications()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次显示时刷新设置
        loadSettings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "设置"
        
        // 配置表格视图
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: SettingsManager.themeDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationSettingsDidChange),
            name: SettingsManager.notificationSettingsDidChangeNotification,
            object: nil
        )
    }
    
    private func loadSettings() {
        settings = SettingsManager.shared.getCurrentSettings()
        buildSections()
        tableView.reloadData()
    }
    
    private func buildSections() {
        sections = [
            // 外观设置
            SettingsSection(title: "外观", items: [
                SettingsItem(
                    title: "主题设置",
                    subtitle: settings.theme.displayName,
                    icon: "paintbrush.fill",
                    accessoryType: .disclosureIndicator,
                    action: { [weak self] in
                        self?.navigateToThemeSettings()
                    }
                )
            ]),
            
            // 通知设置
            SettingsSection(title: "通知", items: [
                SettingsItem(
                    title: "通知设置",
                    subtitle: settings.notifications.pushEnabled ? "已开启" : "已关闭",
                    icon: "bell.fill",
                    accessoryType: .disclosureIndicator,
                    action: { [weak self] in
                        self?.navigateToNotificationSettings()
                    }
                )
            ]),
            
            // 账户设置
            SettingsSection(title: "账户", items: [
                SettingsItem(
                    title: "自动登录",
                    subtitle: nil,
                    icon: "person.fill.checkmark",
                    accessoryType: .none,
                    action: {}
                )
            ]),
            
            // 应用设置
            SettingsSection(title: "应用", items: [
                SettingsItem(
                    title: "缓存管理",
                    subtitle: nil,
                    icon: "externaldrive.fill",
                    accessoryType: .none,
                    action: {}
                ),
                SettingsItem(
                    title: "调试模式",
                    subtitle: nil,
                    icon: "ladybug.fill",
                    accessoryType: .none,
                    action: {}
                )
            ]),
            
            // 关于
            SettingsSection(title: "关于", items: [
                SettingsItem(
                    title: "关于应用",
                    subtitle: "版本 1.0.0",
                    icon: "info.circle.fill",
                    accessoryType: .disclosureIndicator,
                    action: { [weak self] in
                        self?.navigateToAbout()
                    }
                ),
                SettingsItem(
                    title: "重置设置",
                    subtitle: "恢复默认设置",
                    icon: "arrow.clockwise.circle.fill",
                    accessoryType: .none,
                    action: { [weak self] in
                        self?.showResetConfirmation()
                    }
                )
            ])
        ]
    }
    
    private func navigateToThemeSettings() {
        print("SettingsViewController: 跳转到主题设置")
        Router.push(to: "/SettingsModule/theme")
    }
    
    private func navigateToNotificationSettings() {
        print("SettingsViewController: 跳转到通知设置")
        Router.push(to: "/SettingsModule/notification")
    }
    
    private func navigateToAbout() {
        print("SettingsViewController: 跳转到关于页面")
        Router.push(to: "/SettingsModule/about")
    }
    
    private func showResetConfirmation() {
        let alert = UIAlertController(
            title: "重置设置",
            message: "确定要将所有设置恢复为默认值吗？此操作不可撤销。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "重置", style: .destructive) { _ in
            self.resetSettings()
        })
        
        present(alert, animated: true)
    }
    
    private func resetSettings() {
        SettingsManager.shared.resetToDefaults()
        loadSettings()
        
        let alert = UIAlertController(
            title: "重置完成",
            message: "所有设置已恢复为默认值",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func themeDidChange(_ notification: Notification) {
        loadSettings()
    }
    
    @objc private func notificationSettingsDidChange(_ notification: Notification) {
        loadSettings()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        
        // 判断是否需要开关控件
        let needsSwitch = (item.title == "自动登录" || item.title == "缓存管理" || item.title == "调试模式")
        
        if needsSwitch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(with: item, settings: settings) { [weak self] newValue in
                self?.handleSwitchChange(for: item.title, value: newValue)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.subtitle
            cell.accessoryType = item.accessoryType
            
            if let iconName = item.icon {
                cell.imageView?.image = UIImage(systemName: iconName)
                cell.imageView?.tintColor = .systemBlue
            }
            
            return cell
        }
    }
    
    private func handleSwitchChange(for title: String, value: Bool) {
        switch title {
        case "自动登录":
            SettingsManager.shared.updateAutoLogin(value)
        case "缓存管理":
            SettingsManager.shared.updateCacheEnabled(value)
        case "调试模式":
            SettingsManager.shared.updateDebugMode(value)
        default:
            break
        }
        
        // 更新本地设置
        settings = SettingsManager.shared.getCurrentSettings()
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        item.action()
    }
}

// MARK: - 自定义开关单元格
class SwitchTableViewCell: UITableViewCell {
    
    private let switchControl = UISwitch()
    private var switchAction: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        accessoryView = switchControl
        selectionStyle = .none
    }
    
    func configure(with item: SettingsViewController.SettingsItem, settings: AppSettings, switchAction: @escaping (Bool) -> Void) {
        textLabel?.text = item.title
        self.switchAction = switchAction
        
        if let iconName = item.icon {
            imageView?.image = UIImage(systemName: iconName)
            imageView?.tintColor = .systemBlue
        }
        
        // 根据设置项设置开关状态
        switch item.title {
        case "自动登录":
            switchControl.isOn = settings.autoLogin
        case "缓存管理":
            switchControl.isOn = settings.cacheEnabled
        case "调试模式":
            switchControl.isOn = settings.debugMode
        default:
            switchControl.isOn = false
        }
    }
    
    // 为 NotificationSettingsViewController 添加的配置方法
    func configure(title: String, isOn: Bool, switchAction: @escaping (Bool) -> Void) {
        textLabel?.text = title
        switchControl.isOn = isOn
        self.switchAction = switchAction
    }
    
    @objc private func switchValueChanged() {
        switchAction?(switchControl.isOn)
    }
}
