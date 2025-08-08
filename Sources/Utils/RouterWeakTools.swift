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
public class WeakArray<Element: AnyObject> {
    private var items: [Weak<Element>] = []  // 内部存储弱引用包装器
    
    public init() {
        items = []
    }
    
    public var count: Int {
        cleanUp()  // 清理无效引用
        return items.count
    }
    
    /// 获取所有存活的元素（过滤已释放的对象）
    var aliveObjects: [Element] {
        items.compactMap { $0.value }
    }
    
    /// 添加对象到数组（弱引用存储）
    /// - Parameter object: 要添加的对象（必须是类实例）
    func append(_ object: Element) {
        items.append(Weak(value: object))
        cleanUp()  // 清理无效引用
    }
    
    /// 从数组中移除指定对象
    /// - Parameter object: 要移除的对象
    func remove(_ object: Element) {
        items.removeAll { $0.value === object }  // 用===比较引用
        cleanUp()  // 清理无效引用
    }
    
    /// 清理已释放的对象引用（内部维护）
    private func cleanUp() {
        items = items.filter { $0.value != nil }
    }
}
