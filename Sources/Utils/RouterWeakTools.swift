//
//  RouterWeakTools.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

// MARK: - 弱引用包装器
/// 弱引用包装类，用于在集合中存储弱引用对象
public class Weak<T: AnyObject> {
    public weak var value: T?  // 弱引用对象
    public init(value: T) {
        self.value = value
    }
}

// MARK: - 弱引用数组
/// 存储弱引用对象的数组，自动清理已释放的对象
/// 优化版本：减少不必要的清理操作，提升性能
public class WeakArray<Element: AnyObject> {
    private var items: [Weak<Element>] = []  // 内部存储弱引用包装器
    private var lastCleanupTime: Date = Date()  // 上次清理时间
    private var operationsSinceLastCleanup: Int = 0  // 自上次清理以来的操作次数
    
    // 清理策略配置
    private let cleanupInterval: TimeInterval = 30.0  // 清理间隔（秒）
    private let operationsThreshold: Int = 50  // 操作次数阈值
    private let maxNilRatio: Double = 0.3  // 最大无效引用比例
    
    public init() {
        items = []
    }
    
    public var count: Int {
        conditionalCleanUp()  // 条件性清理
        return items.count
    }
    
    /// 获取所有存活的元素（过滤已释放的对象）
    /// 使用懒加载方式，避免不必要的遍历
    var aliveObjects: [Element] {
        conditionalCleanUp()
        return items.compactMap { $0.value }
    }
    
    /// 添加对象到数组（弱引用存储）
    /// - Parameter object: 要添加的对象（必须是类实例）
    func append(_ object: Element) {
        items.append(Weak(value: object))
        operationsSinceLastCleanup += 1
        conditionalCleanUp()
    }
    
    /// 从数组中移除指定对象
    /// - Parameter object: 要移除的对象
    func remove(_ object: Element) {
        items.removeAll { $0.value === object }  // 用===比较引用
        operationsSinceLastCleanup += 1
        conditionalCleanUp()
    }
    
    /// 批量添加对象（性能优化）
    /// - Parameter objects: 要添加的对象数组
    func append(contentsOf objects: [Element]) {
        let newItems = objects.map { Weak(value: $0) }
        items.append(contentsOf: newItems)
        operationsSinceLastCleanup += objects.count
        conditionalCleanUp()
    }
    
    /// 检查是否包含指定对象
    /// - Parameter object: 要检查的对象
    /// - Returns: 是否包含该对象
    func contains(_ object: Element) -> Bool {
        return items.contains { $0.value === object }
    }
    
    /// 获取当前无效引用的数量（用于监控）
    var nilCount: Int {
        return items.count { $0.value == nil }
    }
    
    /// 获取当前无效引用的比例
    var nilRatio: Double {
        guard !items.isEmpty else { return 0.0 }
        return Double(nilCount) / Double(items.count)
    }
    
    /// 条件性清理：根据时间间隔、操作次数和无效引用比例决定是否清理
    private func conditionalCleanUp() {
        let now = Date()
        let timeSinceLastCleanup = now.timeIntervalSince(lastCleanupTime)
        
        // 满足以下任一条件时进行清理：
        // 1. 距离上次清理超过指定时间间隔
        // 2. 操作次数超过阈值
        // 3. 无效引用比例超过阈值
        let shouldCleanup = timeSinceLastCleanup >= cleanupInterval ||
                           operationsSinceLastCleanup >= operationsThreshold ||
                           nilRatio >= maxNilRatio
        
        if shouldCleanup {
            performCleanup()
        }
    }
    
    /// 执行实际的清理操作
    private func performCleanup() {
        let originalCount = items.count
        items = items.filter { $0.value != nil }
        let cleanedCount = originalCount - items.count
        
        // 更新清理状态
        lastCleanupTime = Date()
        operationsSinceLastCleanup = 0
        
        #if DEBUG
        if cleanedCount > 0 {
            print("WeakArray清理完成: 移除了\(cleanedCount)个无效引用，剩余\(items.count)个有效引用")
        }
        #endif
    }
    
    /// 强制清理所有无效引用（公开方法）
    public func forceCleanup() {
        performCleanup()
    }
    
    /// 清空所有引用
    public func removeAll() {
        items.removeAll()
        operationsSinceLastCleanup = 0
        lastCleanupTime = Date()
    }
    
    /// 遍历所有存活的对象
    /// - Parameter body: 对每个存活对象执行的闭包
    func forEach(_ body: (Element) throws -> Void) rethrows {
        conditionalCleanUp()
        for item in items {
            if let value = item.value {
                try body(value)
            }
        }
    }
    
    /// 获取清理统计信息（用于调试和监控）
    var cleanupStats: (totalItems: Int, nilItems: Int, nilRatio: Double, lastCleanup: Date, operationsSinceCleanup: Int) {
        return (
            totalItems: items.count,
            nilItems: nilCount,
            nilRatio: nilRatio,
            lastCleanup: lastCleanupTime,
            operationsSinceCleanup: operationsSinceLastCleanup
        )
    }
}
