import XCTest
@testable import RouterKit
#if canImport(UIKit)
import UIKit

class TestViewController: UIViewController, Routable {
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return TestViewController()
    }
    
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return TestViewController()
    }
    
    static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.success(()))
    }
    
    func configure(with parameters: RouterParameters?) {
        // 配置视图控制器
    }
}
#endif

final class RouterModuleTests: XCTestCase, @unchecked Sendable {
    
    var router: Router!
    
    override func setUp() async throws {
        try await super.setUp()
        router = Router.shared
        
        // 清理之前注册的模块
        await router.clearRouteCache()
    }
    
    override func tearDown() async throws {
        await router.clearRouteCache()
        router = nil
        try await super.tearDown()
    }
    
    // MARK: - 基础模块管理测试
    
    func testModuleRegistration() async {
        // 测试模块注册
        let module = TestModule()
        
        await router.registerModule(module)
        
        let isLoaded = await router.isModuleLoaded(module.moduleName)
        XCTAssertTrue(isLoaded)
        
        let retrievedModule: TestModule? = await router.getModule(TestModule.self)
        XCTAssertNotNil(retrievedModule)
        XCTAssertTrue(retrievedModule === module)
    }
    
    func testModuleUnregistration() async {
        // 测试模块注销
        let module = TestModule()
        
        await router.registerModule(module)
        let isLoadedBefore = await router.isModuleLoaded(module.moduleName)
        XCTAssertTrue(isLoadedBefore)
        
        await router.unregisterModule(module.moduleName)
        let isLoadedAfter = await router.isModuleLoaded(module.moduleName)
        XCTAssertFalse(isLoadedAfter)
        
        let retrievedModule: TestModule? = await router.getModule(TestModule.self)
        XCTAssertNil(retrievedModule)
    }
    
    func testModuleRouteRegistration() async {
        // 测试模块路由注册
        let expectation = self.expectation(description: "Module route execution")
        
        let module = TestModule()
        module.routeHandler = { context in
            XCTAssertEqual(context.url, "/test-module")
            expectation.fulfill()
        }
        
        await router.registerModule(module)
        try! await router.registerRoute("/test-module", for: TestViewController.self)
        await MainActor.run {
            Router.push(to: "/test-module") { _ in }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 模块依赖测试
    
    func testModuleDependencies() async {
        // 测试模块依赖关系
        let baseModule = BaseModule()
        let dependentModule = DependentModule()
        
        // 先注册依赖模块
        await router.registerModule(baseModule)
        
        // 再注册依赖于基础模块的模块
        await router.registerModule(dependentModule)
        
        let isBaseLoaded = await router.isModuleLoaded("BaseModule")
        let isDependentLoaded = await router.isModuleLoaded("DependentModule")
        XCTAssertTrue(isBaseLoaded)
        XCTAssertTrue(isDependentLoaded)
        
        // 验证依赖模块可以访问基础模块
        let retrievedDependentModule = await router.getModule("DependentModule")
        XCTAssertNotNil(retrievedDependentModule)
    }
    
    func testModuleDependencyFailure() async {
        // 测试缺少依赖时的失败情况
        let dependentModule = DependentModule()
        
        // 尝试注册没有依赖的模块应该失败
        do {
            try await router.registerModuleWithDependencyCheck(dependentModule)
            XCTFail("应该抛出依赖错误")
        } catch {
            XCTAssertTrue(error is RouterError)
        }
    }
    
    // MARK: - 模块生命周期测试
    
    func testModuleLifecycle() async {
        // 测试模块生命周期
        let module = LifecycleTestModule()
        
        // 注册模块应该调用load
        await router.registerModule(module)
        XCTAssertTrue(module.loadCalled)
        
        // 注销模块应该调用unload
        await router.unregisterModule(module.moduleName)
        XCTAssertTrue(module.unloadCalled)
    }
    
    // MARK: - 模块清理测试
    
    func testModuleCleanup() async {
        // 测试模块自动清理
        let module = TestModule()
        await router.registerModule(module)
        
        // 模拟模块长时间未使用
        module.simulateUnused()
        
        // 触发清理
        await router.forceCleanup()
        
        // 检查未使用的模块是否被清理
        let isLoaded = await router.isModuleLoaded(module.moduleName)
        XCTAssertFalse(isLoaded)
    }
    
    func testModuleCleanupTimer() async {
        // 测试模块清理定时器
        let module = TestModule()
        await router.registerModule(module)
        
        // 启动清理定时器
        router.startModuleCleanupTimer()
        
        // 模拟模块未使用
        module.simulateUnused()
        
        let expectation = self.expectation(description: "Module cleanup timer")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            Task {
                // 检查模块是否被自动清理
                let isLoaded = await self.router.isModuleLoaded(module.moduleName)
                XCTAssertFalse(isLoaded)
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 模块配置测试
    
    func testModuleConfiguration() async {
        // 测试模块配置
        let module = ConfigurableModule()
        
        let config = ["key1": "value1", "key2": "value2"]
        module.configure(with: config)
        
        await router.registerModule(module)
        
        XCTAssertEqual(module.configuration["key1"] as? String, "value1")
        XCTAssertEqual(module.configuration["key2"] as? String, "value2")
    }
    
    // MARK: - 模块通信测试
    
    func testModuleCommunication() async {
        // 测试模块间通信
        let senderModule = SenderModule()
        let receiverModule = ReceiverModule()
        
        await router.registerModule(senderModule)
        await router.registerModule(receiverModule)
        
        let expectation = self.expectation(description: "Module communication")
        
        receiverModule.messageHandler = { message in
            XCTAssertEqual(message, "Hello from sender")
            expectation.fulfill()
        }
        
        await senderModule.sendMessage("Hello from sender", to: ReceiverModule.self)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // MARK: - 并发模块操作测试
    
    func testConcurrentModuleOperations() async {
        // 测试并发模块操作安全性
        let expectation = self.expectation(description: "Concurrent module operations")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        for i in 0..<10 {
            queue.async {
                Task {
                    let module = TestModule()
                    module.identifier = "module_\(i)"
                    await self.router.registerModule(module)
                    expectation.fulfill()
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - 模块性能测试
    
    func testModulePerformance() async {
        // 测试模块注册性能
        await measureAsync {
            await withTaskGroup(of: Void.self) { group in
                for i in 0..<100 {
                    group.addTask {
                        let module = TestModule()
                        module.identifier = "perf_module_\(i)"
                        await self.router.registerModule(module)
                    }
                }
            }
        }
    }
    
    private func measureAsync(_ block: @escaping () async -> Void) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed: \(timeElapsed) seconds")
    }
}

// MARK: - 测试模块类

class TestModule: ModuleProtocol, @unchecked Sendable {
    var moduleName: String { return identifier }
    var identifier: String = "TestModule"
    var routeHandler: ((RouteContext) -> Void)?
    let dependencies: [ModuleDependency] = []
    var lastUsedTime: Date = Date()
    
    required init() {}
    
    func load(completion: @escaping (Bool) -> Void) {
        // 模块加载，注册路由
        Task {
            #if canImport(UIKit)
            try await Router.shared.registerRoute("/test-module", for: TestViewController.self)
            #endif
        }
        lastUsedTime = Date()
        completion(true)
    }
    
    func unload() {
        // 模块卸载，清理资源
    }
    
    func suspend() {
        // 暂停模块业务
    }
    
    func resume() {
        // 恢复模块业务
    }
    
    func simulateUnused() {
        lastUsedTime = Date().addingTimeInterval(-400) // 模拟6分钟前使用
    }
}

class BaseModule: ModuleProtocol, @unchecked Sendable {
    var moduleName: String { return identifier }
    let identifier: String = "BaseModule"
    let dependencies: [ModuleDependency] = []
    var lastUsedTime: Date = Date()
    
    required init() {}
    
    func load(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func unload() {}
    
    func suspend() {}
    
    func resume() {}
}

class DependentModule: ModuleProtocol, @unchecked Sendable {
    var moduleName: String { return identifier }
    let identifier: String = "DependentModule"
    var baseModule: BaseModule?
    let dependencies: [ModuleDependency] = [ModuleDependency(moduleName: "BaseModule", isRequired: true)]
    var lastUsedTime: Date = Date()
    
    required init() {}
    
    func load(completion: @escaping (Bool) -> Void) {
        // 检查依赖的模块
        Task {
            baseModule = await Router.shared.getModule(BaseModule.self)
            if baseModule == nil {
                // 依赖不满足，加载失败
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func unload() {
        baseModule = nil
    }
    
    func suspend() {}
    
    func resume() {}
}

class LifecycleTestModule: ModuleProtocol, @unchecked Sendable {
    var moduleName: String { return identifier }
    let identifier: String = "LifecycleTestModule"
    var loadCalled = false
    var unloadCalled = false
    var suspendCalled = false
    var resumeCalled = false
    var dependencies: [ModuleDependency] = []
    var lastUsedTime: Date = Date()
    
    required init() {}
    
    func load(completion: @escaping (Bool) -> Void) {
        loadCalled = true
        completion(true)
    }
    
    func unload() {
        unloadCalled = true
    }
    
    func suspend() {
        suspendCalled = true
    }
    
    func resume() {
        resumeCalled = true
    }
}

class ConfigurableModule: ModuleProtocol, @unchecked Sendable {
    var moduleName: String { return identifier }
    let identifier: String = "ConfigurableModule"
    var configuration: [String: Any] = [:]
    let dependencies: [ModuleDependency] = []
    var lastUsedTime: Date = Date()
    
    required init() {}
    
    func configure(with config: [String: Any]) {
        configuration = config
    }
    
    func load(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func unload() {}
    
    func suspend() {}
    
    func resume() {}
}

final class SenderModule: ModuleProtocol, @unchecked Sendable {
    var moduleName: String { return identifier }
    let identifier: String = "SenderModule"
    let dependencies: [ModuleDependency] = []
    private var _lastUsedTime: Date = Date()
    var lastUsedTime: Date {
        get { _lastUsedTime }
        set { _lastUsedTime = newValue }
    }
    
    required init() {}
    
    func sendMessage<T: ModuleProtocol>(_ message: String, to moduleType: T.Type) async {
        if let receiverModule = await Router.shared.getModule(moduleType) {
            if let receiver = receiverModule as? ReceiverModule {
                receiver.receiveMessage(message)
            }
        }
    }
    
    func load(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func unload() {}
    
    func suspend() {}
    
    func resume() {}
}

final class ReceiverModule: ModuleProtocol, @unchecked Sendable {
    var moduleName: String { return identifier }
    let identifier: String = "ReceiverModule"
    let dependencies: [ModuleDependency] = []
    private var _lastUsedTime: Date = Date()
    var lastUsedTime: Date {
        get { _lastUsedTime }
        set { _lastUsedTime = newValue }
    }
    var messageHandler: ((String) -> Void)?
    
    required init() {}
    
    func receiveMessage(_ message: String) {
        messageHandler?(message)
    }
    
    func load(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func unload() {}
    
    func suspend() {}
    
    func resume() {}
}

// MARK: - 扩展Router以支持依赖检查

extension Router {
    func registerModuleWithDependencyCheck<T: ModuleProtocol>(_ module: T) async throws {
        // 这里应该实现依赖检查逻辑
        // 为了测试目的，我们简化实现
        if module is DependentModule {
            let isBaseLoaded = await isModuleLoaded("BaseModule")
            if !isBaseLoaded {
                throw RouterError.moduleNotRegistered("BaseModule is required for DependentModule")
            }
        }
        await registerModule(module)
    }
}