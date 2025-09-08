//
//  RouterStateCacheManager.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation

/// 路由状态缓存管理器
/// 负责管理路由缓存的所有操作
@available(iOS 13.0, macOS 10.15, *)
actor RouterStateCacheManager {
    
    // MARK: - 存储容器
    
    /// 路由缓存实例
    private let routeCache = RouterCache()
    
    // MARK: - 缓存操作
    
    /// 匹配路由并缓存结果
    /// - Parameter url: 要匹配的URL
    /// - Returns: 匹配结果（路由模式、类型和参数）
    func matchRoute(_ url: URL, enableParameterSanitization: Bool, routeManager: RouterStateRouteManager) async -> (pattern: RoutePattern, type: Routable.Type, parameters: RouterParameters)? {
        let urlString = url.absoluteString
        
        // 首先尝试从缓存获取
        if let cacheResult = await routeCache.get(urlString) {
            return (cacheResult.pattern, cacheResult.type, cacheResult.parameters)
        }
        
        // 缓存未命中，进行实际匹配
        guard let matchResult = await routeManager.matchRoute(url) else {
            return nil
        }
        
        let (pattern, routableType, parameters) = matchResult
        
        // 参数清理（如果启用）
        var sanitizedParameters = parameters
        if enableParameterSanitization {
            sanitizedParameters = sanitizeParameters(parameters)
        }
        
        // 获取路由的scheme
        let scheme = await getRouteScheme(for: pattern, routeManager: routeManager)
        
        // 缓存匹配结果
        await routeCache.set(urlString, pattern: pattern, routableType: routableType, parameters: sanitizedParameters, scheme: scheme)
        
        return (pattern, routableType, sanitizedParameters)
    }
    
    /// 清理路由缓存（清理过期项和统计信息）
    func cleanupRouteCache() async {
        await routeCache.cleanupExpiredItems()
    }
    
    /// 获取缓存统计信息
    func getCacheStatistics() async -> RouterCacheStatistics {
        let stats = await routeCache.getStatistics()
        return RouterCacheStatistics(
            hitCount: stats.hitCount,
            missCount: stats.missCount,
            hitRate: stats.hitRate,
            cacheSize: stats.cacheSize,
            hotCacheSize: stats.hotCacheSize,
            precompiledCacheSize: stats.precompiledCacheSize
        )
    }
    
    /// 重置缓存统计信息
    func resetCacheStatistics() async {
        await routeCache.resetStatistics()
    }
    
    /// 清空所有缓存
    func clearRouteCache() async {
        await routeCache.clearAll()
    }
    
    /// 设置路由缓存最大大小
    /// - Parameter size: 缓存大小
    func setRouteCacheMaxSize(_ size: Int) async {
        await routeCache.setMaxCacheSize(size)
    }
    
    /// 设置热点缓存大小
    /// - Parameter size: 热点缓存大小
    func setHotCacheSize(_ size: Int) async {
        await routeCache.setHotCacheSize(size)
    }
    
    /// 设置热点阈值
    /// - Parameter threshold: 热点阈值
    func setHotThreshold(_ threshold: Int) async {
        await routeCache.setHotThreshold(threshold)
    }
    
    /// 设置缓存过期时间
    /// - Parameter time: 过期时间
    func setCacheExpirationTime(_ time: TimeInterval) async {
        await routeCache.setCacheExpirationTime(time)
    }
    
    /// 预编译常用路由
    /// - Parameter patterns: 要预编译的路由模式数组
    func precompileRoutes(_ patterns: [RoutePattern], routeManager: RouterStateRouteManager) async {
        for pattern in patterns {
            if let routableType = await routeManager.getRoutableType(for: pattern) {
                let scheme = await getRouteScheme(for: pattern, routeManager: routeManager)
                let emptyParameters = RouterParameters()
                
                // 预编译到缓存
                await routeCache.set(
                    pattern.pattern,
                    pattern: pattern,
                    routableType: routableType,
                    parameters: emptyParameters,
                    scheme: scheme,
                    isPrecompiled: true
                )
            }
        }
    }
    
    /// 获取缓存命中率
    /// - Returns: 缓存命中率（0.0-1.0）
    func getCacheHitRate() async -> Double {
        let stats = await routeCache.getStatistics()
        return stats.hitRate
    }
    
    /// 获取缓存大小信息
    /// - Returns: 缓存大小信息
    func getCacheSizeInfo() async -> (total: Int, hot: Int, precompiled: Int) {
        let stats = await routeCache.getStatistics()
        return (stats.cacheSize, stats.hotCacheSize, stats.precompiledCacheSize)
    }
    
    /// 清理指定模块的缓存
    /// - Parameter moduleName: 模块名称
    func clearCacheForModule(_ moduleName: String) async {
        // 由于RouterCache没有按模块清理的功能，这里清空整个缓存
        // 在实际实现中，可以考虑为RouterCache添加更精细的清理功能
        await routeCache.clearAll()
    }
    
    // MARK: - 辅助方法
    
    /// 清理参数（移除敏感信息等）
    /// - Parameter parameters: 原始参数
    /// - Returns: 清理后的参数
    private func sanitizeParameters(_ parameters: RouterParameters) -> RouterParameters {
        var sanitized = parameters
        
        // 移除可能的敏感参数
        let sensitiveKeys = ["password", "token", "secret", "key", "auth"]
        for key in sensitiveKeys {
            sanitized.removeValue(forKey: key)
        }
        
        // 清理特殊字符
        for (key, value) in sanitized {
            if let stringValue = value as? String {
                // 移除潜在的脚本注入字符
                let cleanValue = stringValue
                    .replacingOccurrences(of: "<script", with: "")
                    .replacingOccurrences(of: "javascript:", with: "")
                    .replacingOccurrences(of: "data:", with: "")
                
                sanitized[key] = cleanValue
            }
        }
        
        return sanitized
    }
    
    /// 获取路由的scheme
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - routeManager: 路由管理器
    /// - Returns: scheme字符串
    private func getRouteScheme(for pattern: RoutePattern, routeManager: RouterStateRouteManager) async -> String {
        // 这里需要从routeManager获取scheme信息
        // 由于当前的RouteEntry是私有的，我们使用默认值
        return "default"
    }
    
    // MARK: - 状态重置
    
    /// 重置所有缓存数据
    func reset() async {
        await routeCache.clearAll()
        await routeCache.resetStatistics()
    }
}