//
//  ProfileModule.swift
//  ProfileModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 用户资料模块，处理用户信息编辑、头像上传等功能
public class ProfileModuleManager: ModuleProtocol, @unchecked Sendable {
    public var moduleName: String = "ProfileModule"
    public var dependencies: [ModuleDependency] = []
    public var lastUsedTime: Date = Date()
    public var isLoaded: Bool = false
    public var router: Router?

    public required init() {}

    public func load(completion: @escaping (Bool) -> Void) {
        print("ProfileModule: 开始加载模块")

        // 注册用户资料相关路由
        Task {
            try await Router.shared.registerRoute("profile", for: ProfileViewController.self)
            try await Router.shared.registerRoute("profile/edit", for: ProfileEditViewController.self)
            try await Router.shared.registerRoute("profile/avatar", for: AvatarUploadViewController.self)
        }

        self.isLoaded = true
        print("ProfileModule: 模块加载成功")
        completion(true)
    }

    public func unload() {
        isLoaded = false
        print("ProfileModule: 模块已卸载")
    }

    public func suspend() {
        lastUsedTime = Date()
        print("ProfileModule: 模块已暂停")
    }

    public func resume() {
        lastUsedTime = Date()
        print("ProfileModule: 模块已恢复")
    }

    // MARK: - 用户数据模型
    public struct UserProfile {
        public var id: String
        public var username: String
        public var email: String
        public var avatar: String?
        public var bio: String?
        public var createdAt: Date

        public init(id: String, username: String, email: String, avatar: String? = nil, bio: String? = nil, createdAt: Date = Date()) {
            self.id = id
            self.username = username
            self.email = email
            self.avatar = avatar
            self.bio = bio
            self.createdAt = createdAt
        }
    }

    // MARK: - 用户数据管理
    public class UserProfileManager {
        public static let shared = UserProfileManager()

        private var currentProfile: UserProfile?

        private init() {
            // 模拟用户数据
            currentProfile = UserProfile(
                id: "user_001",
                username: "RouterKit用户",
                email: "user@routerkit.com",
                avatar: nil,
                bio: "这是一个使用RouterKit的示例用户"
            )
        }

        public func getCurrentProfile() -> UserProfile? {
            return currentProfile
        }

        public func updateProfile(_ profile: UserProfile, completion: @escaping (Bool, Error?) -> Void) {
            // 模拟网络请求延迟
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.currentProfile = profile
                completion(true, nil)
            }
        }

        public func uploadAvatar(_ image: UIImage, completion: @escaping (Bool, String?, Error?) -> Void) {
            // 模拟头像上传
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let avatarURL = "https://example.com/avatar/\(UUID().uuidString).jpg"
                self.currentProfile?.avatar = avatarURL
                completion(true, avatarURL, nil)
            }
        }
    }
}
