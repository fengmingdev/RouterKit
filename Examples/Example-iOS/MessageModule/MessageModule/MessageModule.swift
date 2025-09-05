//
//  MessageModule.swift
//  MessageModule
//
//  Created by fengming on 2025/8/8.
//

import UIKit
import RouterKit

/// 消息模块，处理消息列表、详情等功能
public class MessageModule: ModuleProtocol, @unchecked Sendable {
    public var moduleName: String = "MessageModule"
    public var dependencies: [ModuleDependency] = []
    public var lastUsedTime: Date = Date()
    public var isLoaded: Bool = false
    public var router: Router?

    public required init() {}

    public func load(completion: @escaping (Bool) -> Void) {
        // 注册消息路由
        print("MessageModule: 开始加载模块")
        Task {
            do {
                try await Router.shared.registerRoute("/MessageModule/message", for: MessageViewController.self)
                self.isLoaded = true
                completion(true)
            } catch {
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
