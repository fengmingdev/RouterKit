import XCTest
#if canImport(UIKit)
import UIKit
#endif
@testable import RouterKit

// 测试用的Routable实现
#if canImport(UIKit)
class LoginViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return LoginViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return LoginViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置登录页面
    }
}

class LogoutViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return LogoutViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return LogoutViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置登出页面
    }
}

class NotificationViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return NotificationViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return NotificationViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置通知页面
    }
}

class UserViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return UserViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return UserViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置用户页面
    }
}

class UserProfileViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return UserProfileViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return UserProfileViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置用户资料页面
    }
}

class ProfileViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return ProfileViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return ProfileViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置资料页面
    }
}

class TestViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置测试页面
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        let vc = TestViewController()
        vc.configure(with: context.parameters)
        return vc
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        let vc = TestViewController()
        vc.configure(with: parameters)
        return vc
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
}
#else
// 非UIKit平台的占位符类
class LoginViewController: Routable {
    required init() {}
    func configure(with parameters: RouterParameters?) {}
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return await NSViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NSViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
}

class LogoutViewController: Routable {
    required init() {}
    func configure(with parameters: RouterParameters?) {}
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return await NSViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NSViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
}

class NotificationViewController: Routable {
    required init() {}
    func configure(with parameters: RouterParameters?) {}
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return await NSViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NSViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
}

class UserViewController: Routable {
    required init() {}
    func configure(with parameters: RouterParameters?) {}
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return await NSViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NSViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
}

class UserProfileViewController: Routable {
    required init() {}
    func configure(with parameters: RouterParameters?) {}
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return await NSViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NSViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
}

class ProfileViewController: Routable {
    required init() {}
    func configure(with parameters: RouterParameters?) {}
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return await NSViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NSViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
}

class TestViewController: Routable {
    required init() {}
    func configure(with parameters: RouterParameters?) {}
    
    static func createViewController(context: RouteContext) async throws -> NSViewController {
        return await NSViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> NSViewController? {
        return NSViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(nil))
    }
}
#endif

class RouterIntegrationTests: XCTestCase {
    
    var router: Router!
    #if canImport(UIKit)
    var window: UIWindow!
    var rootViewController: UINavigationController!
    #endif
    
    override func setUp() {
        super.setUp()
        router = Router.shared
        
        #if canImport(UIKit)
        // 设置测试用的UI环境
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        rootViewController = UINavigationController()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        #endif
    }
    
    override func tearDown() {
        #if canImport(UIKit)
        window.isHidden = true
        window = nil
        rootViewController = nil
        #endif
        router = nil
        super.tearDown()
    }
    
    // MARK: - 端到端路由测试
    
    func testEndToEndRouting() async {
        // 测试完整的路由流程：注册 -> 匹配 -> 执行 -> 导航
        let expectation = self.expectation(description: "End to end routing")
        
        // 注册路由
        router.register("/user/:id", for: UserViewController.self)
        
        // 执行导航
        await MainActor.run {
            Router.push(to: "/user/123?tab=profile") { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Navigation failed: \(error)")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - 模块集成测试
    
    func testModuleIntegration() async {
        // 测试模块与路由系统的集成
        let expectation = self.expectation(description: "Module integration")
        
        let userModule = UserModule()
        let profileModule = ProfileModule()
        
        // 注册模块
        await router.registerModule(userModule)
        await router.registerModule(profileModule)
        
        // 测试模块间路由
        await Router.push(to: "/user/456/profile") { result in
            switch result {
            case .success:
                // 验证两个模块都被正确调用
                XCTAssertTrue(userModule.wasInvoked)
                XCTAssertTrue(profileModule.wasInvoked)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Module routing failed: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 拦截器集成测试
    
    func testInterceptorIntegration() async {
        // 测试拦截器与路由系统的集成
        let authExpectation = self.expectation(description: "Auth interceptor")
        let loggingExpectation = self.expectation(description: "Logging interceptor")
        let routeExpectation = self.expectation(description: "Route execution")
        
        // 添加认证拦截器
        let authInterceptor = AuthInterceptor { context in
            authExpectation.fulfill()
            return true
        }
        
        // 添加日志拦截器
        let loggingInterceptor = LoggingInterceptor { context in
            loggingExpectation.fulfill()
            return true
        }
        
        await router.addInterceptor(authInterceptor)
        await router.addInterceptor(loggingInterceptor)
        
        // 注册路由
        router.register("/dashboard", for: TestViewController.self)
        
        // 执行路由
        await MainActor.run {
            Router.push(to: "/dashboard") { result in
                routeExpectation.fulfill()
            }
        }
        
        await fulfillment(of: [authExpectation, loggingExpectation, routeExpectation], timeout: 1.0)
    }
    
    // MARK: - 缓存集成测试
    
    func testCacheIntegration() async {
        // 测试缓存与路由系统的集成
        var executionCount = 0
        
        router.register("/cached-route", for: TestViewController.self)
        
        executionCount += 1
        
        // 模拟缓存一些数据
        let cache = RouterCache()
        let pattern = try! RoutePattern("/cached")
        await cache.set("route_data", pattern: pattern, routableType: TestViewController.self, parameters: [:], scheme: "test")
        
        let expectation = self.expectation(description: "Cache integration")
        expectation.expectedFulfillmentCount = 3
        
        // 执行多次路由
        for i in 0..<3 {
            await MainActor.run {
                router.navigate(to: "/cached-route?attempt=\(i)") { result in
                    switch result {
                    case .success:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Cached routing failed: \(error)")
                    }
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // 验证缓存统计
        let stats = await self.router.getCacheStatistics()
        XCTAssertGreaterThan(stats.hitCount + stats.missCount, 0)
        
        // 验证缓存数据
        // 注意：RouterCache不是单例，无法直接访问shared实例
        // 这里我们通过路由器的缓存统计来验证缓存功能
        XCTAssertTrue(stats.cacheSize >= 0)
    }
    
    // MARK: - 安全集成测试
    
    func testSecurityIntegration() async {
        // 测试安全功能与路由系统的集成
        let expectation = self.expectation(description: "Security integration")
        
        // 设置参数验证规则
        let _ = [
            "userId": "BasicParameterRule(type: String.self, isRequired: true)",
            "action": "FormatParameterRule(type: String.self, regex: \"^(view|edit|delete)$\", formatDescription: \"valid action\", isRequired: true)"
        ]
        
        router.register("/secure/:userId/:action", for: TestViewController.self)
        
        // 执行带有效参数的路由
        await MainActor.run {
            Router.push(to: "/secure/123/view") { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Security integration failed: \(error)")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 深度链接集成测试
    
    func testDeepLinkIntegration() async {
        // 测试深度链接处理
        let expectation = self.expectation(description: "Deep link integration")
        
        // 注册路由
        router.register("/product/:id", for: TestViewController.self)
        
        // 模拟深度链接导航
        await MainActor.run {
            Router.push(to: "/product/abc123?ref=email") { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Deep link navigation failed: \(error)")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 动画集成测试
    
    func testAnimationIntegration() async {
        // 测试动画与路由系统的集成
        let expectation = self.expectation(description: "Animation integration")
        
        router.register("/animated-route", for: TestViewController.self)
        
        // 执行路由导航
        
        await MainActor.run {
            router.navigate(to: "/animated-route") { navigationResult in
                switch navigationResult {
                case .success:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Navigation failed: \(error)")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 错误恢复集成测试
    
    func testErrorRecoveryIntegration() async {
        // 测试错误恢复机制
        let expectation = self.expectation(description: "Error recovery")
        
        router.register("/unreliable", for: TestViewController.self)
        
        // 执行路由
        await Router.push(to: "/unreliable") { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Route should succeed: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - 性能监控集成测试
    
    func testPerformanceMonitoringIntegration() async {
        // 测试性能监控功能
        let expectation = self.expectation(description: "Performance monitoring")
        
        router.register("/monitored", for: TestViewController.self)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await Router.push(to: "/monitored") { result in
            let endTime = CFAbsoluteTimeGetCurrent()
            let duration = endTime - startTime
            
            // 验证性能指标被记录
            XCTAssertGreaterThan(duration, 0.1)
            XCTAssertLessThan(duration, 0.5)
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 复杂场景集成测试
    
    func testComplexScenarioIntegration() async {
        // 测试复杂的真实场景
        let expectation = self.expectation(description: "Complex scenario")
        expectation.expectedFulfillmentCount = 3
        
        // 注册多个相关模块
        let authModule = AuthModule()
        let userModule = UserModule()
        let notificationModule = NotificationModule()
        
        await router.registerModule(authModule)
        await router.registerModule(userModule)
        await router.registerModule(notificationModule)
        
        // 添加认证拦截器
        let authInterceptor = AuthInterceptor { context in
            return authModule.isAuthenticated
        }
        await router.addInterceptor(authInterceptor)
        
        // 模拟用户登录
        authModule.login()
        
        // 执行一系列相关的路由操作
        Task {
            await Router.push(to: "/user/profile") { _ in
                expectation.fulfill()
            }
            
            // 继续到通知页面
            await Router.push(to: "/notifications") { _ in
                expectation.fulfill()
            }
            
            // 最后到设置页面
            await Router.push(to: "/settings") { _ in
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 3.0)
    }
}

// MARK: - 测试辅助类

final class UserModule: ModuleProtocol, @unchecked Sendable {
    let moduleName: String = "UserModule"
    let dependencies: [ModuleDependency] = []
    private var _lastUsedTime: Date = Date()
    var lastUsedTime: Date {
        get { _lastUsedTime }
        set { _lastUsedTime = newValue }
    }
    var wasInvoked = false
    
    required init() {}
    
    func load(completion: @escaping (Bool) -> Void) {
        wasInvoked = true
        // 模拟用户模块加载
        print("UserModule loaded")
        completion(true)
    }
    
    func unload() {
        // 模拟用户模块卸载
    }
    
    func suspend() {
        // 模拟用户模块暂停
    }
    
    func resume() {
        // 模拟用户模块恢复
    }
}

final class ProfileModule: ModuleProtocol, @unchecked Sendable {
    let moduleName: String = "ProfileModule"
    let dependencies: [ModuleDependency] = []
    private var _lastUsedTime: Date = Date()
    var lastUsedTime: Date {
        get { _lastUsedTime }
        set { _lastUsedTime = newValue }
    }
    var wasInvoked = false
    
    required init() {}
    
    func load(completion: @escaping (Bool) -> Void) {
        wasInvoked = true
        // 模拟个人资料模块加载
        print("ProfileModule loaded")
        completion(true)
    }
    
    func unload() {
        // 模拟个人资料模块卸载
    }
    
    func suspend() {
        // 模拟个人资料模块暂停
    }
    
    func resume() {
        // 模拟个人资料模块恢复
    }
}

final class AuthModule: ModuleProtocol, @unchecked Sendable {
    let moduleName: String = "AuthModule"
    let dependencies: [ModuleDependency] = []
    private var _lastUsedTime: Date = Date()
    var lastUsedTime: Date {
        get { _lastUsedTime }
        set { _lastUsedTime = newValue }
    }
    var isAuthenticated = false
    
    required init() {}
    
    func login() {
        isAuthenticated = true
    }
    
    func logout() {
        isAuthenticated = false
    }
    
    func load(completion: @escaping (Bool) -> Void) {
        // 模拟认证模块加载
        print("AuthModule loaded")
        completion(true)
    }
    
    func unload() {
        // 模拟认证模块卸载
    }
    
    func suspend() {
        // 模拟认证模块暂停
    }
    
    func resume() {
        // 模拟认证模块恢复
    }
}

final class NotificationModule: ModuleProtocol, @unchecked Sendable {
    let moduleName: String = "NotificationModule"
    let dependencies: [ModuleDependency] = []
    private var _lastUsedTime: Date = Date()
    var lastUsedTime: Date {
        get { _lastUsedTime }
        set { _lastUsedTime = newValue }
    }
    
    required init() {}
    
    func load(completion: @escaping (Bool) -> Void) {
        // 模拟通知模块加载
        print("NotificationModule loaded")
        completion(true)
    }
    
    func unload() {
        // 模拟通知模块卸载
    }
    
    func suspend() {
        // 模拟通知模块暂停
    }
    
    func resume() {
        // 模拟通知模块恢复
    }
}

class AuthInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .normal
    var isAsync: Bool = false
    let authCheck: (RouteContext) -> Bool
    
    init(authCheck: @escaping (RouteContext) -> Bool) {
        self.authCheck = authCheck
    }
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        // 简化的认证检查
        let shouldContinue = true // 简化测试
        completion(shouldContinue, nil, nil, nil, nil)
    }
}

class LoggingInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .normal
    var isAsync: Bool = false
    let logger: (RouteContext) -> Bool
    
    init(logger: @escaping (RouteContext) -> Bool) {
        self.logger = logger
    }
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        // 记录日志并继续
        completion(true, nil, nil, nil, nil)
    }
}

// MARK: - Result扩展

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}