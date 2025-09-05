//
//  NotificationSettingsViewController.swift
//  SettingsModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import UserNotifications
import RouterKit

public class NotificationSettingsViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return NotificationSettingsViewController()
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "enableAllNotifications":
            var settings = SettingsManager.shared.getNotificationSettings()
            settings.pushEnabled = true
            settings.messageEnabled = true
            settings.systemEnabled = true
            SettingsManager.shared.updateNotificationSettings(settings)
            completion(.success("已启用所有通知"))
        case "disableAllNotifications":
            var settings = SettingsManager.shared.getNotificationSettings()
            settings.pushEnabled = false
            settings.messageEnabled = false
            settings.systemEnabled = false
            SettingsManager.shared.updateNotificationSettings(settings)
            completion(.success("已禁用所有通知"))
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var notificationSettings: NotificationSettings!
    private var systemAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // 设置项数据
    private let settingSections: [(title: String, items: [SettingItem])] = [
        ("推送通知", [
            SettingItem(key: "pushEnabled", title: "启用推送通知", type: .switch, description: "接收应用推送通知"),
            SettingItem(key: "soundEnabled", title: "通知声音", type: .switch, description: "播放通知提示音")
        ]),
        ("消息通知", [
            SettingItem(key: "messageEnabled", title: "消息通知", type: .switch, description: "接收新消息通知"),
            SettingItem(key: "commentEnabled", title: "评论通知", type: .switch, description: "接收评论回复通知"),
            SettingItem(key: "likeEnabled", title: "点赞通知", type: .switch, description: "接收点赞通知")
        ]),
        ("系统通知", [
            SettingItem(key: "systemEnabled", title: "系统通知", type: .switch, description: "接收系统重要通知"),
            SettingItem(key: "updateEnabled", title: "更新通知", type: .switch, description: "接收应用更新通知"),
            SettingItem(key: "maintenanceEnabled", title: "维护通知", type: .switch, description: "接收系统维护通知")
        ]),
        ("通知时间", [
            SettingItem(key: "quietHours", title: "免打扰时间", type: .disclosure, description: "设置免打扰时间段"),
            SettingItem(key: "weekendMode", title: "周末模式", type: .switch, description: "周末减少通知频率")
        ])
    ]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadNotificationSettings()
        checkNotificationPermission()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNotificationPermission()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "通知设置"
        
        // 添加权限设置按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "权限设置",
            style: .plain,
            target: self,
            action: #selector(openSystemSettings)
        )
        
        // 配置表格视图
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DisclosureCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 添加权限状态头部视图
        setupPermissionHeaderView()
    }
    
    private func setupPermissionHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 120))
        headerView.backgroundColor = .clear
        
        // 权限状态容器
        let statusContainer = UIView()
        statusContainer.translatesAutoresizingMaskIntoConstraints = false
        statusContainer.backgroundColor = .systemBackground
        statusContainer.layer.cornerRadius = 12
        statusContainer.layer.shadowColor = UIColor.black.cgColor
        statusContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        statusContainer.layer.shadowRadius = 8
        statusContainer.layer.shadowOpacity = 0.1
        headerView.addSubview(statusContainer)
        
        // 状态图标
        let statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.image = UIImage(systemName: "bell.fill")
        statusIcon.tintColor = .systemBlue
        statusIcon.contentMode = .scaleAspectFit
        statusContainer.addSubview(statusIcon)
        
        // 状态标题
        let statusTitle = UILabel()
        statusTitle.translatesAutoresizingMaskIntoConstraints = false
        statusTitle.text = "通知权限状态"
        statusTitle.font = UIFont.boldSystemFont(ofSize: 16)
        statusTitle.textColor = .label
        statusContainer.addSubview(statusTitle)
        
        // 状态描述
        let statusDescription = UILabel()
        statusDescription.translatesAutoresizingMaskIntoConstraints = false
        statusDescription.text = "检查中..."
        statusDescription.font = UIFont.systemFont(ofSize: 14)
        statusDescription.textColor = .secondaryLabel
        statusDescription.numberOfLines = 0
        statusDescription.tag = 100 // 用于后续更新
        statusContainer.addSubview(statusDescription)
        
        NSLayoutConstraint.activate([
            // 状态容器约束
            statusContainer.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            statusContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            statusContainer.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            statusContainer.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            // 状态图标约束
            statusIcon.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 16),
            statusIcon.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // 状态标题约束
            statusTitle.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 16),
            statusTitle.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            statusTitle.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -16),
            
            // 状态描述约束
            statusDescription.topAnchor.constraint(equalTo: statusTitle.bottomAnchor, constant: 4),
            statusDescription.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            statusDescription.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -16),
            statusDescription.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -16)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func loadNotificationSettings() {
        notificationSettings = SettingsManager.shared.getCurrentSettings().notifications
        tableView.reloadData()
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.systemAuthorizationStatus = settings.authorizationStatus
                self?.updatePermissionStatus(settings)
            }
        }
    }
    
    private func updatePermissionStatus(_ settings: UNNotificationSettings) {
        guard let statusLabel = tableView.tableHeaderView?.viewWithTag(100) as? UILabel else { return }
        
        let statusText: String
        let iconName: String
        let iconColor: UIColor
        
        switch settings.authorizationStatus {
        case .authorized:
            statusText = "通知权限已授权，可以正常接收推送通知"
            iconName = "checkmark.circle.fill"
            iconColor = .systemGreen
        case .denied:
            statusText = "通知权限被拒绝，请在系统设置中开启通知权限"
            iconName = "xmark.circle.fill"
            iconColor = .systemRed
        case .notDetermined:
            statusText = "尚未请求通知权限，点击下方开关将请求权限"
            iconName = "questionmark.circle.fill"
            iconColor = .systemOrange
        case .provisional:
            statusText = "临时通知权限已授权，通知将静默显示"
            iconName = "bell.badge.fill"
            iconColor = .systemBlue
        case .ephemeral:
            statusText = "临时应用通知权限"
            iconName = "clock.fill"
            iconColor = .systemBlue
        @unknown default:
            statusText = "未知通知权限状态"
            iconName = "exclamationmark.circle.fill"
            iconColor = .systemGray
        }
        
        statusLabel.text = statusText
        
        // 更新图标
        if let headerView = tableView.tableHeaderView,
           let statusContainer = headerView.subviews.first,
           let statusIcon = statusContainer.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            statusIcon.image = UIImage(systemName: iconName)
            statusIcon.tintColor = iconColor
        }
    }
    
    @objc private func openSystemSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("NotificationSettingsViewController: 请求通知权限失败: \(error)")
                } else {
                    print("NotificationSettingsViewController: 通知权限请求结果: \(granted)")
                }
                self?.checkNotificationPermission()
            }
        }
    }
    
    private func updateNotificationSetting(key: String, value: Bool) {
        print("NotificationSettingsViewController: 更新通知设置 \(key) = \(value)")
        
        // 如果是主开关且系统权限未授权，先请求权限
        if key == "pushEnabled" && value && systemAuthorizationStatus == .notDetermined {
            requestNotificationPermission()
            return
        }
        
        // 更新设置
        switch key {
        case "pushEnabled":
            notificationSettings.pushEnabled = value
        case "soundEnabled":
            notificationSettings.soundEnabled = value
        case "messageEnabled":
            notificationSettings.messageEnabled = value
        case "commentEnabled":
            notificationSettings.commentEnabled = value
        case "likeEnabled":
            notificationSettings.likeEnabled = value
        case "systemEnabled":
            notificationSettings.systemEnabled = value
        case "updateEnabled":
            notificationSettings.updateEnabled = value
        case "maintenanceEnabled":
            notificationSettings.maintenanceEnabled = value
        case "weekendMode":
            notificationSettings.weekendMode = value
        default:
            break
        }
        
        // 保存设置
        SettingsManager.shared.updateNotificationSettings(notificationSettings)
    }
    
    private func showQuietHoursSettings() {
        let alert = UIAlertController(
            title: "免打扰时间",
            message: "设置免打扰时间段，在此期间将不会收到通知",
            preferredStyle: .actionSheet
        )
        
        let timeOptions = [
            ("22:00 - 08:00", "晚上10点到早上8点"),
            ("23:00 - 07:00", "晚上11点到早上7点"),
            ("00:00 - 09:00", "午夜到早上9点"),
            ("自定义时间", "设置自定义免打扰时间")
        ]
        
        for (time, description) in timeOptions {
            alert.addAction(UIAlertAction(title: "\(time)\n\(description)", style: .default) { _ in
                print("NotificationSettingsViewController: 设置免打扰时间: \(time)")
                // 这里可以实现具体的时间设置逻辑
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad适配
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NotificationSettingsViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return settingSections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingSections[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingSections[section].title
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "推送通知需要系统权限，请确保在系统设置中已开启通知权限。"
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = settingSections[indexPath.section].items[indexPath.row]
        
        switch item.type {
        case .switch:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(title: item.title, isOn: getSettingValue(for: item.key)) { [weak self] isOn in
                self?.updateNotificationSetting(key: item.key, value: isOn)
            }
            cell.detailTextLabel?.text = item.description
            return cell
            
        case .disclosure:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisclosureCell", for: indexPath)
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.description
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    private func getSettingValue(for key: String) -> Bool {
        switch key {
        case "pushEnabled": return notificationSettings.pushEnabled
        case "soundEnabled": return notificationSettings.soundEnabled
        case "messageEnabled": return notificationSettings.messageEnabled
        case "commentEnabled": return notificationSettings.commentEnabled
        case "likeEnabled": return notificationSettings.likeEnabled
        case "systemEnabled": return notificationSettings.systemEnabled
        case "updateEnabled": return notificationSettings.updateEnabled
        case "maintenanceEnabled": return notificationSettings.maintenanceEnabled
        case "weekendMode": return notificationSettings.weekendMode
        default: return false
        }
    }
}

// MARK: - UITableViewDelegate
extension NotificationSettingsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settingSections[indexPath.section].items[indexPath.row]
        
        if item.key == "quietHours" {
            showQuietHoursSettings()
        }
    }
}

// MARK: - SettingItem
private struct SettingItem {
    let key: String
    let title: String
    let type: SettingType
    let description: String
    
    enum SettingType {
        case `switch`
        case disclosure
    }
}
