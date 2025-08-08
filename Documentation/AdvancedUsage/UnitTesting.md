# 单元测试

为路由系统编写单元测试可以确保路由功能的正确性和稳定性。RouterKit提供了多种测试路由的方法。

## 测试路由注册

测试路由是否正确注册。

```swift
import XCTest
import RouterKit

class RouterTests: XCTestCase {
    var router: Router!
    
    override func setUp() {
        super.setUp()
        router = Router()
    }
    
    override func tearDown() {
        router = nil
        super.tearDown()
    }
    
    func testRouteRegistration() {
        // 注册路由
        router.register("/home") { _ in
            return UIViewController()
        }
        
        // 验证路由是否注册成功
        XCTAssertEqual(router.routes.count, 1)
        XCTAssertEqual(router.routes.first?.pattern, "/home")
    }
}
```

## 测试路由匹配

测试路由是否正确匹配URL路径。

```swift
func testRouteMatching() {
    // 注册路由
    router.register("/user/:id") { _ in
        return UIViewController()
    }
    
    // 测试匹配
    XCTAssertTrue(router.canNavigate(to: "/user/123"))
    XCTAssertFalse(router.canNavigate(to: "/user/profile"))
}
```

## 测试参数提取

测试路由是否正确提取URL路径中的参数。

```swift
func testParameterExtraction() {
    // 注册路由
    router.register("/user/:id") { context in
        // 验证参数
        XCTAssertEqual(context.parameters["id"], "123")
        return UIViewController()
    }
    
    // 导航到路由
    router.navigate(to: "/user/123")
}
```

## 测试拦截器

测试拦截器是否正确工作。

```swift
func testInterceptor() {
    // 创建拦截器
    class TestInterceptor: RouterInterceptor {
        var shouldNavigateCalled = false
        
        func shouldNavigate(to path: String, context: RouteContext) -> Bool {
            shouldNavigateCalled = true
            return true
        }
    }
    
    // 注册拦截器
    let interceptor = TestInterceptor()
    router.addInterceptor(interceptor)
    
    // 注册路由
    router.register("/home") { _ in
        return UIViewController()
    }
    
    // 导航到路由
    router.navigate(to: "/home")
    
    // 验证拦截器是否被调用
    XCTAssertTrue(interceptor.shouldNavigateCalled)
}
```

## 测试动画

测试动画是否正确应用。

```swift
func testAnimation() {
    // 注册动画
    class TestAnimation: RouterAnimation {
        var animateCalled = false
        
        func animate(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, completion: @escaping () -> Void) {
            animateCalled = true
            completion()
        }
    }
    
    let animation = TestAnimation()
    router.registerAnimation("test", animation: animation)
    
    // 注册路由
    router.register("/home") { _ in
        return UIViewController()
    }
    
    // 导航到路由
    router.navigate(to: "/home", options: [.animation(.custom("test"))])
    
    // 验证动画是否被调用
    XCTAssertTrue(animation.animateCalled)
}
```

## 测试模块

测试模块是否正确注册路由。

```swift
func testModule() {
    // 创建模块
    class TestModule: RouterModuleProtocol {
        var name: String { return "test" }
        var dependencies: [String] { return [] }
        
        func registerRoutes(with router: Router) {
            router.register("/test") { _ in
                return UIViewController()
            }
        }
    }
    
    // 注册模块
    let module = TestModule()
    router.registerModule(module)
    
    // 验证路由是否注册成功
    XCTAssertTrue(router.canNavigate(to: "/test"))
}
```

## 最佳实践

1. 为每个路由功能编写单元测试
2. 使用`setUp`和`tearDown`方法创建和清理测试环境
3. 模拟外部依赖，如视图控制器和数据模型
4. 测试边界情况，如无效路径和重复注册
5. 保持测试小巧、快速和独立