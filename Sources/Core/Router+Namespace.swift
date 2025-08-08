//  Router+Namespace.swift
//  RouterKitDemo
//
//  Created by fengming on 2025/8/4.
//

import Foundation

// MARK: - 路由命名空间管理
/// 命名空间管理器，用于隔离不同模块或功能的路由
public class RouterNamespace {
    /// 命名空间名称
    public let name: String
    /// 父路由管理器
    private unowned let router: Router
    
    /// 初始化命名空间
    /// - Parameters:
    ///   - name: 命名空间名称
    ///   - router: 父路由管理器
    init(name: String, router: Router) {
        self.name = name
        self.router = router
    }
    
    /// 在当前命名空间注册路由
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - routableType: 可路由类型
    ///   - permission: 权限配置
    ///   - priority: 优先级
    /// - Throws: 路由注册错误
    public func register(_ pattern: String, for routableType: Routable.Type, permission: RoutePermission? = nil, priority: Int = 0) async throws {
        try await router.registerRoute(pattern, for: routableType, permission: permission, priority: priority, scheme: name)
    }
    
    /// 在当前命名空间动态注册路由
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - routableType: 可路由类型
    ///   - permission: 权限配置
    ///   - priority: 优先级
    /// - Throws: 路由注册错误
    public func registerDynamic(_ pattern: String, for routableType: Routable.Type, permission: RoutePermission? = nil, priority: Int = 0) async throws {
        try await router.registerDynamicRoute(pattern, for: routableType, permission: permission, priority: priority, scheme: name)
    }
    
    /// 创建带命名空间的URL
    /// - Parameters:
    ///   - path: 路径
    ///   - parameters: 参数
    /// - Returns: URL字符串
    public func url(for path: String, parameters: [String: Any] = [:]) -> String {
        var urlString = "\(name):\(path)"
        if !parameters.isEmpty {
            urlString += "?"
            let queryItems = parameters.map { "\($0.key)=\($0.value)" }
            urlString += queryItems.joined(separator: "&")
        }
        return urlString
    }
}

// MARK: - 为Router添加命名空间支持
extension Router {

    
    /// 获取或创建命名空间
    /// - Parameter name: 命名空间名称
    /// - Returns: 命名空间实例
    public func namespace(_ name: String) -> RouterNamespace {
        if let existingNamespace = namespaces[name] {
            return existingNamespace
        }
        let newNamespace = RouterNamespace(name: name, router: self)
        namespaces[name] = newNamespace
        return newNamespace
    }
    
    /// 移除命名空间
    /// - Parameter name: 命名空间名称
    public func removeNamespace(_ name: String) async {
        namespaces.removeValue(forKey: name)
        // 可以在这里添加清理该命名空间下所有路由的逻辑
        await state.cleanupRoutes(forScheme: name)
        log("已移除命名空间: \(name)")
    }
    
    /// 查找指定命名空间
    /// - Parameter name: 命名空间名称
    /// - Returns: 命名空间实例（可选）
    public func findNamespace(_ name: String) -> RouterNamespace? {
        return namespaces[name]
    }
}
