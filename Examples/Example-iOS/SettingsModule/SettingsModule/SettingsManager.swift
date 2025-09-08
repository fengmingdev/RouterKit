//
//  SettingsManager.swift
//  SettingsModule
//
//  Created by fengming on 2025/9/5.
//

import Foundation
import UIKit

public struct AppSettings {
    public var theme: AppTheme
    public var notifications: NotificationSettings
    public var autoLogin: Bool
    public var cacheEnabled: Bool
    public var debugMode: Bool

    public init(theme: AppTheme = .system, notifications: NotificationSettings = NotificationSettings(), autoLogin: Bool = false, cacheEnabled: Bool = true, debugMode: Bool = false) {
        self.theme = theme
        self.notifications = notifications
        self.autoLogin = autoLogin
        self.cacheEnabled = cacheEnabled
        self.debugMode = debugMode
    }
}

// MARK: - 设置管理器
public class SettingsManager {
    public static let shared = SettingsManager()

    private let userDefaults = UserDefaults.standard
    private var currentSettings: AppSettings

    // 通知名称
    public static let themeDidChangeNotification = Notification.Name("ThemeDidChange")
    public static let notificationSettingsDidChangeNotification = Notification.Name("NotificationSettingsDidChange")

    private init() {
        // 从UserDefaults加载设置
        let theme = AppTheme(rawValue: userDefaults.string(forKey: "app_theme") ?? "system") ?? .system

        let notifications = NotificationSettings(
            pushEnabled: userDefaults.object(forKey: "notification_push_enabled") as? Bool ?? true,
            soundEnabled: userDefaults.object(forKey: "notification_sound_enabled") as? Bool ?? true,
            badgeEnabled: userDefaults.object(forKey: "notification_badge_enabled") as? Bool ?? true,
            messageNotification: userDefaults.object(forKey: "notification_message_enabled") as? Bool ?? true,
            systemNotification: userDefaults.object(forKey: "notification_system_enabled") as? Bool ?? true,
            messageEnabled: userDefaults.object(forKey: "notification_message_enabled") as? Bool ?? true,
            commentEnabled: userDefaults.object(forKey: "notification_comment_enabled") as? Bool ?? true,
            likeEnabled: userDefaults.object(forKey: "notification_like_enabled") as? Bool ?? true,
            systemEnabled: userDefaults.object(forKey: "notification_system_enabled") as? Bool ?? true,
            updateEnabled: userDefaults.object(forKey: "notification_update_enabled") as? Bool ?? true,
            maintenanceEnabled: userDefaults.object(forKey: "notification_maintenance_enabled") as? Bool ?? true,
            weekendMode: userDefaults.object(forKey: "notification_weekend_mode") as? Bool ?? false
        )

        self.currentSettings = AppSettings(
            theme: theme,
            notifications: notifications,
            autoLogin: userDefaults.object(forKey: "auto_login") as? Bool ?? false,
            cacheEnabled: userDefaults.object(forKey: "cache_enabled") as? Bool ?? true,
            debugMode: userDefaults.object(forKey: "debug_mode") as? Bool ?? false
        )

        // 应用当前主题
        applyTheme(theme)
    }

    public func getCurrentSettings() -> AppSettings {
        return currentSettings
    }

    public func getNotificationSettings() -> NotificationSettings {
        return currentSettings.notifications
    }

    public func updateTheme(_ theme: AppTheme) {
        currentSettings.theme = theme
        userDefaults.set(theme.rawValue, forKey: "app_theme")
        applyTheme(theme)
        NotificationCenter.default.post(name: SettingsManager.themeDidChangeNotification, object: theme)
    }

    public func updateNotificationSettings(_ settings: NotificationSettings) {
        currentSettings.notifications = settings

        // 保存到UserDefaults
        userDefaults.set(settings.pushEnabled, forKey: "notification_push_enabled")
        userDefaults.set(settings.soundEnabled, forKey: "notification_sound_enabled")
        userDefaults.set(settings.badgeEnabled, forKey: "notification_badge_enabled")
        userDefaults.set(settings.messageNotification, forKey: "notification_message_enabled")
        userDefaults.set(settings.systemNotification, forKey: "notification_system_enabled")
        userDefaults.set(settings.messageEnabled, forKey: "notification_message_enabled")
        userDefaults.set(settings.commentEnabled, forKey: "notification_comment_enabled")
        userDefaults.set(settings.likeEnabled, forKey: "notification_like_enabled")
        userDefaults.set(settings.systemEnabled, forKey: "notification_system_enabled")
        userDefaults.set(settings.updateEnabled, forKey: "notification_update_enabled")
        userDefaults.set(settings.maintenanceEnabled, forKey: "notification_maintenance_enabled")
        userDefaults.set(settings.weekendMode, forKey: "notification_weekend_mode")

        NotificationCenter.default.post(name: SettingsManager.notificationSettingsDidChangeNotification, object: settings)
    }

    public func updateAutoLogin(_ enabled: Bool) {
        currentSettings.autoLogin = enabled
        userDefaults.set(enabled, forKey: "auto_login")
    }

    public func updateCacheEnabled(_ enabled: Bool) {
        currentSettings.cacheEnabled = enabled
        userDefaults.set(enabled, forKey: "cache_enabled")
    }

    public func updateDebugMode(_ enabled: Bool) {
        currentSettings.debugMode = enabled
        userDefaults.set(enabled, forKey: "debug_mode")
    }

    private func applyTheme(_ theme: AppTheme) {
        DispatchQueue.main.async {
            guard #available(iOS 13.0, *) else { return }

            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene

            let windows = windowScene?.windows ?? []

            switch theme {
            case .light:
                windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }
            case .dark:
                windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                }
            case .system:
                windows.forEach { window in
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
    }

    public func resetToDefaults() {
        let defaultSettings = AppSettings()

        userDefaults.set(defaultSettings.theme.rawValue, forKey: "app_theme")
        userDefaults.set(defaultSettings.notifications.pushEnabled, forKey: "notification_push_enabled")
        userDefaults.set(defaultSettings.notifications.soundEnabled, forKey: "notification_sound_enabled")
        userDefaults.set(defaultSettings.notifications.badgeEnabled, forKey: "notification_badge_enabled")
        userDefaults.set(defaultSettings.notifications.messageNotification, forKey: "notification_message_enabled")
        userDefaults.set(defaultSettings.notifications.systemNotification, forKey: "notification_system_enabled")
        userDefaults.set(defaultSettings.notifications.messageEnabled, forKey: "notification_message_enabled")
        userDefaults.set(defaultSettings.notifications.commentEnabled, forKey: "notification_comment_enabled")
        userDefaults.set(defaultSettings.notifications.likeEnabled, forKey: "notification_like_enabled")
        userDefaults.set(defaultSettings.notifications.systemEnabled, forKey: "notification_system_enabled")
        userDefaults.set(defaultSettings.notifications.updateEnabled, forKey: "notification_update_enabled")
        userDefaults.set(defaultSettings.notifications.maintenanceEnabled, forKey: "notification_maintenance_enabled")
        userDefaults.set(defaultSettings.notifications.weekendMode, forKey: "notification_weekend_mode")
        userDefaults.set(defaultSettings.autoLogin, forKey: "auto_login")
        userDefaults.set(defaultSettings.cacheEnabled, forKey: "cache_enabled")
        userDefaults.set(defaultSettings.debugMode, forKey: "debug_mode")

        applyTheme(defaultSettings.theme)
    }
}
