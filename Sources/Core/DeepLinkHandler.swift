//
//  DeepLinkHandler.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// 跨平台类型别名
typealias PlatformApplication = UIApplication

typealias PlatformUserActivity = NSUserActivity

typealias PlatformOpenURLOptionsKey = UIApplication.OpenURLOptionsKey

#if os(macOS)
typealias UIApplication = NSApplication
typealias UIApplicationDelegate = NSObjectProtocol
extension NSApplication {
    struct OpenURLOptionsKey: Hashable, Equatable, RawRepresentable {
        let rawValue: String
        static let sourceApplication = OpenURLOptionsKey(rawValue: "sourceApplication")
    }
}
#endif

/// 深度链接处理类，支持从外部唤起App内页面
@available(iOS 13.0, macOS 10.15, *)
final class DeepLinkHandler {
    static let shared = DeepLinkHandler()
    private init() {}

    // 已注册的安全URL Scheme
    private var registeredSchemes: Set<String> = []

    // 信任的来源应用列表
    private var trustedSources: Set<String> = []

    // 最大允许的路径深度，默认为5层
    private var maxPathDepth: Int = 5

    /// 设置最大允许的路径深度
    /// - Parameter depth: 最大路径深度值
    func setMaximumPathDepth(_ depth: Int) {
        maxPathDepth = max(1, depth) // 确保至少为1
        Router.shared.log("已设置最大路径深度: \(maxPathDepth)", level: .info)
    }

    /// 处理系统URL打开请求
    /// - Parameters:
    ///   - url: 外部URL
    ///   - options: 打开选项
    /// - Returns: 是否成功处理
    @MainActor @discardableResult
    func handle(url: URL, options: [PlatformOpenURLOptionsKey: Any]?) async -> Bool {
        // 1. 基础验证
        guard let scheme = url.scheme, !scheme.isEmpty else {
            Router.shared.log("URL缺少scheme，拒绝处理", level: .warning)
            return false
        }

        // 2. 验证scheme是否已注册
        guard registeredSchemes.contains(scheme.lowercased()) else {
            Router.shared.log("未注册的URL Scheme: \(scheme)", level: .warning)
            return false
        }

        // 3. 验证来源应用
        let sourceApplication = options?[PlatformOpenURLOptionsKey.sourceApplication] as? String ?? "unknown"
        if !trustedSources.isEmpty && !trustedSources.contains(sourceApplication) {
            Router.shared.log("不信任的来源应用: \(sourceApplication)", level: .warning)
            return false
        }

        // 4. 验证URL长度
        let urlString = url.absoluteString
        if urlString.count > 2048 {
            Router.shared.log("URL过长，可能存在安全风险", level: .warning)
            return false
        }

        // 5. 检查路径安全性
        guard isValidPath(url.path) else {
            Router.shared.log("URL路径存在安全风险", level: .warning)
            return false
        }

        Router.shared.log("收到外部链接: \(urlString) 来源: \(sourceApplication)", level: .info)

        // 特殊处理Universal Link（去除域名部分）
        let path = url.path.isEmpty ? urlString : url.path

        // 执行路由跳转
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                #if canImport(UIKit)
                Router.shared.navigate(to: path, parameters: nil, from: nil, type: .push, animated: true, animationId: nil, completion: { result in
                    switch result {
                    case .success:
                        Router.shared.log("成功处理外部链接: \(urlString)", level: .info)
                        continuation.resume()
                    case .failure(let error):
                        Router.shared.log("处理外部链接失败: \(error)", level: .error)
                        continuation.resume(throwing: error)
                    }
                })
                #else
                continuation.resume(throwing: RouterError.unsupportedAction("UIKit navigation not available on this platform"))
                #endif
            }
            return true
        } catch {
            return false
        }
    }

    /// 注册URL Scheme支持
    /// - Parameter schemes: 安全的URL Scheme列表
    func registerURLSchemes(_ schemes: [String]) {
        registeredSchemes = Set(schemes.map { $0.lowercased() })
        Router.shared.log("已注册URL Scheme: \(registeredSchemes.joined(separator: ","))", level: .info)
    }

    /// 添加信任的来源应用
    /// - Parameter sources: 信任的来源应用Bundle ID列表
    func addTrustedSources(_ sources: [String]) {
        trustedSources.formUnion(sources)
        if #available(iOS 13.0, macOS 10.15, *) {
            Router.shared.log("已添加信任的来源应用: \(sources.joined(separator: ","))", level: .info)
        }
    }

    /// 验证URL路径是否安全
    /// - Parameter path: URL路径
    /// - Returns: 是否安全
    @available(iOS 13.0, macOS 10.15, *)
    private func isValidPath(_ path: String) -> Bool {
        // 1. 禁止包含敏感路径字符及其编码形式
        let invalidPatterns = ["../", "./", "~/", "%2E%2E%2F", "%2e%2e%2f"]
        for pattern in invalidPatterns {
            if path.contains(pattern) {
                return false
            }
        }

        // 2. 限制路径深度
        let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
        if pathComponents.count > maxPathDepth {
            if #available(iOS 13.0, macOS 10.15, *) {
                Router.shared.log("URL路径深度(\(pathComponents.count))超过最大限制(\(maxPathDepth))", level: .warning)
            }
            return false
        }

        // 3. 限制只允许字母、数字、下划线和常见分隔符
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/-.")
        let disallowedRange = path.rangeOfCharacter(from: allowedCharacters.inverted)
        return disallowedRange == nil
    }
}

// MARK: - AppDelegate扩展（方便集成）
@available(iOS 13.0, macOS 10.15, *)
extension PlatformApplication: PlatformApplicationProtocol {
    @available(iOS 13.0, macOS 10.15, *)
    func open(_ url: URL, options: [PlatformOpenURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            if #available(iOS 13.0, macOS 10.15, *) {
                Task {
                    let result = await DeepLinkHandler.shared.handle(url: url, options: options)
                    completionHandler?(result)
                }
            }
        }
    }
}

protocol PlatformApplicationProtocol {
    func open(_ url: URL, options: [PlatformOpenURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?)
}

extension UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        DispatchQueue.main.async {
            if #available(iOS 13.0, macOS 10.15, *) {
                Task {
                    _ = await DeepLinkHandler.shared.handle(url: url, options: options)
                }
            }
        }
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            DispatchQueue.main.async {
                if #available(iOS 13.0, macOS 10.15, *) {
                    Task {
                        _ = await DeepLinkHandler.shared.handle(url: url, options: nil)
                    }
                }
            }
            return true
        }
        return false
    }
}
