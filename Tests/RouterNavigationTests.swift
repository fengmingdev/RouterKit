import XCTest
#if canImport(UIKit)
import UIKit
#endif
@testable import RouterKit

// 测试用的Routable实现
#if canImport(UIKit)
class TestRoutable: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return TestRoutable()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return TestRoutable()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}
#else
class TestRoutable: NSViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return TestRoutable()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return TestRoutable()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}
#endif

class RouterNavigationTests: XCTestCase {
    
    var router: Router!
    #if canImport(UIKit)
    var mockViewController: UIViewController!
    #endif
    
    override func setUp() async throws {
        try await super.setUp()
        router = Router.shared
        #if canImport(UIKit)
        mockViewController = UIViewController()
        #endif
        
        // 清理之前的注册
        await router.clearRouteCache()
    }
    
    override func tearDown() async throws {
        await router.clearRouteCache()
        router = nil
        #if canImport(UIKit)
        mockViewController = nil
        #endif
        try await super.tearDown()
    }
    
    // MARK: - 基础路由注册和匹配测试
    
    func testBasicRouteRegistration() async {
        // 测试基础路由注册
        let expectation = self.expectation(description: "Route registration")
        
        router.register("/test", for: TestRoutable.self)
        
        await MainActor.run {
            router.navigate(to: "/test") { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Navigation should succeed")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testParameterizedRoute() async {
        // 测试参数化路由
        let expectation = self.expectation(description: "Parameterized route")
        
        router.register("/user/:id", for: TestRoutable.self)
        
        await MainActor.run {
            router.navigate(to: "/user/123") { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Navigation should succeed")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testWildcardRoute() async {
        // 测试通配符路由
        let expectation = self.expectation(description: "Wildcard route")
        
        router.register("/files/*", for: TestRoutable.self)
        
        await MainActor.run {
            router.navigate(to: "/files/documents/test.pdf") { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Navigation should succeed")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testQueryParameters() async {
        // 测试查询参数
        let expectation = self.expectation(description: "Query parameters")
        
        router.register("/search", for: TestRoutable.self)
        
        await MainActor.run {
            router.navigate(to: "/search?q=test&page=1") { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Navigation should succeed")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 导航测试
    
    func testNavigationWithViewController() async {
        // 测试带视图控制器的导航
        let expectation = self.expectation(description: "Navigation with ViewController")
        
        router.register("/profile", for: TestRoutable.self)
        
        await MainActor.run {
            router.navigate(to: "/profile") { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Navigation should succeed")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testNavigationWithCompletion() async {
        // 测试带完成回调的导航
        let completionExpectation = self.expectation(description: "Navigation completion")
        
        router.register("/settings", for: TestRoutable.self)
        
        await MainActor.run {
            router.navigate(to: "/settings") { result in
                switch result {
                case .success:
                    completionExpectation.fulfill()
                case .failure:
                    XCTFail("Navigation should succeed")
                }
            }
        }
        
        await fulfillment(of: [completionExpectation], timeout: 1.0)
    }
    
    func testNavigationFailure() async {
        // 测试导航失败情况
        let expectation = self.expectation(description: "Navigation failure")
        
        await MainActor.run {
            router.navigate(to: "/nonexistent") { result in
                switch result {
                case .success:
                    XCTFail("Navigation should fail for unregistered route")
                case .failure(let error):
                    XCTAssertTrue(error is RouterError)
                    expectation.fulfill()
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 路由优先级测试
    
    func testRoutePriority() async {
        // 测试路由优先级
        let expectation = self.expectation(description: "Route priority")
        
        // 注册低优先级路由
        router.register("/api/*", for: TestRoutable.self)
        
        // 注册高优先级路由
        router.register("/api/users", for: TestRoutable.self)
        
        await MainActor.run {
            router.navigate(to: "/api/users") { _ in
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 拦截器测试
    
    func testInterceptor() async {
        // 测试拦截器功能
        let interceptorExpectation = self.expectation(description: "Interceptor execution")
        let routeExpectation = self.expectation(description: "Route execution")
        
        let interceptor = TestInterceptor { context in
            interceptorExpectation.fulfill()
            return true // 允许继续
        }
        
        await router.addInterceptor(interceptor)
        
        router.register("/intercepted", for: TestRoutable.self)
        
        await MainActor.run {
            Router.push(to: "/intercepted") { _ in
                routeExpectation.fulfill()
            }
        }
        
        await fulfillment(of: [interceptorExpectation, routeExpectation], timeout: 1.0)
    }
    
    func testInterceptorBlocking() async {
        // 测试拦截器阻止导航
        let interceptorExpectation = self.expectation(description: "Interceptor execution")
        
        let interceptor = TestInterceptor { context in
            interceptorExpectation.fulfill()
            return false // 阻止继续
        }
        
        await router.addInterceptor(interceptor)
        
        router.register("/blocked", for: TestRoutable.self)
        
        await MainActor.run {
            Router.push(to: "/blocked") { _ in }
        }
        
        await fulfillment(of: [interceptorExpectation], timeout: 1.0)
    }
    
    // MARK: - 错误处理测试
    
    func testInvalidURL() async {
        // 测试无效URL处理
        let expectation = self.expectation(description: "Invalid URL handling")
        
        await MainActor.run {
            Router.push(to: "") { result in
                 switch result {
                 case .failure:
                     expectation.fulfill()
                 case .success:
                     XCTFail("Empty URL should fail")
                 }
             }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 并发安全测试
    
    func testConcurrentRouting() async {
        // 测试并发路由安全性
        let expectation = self.expectation(description: "Concurrent routing")
        expectation.expectedFulfillmentCount = 10
        
        router.register("/concurrent", for: NavigationTestRoutable.self)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    await MainActor.run {
                        Router.push(to: "/concurrent?id=\(i)") { _ in
                             expectation.fulfill()
                         }
                    }
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
}

// MARK: - 测试辅助类

#if canImport(UIKit) || canImport(AppKit)
class NavigationTestRoutable: PlatformViewController, Routable {
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
        return NavigationTestRoutable()
    }
    
    #if canImport(UIKit)
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return NavigationTestRoutable()
    }
    #else
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NavigationTestRoutable()
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

class TestInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .normal
    var isAsync: Bool = false
    let handler: (RouteContext) -> Bool
    
    init(handler: @escaping (RouteContext) -> Bool) {
        self.handler = handler
    }
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        let context = RouteContext(url: url, parameters: parameters, moduleName: "TestModule")
        let shouldContinue = handler(context)
        completion(shouldContinue, nil, nil, nil, nil)
    }
}