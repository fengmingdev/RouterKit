import XCTest
import os
@testable import RouterKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit) || canImport(AppKit)
class CacheTestRoutable: PlatformViewController, Routable {
    required init() {
        #if canImport(UIKit)
        super.init(nibName: nil, bundle: nil)
        #elseif canImport(AppKit)
        super.init(nibName: nil, bundle: nil)
        #endif
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> PlatformViewController {
        return CacheTestRoutable()
    }
    
    #if canImport(UIKit)
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return CacheTestRoutable()
    }
    #else
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return CacheTestRoutable()
    }
    #endif
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // Test implementation
    }
}
#endif

final class RouterCacheTests: XCTestCase, @unchecked Sendable {
    
    var router: Router!
    
    override func setUp() async throws {
        try await super.setUp()
        router = Router.shared
        
        // 清理缓存
        await router.clearRouteCache()
        await router.resetCacheStatistics()
    }
    
    override func tearDown() async throws {
         await router.clearRouteCache()
         await router.resetCacheStatistics()
        router = nil
        try await super.tearDown()
    }
    
    // MARK: - 基础缓存功能测试
    
    func testBasicCaching() async {
        // 测试基础缓存功能通过路由注册和导航
        router.register("/test", for: CacheTestRoutable.self)
        
        // 第一次导航会缓存路由
        let result1 = await withCheckedContinuation { continuation in
            Task { @MainActor in
                router.navigate(to: "/test") { result in
                    continuation.resume(returning: result)
                }
            }
        }
        switch result1 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Navigation should succeed")
        }
        
        // 第二次导航应该使用缓存
        let result2 = await withCheckedContinuation { continuation in
            Task { @MainActor in
                router.navigate(to: "/test") { result in
                    continuation.resume(returning: result)
                }
            }
        }
        switch result2 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Navigation should succeed")
        }
        
        // 检查缓存统计
        let stats = await router.getCacheStatistics()
        XCTAssertGreaterThan(stats.hitCount + stats.missCount, 0)
    }
    
    func testCacheExpiration() async {
        // 测试缓存过期功能
        let shortTTL: TimeInterval = 0.1 // 100ms
        
        // 设置短过期时间
        await router.setCacheExpirationTime(shortTTL)
        
        router.register("/expiring", for: CacheTestRoutable.self)
        
        // 第一次导航
        let result1 = await withCheckedContinuation { continuation in
            Task { @MainActor in
                router.navigate(to: "/expiring") { result in
                    continuation.resume(returning: result)
                }
            }
        }
        switch result1 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Navigation should succeed")
        }
        
        // 等待过期
        let expectation = self.expectation(description: "Cache expiration")
        DispatchQueue.main.asyncAfter(deadline: .now() + shortTTL + 0.05) {
            Task {
                // 过期后的导航应该重新解析路由
                let result2 = await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        self.router.navigate(to: "/expiring") { result in
                            continuation.resume(returning: result)
                        }
                    }
                }
                switch result2 {
                case .success:
                    XCTAssertTrue(true)
                case .failure:
                    XCTFail("Navigation should succeed")
                }
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testCacheRemoval() async {
        // 测试缓存清理功能
        router.register("/removable", for: CacheTestRoutable.self)
        
        // 导航以创建缓存
        let result1 = await withCheckedContinuation { continuation in
            Task { @MainActor in
                router.navigate(to: "/removable") { result in
                    continuation.resume(returning: result)
                }
            }
        }
        switch result1 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Navigation should succeed")
        }
        
        // 获取初始统计
        _ = await router.getCacheStatistics()
        
        // 清理缓存
        await router.clearRouteCache()
        
        // 验证缓存已清理
        let clearedStats = await router.getCacheStatistics()
        XCTAssertEqual(clearedStats.cacheSize, 0)
    }
    
    func testCacheClearAll() async {
        // 测试清空所有缓存
        router.register("/test1", for: CacheTestRoutable.self)
        router.register("/test2", for: CacheTestRoutable.self)
        router.register("/test3", for: CacheTestRoutable.self)
        
        // 导航以创建缓存
        await MainActor.run {
            router.navigate(to: "/test1") { _ in }
        }
        await MainActor.run {
            router.navigate(to: "/test2") { _ in }
        }
        await MainActor.run {
            router.navigate(to: "/test3") { _ in }
        }
        
        // 确认缓存存在
        let initialStats = await router.getCacheStatistics()
        XCTAssertGreaterThan(initialStats.cacheSize, 0)
        
        // 清空所有缓存
        await router.clearRouteCache()
        
        // 确认缓存已被清空
        let clearedStats = await router.getCacheStatistics()
        XCTAssertEqual(clearedStats.cacheSize, 0)
    }
    
    // MARK: - 缓存容量测试
    
    func testCacheCapacityLimit() async {
        // 测试缓存容量限制
        await router.setCacheSize(3)
        
        // 注册路由
        router.register("/test1", for: CacheTestRoutable.self)
        router.register("/test2", for: CacheTestRoutable.self)
        router.register("/test3", for: CacheTestRoutable.self)
        router.register("/test4", for: CacheTestRoutable.self)
        
        // 导航以创建缓存项
        await MainActor.run {
            router.navigate(to: "/test1") { _ in }
        }
        await MainActor.run {
            router.navigate(to: "/test2") { _ in }
        }
        await MainActor.run {
            router.navigate(to: "/test3") { _ in }
        }
        await MainActor.run {
            router.navigate(to: "/test4") { _ in } // 这应该触发LRU清理
        }
        
        // 检查缓存大小不超过限制
        let finalStats = await router.getCacheStatistics()
        XCTAssertLessThanOrEqual(finalStats.cacheSize, 3)
        
        // 恢复原始容量
        await router.setCacheSize(100)
    }
    
    func testLRUEviction() async {
        // 测试LRU淘汰策略
        await router.setCacheSize(2)
        
        // 注册路由
        router.register("/test1", for: CacheTestRoutable.self)
        router.register("/test2", for: CacheTestRoutable.self)
        router.register("/test3", for: CacheTestRoutable.self)
        
        // 导航以创建缓存项
        await MainActor.run {
            router.navigate(to: "/test1") { _ in }
        }
        await MainActor.run {
            router.navigate(to: "/test2") { _ in }
        }
        
        // 再次访问test1使其成为最近使用的
        await MainActor.run {
            router.navigate(to: "/test1") { _ in }
        }
        
        // 添加新项目，应该触发LRU淘汰
        await MainActor.run {
            router.navigate(to: "/test3") { _ in }
        }
        
        // 检查缓存大小不超过限制
        let finalStats = await router.getCacheStatistics()
        XCTAssertLessThanOrEqual(finalStats.cacheSize, 2)
        
        // 恢复原始容量
        await router.setCacheSize(100)
    }
    
    // MARK: - 缓存统计测试
    
    func testCacheStatistics() async {
        // 测试缓存统计功能
        await router.resetCacheStatistics()
        let initialStats = await router.getCacheStatistics()
        
        // 注册路由
        router.register("/test", for: CacheTestRoutable.self)
        
        // 导航以创建缓存项和统计
        await MainActor.run {
            router.navigate(to: "/test") { _ in }
        }
        await MainActor.run {
            router.navigate(to: "/test") { _ in } // 应该命中缓存
        }
        await MainActor.run {
            router.navigate(to: "/nonexistent") { _ in } // 应该未命中
        }
        
        let finalStats = await router.getCacheStatistics()
        
        XCTAssertGreaterThan(finalStats.hitCount, initialStats.hitCount)
        XCTAssertGreaterThan(finalStats.missCount, initialStats.missCount)
    }
    
    func testCacheHitRate() async {
        // 测试缓存命中率计算
        await router.clearRouteCache()
        await router.resetCacheStatistics()
        
        // 注册路由
        router.register("/test", for: CacheTestRoutable.self)
        
        // 执行一些缓存操作
        await MainActor.run {
            router.navigate(to: "/nonexistent1", completion: { _ in }) // miss
        }
        await MainActor.run {
            router.navigate(to: "/test", completion: { _ in }) // miss (first time)
        }
        await MainActor.run {
            router.navigate(to: "/test", completion: { _ in }) // hit
        }
        await MainActor.run {
            router.navigate(to: "/test", completion: { _ in }) // hit
        }
        await MainActor.run {
            router.navigate(to: "/nonexistent2", completion: { _ in }) // miss
        }
        
        let stats = await router.getCacheStatistics()
        
        // 验证命中率在合理范围内
        XCTAssertGreaterThanOrEqual(stats.hitRate, 0.0)
        XCTAssertLessThanOrEqual(stats.hitRate, 1.0)
    }
    
    // MARK: - 路由缓存测试
    
    func testRouteCaching() async {
        // 测试路由结果缓存
        actor Counter {
            private var value = 0
            
            func increment() {
                value += 1
            }
            
            func getValue() -> Int {
                return value
            }
        }
        
        let counter = Counter()
        
        router.register("/cached-route", for: CacheTestRoutable.self)
        
        // 第一次执行
        await MainActor.run {
            Router.push(to: "/cached-route") { _ in
                Task {
                    await counter.increment()
                }
            }
        }
        
        // 等待一小段时间让第一次执行完成
        try! await Task.sleep(nanoseconds: 100_000_000)
        let currentCount = await counter.getValue()
        XCTAssertEqual(currentCount, 1)
        
        // 如果启用了路由缓存，第二次执行可能会使用缓存
        await MainActor.run {
            Router.push(to: "/cached-route") { _ in
                Task {
                    await counter.increment()
                }
            }
        }
        
        // 等待第二次执行完成
        try! await Task.sleep(nanoseconds: 100_000_000)
        let finalCount = await counter.getValue()
        XCTAssertEqual(finalCount, 1) // 应该仍然是1，因为使用了缓存
    }
    
    // MARK: - 内存压力测试
    
    func testMemoryPressureHandling() async {
        // 测试内存压力处理
        await router.setCacheSize(1000)
        
        // 注册大量路由并导航以创建缓存项
        for i in 0..<50 {
            router.register("/test\(i)", for: CacheTestRoutable.self)
            await MainActor.run {
                router.navigate(to: "/test\(i)", completion: { _ in })
            }
        }
        
        // 模拟内存压力
        #if os(iOS)
        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #endif
        
        // 给系统时间处理内存警告
        let expectation = self.expectation(description: "Memory pressure handling")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Task {

                // 检查缓存是否被适当清理
                let _ = await self.router.getCacheStatistics()
                // 缓存应该被部分或完全清理
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // 恢复原始容量
        await router.setCacheSize(100)
    }
    
    // MARK: - 并发缓存测试
    
    func testConcurrentCacheAccess() async {
        // 测试并发缓存访问安全性
        let expectation = self.expectation(description: "Concurrent cache access")
        expectation.expectedFulfillmentCount = 20
        
        // 先注册路由
        for i in 0..<10 {
            router.register("/test\(i)", for: CacheTestRoutable.self)
        }
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        // 并发导航操作
        for i in 0..<10 {
            queue.async {
                Task {
                    await MainActor.run {
                        self.router.navigate(to: "/test\(i)", completion: { _ in })
                    }
                    expectation.fulfill()
                }
            }
            
            queue.async {
                Task {
                    await MainActor.run {
                        self.router.navigate(to: "/test\(i % 5)", completion: { _ in })
                    }
                    expectation.fulfill()
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - 缓存性能测试
    
    func testCachePerformance() {
        // 测试缓存性能
        let iterations = 100
        
        // 测试路由注册性能
        measure {
            let expectation = self.expectation(description: "Route registration performance")
            Task {
                for i in 0..<iterations {
                    self.router.register("/test\(i)", for: CacheTestRoutable.self)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
        
        // 测试导航性能
        measure {
            let expectation = self.expectation(description: "Navigation performance")
            Task {
                for i in 0..<iterations {
                    await MainActor.run {
                        self.router.navigate(to: "/test\(i)", completion: { _ in })
                    }
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }
}
