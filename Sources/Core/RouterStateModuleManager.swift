//
//  RouterStateModuleManager.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation

/// 路由状态模块管理器
/// 负责管理所有模块的注册、卸载和生命周期
@available(iOS 13.0, macOS 10.15, *)
actor RouterStateModuleManager {
    
    // MARK: - 存储容器
    
    /// 模块存储（使用弱引用包装避免循环引用）
    /// 键: 模块名称，值: 弱引用包装的模块实例
    private var modules: [String: Weak<AnyObject>] = [:]
    
    /// 关键模块列表（不会被自动清理）
    private var criticalModules: Set<String> = []
    
    /// 模块过期时间（秒）
    var moduleExpirationTime: TimeInterval = 300 // 5分钟
    
    // MARK: - 模块管理
    
    /// 注册模块
    /// - Parameter module: 要注册的模块实例（需遵循ModuleProtocol）
    func registerModule(_ module: any ModuleProtocol) async {
        let weakWrapper = Weak(value: module as AnyObject)
        modules[module.moduleName] = weakWrapper
    }
    
    /// 卸载模块
    /// - Parameter moduleName: 模块名称
    /// - Returns: 被卸载的模块实例（如果存在）
    func unregisterModule(_ moduleName: String) -> (any ModuleProtocol)? {
        guard let weakWrapper = modules[moduleName],
              let module = weakWrapper.value as? any ModuleProtocol else {
            return nil
        }
        
        modules.removeValue(forKey: moduleName)
        return module
    }
    
    /// 检查模块是否已加载
    /// - Parameter moduleName: 模块名称
    /// - Returns: 模块是否已加载（弱引用仍然有效）
    func isModuleLoaded(_ moduleName: String) -> Bool {
        guard let weakWrapper = modules[moduleName] else {
            return false
        }
        return weakWrapper.value != nil
    }
    
    /// 获取模块实例
    /// - Parameter name: 模块名称
    /// - Returns: 模块实例（可选，弱引用可能已失效）
    func getModule(_ name: String) -> (any ModuleProtocol)? {
        guard let weakWrapper = modules[name] else {
            return nil
        }
        return weakWrapper.value as? any ModuleProtocol
    }
    
    /// 获取指定类型的模块实例
    /// - Parameter type: 模块类型（需遵循ModuleProtocol）
    /// - Returns: 模块实例（可选）
    func getModule<T: ModuleProtocol>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return modules[key]?.value as? T
    }
    
    /// 获取所有模块
    func getModules() -> [String: Weak<AnyObject>] {
        return modules
    }
    
    /// 获取关键模块列表
    func getCriticalModules() -> Set<String> {
        return criticalModules
    }
    
    /// 添加关键模块
    /// - Parameter moduleName: 模块名称
    func addCriticalModule(_ moduleName: String) {
        criticalModules.insert(moduleName)
    }
    
    /// 移除关键模块
    /// - Parameter moduleName: 模块名称
    func removeCriticalModule(_ moduleName: String) {
        criticalModules.remove(moduleName)
    }
    
    /// 获取所有过期模块的名称
    /// - Parameter currentTime: 当前时间
    /// - Returns: 过期模块名称数组
    func getExpiredModules(currentTime: Date) -> [String] {
        return modules.compactMap { name, weakWrapper in
            // 关键模块不会过期
            if criticalModules.contains(name) {
                return nil
            }
            
            guard let module = weakWrapper.value as? any ModuleProtocol else {
                // 弱引用已失效的模块直接视为过期
                return name
            }
            
            // 检查是否超过过期时间
            if currentTime.timeIntervalSince(module.lastUsedTime) > moduleExpirationTime {
                return name
            }
            return nil
        }
    }
    
    /// 清理过期模块
    /// - Parameter currentTime: 当前时间
    /// - Returns: 被清理的模块名称数组
    func cleanupExpiredModules(currentTime: Date) -> [String] {
        let expiredModules = getExpiredModules(currentTime: currentTime)
        
        for moduleName in expiredModules {
            modules.removeValue(forKey: moduleName)
        }
        
        return expiredModules
    }
    
    /// 重置所有模块数据
    func reset() {
        modules.removeAll()
        criticalModules.removeAll()
    }
    
    // MARK: - 配置参数访问器
    
    /// 获取模块过期时间（秒）
    func getModuleExpirationTime() -> TimeInterval {
        return moduleExpirationTime
    }
    
    /// 设置模块过期时间（秒）
    func setModuleExpirationTime(_ value: TimeInterval) {
        moduleExpirationTime = value
    }
}