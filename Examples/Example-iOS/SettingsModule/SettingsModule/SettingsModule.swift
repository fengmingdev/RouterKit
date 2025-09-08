//
//  SettingsModule.swift
//  SettingsModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

// MARK: - SettingsModule Class
public final class SettingsModule: ModuleProtocol {

    // MARK: - ModuleProtocol Properties
    public var moduleName: String = "SettingsModule"

    public var dependencies: [ModuleDependency] = []

    public var lastUsedTime: Date = Date()

    // MARK: - Initializer
    public required init() {}

    // MARK: - ModuleProtocol Methods
    public func load(completion: @escaping (Bool) -> Void) {
        Task {
            await registerRoutes()
            print("SettingsModule loaded successfully")
            completion(true)
        }
    }

    public func unload() {
        print("SettingsModule will unload")
    }

    public func suspend() {
        print("SettingsModule suspended")
    }

    public func resume() {
        lastUsedTime = Date()
        print("SettingsModule resumed")
    }

    // MARK: - Private Methods
    private func registerRoutes() async {
        // Register Settings routes
        do {
            try await Router.shared.registerRoute("/SettingsModule/settings", for: SettingsViewController.self)
            try await Router.shared.registerRoute("/SettingsModule/theme", for: ThemeSettingsViewController.self)
            try await Router.shared.registerRoute("/SettingsModule/notifications", for: NotificationSettingsViewController.self)
            try await Router.shared.registerRoute("/SettingsModule/about", for: AboutViewController.self)
        } catch {
            print("Failed to register routes: \(error)")
        }
    }
}
