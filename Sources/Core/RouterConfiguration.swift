//
//  RouterConfiguration.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/10.
//

import Foundation

// MARK: - Router Configuration Extension
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    
    // MARK: - Configuration Properties
    
    /// 获取最大重试次数
    public func getMaxRetryCount() async -> Int {
        return await state.getMaxRetryCount()
    }
    
    /// 设置最大重试次数
    public func setMaxRetryCount(_ value: Int) async {
        await state.setMaxRetryCount(value)
    }
    
    /// 获取重试延迟时间
    public func getRetryDelay() async -> TimeInterval {
        return await state.getRetryDelay()
    }
    
    /// 设置重试延迟时间
    public func setRetryDelay(_ value: TimeInterval) async {
        await state.setRetryDelay(value)
    }
    
    /// 获取模块过期时间
    public func getModuleExpirationTime() async -> TimeInterval {
        return await state.getModuleExpirationTime()
    }
    
    /// 设置模块过期时间
    public func setModuleExpirationTime(_ value: TimeInterval) async {
        await state.setModuleExpirationTime(value)
    }
    
    /// 获取是否启用日志
    public func getEnableLogging() async -> Bool {
        return await state.getEnableLogging()
    }
    
    /// 设置是否启用日志
    public func setEnableLogging(_ value: Bool) async {
        await state.setEnableLogging(value)
    }
    
    /// 获取清理间隔时间
    public func getCleanupInterval() async -> TimeInterval {
        return await state.getCleanupInterval()
    }
    
    /// 设置清理间隔时间
    public func setCleanupInterval(_ value: TimeInterval) async {
        await state.setCleanupInterval(value)
        startModuleCleanupTimer()
    }
    
    /// 获取缓存大小
    public func getCacheSize() async -> Int {
        return await state.getCacheSize()
    }
    
    /// 设置缓存大小
    public func setCacheSize(_ value: Int) async {
        await state.setCacheSize(value)
        await state.setRouteCacheMaxSize(value)
    }
    
    /// 获取参数清理是否启用
    public func getEnableParameterSanitization() async -> Bool {
        return await state.getEnableParameterSanitization()
    }
    
    /// 设置参数清理是否启用
    public func setEnableParameterSanitization(_ value: Bool) async {
        await state.setEnableParameterSanitization(value)
    }
    
    /// 设置权限验证器
    public func setPermissionValidator(_ validator: RoutePermissionValidator) async {
        await state.setPermissionValidator(validator)
    }
    
    /// 获取权限验证器
    public func getPermissionValidator() async -> RoutePermissionValidator {
        return await state.getPermissionValidator()
    }
}