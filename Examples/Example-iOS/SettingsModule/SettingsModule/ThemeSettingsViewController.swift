//
//  ThemeSettingsViewController.swift
//  SettingsModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

public class ThemeSettingsViewController: UIViewController, Routable {
    
    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return ThemeSettingsViewController()
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "setTheme":
            if let themeRawValue = parameters?["theme"] as? String,
               let theme = AppTheme(rawValue: themeRawValue) {
                SettingsManager.shared.updateTheme(theme)
                completion(.success("主题设置成功"))
            } else {
                completion(.failure(RouterError.parameterError("Invalid theme parameter")))
            }
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var currentTheme: AppTheme!
    private let themes = AppTheme.allCases
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentTheme()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "主题设置"
        
        // 配置表格视图
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ThemeCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 添加预览区域
        setupPreviewSection()
    }
    
    private func setupPreviewSection() {
        // 创建预览头部视图
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        headerView.backgroundColor = .clear
        
        // 预览容器
        let previewContainer = UIView()
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.backgroundColor = .systemBackground
        previewContainer.layer.cornerRadius = 12
        previewContainer.layer.shadowColor = UIColor.black.cgColor
        previewContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        previewContainer.layer.shadowRadius = 8
        previewContainer.layer.shadowOpacity = 0.1
        headerView.addSubview(previewContainer)
        
        // 预览标题
        let previewTitle = UILabel()
        previewTitle.translatesAutoresizingMaskIntoConstraints = false
        previewTitle.text = "预览效果"
        previewTitle.font = UIFont.boldSystemFont(ofSize: 18)
        previewTitle.textColor = .label
        previewContainer.addSubview(previewTitle)
        
        // 预览内容
        let previewContent = UILabel()
        previewContent.translatesAutoresizingMaskIntoConstraints = false
        previewContent.text = "这是在当前主题下的文本显示效果"
        previewContent.font = UIFont.systemFont(ofSize: 14)
        previewContent.textColor = .secondaryLabel
        previewContent.numberOfLines = 0
        previewContainer.addSubview(previewContent)
        
        // 预览按钮
        let previewButton = UIButton(type: .system)
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.setTitle("示例按钮", for: .normal)
        previewButton.backgroundColor = .systemBlue
        previewButton.setTitleColor(.white, for: .normal)
        previewButton.layer.cornerRadius = 8
        previewButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        previewContainer.addSubview(previewButton)
        
        NSLayoutConstraint.activate([
            // 预览容器约束
            previewContainer.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            previewContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            previewContainer.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            previewContainer.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            // 预览标题约束
            previewTitle.topAnchor.constraint(equalTo: previewContainer.topAnchor, constant: 16),
            previewTitle.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 16),
            previewTitle.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -16),
            
            // 预览内容约束
            previewContent.topAnchor.constraint(equalTo: previewTitle.bottomAnchor, constant: 12),
            previewContent.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 16),
            previewContent.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -16),
            
            // 预览按钮约束
            previewButton.topAnchor.constraint(equalTo: previewContent.bottomAnchor, constant: 16),
            previewButton.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 16),
            previewButton.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -16),
            previewButton.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -16),
            previewButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func loadCurrentTheme() {
        currentTheme = SettingsManager.shared.getCurrentSettings().theme
        tableView.reloadData()
    }
    
    private func selectTheme(_ theme: AppTheme) {
        guard theme != currentTheme else { return }
        
        print("ThemeSettingsViewController: 切换主题到 \(theme.displayName)")
        
        // 更新主题
        SettingsManager.shared.updateTheme(theme)
        currentTheme = theme
        
        // 重新加载表格以更新选中状态
        tableView.reloadData()
        
        // 显示切换成功提示
        showThemeChangeSuccess(theme)
    }
    
    private func showThemeChangeSuccess(_ theme: AppTheme) {
        let alert = UIAlertController(
            title: "主题已切换",
            message: "已切换到\(theme.displayName)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func getThemeIcon(_ theme: AppTheme) -> String {
        switch theme {
        case .system:
            return "gear"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
    
    private func getThemeDescription(_ theme: AppTheme) -> String {
        switch theme {
        case .system:
            return "跟随系统设置自动切换"
        case .light:
            return "始终使用浅色主题"
        case .dark:
            return "始终使用深色主题"
        }
    }
}

// MARK: - UITableViewDataSource
extension ThemeSettingsViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "选择主题"
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "主题设置会立即生效，并在应用重启后保持。"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath)
        let theme = themes[indexPath.row]
        
        // 配置单元格
        cell.textLabel?.text = theme.displayName
        cell.detailTextLabel?.text = getThemeDescription(theme)
        cell.imageView?.image = UIImage(systemName: getThemeIcon(theme))
        cell.imageView?.tintColor = .systemBlue
        
        // 设置选中状态
        if theme == currentTheme {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ThemeSettingsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTheme = themes[indexPath.row]
        selectTheme(selectedTheme)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
