//
//  NotificationSettings.swift
//  SettingsModule
//
//  Created by fengming on 2025/9/5.
//

import Foundation
public struct NotificationSettings {
    public var pushEnabled: Bool
    public var soundEnabled: Bool
    public var badgeEnabled: Bool
    public var messageNotification: Bool
    public var systemNotification: Bool
    public var messageEnabled: Bool
    public var commentEnabled: Bool
    public var likeEnabled: Bool
    public var systemEnabled: Bool
    public var updateEnabled: Bool
    public var maintenanceEnabled: Bool
    public var weekendMode: Bool

    public init(pushEnabled: Bool = true, soundEnabled: Bool = true, badgeEnabled: Bool = true, messageNotification: Bool = true, systemNotification: Bool = true, messageEnabled: Bool = true, commentEnabled: Bool = true, likeEnabled: Bool = true, systemEnabled: Bool = true, updateEnabled: Bool = true, maintenanceEnabled: Bool = true, weekendMode: Bool = false) {
        self.pushEnabled = pushEnabled
        self.soundEnabled = soundEnabled
        self.badgeEnabled = badgeEnabled
        self.messageNotification = messageNotification
        self.systemNotification = systemNotification
        self.messageEnabled = messageEnabled
        self.commentEnabled = commentEnabled
        self.likeEnabled = likeEnabled
        self.systemEnabled = systemEnabled
        self.updateEnabled = updateEnabled
        self.maintenanceEnabled = maintenanceEnabled
        self.weekendMode = weekendMode
    }
}
