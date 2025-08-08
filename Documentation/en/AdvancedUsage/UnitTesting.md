# Unit Testing

RouterKit is designed to be testable, making it easy to write unit tests for your routing logic.

## Testing Route Registration

Test that routes are registered correctly:

```swift
import XCTest
import RouterKit

class RouterTests: XCTestCase {
    var router: Router!

    override func setUp() {
        super.setUp()
        router = Router(name: "test")
    }

    func testRouteRegistration() {
        // Register a route
        router.register("/home") { _ in UIViewController() }

        // Check if the route is registered
        let routes = router.describeRoutes()
        XCTAssertTrue(routes.contains("/home"))
    }
}
```

## Testing Route Matching

Test that URLs are matched to the correct routes:

```swift
func testRouteMatching() {
    // Register a route
    router.register("/user/:id") { _ in UIViewController() }

    // Test matching URL
    let url = URL(string: "/user/123")!
    let matchResult = router.match(url)

    XCTAssertNotNil(matchResult)
    XCTAssertEqual(matchResult?.context.parameters["id"], "123")
}
```

## Testing Parameter Extraction

Test that parameters are extracted correctly from URLs:

```swift
func testParameterExtraction() {
    // Register a route
    router.register("/product/:category/:id") { _ in UIViewController() }

    // Test URL with parameters
    let url = URL(string: "/product/electronics/456?sort=price")!
    let matchResult = router.match(url)

    XCTAssertEqual(matchResult?.context.parameters["category"], "electronics")
    XCTAssertEqual(matchResult?.context.parameters["id"], "456")
    XCTAssertEqual(matchResult?.context.parameters["sort"], "price")
}
```

## Testing Interceptors

Test that interceptors work correctly:

```swift
func testInterceptor() {
    // Create mock interceptor
    class MockInterceptor: RouterInterceptor {
        var shouldNavigateCalled = false

        func shouldNavigate(to url: URL, context: RouteContext) -> Bool {
            shouldNavigateCalled = true
            return true
        }
    }

    // Add interceptor to router
    let interceptor = MockInterceptor()
    router.addInterceptor(interceptor)

    // Register route
    router.register("/home") { _ in UIViewController() }

    // Navigate
    router.navigate(to: URL(string: "/home")!)

    // Check if interceptor was called
    XCTAssertTrue(interceptor.shouldNavigateCalled)
}
```

## Testing Animations

Test that animations are applied correctly:

```swift
func testAnimation() {
    // Register animation
    class TestAnimation: RouterAnimation {
        var animateCalled = false

        func animate(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, completion: @escaping () -> Void) {
            animateCalled = true
            completion()
        }
    }

    let animation = TestAnimation()
    router.registerAnimation(animation, for: "test")

    // Navigate with animation
    router.navigate(to: URL(string: "/home")!, options: [.animation("test")])

    // Check if animation was called
    // Note: You may need to use expectations for async testing
    XCTAssertTrue(animation.animateCalled)
}
```

## Testing Modules

Test that modules register their routes correctly:

```swift
func testModuleRegistration() {
    // Create test module
    class TestModule: RouterModuleProtocol {
        var name: String { return "Test" }
        var dependencies: [String] { return [] }

        func registerRoutes(with router: Router) {
            router.register("/module-route") { _ in UIViewController() }
        }
    }

    // Register module
    let module = TestModule()
    router.registerModule(module)

    // Check if route was registered
    let routes = router.describeRoutes()
    XCTAssertTrue(routes.contains("/module-route"))
}
```

## Best Practices

- Use a dedicated test router instance for each test
- Test both successful and failed route matches
- Use mock objects for dependencies
- Test edge cases (e.g., malformed URLs, conflicting routes)
- Keep tests focused on a single aspect of routing
- Use expectations for asynchronous tests (e.g., animations)
- Test interceptors in isolation before integrating them with routes