//
//  DeepLinkHandler.swift
//  MyMainProject
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 深度链接处理器
class DeepLinkHandler {
    
    static let shared = DeepLinkHandler()
    
    private init() {}
    
    // MARK: - URL Scheme处理
    
    /// 处理URL Scheme深度链接
    /// - Parameter url: 传入的URL
    /// - Returns: 是否成功处理
    func handleURLScheme(_ url: URL) -> Bool {
        print("DeepLinkHandler: 处理URL Scheme: \(url.absoluteString)")
        
        guard url.scheme == "routerkit-example" else {
            print("DeepLinkHandler: 不支持的URL Scheme: \(url.scheme ?? "nil")")
            return false
        }
        
        return processDeepLink(url)
    }
    
    /// 处理Universal Links
    /// - Parameter url: 传入的URL
    /// - Returns: 是否成功处理
    func handleUniversalLink(_ url: URL) -> Bool {
        print("DeepLinkHandler: 处理Universal Link: \(url.absoluteString)")
        
        guard url.host == "routerkit.example.com" else {
            print("DeepLinkHandler: 不支持的Universal Link域名: \(url.host ?? "nil")")
            return false
        }
        
        return processDeepLink(url)
    }
    
    // MARK: - 深度链接处理逻辑
    
    private func processDeepLink(_ url: URL) -> Bool {
        // 解析URL路径和参数
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        
        print("DeepLinkHandler: 路径组件: \(pathComponents)")
        print("DeepLinkHandler: 查询参数: \(queryItems?.description ?? "无")")
        
        // 根据路径组件构建路由
        let route = buildRoute(from: pathComponents)
        let parameters = buildParameters(from: queryItems)
        
        // 执行路由跳转
        return executeNavigation(route: route, parameters: parameters)
    }
    
    private func buildRoute(from pathComponents: [String]) -> String {
        guard !pathComponents.isEmpty else {
            return "/" // 默认首页
        }
        
        let firstComponent = pathComponents[0].lowercased()
        
        switch firstComponent {
        case "login":
            return "/LoginModule/login"
            
        case "message", "messages":
            if pathComponents.count > 1 {
                // 支持 /message/detail?id=123 格式
                return "/MessageModule/\(pathComponents[1])"
            }
            return "/MessageModule/message"
            
        case "profile", "user":
            if pathComponents.count > 1 {
                let action = pathComponents[1].lowercased()
                switch action {
                case "edit":
                    return "/ProfileModule/edit"
                case "avatar":
                    return "/ProfileModule/avatar"
                default:
                    return "/ProfileModule/profile"
                }
            }
            return "/ProfileModule/profile"
            
        case "settings":
            if pathComponents.count > 1 {
                let setting = pathComponents[1].lowercased()
                switch setting {
                case "theme":
                    return "/SettingsModule/theme"
                case "notification", "notifications":
                    return "/SettingsModule/notification"
                case "about":
                    return "/SettingsModule/about"
                default:
                    return "/SettingsModule/settings"
                }
            }
            return "/SettingsModule/settings"
            
        case "home", "main":
            return "/"
            
        default:
            print("DeepLinkHandler: 未知的路径组件: \(firstComponent)")
            return "/" // 默认返回首页
        }
    }
    
    private func buildParameters(from queryItems: [URLQueryItem]?) -> [String: Any] {
        guard let queryItems = queryItems else { return [:] }
        
        var parameters: [String: Any] = [:]
        
        for item in queryItems {
            if let value = item.value {
                // 尝试转换为合适的类型
                if let intValue = Int(value) {
                    parameters[item.name] = intValue
                } else if let boolValue = Bool(value) {
                    parameters[item.name] = boolValue
                } else {
                    parameters[item.name] = value
                }
            }
        }
        
        return parameters
    }
    
    private func executeNavigation(route: String, parameters: [String: Any]) -> Bool {
        print("DeepLinkHandler: 执行导航 - 路由: \(route), 参数: \(parameters)")
        
        // 延迟执行，确保应用已完全启动
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if parameters.isEmpty {
                Router.push(to: route)
            } else {
                Router.push(to: route, parameters: parameters)
            }
        }
        
        return true
    }
    
    // MARK: - 深度链接生成
    
    /// 生成URL Scheme深度链接
    /// - Parameters:
    ///   - route: 路由路径
    ///   - parameters: 参数字典
    /// - Returns: 生成的URL
    func generateURLSchemeLink(route: String, parameters: [String: Any] = [:]) -> URL? {
        let path = convertRouteToPath(route)
        var components = URLComponents()
        components.scheme = "routerkit-example"
        components.path = path
        
        if !parameters.isEmpty {
            components.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        return components.url
    }
    
    /// 生成Universal Link
    /// - Parameters:
    ///   - route: 路由路径
    ///   - parameters: 参数字典
    /// - Returns: 生成的URL
    func generateUniversalLink(route: String, parameters: [String: Any] = [:]) -> URL? {
        let path = convertRouteToPath(route)
        var components = URLComponents()
        components.scheme = "https"
        components.host = "routerkit.example.com"
        components.path = path
        
        if !parameters.isEmpty {
            components.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        return components.url
    }
    
    private func convertRouteToPath(_ route: String) -> String {
        // 将内部路由转换为外部路径
        switch route {
        case "/LoginModule/login":
            return "/login"
        case "/MessageModule/message":
            return "/message"
        case "/ProfileModule/profile":
            return "/profile"
        case "/ProfileModule/edit":
            return "/profile/edit"
        case "/ProfileModule/avatar":
            return "/profile/avatar"
        case "/SettingsModule/settings":
            return "/settings"
        case "/SettingsModule/theme":
            return "/settings/theme"
        case "/SettingsModule/notification":
            return "/settings/notification"
        case "/SettingsModule/about":
            return "/settings/about"
        case "/":
            return "/home"
        default:
            return "/home"
        }
    }
    
    // MARK: - 分享功能
    
    /// 分享深度链接
    /// - Parameters:
    ///   - route: 路由路径
    ///   - parameters: 参数字典
    ///   - from: 发起分享的视图控制器
    ///   - useUniversalLink: 是否使用Universal Link（默认true）
    func shareDeepLink(route: String, parameters: [String: Any] = [:], from viewController: UIViewController, useUniversalLink: Bool = true) {
        
        let url: URL?
        let title: String
        
        if useUniversalLink {
            url = generateUniversalLink(route: route, parameters: parameters)
            title = "分享链接"
        } else {
            url = generateURLSchemeLink(route: route, parameters: parameters)
            title = "分享应用链接"
        }
        
        guard let shareURL = url else {
            print("DeepLinkHandler: 无法生成分享链接")
            return
        }
        
        let message = getShareMessage(for: route)
        let activityItems: [Any] = [message, shareURL]
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // iPad适配
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
        }
        
        viewController.present(activityViewController, animated: true)
        
        print("DeepLinkHandler: 分享链接: \(shareURL.absoluteString)")
    }
    
    private func getShareMessage(for route: String) -> String {
        switch route {
        case "/LoginModule/login":
            return "快来登录RouterKit Example应用！"
        case "/MessageModule/message":
            return "查看RouterKit Example中的消息功能！"
        case "/ProfileModule/profile":
            return "查看我的个人资料！"
        case "/SettingsModule/settings":
            return "体验RouterKit Example的设置功能！"
        default:
            return "快来体验RouterKit Example应用！"
        }
    }
    
    // MARK: - 调试功能
    
    /// 测试深度链接
    func testDeepLinks() {
        print("\n=== DeepLinkHandler 测试开始 ===")
        
        let testCases = [
            "routerkit-example://login",
            "routerkit-example://message?id=123",
            "routerkit-example://profile/edit?userId=456",
            "routerkit-example://settings/theme",
            "https://routerkit.example.com/login",
            "https://routerkit.example.com/profile?tab=edit",
            "https://routerkit.example.com/settings/notification?enabled=true"
        ]
        
        for testCase in testCases {
            if let url = URL(string: testCase) {
                print("\n测试URL: \(testCase)")
                if url.scheme == "routerkit-example" {
                    _ = handleURLScheme(url)
                } else {
                    _ = handleUniversalLink(url)
                }
            }
        }
        
        print("\n=== DeepLinkHandler 测试结束 ===\n")
    }
    
    /// 生成测试链接
    func generateTestLinks() -> [String] {
        let routes = [
            "/LoginModule/login",
            "/MessageModule/message",
            "/ProfileModule/profile",
            "/ProfileModule/edit",
            "/SettingsModule/settings",
            "/SettingsModule/theme"
        ]
        
        var links: [String] = []
        
        for route in routes {
            if let urlScheme = generateURLSchemeLink(route: route) {
                links.append("URL Scheme: \(urlScheme.absoluteString)")
            }
            
            if let universalLink = generateUniversalLink(route: route) {
                links.append("Universal Link: \(universalLink.absoluteString)")
            }
        }
        
        return links
    }
}

// MARK: - DeepLinkHandler Extension for AppDelegate
extension DeepLinkHandler {
    
    /// 处理应用启动时的深度链接
    func handleLaunchURL(_ url: URL) -> Bool {
        print("DeepLinkHandler: 应用启动时处理深度链接: \(url.absoluteString)")
        
        if url.scheme == "routerkit-example" {
            return handleURLScheme(url)
        } else if url.scheme == "https" && url.host == "routerkit.example.com" {
            return handleUniversalLink(url)
        }
        
        return false
    }
    
    /// 处理应用在后台时接收到的深度链接
    func handleBackgroundURL(_ url: URL) -> Bool {
        print("DeepLinkHandler: 应用在后台时处理深度链接: \(url.absoluteString)")
        
        // 后台处理逻辑可能需要特殊处理
        return handleLaunchURL(url)
    }
}