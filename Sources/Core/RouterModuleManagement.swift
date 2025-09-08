//
//  RouterModuleManagement.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/10.
//

import Foundation

// MARK: - Router Module Management Extension
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    
    // MARK: - Module Management
    
    /// 注册模块
    public func registerModule<T: ModuleProtocol>(_ module: T) async {
        let moduleName = module.moduleName
        
        // 检查依赖
        let dependenciesResolved = await resolveDependencies(for: module)
        
        if dependenciesResolved {
            await state.registerModule(module)
            
            // 通知生命周期观察者
            notifyModuleStateChanged(module, ModuleState.didLoad)
            
            // 重试依赖此模块的其他模块
            retryDependentModules(for: moduleName)
        } else {
            // 如果依赖未解决，将模块添加到待处理列表
            if dependentModules[moduleName] == nil {
                dependentModules[moduleName] = []
            }
            
            // 添加到依赖模块列表
            for dependency in module.dependencies {
                if dependentModules[dependency.moduleName] == nil {
                    dependentModules[dependency.moduleName] = []
                }
                dependentModules[dependency.moduleName]?.append(Weak(value: module))
            }
        }
    }
    
    /// 注销模块
    public func unregisterModule(_ moduleName: String) async {
        if let module = await state.getModule(moduleName) {
            notifyModuleStateChanged(module, ModuleState.didUnload)
        }
        
        _ = await state.unregisterModule(moduleName)
        
        // 清理依赖关系
        dependentModules.removeValue(forKey: moduleName)
        
        // 从其他模块的依赖列表中移除
        for (key, var weakModules) in dependentModules {
            weakModules.removeAll { $0.value == nil }
            if weakModules.isEmpty {
                dependentModules.removeValue(forKey: key)
            } else {
                dependentModules[key] = weakModules
            }
        }
    }
    
    /// 检查模块是否已加载
    public func isModuleLoaded(_ moduleName: String) async -> Bool {
        return await state.isModuleLoaded(moduleName)
    }
    
    /// 获取模块（通用版本）
    public func getModule(_ name: String) async -> (any ModuleProtocol)? {
        return await state.getModule(name)
    }
    
    /// 获取模块（类型安全版本）
    public func getModule<T: ModuleProtocol>(_ type: T.Type) async -> T? {
        return await state.getModule(type)
    }
    
    /// 重试依赖模块
    private func retryDependentModules(for moduleName: String) {
        guard let dependents = dependentModules[moduleName] else { return }
        
        for weakModule in dependents {
            if let module = weakModule.value as? ModuleProtocol {
                Task {
                    let dependenciesResolved = await resolveDependencies(for: module)
                    if dependenciesResolved {
                        await state.registerModule(module)
                        notifyModuleStateChanged(module, ModuleState.didLoad)
                        retryDependentModules(for: module.moduleName)
                    }
                }
            }
        }
    }
    
    /// 解析依赖关系
    private func resolveDependencies(for module: ModuleProtocol) async -> Bool {
        for dependency in module.dependencies {
            let isLoaded = await state.isModuleLoaded(dependency.moduleName)
            if !isLoaded {
                // 尝试创建依赖模块
                if let dependencyModule = createModule(named: dependency.moduleName) {
                    await registerModule(dependencyModule)
                } else {
                    return false
                }
            }
        }
        return true
    }
    
    /// 创建模块
    public func createModule(named moduleName: String) -> (any ModuleProtocol)? {
        // 这里应该根据模块名称创建相应的模块实例
        // 具体实现取决于你的模块注册机制
        return nil
    }
    

}