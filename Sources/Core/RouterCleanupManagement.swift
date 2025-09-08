//
//  RouterCleanupManagement.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/10.
//

import Foundation

// MARK: - Router Cleanup Management Extension
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    
    // MARK: - Cleanup Management
    
    /// 启动模块清理定时器
    public func startModuleCleanupTimer() {
        cleanupTimer?.invalidate()
        
        Task {
            let interval = await getCleanupInterval()
            await MainActor.run {
                cleanupTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                    guard let self = self, !self.isCleanupPaused else { return }
                    
                    Task {
                        await self.cleanupUnusedModules()
                    }
                }
            }
        }
    }
    
    /// 暂停清理
    public func pauseCleanup() {
        isCleanupPaused = true
        lastCleanupTime = Date()
    }
    
    /// 恢复清理
    public func resumeCleanup() {
        guard isCleanupPaused else { return }
        
        isCleanupPaused = false
        
        Task {
            let interval = await getCleanupInterval()
            let timeSinceLastCleanup = Date().timeIntervalSince(self.lastCleanupTime)
            
            if timeSinceLastCleanup >= interval {
                // 如果暂停时间超过清理间隔，立即执行清理
                await cleanupUnusedModules()
            } else {
                // 否则重新启动定时器
                startModuleCleanupTimer()
            }
        }
    }
    
    /// 强制清理
    public func forceCleanup() async {
        await cleanupUnusedModules()
    }
    
    /// 清理未使用的模块
    public func cleanupUnusedModules() async {
        let expirationTime = await getModuleExpirationTime()
        let currentTime = Date()
        
        let modules = await state.getModules()
        
        for (name, weakWrapper) in modules {
            guard let module = weakWrapper.value as? any ModuleProtocol else {
                // 弱引用已失效的模块直接清理
                await unregisterModule(name)
                log("Cleaned up expired module: \(name)", level: .debug)
                continue
            }
            
            if currentTime.timeIntervalSince(module.lastUsedTime) > expirationTime {
                await unregisterModule(name)
                log("Cleaned up unused module: \(name)", level: .debug)
            }
        }
    }
}