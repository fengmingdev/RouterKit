//
//  RouterInterceptorTests.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import XCTest
@testable import RouterKit
#if canImport(UIKit)
import UIKit

class TestInterceptorViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        let vc = TestInterceptorViewController()
        vc.configure(with: context.parameters)
        return vc
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = TestInterceptorViewController()
        vc.configure(with: parameters)
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
}

class TestRedirectedViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        let vc = TestRedirectedViewController()
        vc.configure(with: context.parameters)
        return vc
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = TestRedirectedViewController()
        vc.configure(with: parameters)
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
}

class TestParameterViewController: UIViewController, Routable {
    var receivedParameters: RouterParameters?
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        self.receivedParameters = parameters
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        let vc = TestParameterViewController()
        vc.configure(with: context.parameters)
        return vc
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = TestParameterViewController()
        vc.configure(with: parameters)
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
}
#elseif canImport(AppKit)
import AppKit

class TestInterceptorViewController: NSViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        let vc = TestInterceptorViewController()
        vc.configure(with: context.parameters)
        return vc
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        let vc = TestInterceptorViewController()
        vc.configure(with: parameters)
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
}

class TestRedirectedViewController: NSViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        let vc = TestRedirectedViewController()
        vc.configure(with: context.parameters)
        return vc
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        let vc = TestRedirectedViewController()
        vc.configure(with: parameters)
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
}

class TestParameterViewController: NSViewController, Routable {
    var receivedParameters: RouterParameters?
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        self.receivedParameters = parameters
    }
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        let vc = TestParameterViewController()
        vc.configure(with: context.parameters)
        return vc
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        let vc = TestParameterViewController()
        vc.configure(with: parameters)
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
}
#endif

/// 路由拦截器测试类
@available(iOS 13.0, macOS 10.15, *)
class RouterInterceptorTests: XCTestCase {
    
    var router: Router { Router.shared }
    
    override func setUp() {
        super.setUp()
        
        // 注册测试模块
        Task {
            await router.registerModule(TestInterceptorModule())
        }
    }
    
    override func tearDown() {
        Task {
            await router.unregisterModule("TestInterceptorModule")
            // 手动移除所有拦截器
            let interceptors = await router.state.getInterceptors()
            for interceptor in interceptors {
                await router.removeInterceptor(interceptor)
            }
            // 清理路由（如果需要的话）
        }
        // router是共享实例，不需要设置为nil
        super.tearDown()
    }
    
    // MARK: - 基本拦截器测试
    
    /// 测试基本拦截器注册和移除
    func testBasicInterceptorRegistration() async {
        let interceptor = TestBasicInterceptor()
        
        // 添加拦截器
        await router.addInterceptor(interceptor)
        let interceptors = await router.state.getInterceptors()
        XCTAssertEqual(interceptors.count, 1)
        XCTAssertTrue(interceptors.first === interceptor)
        
        // 移除拦截器
        await router.removeInterceptor(interceptor)
        let interceptorsAfterRemoval = await router.state.getInterceptors()
        XCTAssertEqual(interceptorsAfterRemoval.count, 0)
    }
    
    /// 测试拦截器优先级排序
    func testInterceptorPriority() async {
        let lowPriorityInterceptor = TestPriorityInterceptor(priority: .low)
        let highPriorityInterceptor = TestPriorityInterceptor(priority: .high)
        let normalPriorityInterceptor = TestPriorityInterceptor(priority: .normal)
        
        // 按随机顺序添加拦截器
        await router.addInterceptor(normalPriorityInterceptor)
        await router.addInterceptor(highPriorityInterceptor)
        await router.addInterceptor(lowPriorityInterceptor)
        
        let allInterceptors = await router.state.getInterceptors()
        let sortedInterceptors = allInterceptors.sorted { lhs, rhs in
            return lhs.priority > rhs.priority
        }
        
        // 验证优先级排序（高优先级在前）
        XCTAssertEqual(sortedInterceptors.count, 3)
        if let first = sortedInterceptors.first as? TestPriorityInterceptor {
            XCTAssertEqual(first.priority, InterceptorPriority.high)
        }
    }
    
    /// 测试重复添加拦截器
    func testDuplicateInterceptorAddition() async {
        let interceptor = TestBasicInterceptor()
        
        // 多次添加同一个拦截器
        await router.addInterceptor(interceptor)
        await router.addInterceptor(interceptor)
        await router.addInterceptor(interceptor)
        
        let interceptors = await router.state.getInterceptors()
        XCTAssertEqual(interceptors.count, 1, "同一个拦截器不应该被重复添加")
    }
    
    // MARK: - 拦截器功能测试
    
    /// 测试拦截器允许导航
    func testInterceptorAllowNavigation() async {
        let expectation = self.expectation(description: "Navigation should succeed")
        let interceptor = TestAllowInterceptor()
        
        await router.addInterceptor(interceptor)
        
        do {
            try await router.registerRoute("/test", for: TestInterceptorViewController.self)
            
            await MainActor.run {
                Router.push(to: "/test") { result in
                    switch result {
                    case .success:
                        expectation.fulfill()
                    case .failure:
                        XCTFail("导航应该成功")
                    }
                }
            }
            
            await fulfillment(of: [expectation], timeout: 2.0)
            XCTAssertTrue(interceptor.wasCalled, "拦截器应该被调用")
        } catch {
            XCTFail("路由注册失败: \(error)")
        }
    }
    
    /// 测试拦截器阻止导航
    func testInterceptorBlockNavigation() async {
        let expectation = self.expectation(description: "Navigation should be blocked")
        let interceptor = TestBlockInterceptor()
        
        await router.addInterceptor(interceptor)
        
        do {
            try await router.registerRoute("/blocked", for: TestInterceptorViewController.self)
            
            await MainActor.run {
                Router.push(to: "/blocked") { result in
                    switch result {
                    case .success:
                        XCTFail("导航应该被阻止")
                    case .failure:
                        expectation.fulfill()
                    }
                }
            }
            
            await fulfillment(of: [expectation], timeout: 2.0)
            XCTAssertTrue(interceptor.wasCalled, "拦截器应该被调用")
        } catch {
            XCTFail("路由注册失败: \(error)")
        }
    }
    
    /// 测试拦截器重定向
    func testInterceptorRedirect() async {
        let expectation = self.expectation(description: "Navigation should redirect")
        let interceptor = TestRedirectInterceptor(redirectTo: "/redirected")
        
        await router.addInterceptor(interceptor)
        
        do {
            try await router.registerRoute("/original", for: TestInterceptorViewController.self)
            try await router.registerRoute("/redirected", for: TestRedirectedViewController.self)
            
            await MainActor.run {
                Router.push(to: "/original") { result in
                    switch result {
                    case .success:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("重定向导航失败: \(error)")
                    }
                }
            }
            
            await fulfillment(of: [expectation], timeout: 2.0)
            XCTAssertTrue(interceptor.wasCalled, "拦截器应该被调用")
        } catch {
            XCTFail("路由注册失败: \(error)")
        }
    }
    
    // MARK: - 参数修改测试
    
    /// 测试拦截器修改参数
    func testInterceptorModifyParameters() async {
        let expectation = self.expectation(description: "Parameters should be modified")
        let interceptor = TestParameterModifyInterceptor()
        
        await router.addInterceptor(interceptor)
        
        do {
            try await router.registerRoute("/user/:id", for: TestParameterViewController.self)
            
            await MainActor.run {
                Router.push(to: "/user/123", parameters: ["name": "John"]) { result in
                    switch result {
                    case .success:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("导航失败: \(error)")
                    }
                }
            }
            
            await fulfillment(of: [expectation], timeout: 2.0)
            XCTAssertTrue(interceptor.wasCalled, "拦截器应该被调用")
        } catch {
            XCTFail("路由注册失败: \(error)")
        }
    }
    
    // MARK: - 异步拦截器测试
    
    /// 测试异步拦截器
    func testAsyncInterceptor() async {
        let expectation = self.expectation(description: "Async interceptor should work")
        let interceptor = TestAsyncInterceptor()
        
        await router.addInterceptor(interceptor)
        
        do {
            try await router.registerRoute("/async", for: TestInterceptorViewController.self)
            
            Task {
                await MainActor.run {
                    Router.shared.navigate(to: "/async") { _ in
                        expectation.fulfill()
                    }
                }
            }
            
            await fulfillment(of: [expectation], timeout: 3.0)
            XCTAssertTrue(interceptor.wasCalled, "异步拦截器应该被调用")
        } catch {
            XCTFail("路由注册失败: \(error)")
        }
    }
    
    // MARK: - 多拦截器测试
    
    /// 测试多个拦截器按优先级执行
    func testMultipleInterceptorsExecution() async {
        let expectation = self.expectation(description: "Multiple interceptors should execute in order")
        
        let interceptor1 = TestOrderInterceptor(order: 1, priority: .highest)
        let interceptor2 = TestOrderInterceptor(order: 2, priority: .high)
        let interceptor3 = TestOrderInterceptor(order: 3, priority: .normal)
        
        await router.addInterceptor(interceptor3) // 添加顺序与优先级不同
        await router.addInterceptor(interceptor1)
        await router.addInterceptor(interceptor2)
        
        do {
            try await router.registerRoute("/multi", for: TestInterceptorViewController.self)
            
            Task { @MainActor in
                Router.push(to: "/multi") { result in
                    switch result {
                    case .success:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("多拦截器导航失败: \(error)")
                    }
                }
            }
            
            await fulfillment(of: [expectation], timeout: 2.0)
            
            // 验证执行顺序
            XCTAssertTrue(interceptor1.wasCalled)
            XCTAssertTrue(interceptor2.wasCalled)
            XCTAssertTrue(interceptor3.wasCalled)
        } catch {
            XCTFail("路由注册失败: \(error)")
        }
    }
    
    /// 测试拦截器链中断
    func testInterceptorChainBreak() async {
        let expectation = self.expectation(description: "Interceptor chain should break")
        
        let allowInterceptor = TestAllowInterceptor()
        let blockInterceptor = TestBlockInterceptor() // 这个会阻止导航
        let neverCalledInterceptor = TestNeverCalledInterceptor()
        
        // 按优先级添加：allow(高) -> block(中) -> neverCalled(低)
        allowInterceptor.priority = .highest
        blockInterceptor.priority = .high
        neverCalledInterceptor.priority = .normal
        
        await router.addInterceptor(allowInterceptor)
        await router.addInterceptor(blockInterceptor)
        await router.addInterceptor(neverCalledInterceptor)
        
        do {
            try await router.registerRoute("/chain", for: TestInterceptorViewController.self)
            
            Task { @MainActor in
                Router.push(to: "/chain") { result in
                    switch result {
                    case .success:
                        XCTFail("导航应该被阻止")
                    case .failure:
                        expectation.fulfill()
                    }
                }
            }
            
            await fulfillment(of: [expectation], timeout: 2.0)
            
            XCTAssertTrue(allowInterceptor.wasCalled, "第一个拦截器应该被调用")
            XCTAssertTrue(blockInterceptor.wasCalled, "阻止拦截器应该被调用")
            XCTAssertFalse(neverCalledInterceptor.wasCalled, "后续拦截器不应该被调用")
        } catch {
            XCTFail("路由注册失败: \(error)")
        }
    }
    
    // MARK: - 并发安全测试
    
    /// 测试并发添加拦截器
    func testConcurrentInterceptorAddition() async {
        let expectation = self.expectation(description: "Concurrent interceptor addition")
        expectation.expectedFulfillmentCount = 10
        
        // 并发添加多个拦截器
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let interceptor = TestBasicInterceptor()
                    interceptor.identifier = "interceptor_\(i)"
                    await self.router.addInterceptor(interceptor)
                    expectation.fulfill()
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 3.0)
        
        let interceptors = await router.state.getInterceptors()
        XCTAssertEqual(interceptors.count, 10, "所有拦截器都应该被添加")
    }
    
    // MARK: - 性能测试
    
    /// 测试大量拦截器的性能
    func testInterceptorPerformance() async {
        // 添加大量拦截器
        for i in 0..<100 {
            let interceptor = TestBasicInterceptor()
            interceptor.identifier = "perf_interceptor_\(i)"
            await self.router.addInterceptor(interceptor)
        }
        
        #if canImport(UIKit)
        do {
            try await self.router.registerRoute("/perf", for: TestInterceptorViewController.self)
        } catch {
            XCTFail("性能测试设置失败: \(error)")
        }
        #endif
        
        measure {
            let expectation = self.expectation(description: "Performance test")
            
            Task {
                #if canImport(UIKit)
                _ = await self.router.navigate(to: "/perf")
                #endif
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - 错误处理测试
    
    /// 测试拦截器异常处理
    func testInterceptorErrorHandling() async {
        let expectation = self.expectation(description: "Error handling should work")
        let interceptor = TestErrorInterceptor()
        
        await self.router.addInterceptor(interceptor)
        
        #if canImport(UIKit)
        do {
            try await self.router.registerRoute("/error", for: TestInterceptorViewController.self)
            
            Task { @MainActor in
                Router.push(to: "/error") { result in
                    switch result {
                    case .success:
                        XCTFail("导航应该失败")
                    case .failure:
                        expectation.fulfill()
                    }
                }
            }
            
            await fulfillment(of: [expectation], timeout: 2.0)
        } catch {
            XCTFail("路由注册失败: \(error)")
        }
        #else
        // 在macOS上跳过此测试
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 0.1)
        #endif
    }
    
    /// 测试清除所有拦截器
    func testRemoveAllInterceptors() async {
        // 添加多个拦截器
        for i in 0..<5 {
            let interceptor = TestBasicInterceptor()
            interceptor.identifier = "remove_all_\(i)"
            await self.router.addInterceptor(interceptor)
        }
        
        let interceptorsBeforeRemoval = await self.router.state.getInterceptors()
        XCTAssertEqual(interceptorsBeforeRemoval.count, 5)
        
        // 清除所有拦截器
        let interceptors = await self.router.state.getInterceptors()
        for interceptor in interceptors {
            await self.router.removeInterceptor(interceptor)
        }
        
        let interceptorsAfterRemoval = await self.router.state.getInterceptors()
        XCTAssertEqual(interceptorsAfterRemoval.count, 0)
    }
}

// MARK: - 测试辅助类

/// 测试模块
class TestInterceptorModule: ModuleProtocol, @unchecked Sendable {
    let moduleName = "TestInterceptorModule"
    let dependencies: [ModuleDependency] = []
    var lastUsedTime: Date = Date()
    
    required init() {
        // 模块初始化
    }
    
    func load(completion: @escaping (Bool) -> Void) {
        // 模块加载
        completion(true)
    }
    
    func unload() {
        // 模块卸载
    }
    
    func suspend() {
        // 模块挂起
    }
    
    func resume() {
        // 模块恢复
    }
}

/// 基础测试拦截器
class TestBasicInterceptor: BaseInterceptor {
    var identifier: String = "test_basic"
    var wasCalled = false
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        completion(true, nil, nil, nil, nil)
    }
}

/// 优先级测试拦截器
class TestPriorityInterceptor: RouterInterceptor {
    var priority: InterceptorPriority
    var isAsync: Bool
    var identifier: String = "test_priority"
    var wasCalled = false
    
    init(priority: InterceptorPriority = .normal, isAsync: Bool = false) {
        self.priority = priority
        self.isAsync = isAsync
    }
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        completion(true, nil, nil, nil, nil)
    }
}

/// 允许导航的拦截器
class TestAllowInterceptor: BaseInterceptor {
    var identifier: String = "test_allow"
    var wasCalled = false
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        completion(true, nil, nil, nil, nil)
    }
}

/// 阻止导航的拦截器
class TestBlockInterceptor: BaseInterceptor {
    var identifier: String = "test_block"
    var wasCalled = false
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        completion(false, nil, "Navigation blocked by test", nil, nil)
    }
}

/// 重定向拦截器
class TestRedirectInterceptor: BaseInterceptor {
    var identifier: String = "test_redirect"
    var wasCalled = false
    let redirectTo: String
    
    init(redirectTo: String) {
        self.redirectTo = redirectTo
        super.init()
    }
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        completion(false, redirectTo, nil, nil, nil)
    }
}

/// 参数修改拦截器
class TestParameterModifyInterceptor: BaseInterceptor {
    var identifier: String = "test_param_modify"
    var wasCalled = false
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        var newParams = parameters
        newParams["modified"] = "true"
        newParams["timestamp"] = "\(Date().timeIntervalSince1970)"
        completion(true, nil, nil, newParams, nil)
    }
}

/// 异步拦截器
class TestAsyncInterceptor: BaseInterceptor {
    var identifier: String = "test_async"
    var wasCalled = false
    
    override init(priority: InterceptorPriority = .normal, isAsync: Bool = true) {
        super.init(priority: priority, isAsync: isAsync)
    }
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        
        // 模拟异步操作
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            completion(true, nil, nil, nil, nil)
        }
    }
}

/// 执行顺序测试拦截器
class TestOrderInterceptor: RouterInterceptor {
    var priority: InterceptorPriority
    var isAsync: Bool = false
    var identifier: String
    var wasCalled = false
    let order: Int
    
    init(order: Int, priority: InterceptorPriority) {
        self.order = order
        self.identifier = "test_order_\(order)"
        self.priority = priority
    }
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        print("Interceptor \(order) executed")
        completion(true, nil, nil, nil, nil)
    }
}

/// 永不被调用的拦截器（用于测试链中断）
class TestNeverCalledInterceptor: BaseInterceptor {
    var identifier: String = "test_never_called"
    var wasCalled = false
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        wasCalled = true
        completion(true, nil, nil, nil, nil)
    }
}

/// 错误拦截器
class TestErrorInterceptor: BaseInterceptor {
    var identifier: String = "test_error"
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        completion(false, nil, "Simulated error", nil, nil)
    }
}

#if canImport(UIKit)
// MARK: - 测试视图控制器

/// 基础测试视图控制器
class TestInterceptorViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}

/// 重定向目标视图控制器
class TestRedirectedViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}

/// 参数测试视图控制器
class TestParameterViewController: UIViewController, Routable {
    var receivedParameters: RouterParameters?
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        self.receivedParameters = parameters
    }
}
#endif