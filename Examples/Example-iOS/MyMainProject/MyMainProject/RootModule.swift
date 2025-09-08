//
//  RootModule.swift
//  MyMainProject
//
//  Created by fengming on 2025/9/8.
//

import Foundation
import RouterKit

/// 根模块，用于处理根路径路由
public class RootModule: ModuleProtocol, @unchecked Sendable {
    public var moduleName: String = "Root"
    public var dependencies: [ModuleDependency] = []
    public var lastUsedTime: Date = Date()
    public var isLoaded: Bool = false
    public var router: Router?

    public required init() {}

    public func load(completion: @escaping (Bool) -> Void) {
        // 注册根路径路由
        print("RootModule: 开始加载模块")
        Task {
            do {
                // 注册首页路由，使用正确的模块名
                try await Router.shared.registerRoute("/Root/home", for: HomeViewController.self)
                self.isLoaded = true
                print("RootModule: 路由注册成功")
                completion(true)
            } catch {
                print("RootModule: 路由注册失败 - \(error)")
                completion(false)
            }
        }
    }

    public func unload() {
        isLoaded = false
        // 清理资源
    }

    public func suspend() {
        // 暂停模块业务逻辑
        lastUsedTime = Date()
    }

    public func resume() {
        // 恢复模块业务逻辑
        lastUsedTime = Date()
    }
}
