//
//  RouterStateConfigurationManager.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation

/// 路由状态配置管理器
/// 负责管理所有路由相关的配置参数
@available(iOS 13.0, macOS 10.15, *)
actor RouterStateConfigurationManager {
    
    // MARK: - 配置参数
    
    /// 最大重试次数
    var maxRetryCount: Int = 3
    
    /// 重试延迟时间（秒）
    var retryDelay: TimeInterval = 0.5
    
    /// 模块过期时间（秒）
    var moduleExpirationTime: TimeInterval = 300 // 5分钟
    
    /// 是否启用日志记录
    var enableLogging: Bool = true
    
    /// 清理间隔时间（秒）
    var cleanupInterval: TimeInterval = 60 // 1分钟
    
    /// 路由缓存大小
    var cacheSize: Int = 100
    
    /// 是否启用参数清理
    var enableParameterSanitization: Bool = true
    
    /// 权限验证器
    var permissionValidator: RoutePermissionValidator = DefaultPermissionValidator()
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// 当前导航任务
    var currentNavigationTask: Task<Void, Error>?
    #endif
    
    // MARK: - 配置参数访问器
    
    /// 获取最大重试次数
    func getMaxRetryCount() -> Int {
        return maxRetryCount
    }
    
    /// 设置最大重试次数
    /// - Parameter value: 重试次数
    func setMaxRetryCount(_ value: Int) {
        maxRetryCount = max(0, value) // 确保不为负数
    }
    
    /// 获取重试延迟时间（秒）
    func getRetryDelay() -> TimeInterval {
        return retryDelay
    }
    
    /// 设置重试延迟时间（秒）
    /// - Parameter value: 延迟时间
    func setRetryDelay(_ value: TimeInterval) {
        retryDelay = max(0, value) // 确保不为负数
    }
    
    /// 获取模块过期时间（秒）
    func getModuleExpirationTime() -> TimeInterval {
        return moduleExpirationTime
    }
    
    /// 设置模块过期时间（秒）
    /// - Parameter value: 过期时间
    func setModuleExpirationTime(_ value: TimeInterval) {
        moduleExpirationTime = max(0, value) // 确保不为负数
    }
    
    /// 获取日志启用状态
    func getEnableLogging() -> Bool {
        return enableLogging
    }
    
    /// 设置日志启用状态
    /// - Parameter value: 是否启用日志
    func setEnableLogging(_ value: Bool) {
        enableLogging = value
    }
    
    /// 获取清理间隔时间（秒）
    func getCleanupInterval() -> TimeInterval {
        return cleanupInterval
    }
    
    /// 设置清理间隔时间（秒）
    /// - Parameter value: 清理间隔
    func setCleanupInterval(_ value: TimeInterval) {
        cleanupInterval = max(0, value) // 确保不为负数
    }
    
    /// 获取路由缓存大小
    func getCacheSize() -> Int {
        return cacheSize
    }
    
    /// 设置路由缓存大小
    /// - Parameter value: 缓存大小
    func setCacheSize(_ value: Int) {
        cacheSize = max(0, value) // 确保不为负数
    }
    
    /// 获取参数清理启用状态
    func getEnableParameterSanitization() -> Bool {
        return enableParameterSanitization
    }
    
    /// 设置参数清理启用状态
    /// - Parameter value: 是否启用参数清理
    func setEnableParameterSanitization(_ value: Bool) {
        enableParameterSanitization = value
    }
    
    /// 设置权限验证器
    /// - Parameter validator: 权限验证器实例
    func setPermissionValidator(_ validator: RoutePermissionValidator) {
        permissionValidator = validator
    }
    
    /// 获取当前权限验证器
    /// - Returns: 权限验证器实例
    func getPermissionValidator() -> RoutePermissionValidator {
        return permissionValidator
    }
    
    // MARK: - 导航任务管理
    
    #if swift(>=5.5) && canImport(_Concurrency)
    /// 获取当前导航任务
    /// - Returns: 当前导航任务
    @available(iOS 13.0, macOS 10.15, *)
    func getCurrentNavigationTask() -> Task<Void, Error>? {
        return currentNavigationTask
    }
    
    /// 设置当前导航任务
    /// - Parameter task: 导航任务
    @available(iOS 13.0, macOS 10.15, *)
    func setCurrentNavigationTask(_ task: Task<Void, Error>?) {
        currentNavigationTask = task
    }
    
    /// 取消当前导航任务
    @available(iOS 13.0, macOS 10.15, *)
    func cancelCurrentNavigationTask() {
        currentNavigationTask?.cancel()
        currentNavigationTask = nil
    }
    #endif
    
    // MARK: - 配置验证
    
    /// 验证配置参数的有效性
    /// - Returns: 验证结果和错误信息
    func validateConfiguration() -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        // 验证最大重试次数
        if maxRetryCount < 0 {
            errors.append("最大重试次数不能为负数")
        }
        
        // 验证重试延迟
        if retryDelay < 0 {
            errors.append("重试延迟不能为负数")
        }
        
        // 验证模块过期时间
        if moduleExpirationTime <= 0 {
            errors.append("模块过期时间必须大于0")
        }
        
        // 验证清理间隔
        if cleanupInterval <= 0 {
            errors.append("清理间隔必须大于0")
        }
        
        // 验证缓存大小
        if cacheSize <= 0 {
            errors.append("缓存大小必须大于0")
        }
        
        return (errors.isEmpty, errors)
    }
    
    // MARK: - 配置导入导出
    
    /// 导出当前配置
    /// - Returns: 配置字典
    func exportConfiguration() -> [String: Any] {
        return [
            "maxRetryCount": maxRetryCount,
            "retryDelay": retryDelay,
            "moduleExpirationTime": moduleExpirationTime,
            "enableLogging": enableLogging,
            "cleanupInterval": cleanupInterval,
            "cacheSize": cacheSize,
            "enableParameterSanitization": enableParameterSanitization
        ]
    }
    
    /// 导入配置
    /// - Parameter config: 配置字典
    /// - Returns: 导入是否成功
    func importConfiguration(_ config: [String: Any]) -> Bool {
        var success = true
        
        if let value = config["maxRetryCount"] as? Int {
            setMaxRetryCount(value)
        }
        
        if let value = config["retryDelay"] as? TimeInterval {
            setRetryDelay(value)
        }
        
        if let value = config["moduleExpirationTime"] as? TimeInterval {
            setModuleExpirationTime(value)
        }
        
        if let value = config["enableLogging"] as? Bool {
            setEnableLogging(value)
        }
        
        if let value = config["cleanupInterval"] as? TimeInterval {
            setCleanupInterval(value)
        }
        
        if let value = config["cacheSize"] as? Int {
            setCacheSize(value)
        }
        
        if let value = config["enableParameterSanitization"] as? Bool {
            setEnableParameterSanitization(value)
        }
        
        let validation = validateConfiguration()
        return validation.isValid
    }
    
    // MARK: - 状态重置
    
    /// 重置所有配置为默认值
    func reset() {
        maxRetryCount = 3
        retryDelay = 0.5
        moduleExpirationTime = 300
        enableLogging = true
        cleanupInterval = 60
        cacheSize = 100
        enableParameterSanitization = true
        permissionValidator = DefaultPermissionValidator()
        
        #if swift(>=5.5) && canImport(_Concurrency)
        currentNavigationTask?.cancel()
        currentNavigationTask = nil
        #endif
    }
}