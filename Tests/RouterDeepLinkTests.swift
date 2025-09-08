//
//  RouterDeepLinkTests.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import XCTest
#if canImport(UIKit)
import UIKit
#endif
@testable import RouterKit

// 测试用的Routable实现
#if canImport(UIKit)
class DeepLinkTestViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return DeepLinkTestViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return DeepLinkTestViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}
#else
class DeepLinkTestViewController: NSViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return DeepLinkTestViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return DeepLinkTestViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}
#endif

@available(iOS 13.0, macOS 10.15, *)
class RouterDeepLinkTests: XCTestCase {
    
    var deepLinkHandler: DeepLinkHandler!
    var router: Router!
    
    override func setUp() async throws {
        try await super.setUp()
        router = Router.shared
        deepLinkHandler = DeepLinkHandler.shared
        
        // 注册测试路由
        try await router.registerRoute("/deeplink/test", for: DeepLinkTestViewController.self)
        try await router.registerRoute("/deeplink/user/:id", for: DeepLinkTestViewController.self)
    }
    
    override func tearDown() async throws {
        await router.clearRouteCache()
        router = nil
        deepLinkHandler = nil
        try await super.tearDown()
    }
    
    // MARK: - URL Scheme 注册测试
    
    func testRegisterURLSchemes() {
        // 测试注册URL schemes
        let schemes = ["myapp", "testapp"]
        deepLinkHandler.registerURLSchemes(schemes)
        
        // 验证注册成功（通过尝试处理URL来验证）
        let expectation = XCTestExpectation(description: "URL scheme registration")
        
        Task {
            let url = URL(string: "myapp://deeplink/test")!
            let result = await deepLinkHandler.handle(url: url, options: nil)
            XCTAssertTrue(result, "应该成功处理已注册的URL scheme")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUnregisteredURLScheme() {
        // 测试未注册的URL scheme应该被拒绝
        let expectation = XCTestExpectation(description: "Unregistered URL scheme rejection")
        
        Task {
            let url = URL(string: "unregistered://deeplink/test")!
            let result = await deepLinkHandler.handle(url: url, options: nil)
            XCTAssertFalse(result, "应该拒绝未注册的URL scheme")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - 深度链接处理测试
    
    func testBasicDeepLinkHandling() {
        // 测试基本深度链接处理
        deepLinkHandler.registerURLSchemes(["testapp"])
        
        let expectation = XCTestExpectation(description: "Basic deep link handling")
        
        Task {
            let url = URL(string: "testapp://deeplink/test")!
            let result = await deepLinkHandler.handle(url: url, options: nil)
            XCTAssertTrue(result, "应该成功处理基本深度链接")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testParameterizedDeepLink() {
        // 测试带参数的深度链接
        deepLinkHandler.registerURLSchemes(["testapp"])
        
        let expectation = XCTestExpectation(description: "Parameterized deep link")
        
        Task {
            let url = URL(string: "testapp://deeplink/user/123")!
            let result = await deepLinkHandler.handle(url: url, options: nil)
            XCTAssertTrue(result, "应该成功处理带参数的深度链接")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDeepLinkWithQueryParameters() {
        // 测试带查询参数的深度链接
        deepLinkHandler.registerURLSchemes(["testapp"])
        
        let expectation = XCTestExpectation(description: "Deep link with query parameters")
        
        Task {
            let url = URL(string: "testapp://deeplink/test?param1=value1&param2=value2")!
            let result = await deepLinkHandler.handle(url: url, options: nil)
            XCTAssertTrue(result, "应该成功处理带查询参数的深度链接")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - 安全性测试
    
    func testInvalidURLRejection() {
        // 测试无效URL的拒绝
        let expectation = XCTestExpectation(description: "Invalid URL rejection")
        
        Task {
            // 测试没有scheme的URL
            let invalidURL = URL(string: "deeplink/test")!
            let result = await deepLinkHandler.handle(url: invalidURL, options: nil)
            XCTAssertFalse(result, "应该拒绝没有scheme的URL")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMaxPathDepthLimit() {
        // 测试路径深度限制
        deepLinkHandler.registerURLSchemes(["testapp"])
        deepLinkHandler.setMaximumPathDepth(3)
        
        let expectation = XCTestExpectation(description: "Path depth limit")
        
        Task {
            // 创建超过深度限制的URL
            let deepURL = URL(string: "testapp://level1/level2/level3/level4/level5")!
            let result = await deepLinkHandler.handle(url: deepURL, options: nil)
            XCTAssertFalse(result, "应该拒绝超过深度限制的URL")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testTrustedSourcesHandling() {
        // 测试信任来源处理
        deepLinkHandler.registerURLSchemes(["testapp"])
        deepLinkHandler.addTrustedSources(["com.trusted.app"])
        
        let expectation = XCTestExpectation(description: "Trusted sources handling")
        
        Task {
            let url = URL(string: "testapp://deeplink/test")!
            let options: [UIApplication.OpenURLOptionsKey: Any] = [
                .sourceApplication: "com.trusted.app"
            ]
            let result = await deepLinkHandler.handle(url: url, options: options)
            XCTAssertTrue(result, "应该接受来自信任来源的URL")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - 错误处理测试
    
    func testMalformedURLHandling() {
        // 测试格式错误的URL处理
        deepLinkHandler.registerURLSchemes(["testapp"])
        
        let expectation = XCTestExpectation(description: "Malformed URL handling")
        
        Task {
            // 测试包含非法字符的URL
            let malformedURL = URL(string: "testapp://deeplink/test with spaces")!
            let _ = await deepLinkHandler.handle(url: malformedURL, options: nil)
            // 根据实际实现决定是否应该处理这种URL
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testEmptyPathHandling() {
        // 测试空路径处理
        deepLinkHandler.registerURLSchemes(["testapp"])
        
        let expectation = XCTestExpectation(description: "Empty path handling")
        
        Task {
            let url = URL(string: "testapp://")!
            let _ = await deepLinkHandler.handle(url: url, options: nil)
            // 根据实际需求决定是否应该处理空路径
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - 性能测试
    
    func testDeepLinkHandlingPerformance() {
        // 测试深度链接处理性能
        deepLinkHandler.registerURLSchemes(["testapp"])
        
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            Task {
                for i in 0..<100 {
                    let url = URL(string: "testapp://deeplink/test/\(i)")!
                    await deepLinkHandler.handle(url: url, options: nil)
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - 并发测试
    
    func testConcurrentDeepLinkHandling() {
        // 测试并发深度链接处理
        deepLinkHandler.registerURLSchemes(["testapp"])
        
        let expectation = XCTestExpectation(description: "Concurrent deep link handling")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            Task {
                let url = URL(string: "testapp://deeplink/test/\(i)")!
                let result = await deepLinkHandler.handle(url: url, options: nil)
                XCTAssertTrue(result, "并发处理应该成功")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}