//
//  LoginModule.swift
//  LoginModule
//
//  Created by fengming on 2025/8/8.
//

import UIKit
import RouterKit_Swift

/// 认证模块，处理登录、注册等功能
public class LoginModule: ModuleProtocol, @unchecked Sendable {
    public var moduleName: String = "LoginModule"
    public var dependencies: [ModuleDependency] = []
    public var lastUsedTime: Date = Date()
    public var isLoaded: Bool = false
    public var router: Router?

    public required init() {}

    public func load(completion: @escaping (Bool) -> Void) {
        // 注册登录路由
        print("LoginModule: 开始加载模块")
        Task {
            do {
                try await Router.shared.registerRoute("/LoginModule/login", for: LoginViewController.self)
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

    /// 处理登录逻辑
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - completion: 完成回调
    func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        // 模拟网络请求
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // 简单验证，实际项目中应该调用API
            if username == "admin" && password == "password" {
                // 保存登录状态
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(username, forKey: "username")
                completion(true, nil)
            } else {
                completion(false, NSError(domain: "AuthModule", code: 401, userInfo: [NSLocalizedDescriptionKey: "用户名或密码错误"]))
            }
        }
    }

    /// 检查用户是否已登录
    /// - Returns: 是否已登录
    public func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    /// 登出
    public func logout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "username")
    }
}


