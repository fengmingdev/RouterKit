import XCTest
import RouterKit

class RouterKitTests: XCTestCase {
    var router: Router!

    override func setUp() {
        super.setUp()
        router = Router.shared
    }

    override func tearDown() {
        // 清理路由器状态
        Task {
            await router.clearAllRoutes()
        }
        router = nil
        super.tearDown()
    }

    // 测试基本路由注册和匹配
    func testBasicRouteRegistration() async {
        // 创建测试视图控制器
        class TestViewController: UIViewController, Routable {
            func viewController(with parameters: RouterParameters?) -> UIViewController {
                return TestViewController()
            }
        }
        
        do {
            // 注册路由
            try await router.registerRoute("/home", for: TestViewController.self)

            // 测试匹配
            let url = URL(string: "router://home")!
            let canNavigate = await router.canNavigate(to: url)
            XCTAssertTrue(canNavigate)

            // 测试不匹配的路由
            let invalidUrl = URL(string: "router://invalid")!
            let cannotNavigate = await router.canNavigate(to: invalidUrl)
            XCTAssertFalse(cannotNavigate)
        } catch {
            XCTFail("Route registration failed: \(error)")
        }
    }

    // 测试带参数的路由
    func testRouteWithParameters() async {
        // 创建测试视图控制器
        class UserViewController: UIViewController, Routable {
            func viewController(with parameters: RouterParameters?) -> UIViewController {
                return UserViewController()
            }
        }
        
        do {
            // 注册带参数的路由
            try await router.registerRoute("/user/:id", for: UserViewController.self)

            // 测试匹配
            let url = URL(string: "router://user/123")!
            let canNavigate = await router.canNavigate(to: url)
            XCTAssertTrue(canNavigate)

            // 测试参数匹配
            let matchResult = await router.matchRoute(url: url)
            XCTAssertNotNil(matchResult)
            let userId = matchResult?.parameters.getValue(forKey: "id") as? String
            XCTAssertEqual(userId, "123")
        } catch {
            XCTFail("Route registration failed: \(error)")
        }
    }

    // 测试查询参数
    func testQueryParameters() async {
        // 创建测试视图控制器
        class SearchViewController: UIViewController, Routable {
            func viewController(with parameters: RouterParameters?) -> UIViewController {
                return SearchViewController()
            }
        }
        
        do {
            try await router.registerRoute("/search", for: SearchViewController.self)

            let url = URL(string: "router://search?q=test&page=1")!
            let canNavigate = await router.canNavigate(to: url)
            XCTAssertTrue(canNavigate)

            let matchResult = await router.matchRoute(url: url)
            XCTAssertNotNil(matchResult)
            let query = matchResult?.parameters.getValue(forKey: "q") as? String
            let page = matchResult?.parameters.getValue(forKey: "page") as? String
            XCTAssertEqual(query, "test")
            XCTAssertEqual(page, "1")
        } catch {
            XCTFail("Route registration failed: \(error)")
        }
    }

    // 测试路由优先级
    func testRoutePriority() {
        // 注册低优先级路由
        router.register("router://product/:id", priority: 1) { _ in
            return UIViewController()
        }

        // 注册高优先级路由
        router.register("router://product/featured", priority: 10) { _ in
            return UIViewController()
        }

        // 测试高优先级路由优先匹配
        let url = URL(string: "router://product/featured")!
        let handler = router.findHandler(for: url)
        XCTAssertNotNil(handler)
        XCTAssertEqual(handler?.priority, 10)
    }

    // 测试拦截器
    func testInterceptor() async {
        let expectation = self.expectation(description: "Interceptor should be called")

        // 创建测试拦截器
        class TestInterceptor: RouterInterceptor {
            var priority: Int = 0
            var wasCalled = false

            func shouldIntercept(url: URL, parameters: RouterParameters?) async -> Bool {
                wasCalled = true
                return false // 不拦截
            }
            
            func intercept(url: URL, parameters: RouterParameters?) async -> InterceptorResult {
                return .continue
            }
        }

        // 创建测试视图控制器
        class TestViewController: UIViewController, Routable {
            func viewController(with parameters: RouterParameters?) -> UIViewController {
                expectation.fulfill()
                return TestViewController()
            }
        }

        let interceptor = TestInterceptor()
        
        do {
            try await router.addInterceptor(interceptor)
            try await router.registerRoute("/test", for: TestViewController.self)

            // 触发导航
            Router.push(to: "/test") { _ in }

            // 等待期望完成
            await fulfillment(of: [expectation], timeout: 1)
            XCTAssertTrue(interceptor.wasCalled)
        } catch {
            XCTFail("Setup failed: \(error)")
        }
    }

    // 测试自定义路由匹配器
    func testCustomRouteMatcher() async {
        // 创建自定义匹配器
        class TestMatcher: CustomRouteMatcher {
            func matches(_ url: URL) -> Bool {
                return url.host == "custom"
            }

            func extractParameters(from url: URL) -> [String: String] {
                return ["custom": "true"]
            }
        }

        // 创建测试视图控制器
        class CustomViewController: UIViewController, Routable {
            func viewController(with parameters: RouterParameters?) -> UIViewController {
                let customValue = parameters?.getValue(forKey: "custom") as? String
                XCTAssertEqual(customValue, "true")
                return CustomViewController()
            }
        }

        do {
            // 注册自定义匹配器
            try await router.registerRoute(matcher: TestMatcher(), for: CustomViewController.self)

            // 测试匹配
            let url = URL(string: "router://custom/path")!
            let canNavigate = await router.canNavigate(to: url)
            XCTAssertTrue(canNavigate)

            // 测试不匹配
            let invalidUrl = URL(string: "router://normal/path")!
            let cannotNavigate = await router.canNavigate(to: invalidUrl)
            XCTAssertFalse(cannotNavigate)
        } catch {
            XCTFail("Custom matcher registration failed: \(error)")
        }
    }
}
