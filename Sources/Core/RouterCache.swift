//
//  RouterCache.swift
//  RouterKit
//
//  Created by fengming on 2025/8/10.
//

import Foundation

/// 路由缓存管理器
/// 提供多层缓存机制，包括内存缓存、LRU缓存和预编译缓存
public actor RouterCache {
    
    // MARK: - 缓存项结构
    
    /// 缓存项，包含匹配结果和元数据
    private struct CacheItem {
        let pattern: RoutePattern
        let routableType: Routable.Type
        let parameters: RouterParameters
        let timestamp: Date
        let hitCount: Int
        let scheme: String
        
        init(pattern: RoutePattern, routableType: Routable.Type, parameters: RouterParameters, scheme: String, timestamp: Date = Date(), hitCount: Int = 0) {
            self.pattern = pattern
            self.routableType = routableType
            self.parameters = parameters
            self.timestamp = timestamp
            self.hitCount = hitCount
            self.scheme = scheme
        }
        
        /// 增加命中次数并返回一个新的CacheItem实例
        func incrementHit() -> CacheItem {
            return CacheItem(pattern: pattern, routableType: routableType, parameters: parameters, scheme: scheme, timestamp: timestamp, hitCount: hitCount + 1)
        }
    }
    
/// 空路由类型（用于初始化）
private class EmptyRoutable: Routable {
    #if canImport(UIKit)
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return nil
    }
    #endif
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        // Do nothing
    }
}

    /// LRU节点
    private class LRUNode {
        let key: String
        var item: CacheItem
        var prev: LRUNode?
        var next: LRUNode?
        
        init(key: String, item: CacheItem) {
            self.key = key
            self.item = item
        }
    }
    
    // MARK: - 缓存存储
    
    /// 主缓存存储
    private var cache: [String: LRUNode] = [:]
    
    /// LRU链表头尾节点
    private let head = LRUNode(key: "", item: CacheItem(
        pattern: try! RoutePattern("/Empty"),
        routableType: EmptyRoutable.self,
        parameters: [:],
        scheme: ""
    ))
    private let tail = LRUNode(key: "", item: CacheItem(
        pattern: try! RoutePattern("/Empty"),
        routableType: EmptyRoutable.self,
        parameters: [:],
        scheme: ""
    ))
    
    /// 预编译缓存（用于静态路由）
    private var precompiledCache: [String: CacheItem] = [:]
    
    /// 热点路由缓存（高频访问路由）
    private var hotCache: [String: CacheItem] = [:]
    
    // MARK: - 配置参数
    
    /// 最大缓存大小
    private var maxCacheSize: Int = 200
    
    /// 热点缓存大小
    private var hotCacheSize: Int = 50
    
    /// 热点阈值（访问次数）
    private var hotThreshold: Int = 10
    
    /// 缓存过期时间（秒）
    private var cacheExpirationTime: TimeInterval = 3600 // 1小时
    
    /// 统计信息
    private var hitCount: Int = 0
    private var missCount: Int = 0
    
    // MARK: - 初始化
    
    init() {
        head.next = tail
        tail.prev = head
    }
    
    // MARK: - 缓存操作
    
    /// 获取缓存项
    func get(_ url: String) -> (pattern: RoutePattern, type: Routable.Type, parameters: RouterParameters, scheme: String)? {
        // 首先检查热点缓存
        if let hotItem = hotCache[url], !isExpired(hotItem) {
            hitCount += 1
            hotCache[url] = hotItem.incrementHit()
            return (hotItem.pattern, hotItem.routableType, hotItem.parameters, hotItem.scheme)
        }
        
        // 检查预编译缓存
        if let precompiledItem = precompiledCache[url], !isExpired(precompiledItem) {
            hitCount += 1
            let updatedItem = precompiledItem.incrementHit()
            precompiledCache[url] = updatedItem
            
            // 如果访问次数达到热点阈值，移到热点缓存
            if updatedItem.hitCount >= hotThreshold {
                moveToHotCache(url, updatedItem)
            }
            
            return (updatedItem.pattern, updatedItem.routableType, updatedItem.parameters, updatedItem.scheme)
        }
        
        // 检查主缓存
        if let node = cache[url], !isExpired(node.item) {
            hitCount += 1
            let updatedItem = node.item.incrementHit()
            node.item = updatedItem
            
            // 移动到链表头部（LRU）
            moveToHead(node)
            
            // 如果访问次数达到热点阈值，移到热点缓存
            if updatedItem.hitCount >= hotThreshold {
                moveToHotCache(url, updatedItem)
                removeFromLRU(url)
            }
            
            return (updatedItem.pattern, updatedItem.routableType, updatedItem.parameters, updatedItem.scheme)
        }
        
        missCount += 1
        return nil
    }
    
    /// 设置缓存项
    func set(_ url: String, pattern: RoutePattern, routableType: Routable.Type, parameters: RouterParameters, scheme: String, isPrecompiled: Bool = false) {
        let item = CacheItem(pattern: pattern, routableType: routableType, parameters: parameters, scheme: scheme)
        
        if isPrecompiled {
            precompiledCache[url] = item
            return
        }
        
        // 如果已存在，更新并移到头部
        if let existingNode = cache[url] {
            existingNode.item = item
            moveToHead(existingNode)
            return
        }
        
        // 创建新节点
        let newNode = LRUNode(key: url, item: item)
        cache[url] = newNode
        addToHead(newNode)
        
        // 检查缓存大小限制
        if cache.count > maxCacheSize {
            if let tailNode = removeTail() {
                cache.removeValue(forKey: tailNode.key)
            }
        }
    }
    
    /// 移除缓存项
    func remove(_ url: String) {
        hotCache.removeValue(forKey: url)
        precompiledCache.removeValue(forKey: url)
        removeFromLRU(url)
    }
    
    /// 清理过期缓存
    func cleanupExpiredItems() {
        let now = Date()
        
        // 清理热点缓存
        hotCache = hotCache.filter { !isExpired($0.value, at: now) }
        
        // 清理预编译缓存
        precompiledCache = precompiledCache.filter { !isExpired($0.value, at: now) }
        
        // 清理主缓存
        let expiredKeys = cache.compactMap { key, node in
            isExpired(node.item, at: now) ? key : nil
        }
        for key in expiredKeys {
            remove(key)
        }
    }
    
    /// 清空所有缓存
    func clearAll() {
        cache.removeAll()
        precompiledCache.removeAll()
        hotCache.removeAll()
        head.next = tail
        tail.prev = head
        hitCount = 0
        missCount = 0
    }
    
    // MARK: - 配置管理
    
    /// 设置最大缓存大小
    func setMaxCacheSize(_ size: Int) {
        maxCacheSize = size
        
        // 如果当前缓存超过新的限制，清理多余项
        while cache.count > maxCacheSize {
            if let tailNode = removeTail() {
                cache.removeValue(forKey: tailNode.key)
            }
        }
    }
    
    /// 设置热点缓存大小
    func setHotCacheSize(_ size: Int) {
        hotCacheSize = size
        
        // 如果当前热点缓存超过新的限制，移除访问次数最少的项
        while hotCache.count > hotCacheSize {
            if let leastUsedKey = hotCache.min(by: { $0.value.hitCount < $1.value.hitCount })?.key {
                hotCache.removeValue(forKey: leastUsedKey)
            }
        }
    }
    
    /// 设置热点阈值
    func setHotThreshold(_ threshold: Int) {
        hotThreshold = threshold
    }
    
    /// 设置缓存过期时间
    func setCacheExpirationTime(_ time: TimeInterval) {
        cacheExpirationTime = time
    }
    
    // MARK: - 统计信息
    
    /// 获取缓存统计信息
    func getStatistics() -> (hitCount: Int, missCount: Int, hitRate: Double, cacheSize: Int, hotCacheSize: Int, precompiledCacheSize: Int) {
        let totalRequests = hitCount + missCount
        let hitRate = totalRequests > 0 ? Double(hitCount) / Double(totalRequests) : 0.0
        
        return (
            hitCount: hitCount,
            missCount: missCount,
            hitRate: hitRate,
            cacheSize: cache.count,
            hotCacheSize: hotCache.count,
            precompiledCacheSize: precompiledCache.count
        )
    }
    
    /// 重置统计信息
    func resetStatistics() {
        hitCount = 0
        missCount = 0
    }
    
    // MARK: - 私有辅助方法
    
    /// 辅助方法
    private func isExpired(_ item: CacheItem, at now: Date = Date()) -> Bool {
        return now.timeIntervalSince(item.timestamp) > cacheExpirationTime
    }
    
    private func moveToHotCache(_ url: String, _ item: CacheItem) {
        hotCache[url] = item
        if hotCache.count > hotCacheSize {
            // 移除最少使用的热点项（这里可以简单移除任意一个，或者实现更复杂的LRU/LFU策略）
            if let firstKey = hotCache.keys.first {
                hotCache.removeValue(forKey: firstKey)
            }
        }
    }
    
    /// LRU 链表操作
    private func removeNode(_ node: LRUNode) {
        node.prev?.next = node.next
        node.next?.prev = node.prev
        node.prev = nil
        node.next = nil
    }
    
    private func addToHead(_ node: LRUNode) {
        node.prev = head
        node.next = head.next
        head.next?.prev = node
        head.next = node
    }
    
    private func moveToHead(_ node: LRUNode) {
        removeNode(node)
        addToHead(node)
    }
    
    private func removeTail() -> LRUNode? {
        guard let node = tail.prev, node !== head else { return nil }
        removeNode(node)
        return node
    }
    
    private func removeFromLRU(_ url: String) {
        if let node = cache[url] {
            removeNode(node)
            cache.removeValue(forKey: url)
        }
    }
}
