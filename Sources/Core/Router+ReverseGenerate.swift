//
//  Router+ReverseGenerate.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

extension Router {
    /// 根据Routable类型和参数生成对应的URL
    /// - Parameters:
    ///   - routableType: 页面类型
    ///   - parameters: 参数
    /// - Returns: 生成的URL字符串（可选）
    func generateURL(for routableType: Routable.Type, parameters: RouterParameters? = nil) async -> String? {
        // 通过RouterState安全获取所有路由（异步操作）
        let allRoutes = await getAllRoutes()
        
        // 查找该类型对应的路由模式
        guard let (pattern, _) = allRoutes.first(where: { $0.value == routableType }) else {
            log("未找到 \(routableType) 对应的路由模式", level: .warning)
            return nil
        }
        
        // 替换模式中的参数占位符
        return replaceParameters(in: pattern.pattern, with: parameters ?? [:])
    }
    
    /// 根据路由名称和参数生成URL
    /// - Parameters:
    ///   - routeName: 路由名称（如"/UserModule/profile"）
    ///   - parameters: 参数
    /// - Returns: 生成的URL字符串（可选）
    func generateURL(for routeName: String, parameters: RouterParameters? = nil) -> String? {
        do {
            // 验证路由模式格式
            let _ = try RoutePattern(routeName)
            return replaceParameters(in: routeName, with: parameters ?? [:])
        } catch {
            log("生成URL失败: \(error)", level: .error)
            return nil
        }
    }
    
    /// 替换路由模式中的参数占位符
    private func replaceParameters(in pattern: String, with parameters: RouterParameters) -> String {
        var result = pattern
        
        // 替换参数占位符（如:id -> 实际值）
        parameters.forEach { key, value in
            let placeholder = ":\(key)"
            // 对值进行URL编码处理
            let valueString: String
            if let urlValue = value as? CustomStringConvertible {
                valueString = urlValue.description.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "\(value)"
            } else {
                valueString = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "\(value)"
            }
            
            result = result.replacingOccurrences(of: placeholder, with: valueString)
        }
        
        // 移除可选参数占位符（如:name?）
        result = result.replacingOccurrences(of: "\\:\\w+\\?", with: "", options: .regularExpression)
        
        return result
    }
    
    /// 从RouterState获取所有路由（辅助方法）
    private func getAllRoutes() async -> [RoutePattern: Routable.Type] {
        // 这里需要在RouterState中添加获取所有路由的方法
        // 实际实现应该是通过RouterState的异步接口获取
        await state.getAllRoutes()
    }
}
