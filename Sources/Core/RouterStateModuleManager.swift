//
//  RouterStateModuleManager.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation

@available(iOS 13.0, macOS 10.15, *)
actor RouterStateModuleManager {
    /// 存储已注册的模块
    private var modules: [String: Weak<AnyObject>] = [:]
    
    /// 关键模块列表
    private var criticalModules: Set<String> = []
    
    /// 模块过期时间（秒）
    private var moduleExpirationTime: TimeInterval = 300 // 默认5分钟
    
    // MARK: - 模块管理方法

    /// 注册模块
    /// - Parameter module: 要注册的模块实例
    func registerModule(_ module: ModuleProtocol) async {
        let moduleName = module.moduleName
        modules[moduleName] = Weak(value: module)
        print("RouterStateModuleManager: 模块注册成功 - \(moduleName)")
    }

    /// 卸载模块
    /// - Parameter moduleName: 模块名称
    /// - Returns: 被卸载的模块实例
    func unregisterModule(_ moduleName: String) async -> ModuleProtocol? {
        guard let weakModule = modules[moduleName],
              let module = weakModule.value as? ModuleProtocol else {
            print("RouterStateModuleManager: 未找到要卸载的模块 - \(moduleName)")
            return nil
        }
        
        modules.removeValue(forKey: moduleName)
        print("RouterStateModuleManager: 模块卸载成功 - \(moduleName)")
        return module
    }

    /// 检查模块是否已加载
    /// - Parameter moduleName: 模块名称
    /// - Returns: 模块是否已加载
    func isModuleLoaded(_ moduleName: String) async -> Bool {
        // 检查模块是否存在且未被释放
        guard let weakModule = modules[moduleName] else {
            print("RouterStateModuleManager: 模块未注册 - \(moduleName)")
            return false
        }
        
        let isLoaded = weakModule.value != nil
        print("RouterStateModuleManager: 模块 \(moduleName) 加载状态: \(isLoaded)")
        return isLoaded
    }

    /// 获取模块实例
    /// - Parameter name: 模块名称
    /// - Returns: 模块实例
    func getModule(_ name: String) async -> ModuleProtocol? {
        guard let weakModule = modules[name],
              let module = weakModule.value as? ModuleProtocol else {
            print("RouterStateModuleManager: 未找到模块 - \(name)")
            return nil
        }
        
        print("RouterStateModuleManager: 成功获取模块 - \(name)")
        return module
    }

    /// 获取指定类型的模块实例
    /// - Parameter type: 模块类型
    /// - Returns: 模块实例
    func getModule<T: ModuleProtocol>(_ type: T.Type) async -> T? {
        for (_, weakModule) in modules {
            if let module = weakModule.value as? T {
                print("RouterStateModuleManager: 成功获取模块类型 - \(type)")
                return module
            }
        }
        
        print("RouterStateModuleManager: 未找到模块类型 - \(type)")
        return nil
    }

    /// 获取所有模块
    func getModules() async -> [String: Weak<AnyObject>] {
        print("RouterStateModuleManager: 获取所有模块数量: \(modules.count)")
        return modules
    }

    /// 获取关键模块列表
    func getCriticalModules() async -> Set<String> {
        print("RouterStateModuleManager: 获取关键模块列表数量: \(criticalModules.count)")
        return criticalModules
    }

    // MARK: - 配置方法

    /// 设置模块过期时间
    /// - Parameter time: 过期时间（秒）
    func setModuleExpirationTime(_ time: TimeInterval) {
        moduleExpirationTime = time
        print("RouterStateModuleManager: 设置模块过期时间 - \(time)秒")
    }

    // MARK: - 模块清理辅助

    /// 获取所有过期模块的名称
    /// - Parameter currentTime: 当前时间
    /// - Returns: 过期模块名称列表
    func getExpiredModules(currentTime: Date) async -> [String] {
        let expiredModules = modules.compactMap { name, weakModule in
            guard let module = weakModule.value as? ModuleProtocol else {
                return name // 已释放的模块视为过期
            }
            
            let timeSinceLastUse = currentTime.timeIntervalSince(module.lastUsedTime)
            return timeSinceLastUse > moduleExpirationTime ? name : nil
        }
        
        print("RouterStateModuleManager: 获取过期模块数量: \(expiredModules.count)")
        return expiredModules
    }

    // MARK: - 状态重置

    /// 重置模块管理器状态
    func reset() async {
        modules.removeAll()
        criticalModules.removeAll()
        print("RouterStateModuleManager: 模块管理器状态已重置")
    }
}