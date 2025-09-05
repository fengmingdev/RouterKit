//
//  AppTheme.swift
//  SettingsModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import Foundation

// MARK: - 设置数据模型
public enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var displayName: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色模式"
        case .dark: return "深色模式"
        }
    }
}