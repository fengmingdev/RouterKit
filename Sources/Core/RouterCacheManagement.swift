//
//  RouterCacheManagement.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/10.
//

import Foundation

// MARK: - Router Cache Management Extension
@available(iOS 13.0, macOS 10.15, *)
extension Router {
    
    // MARK: - Cache Management
    
    /// 获取缓存统计信息
    public func getCacheStatistics() async -> RouterCacheStatistics {
        let stats = await state.getCacheStatistics()
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
    public func resetCacheStatistics() async {
        await state.resetCacheStatistics()
    }
    
    /// 清空路由缓存
    public func clearRouteCache() async {
        await state.clearRouteCache()
    }
    
    /// 设置热缓存大小
    public func setHotCacheSize(_ size: Int) async {
        await state.setHotCacheSize(size)
    }
    
    /// 设置热缓存阈值
    public func setHotThreshold(_ threshold: Int) async {
        await state.setHotThreshold(threshold)
    }
    
    /// 设置缓存过期时间
    public func setCacheExpirationTime(_ time: TimeInterval) async {
        await state.setCacheExpirationTime(time)
    }
}