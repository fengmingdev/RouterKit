import XCTest
import RouterKit

class RouterKitTests: XCTestCase {
    var router: Router!

    override func setUp() {
        super.setUp()
        router = Router()
    }

    override func tearDown() {
        router = nil
        super.tearDown()
    }

    // 测试基本路由注册和匹配
    func testBasicRouteRegistration() {
        // 注册路由
        router.register("router://home") { _ in
            return UIViewController()
        }

        // 测试匹配
        let url = URL(string: "router://home")!
        XCTAssertTrue(router.canNavigate(to: url))

        // 测试不匹配的路由
        let invalidUrl = URL(string: "router://invalid")!
        XCTAssertFalse(router.canNavigate(to: invalidUrl))
    }

    // 测试带参数的路由
    func testRouteWithParameters() {
        // 注册带参数的路由
        router.register("router://user/:id") { _ in
            return UIViewController()
        }

        // 测试匹配
        let url = URL(string: "router://user/123")!
        XCTAssertTrue(router.canNavigate(to: url))

        // 提取参数
        let context = router.createContext(for: url)
        XCTAssertEqual(context.parameters["id"], "123")
    }

    // 测试查询参数
    func testQueryParameters() {
        router.register("router://search") { _ in
            return UIViewController()
        }

        let url = URL(string: "router://search?q=test&page=1")!
        XCTAssertTrue(router.canNavigate(to: url))

        let context = router.createContext(for: url)
        XCTAssertEqual(context.parameters["q"], "test")
        XCTAssertEqual(context.parameters["page"], "1")
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
    func testInterceptor() {
        let expectation = self.expectation(description: "Interceptor should be called")

        // 创建测试拦截器
        class TestInterceptor: RouterInterceptor {
            var priority: Int = 0
            var wasCalled = false

            func shouldNavigate(to url: URL, context: RouteContext) -> Bool {
                wasCalled = true
                return true
            }
        }

        let interceptor = TestInterceptor()
        router.addInterceptor(interceptor)

        // 注册路由
        router.register("router://test") { _ in
            expectation.fulfill()
            return UIViewController()
        }

        // 触发导航
        let url = URL(string: "router://test")!
        router.navigate(to: url)

        // 等待期望完成
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(interceptor.wasCalled)
    }

    // 测试自定义路由匹配器
    func testCustomRouteMatcher() {
        // 创建自定义匹配器
        class TestMatcher: CustomRouteMatcher {
            func matches(_ url: URL) -> Bool {
                return url.host == "custom"
            }

            func extractParameters(from url: URL) -> [String: String] {
                return ["custom": "true"]
            }
        }

        // 注册自定义匹配器
        router.register(matcher: TestMatcher()) { context in
            XCTAssertEqual(context.parameters["custom"], "true")
            return UIViewController()
        }

        // 测试匹配
        let url = URL(string: "router://custom/path")!
        XCTAssertTrue(router.canNavigate(to: url))

        // 测试不匹配
        let invalidUrl = URL(string: "router://normal/path")!
        XCTAssertFalse(router.canNavigate(to: invalidUrl))
    }
}
