//
//  RouterModuleManagement.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation

// MARK: - 模块管理扩展
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    /// 注册模块
    /// - Parameter module: 要注册的模块实例
    public func registerModule(_ module: ModuleProtocol) async {
        print("Router: 开始注册模块 \(module.moduleName)")
        await state.registerModule(module)
        
        // 加载模块
        await MainActor.run {
            module.load { success in
                Task {
                    if success {
                        print("Router: 模块 \(module.moduleName) 加载成功")
                        await self.state.notifyModuleStateChanged(module, .didLoad)
                    } else {
                        print("Router: 模块 \(module.moduleName) 加载失败")
                    }
                }
            }
        }
    }

    /// 卸载模块
    /// - Parameter moduleName: 模块名称
    public func unregisterModule(_ moduleName: String) async {
        print("Router: 开始卸载模块 \(moduleName)")
        let module = await state.unregisterModule(moduleName)
        if let module = module {
            module.unload()
            print("Router: 模块 \(moduleName) 卸载完成")
        }
    }

    /// 检查模块是否已加载
    /// - Parameter moduleName: 模块名称
    /// - Returns: 模块是否已加载
    public func isModuleLoaded(_ moduleName: String) async -> Bool {
        let isLoaded = await state.isModuleLoaded(moduleName)
        print("Router: 检查模块 \(moduleName) 是否已加载: \(isLoaded)")
        return isLoaded
    }

    /// 获取模块实例
    /// - Parameter name: 模块名称
    /// - Returns: 模块实例
    public func getModule(_ name: String) async -> ModuleProtocol? {
        let module = await state.getModule(name)
        print("Router: 获取模块 \(name): \(module != nil)")
        return module
    }

    /// 获取指定类型的模块实例
    /// - Parameter type: 模块类型
    /// - Returns: 模块实例
    public func getModule<T: ModuleProtocol>(_ type: T.Type) async -> T? {
        let module = await state.getModule(type)
        print("Router: 获取模块类型 \(type): \(module != nil)")
        return module
    }
}