import XCTest
@testable import RouterKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// 测试用的Routable实现
#if canImport(UIKit)
class PerformanceTestRoutable: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return PerformanceTestRoutable()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return PerformanceTestRoutable()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}
#else
class PerformanceTestRoutable: Routable {
    required init() {
        // macOS implementation
    }
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return await NSViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NSViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}
#endif

class RouterPerformanceTests: XCTestCase {
    
    var router: Router!
    
    override func setUp() async throws {
        try await super.setUp()
        router = Router.shared
        await router.clearRouteCache()
    }
    
    override func tearDown() async throws {
        await router.clearRouteCache()
        router = nil
        try await super.tearDown()
    }
    
    // MARK: - 路由注册性能测试
    
    func testRouteRegistrationPerformance() async {
        // 测试大量路由注册的性能
        let startTime = CFAbsoluteTimeGetCurrent()
        for i in 0..<1000 {
            try! await router.registerRoute("/route\(i)", for: PerformanceTestRoutable.self)
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Route registration took \(duration) seconds for 1000 routes")
    }
    
    func testParameterizedRouteRegistrationPerformance() async {
        // 测试参数化路由注册性能
        let startTime = CFAbsoluteTimeGetCurrent()
        for i in 0..<500 {
            try! await router.registerRoute("/user/:id/post/:postId/comment\(i)", for: PerformanceTestRoutable.self)
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Parameterized route registration took \(duration) seconds for 500 routes")
    }
    
    func testWildcardRouteRegistrationPerformance() async {
        // 测试通配符路由注册性能
        let startTime = CFAbsoluteTimeGetCurrent()
        for i in 0..<500 {
            try! await router.registerRoute("/files\(i)/*", for: PerformanceTestRoutable.self)
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Wildcard route registration took \(duration) seconds for 500 routes")
    }
    
    // MARK: - 路由匹配性能测试
    
    func testRouteMatchingPerformance() async {
        // 先注册大量路由
        for i in 0..<1000 {
            try! await router.registerRoute("/route\(i)", for: PerformanceTestRoutable.self)
        }
        
        // 测试路由匹配性能
        let startTime = CFAbsoluteTimeGetCurrent()
        for i in 0..<100 {
            await router.navigate(to: "/route\(i % 1000)", completion: { _ in })
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Route matching took \(duration) seconds for 100 navigations")
    }
    
    func testComplexRouteMatchingPerformance() async {
        // 注册复杂路由
        for i in 0..<200 {
            try! await router.registerRoute("/api/v1/users/:userId/posts/:postId/comments/:commentId/replies\(i)", for: PerformanceTestRoutable.self)
        }
        
        // 测试复杂路由匹配性能
        let startTime = CFAbsoluteTimeGetCurrent()
        for i in 0..<50 {
            await router.navigate(to: "/api/v1/users/123/posts/456/comments/789/replies\(i % 200)", completion: { _ in })
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Complex route matching took \(duration) seconds for 50 navigations")
    }
    
    func testWorstCaseRouteMatchingPerformance() async {
        // 创建最坏情况：大量相似但不匹配的路由
        for i in 0..<500 {
            try! await router.registerRoute("/similar/path/\(i)/end", for: PerformanceTestRoutable.self)
        }
        
        // 测试不匹配路由的性能（最坏情况）
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<50 {
            await router.navigate(to: "/similar/path/nonexistent/end", completion: { _ in })
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Worst case route matching took \(duration) seconds for 50 failed navigations")
    }
    
    // MARK: - 并发性能测试
    
    func testConcurrentRouteRegistrationPerformance() async {
        // 测试并发路由注册性能
        let expectation = self.expectation(description: "Concurrent registration")
        expectation.expectedFulfillmentCount = 10
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for threadIndex in 0..<10 {
            Task {
                for i in 0..<100 {
                    try! await self.router.registerRoute("/thread\(threadIndex)/route\(i)", for: PerformanceTestRoutable.self)
                }
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Concurrent registration took \(duration) seconds for 1000 routes")
    }
    
    func testConcurrentRouteExecutionPerformance() async {
        // 先注册路由
        for i in 0..<100 {
            try! await router.registerRoute("/concurrent\(i)", for: PerformanceTestRoutable.self)
        }
        
        let expectation = self.expectation(description: "Concurrent execution")
        expectation.expectedFulfillmentCount = 100
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 并发执行路由
        for i in 0..<100 {
            Task {
                await self.router.navigate(to: "/concurrent\(i)", completion: { _ in
                    expectation.fulfill()
                })
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Concurrent execution took \(duration) seconds for 100 routes")
    }
    
    // MARK: - 内存使用测试
    
    func testMemoryUsageWithManyRoutes() async {
        // 测试大量路由的内存使用
        let initialMemory = getMemoryUsage()
        
        // 注册大量路由
        for i in 0..<10000 {
            try! await router.registerRoute("/memory-test/route\(i)/:param1/:param2", for: PerformanceTestRoutable.self)
        }
        
        let afterRegistrationMemory = getMemoryUsage()
        let memoryIncrease = afterRegistrationMemory - initialMemory
        
        print("Memory increase after 10000 routes: \(memoryIncrease) MB")
        
        // 清理并检查内存是否释放
        await router.clearRouteCache()
        
        // 给GC一些时间
        for _ in 0..<3 {
            autoreleasepool {
                // 触发内存回收
            }
        }
        
        let afterCleanupMemory = getMemoryUsage()
        let memoryRecovered = afterRegistrationMemory - afterCleanupMemory
        
        print("Memory recovered after cleanup: \(memoryRecovered) MB")
        
        // 验证内存泄漏不严重
        XCTAssertLessThan(memoryIncrease, 100, "Memory usage should be reasonable")
    }
    
    // MARK: - 缓存性能测试
    
    func testCachePerformanceWithHighThroughput() async {
        // 测试高吞吐量下的缓存性能
        let router = Router.shared
        
        let startTime = CFAbsoluteTimeGetCurrent()
        for i in 0..<10000 {
            let url = "/test\(i % 1000)" // 重复使用1000个URL
            
            // 注册路由以便缓存
            try? await router.registerRoute(url, for: PerformanceTestRoutable.self)
            
            // 执行路由以触发缓存
            await router.navigate(to: url) { _ in }
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Cache performance test took \(duration) seconds for 10000 operations")
    }
    
    func testCacheEvictionPerformance() async {
        // 测试缓存淘汰性能
        let router = Router.shared
        
        // 设置较小的缓存大小以触发淘汰
        await router.setCacheSize(100)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        // 添加超过容量的项目，触发淘汰
        for i in 0..<2000 {
            let url = "/test\(i)"
            
            // 注册路由以便缓存
            try? await router.registerRoute(url, for: PerformanceTestRoutable.self)
            
            // 执行路由以触发缓存
            await router.navigate(to: url) { _ in }
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        print("Cache eviction test took \(duration) seconds for 2000 operations")
        
        // 恢复默认缓存大小
        await router.setCacheSize(1000)
    }
    
    // MARK: - 边界条件测试
    
    func testExtremelyLongURL() async {
        // 测试极长URL的处理
        let longPath = String(repeating: "a", count: 10000)
        let expectation = self.expectation(description: "Long URL handling")
        
        try! await router.registerRoute("/long/*", for: PerformanceTestRoutable.self)
        
        await MainActor.run {
            Router.push(to: "/long/\(longPath)", completion: { _ in
                expectation.fulfill()
            })
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testManyParameters() async {
        // 测试大量参数的路由
        var pattern = "/test"
        for i in 0..<100 {
            pattern += "/:param\(i)"
        }
        
        let expectation = self.expectation(description: "Many parameters")
        
        try! await router.registerRoute(pattern, for: PerformanceTestRoutable.self)
        
        var urlBuilder = "/test"
        for i in 0..<100 {
            urlBuilder += "/value\(i)"
        }
        let url = urlBuilder
        
        await MainActor.run {
            Router.push(to: url, completion: { _ in
                expectation.fulfill()
            })
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testDeepNesting() async {
        // 测试深度嵌套的路由
        let deepPath = (0..<50).map { "level\($0)" }.joined(separator: "/")
        let pattern = "/" + deepPath
        
        let expectation = self.expectation(description: "Deep nesting")
        
        try! await router.registerRoute(pattern, for: PerformanceTestRoutable.self)
        
        await MainActor.run {
            Router.push(to: pattern, completion: { _ in
                expectation.fulfill()
            })
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 压力测试
    
    func testHighFrequencyRouting() async {
        // 测试高频路由调用
        try! await router.registerRoute("/high-frequency", for: PerformanceTestRoutable.self)
        
        let expectation = self.expectation(description: "High frequency routing")
        expectation.expectedFulfillmentCount = 10000
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<10000 {
            await MainActor.run {
                Router.push(to: "/high-frequency", completion: { _ in
                    expectation.fulfill()
                })
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        let routesPerSecond = 10000.0 / duration
        print("High frequency routing: \(routesPerSecond) routes/second")
    }
    
    func testMemoryPressureHandling() async {
        // 测试内存压力下的表现
        let expectation = self.expectation(description: "Memory pressure handling")
        
        // 注册大量路由
        for i in 0..<5000 {
            try! await router.registerRoute("/pressure\(i)", for: PerformanceTestRoutable.self)
        }
        
        // 模拟内存压力（在macOS上使用不同的通知）
        #if os(iOS)
        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #endif
        
        // 在内存压力下继续路由
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Task {
                await MainActor.run {
                    Router.push(to: "/pressure1000", completion: { result in
                        switch result {
                        case .success:
                            expectation.fulfill()
                        case .failure:
                            XCTFail("Routing should work under memory pressure")
                        }
                    })
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - 辅助方法
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0 // MB
        } else {
            return 0
        }
    }
}