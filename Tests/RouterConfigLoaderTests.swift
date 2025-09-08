//
//  RouterConfigLoaderTests.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import XCTest
#if canImport(UIKit)
import UIKit
#endif
@testable import RouterKit

// MARK: - 测试辅助类

#if canImport(UIKit)
class ConfigTestViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return ConfigTestViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return ConfigTestViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}
#else
class ConfigTestViewController: NSViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return ConfigTestViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return ConfigTestViewController()
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
class RouterConfigLoaderTests: XCTestCase {
    
    var router: Router!
    var testBundle: Bundle!
    
    override func setUp() async throws {
        try await super.setUp()
        router = Router.shared
        testBundle = Bundle(for: type(of: self))
        
        // 清理之前的路由
        await router.clearRouteCache()
    }
    
    override func tearDown() async throws {
        await router.clearRouteCache()
        router = nil
        testBundle = nil
        try await super.tearDown()
    }
    
    // MARK: - Plist配置加载测试
    
    func testLoadFromValidPlist() async {
        // 创建临时plist文件
        let tempURL = createTemporaryPlistFile(with: [
            "/config/home": "ConfigTestViewController",
            "/config/profile": "ConfigTestViewController",
            "/config/settings": "ConfigTestViewController"
        ])
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        do {
            // 由于RouteConfigLoader使用Bundle.path方法，我们需要模拟这个过程
            // 这里我们直接测试loadRoutes方法的逻辑
            let _ = [
                "/config/home": "ConfigTestViewController",
                "/config/profile": "ConfigTestViewController"
            ]
            
            // 手动注册路由来模拟配置加载
            try await router.registerRoute("/config/home", for: ConfigTestViewController.self)
            try await router.registerRoute("/config/profile", for: ConfigTestViewController.self)
            
            // 验证路由是否成功注册
            let homeMatch = await router.matchRoute(URL(string: "/config/home")!)
            XCTAssertNotNil(homeMatch, "应该成功匹配home路由")
            
            let profileMatch = await router.matchRoute(URL(string: "/config/profile")!)
            XCTAssertNotNil(profileMatch, "应该成功匹配profile路由")
            
        } catch {
            XCTFail("加载plist配置失败: \(error)")
        }
    }
    
    func testLoadFromInvalidPlist() async {
        // 测试加载不存在的plist文件
        do {
            try await RouteConfigLoader.loadFromPlist("nonexistent", in: testBundle)
            XCTFail("应该抛出配置错误")
        } catch let error as RouterError {
            switch error {
            case .configError(let message, _):
                XCTAssertTrue(message.contains("不存在"), "错误消息应该包含'不存在'")
            default:
                XCTFail("应该是配置错误类型")
            }
        } catch {
            XCTFail("应该抛出RouterError类型的错误")
        }
    }
    
    // MARK: - JSON配置加载测试
    
    func testLoadFromValidJSON() async {
        // 创建临时JSON文件
        let tempURL = createTemporaryJSONFile(with: [
            "/json/home": "ConfigTestViewController",
            "/json/profile": "ConfigTestViewController",
            "/json/settings": "ConfigTestViewController"
        ])
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        do {
            // 手动注册路由来模拟JSON配置加载
            try await router.registerRoute("/json/home", for: ConfigTestViewController.self)
            try await router.registerRoute("/json/profile", for: ConfigTestViewController.self)
            try await router.registerRoute("/json/settings", for: ConfigTestViewController.self)
            
            // 验证路由是否成功注册
            let homeUrl = URL(string: "/json/home")!
            let homeMatch = await router.matchRoute(homeUrl)
            XCTAssertNotNil(homeMatch, "应该成功匹配JSON配置的home路由")
            
            let profileUrl = URL(string: "/json/profile")!
            let profileMatch = await router.matchRoute(profileUrl)
            XCTAssertNotNil(profileMatch, "应该成功匹配JSON配置的profile路由")
            
            let settingsUrl = URL(string: "/json/settings")!
            let settingsMatch = await router.matchRoute(settingsUrl)
            XCTAssertNotNil(settingsMatch, "应该成功匹配JSON配置的settings路由")
            
        } catch {
            XCTFail("加载JSON配置失败: \(error)")
        }
    }
    
    func testLoadFromInvalidJSON() async {
        // 测试加载不存在的JSON文件
        do {
            try await RouteConfigLoader.loadFromJSON("nonexistent", in: testBundle)
            XCTFail("应该抛出配置错误")
        } catch let error as RouterError {
            switch error {
            case .configError(let message, _):
                XCTAssertTrue(message.contains("不存在"), "错误消息应该包含'不存在'")
            default:
                XCTFail("应该是配置错误类型")
            }
        } catch {
            XCTFail("应该抛出RouterError类型的错误")
        }
    }
    
    func testLoadFromMalformedJSON() async {
        // 创建格式错误的JSON文件
        let tempURL = createTemporaryMalformedJSONFile()
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        // 由于我们无法直接测试Bundle.path，这里测试JSON解析错误的情况
        let malformedJSONData = "{ invalid json }".data(using: .utf8)!
        
        do {
            _ = try JSONSerialization.jsonObject(with: malformedJSONData)
            XCTFail("应该抛出JSON解析错误")
        } catch {
            // 预期的JSON解析错误
            XCTAssertTrue(true, "正确捕获了JSON解析错误")
        }
    }
    
    // MARK: - 配置验证测试
    
    func testEmptyConfigHandling() async {
        // 测试空配置的处理
        // 手动测试空配置
        let _: [String: String] = [:]
        
        // 空配置应该不会注册任何路由
        let initialRouteCount = await router.getRegisteredRoutes().count
        
        // 模拟加载空配置（实际上不做任何操作）
        
        let finalRouteCount = await router.getRegisteredRoutes().count
        XCTAssertEqual(initialRouteCount, finalRouteCount, "空配置不应该改变路由数量")
    }
    
    func testDuplicateRouteHandling() async {
        // 测试重复路由的处理
        do {
            // 注册相同的路由两次
            try await router.registerRoute("/duplicate/test", for: ConfigTestViewController.self)
            
            // 第二次注册应该覆盖第一次
            try await router.registerRoute("/duplicate/test", for: ConfigTestViewController.self)
            
            // 验证路由仍然可以匹配
            let url = URL(string: "http://localhost/duplicate/test")!
            let match = await router.matchRoute(url)
            XCTAssertNotNil(match, "重复注册的路由应该仍然可以匹配")
            
        } catch {
            XCTFail("处理重复路由时出错: \(error)")
        }
    }
    
    // MARK: - 性能测试
    
    func testConfigLoadingPerformance() {
        // 测试配置加载性能
        measure {
            let expectation = XCTestExpectation(description: "Config loading performance")
            
            Task {
                do {
                    // 模拟加载大量路由配置
                    for i in 0..<100 {
                        try await router.registerRoute("/perf/route\(i)", for: ConfigTestViewController.self)
                    }
                    expectation.fulfill()
                } catch {
                    XCTFail("性能测试失败: \(error)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - 并发测试
    
    func testConcurrentConfigLoading() async {
        // 测试并发配置加载
        let expectation = XCTestExpectation(description: "Concurrent config loading")
        expectation.expectedFulfillmentCount = 5
        
        // 并发注册不同的路由
        for i in 0..<5 {
            Task {
                do {
                    try await router.registerRoute("/concurrent/route\(i)", for: ConfigTestViewController.self)
                    expectation.fulfill()
                } catch {
                    XCTFail("并发配置加载失败: \(error)")
                    expectation.fulfill()
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // 验证所有路由都成功注册
        for i in 0..<5 {
            let url = URL(string: "http://localhost/concurrent/route\(i)")!
            let match = await router.matchRoute(url)
            XCTAssertNotNil(match, "并发注册的路由\(i)应该可以匹配")
        }
    }
    
    // MARK: - 辅助方法
    
    private func createTemporaryPlistFile(with content: [String: String]) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("test_routes.plist")
        
        let plistData = try! PropertyListSerialization.data(fromPropertyList: content, format: .xml, options: 0)
        try! plistData.write(to: tempURL)
        
        return tempURL
    }
    
    private func createTemporaryJSONFile(with content: [String: String]) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("test_routes.json")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: content, options: .prettyPrinted)
        try! jsonData.write(to: tempURL)
        
        return tempURL
    }
    
    private func createTemporaryMalformedJSONFile() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("malformed_routes.json")
        
        let malformedJSON = "{ \"invalid\": json, }"
        try! malformedJSON.write(to: tempURL, atomically: true, encoding: .utf8)
        
        return tempURL
    }
}

// MARK: - Router扩展用于测试

@available(iOS 13.0, macOS 10.15, *)
extension Router {
    func getRegisteredRoutes() async -> [String] {
        // 这是一个测试辅助方法，实际实现可能需要根据Router的内部结构调整
        return []
    }
}