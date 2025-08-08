//
//  RouteConfigLoader.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

/// 路由配置加载器，支持从plist/JSON文件预加载路由
final class RouteConfigLoader {
    /// 从plist文件加载路由配置
    /// - Parameters:
    ///   - fileName: 文件名（不含扩展名）
    ///   - bundle: 所在Bundle
    /// - Throws: 加载或解析错误
    static func loadFromPlist(_ fileName: String, in bundle: Bundle = .main) async throws {
        guard let path = bundle.path(forResource: fileName, ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: String] else {
            throw RouterError.configError("路由配置文件 \(fileName).plist 不存在")
        }
        
        try await loadRoutes(from: config)
    }
    
    /// 从JSON文件加载路由配置
    /// - Parameters:
    ///   - fileName: 文件名（不含扩展名）
    ///   - bundle: 所在Bundle
    /// - Throws: 加载或解析错误
    static func loadFromJSON(_ fileName: String, in bundle: Bundle = .main) async throws {
        guard let path = bundle.path(forResource: fileName, ofType: "json") else {
            throw RouterError.configError("路由配置文件 \(fileName).json 不存在")
        }
        
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        guard let config = jsonObject as? [String: String] else {
            throw RouterError.configError("路由配置文件 \(fileName).json 格式错误")
        }
        
        try await loadRoutes(from: config)
    }
    
    /// 实际加载路由配置
    private static func loadRoutes(from config: [String: String]) async throws {
        let router = Router.shared
        var successCount = 0
        
        for (pattern, className) in config {
            // 通过类名反射获取Routable类型
            guard let cls = NSClassFromString(className) as? Routable.Type else {
                router.log("路由 \(pattern) 对应的类 \(className) 不存在或未实现Routable协议", level: .warning)
                continue
            }
            
            do {
                try await router.registerRoute(pattern, for: cls)
                successCount += 1
            } catch {
                router.log("路由 \(pattern) 注册失败: \(error)", level: .error)
            }
        }
        
        router.log("路由配置加载完成，成功注册 \(successCount)/\(config.count) 条路由", level: .info)
    }
}
