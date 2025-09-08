# Router

`Router`类是RouterKit的核心组件，负责管理路由注册、解析和导航。

## 初始化

```swift
// 初始化一个新的路由器实例
public init()

// 获取全局共享路由器实例
public static let shared: Router
```

## 属性

```swift
// 已注册的路由列表
public var routes: [Route] { get }

// 已注册的拦截器列表
public var interceptors: [RouterInterceptor] { get }

// 已注册的动画列表
public var animations: [String: RouterAnimation] { get }

// 已注册的模块列表
public var modules: [String: RouterModuleProtocol] { get }
```

## 注册路由

```swift
// 注册路由（异步方法）
public func registerRoute(_ pattern: String, for routableType: Routable.Type, permission: RoutePermission? = nil, priority: Int = 0, scheme: String = "") async throws

// 注册动态路由
public func registerDynamicRoute(_ pattern: String, for routableType: Routable.Type, permission: RoutePermission? = nil, priority: Int = 0, scheme: String = "") async throws

// 注销动态路由
public func unregisterDynamicRoute(_ pattern: String) async throws

// 链式调用注册（Fluent API）
public func register(_ pattern: String, for routableType: Routable.Type) -> RouteRegistrationBuilder
```

## 导航

```swift
// 核心导航方法
@MainActor
public func navigate(to urlString: String,
                     parameters: RouterParameters? = nil,
                     from sourceVC: UIViewController? = nil,
                     type: NavigationType = .push,
                     animated: Bool = true,
                     animationId: String? = nil,
                     retryCount: Int = 0,
                     completion: @escaping RouterCompletion)

// 静态导航方法
@MainActor
public static func push(to url: String, parameters: RouterParameters? = nil, from sourceVC: UIViewController? = nil, animated: Bool = true, animationId: String? = nil, completion: @escaping RouterCompletion = { _ in })

@MainActor
public static func present(to url: String, parameters: RouterParameters? = nil, from sourceVC: UIViewController? = nil, animated: Bool = true, animationId: String? = nil, completion: @escaping RouterCompletion = { _ in })

@MainActor
public static func pop(animated: Bool = true, completion: @escaping RouterCompletion = { _ in })

// 链式调用导航（Fluent API）
public func navigate(to url: String) -> NavigationBuilder
```

## 路由匹配

```swift
// 匹配路由
public func matchRoute(_ url: URL) async -> (pattern: RoutePattern, type: Routable.Type, parameters: RouterParameters)?

// 查找匹配器
public func findMatcher(for pattern: String) async -> RouteMatcher

// 注册匹配器
func registerMatcher(_ matcher: RouteMatcher, for patternPrefix: String) async
```

## 拦截器

```swift
// 添加拦截器
public func addInterceptor(_ interceptor: RouterInterceptor) async

// 移除拦截器
public func removeInterceptor(_ interceptor: RouterInterceptor) async
```

## 动画

```swift
// 注册动画
public func registerAnimation(_ animation: NavigationAnimatable) async

// 注销动画
public func unregisterAnimation(_ identifier: String) async

// 获取动画
public func getAnimation(_ identifier: String) async -> NavigationAnimatable?
```

## 模块

```swift
// 注册模块
public func registerModule<T: ModuleProtocol>(_ module: T) async

// 注销模块
public func unregisterModule(_ moduleName: String) async

// 检查模块是否已加载
public func isModuleLoaded(_ moduleName: String) async -> Bool

// 获取模块
public func getModule(_ name: String) async -> (any ModuleProtocol)?
public func getModule<T: ModuleProtocol>(_ type: T.Type) async -> T?

// 创建模块
public func createModule(named moduleName: String) -> (any ModuleProtocol)?
```

## 清除

```
// 清除所有路由
public func removeAllRoutes()

// 清除所有拦截器
public func removeAllInterceptors()

// 清除所有动画
public func removeAllAnimations()

// 清除所有模块
public func removeAllModules()
```

## 配置管理

```swift
// 获取配置参数
public func getMaxRetryCount() async -> Int
public func getDefaultAnimationDuration() async -> TimeInterval
public func getCacheSize() async -> Int
public func getLogLevel() async -> LogLevel

// 设置配置参数
public func setMaxRetryCount(_ count: Int) async
public func setDefaultAnimationDuration(_ duration: TimeInterval) async
public func setCacheSize(_ size: Int) async
public func setLogLevel(_ level: LogLevel) async
```

## 使用示例

### 基本使用

```swift
// 注册路由
Router.shared.registerRoute("/user/:id", for: UserViewController.self)

// 导航
Router.shared.navigate(to: "/user/123") { result in
    switch result {
    case .success:
        print("导航成功")
    case .failure(let error):
        print("导航失败: \(error)")
    }
}
```

### 使用拦截器

```swift
class AuthInterceptor: RouterInterceptor {
    let identifier = "auth"
    let priority = 100
    
    func shouldIntercept(for url: String, parameters: RouterParameters?) async -> Bool {
        return !UserManager.shared.isLoggedIn
    }
    
    func intercept(for url: String, parameters: RouterParameters?, from sourceVC: UIViewController?) async -> InterceptorResult {
        // 显示登录界面
        let success = await LoginViewController.present()
        return success ? .continue : .stop
    }
}

// 添加拦截器
await Router.shared.addInterceptor(AuthInterceptor())
```

### 使用模块

```swift
class UserModule: ModuleProtocol {
    let name = "User"
    let version = "1.0.0"
    
    func initialize() async throws {
        // 模块初始化逻辑
    }
    
    func registerRoutes() async throws {
        try await Router.shared.registerRoute("/user/:id", for: UserViewController.self)
        try await Router.shared.registerRoute("/profile", for: ProfileViewController.self)
    }
    
    func cleanup() async {
        // 清理资源
    }
}

// 注册模块
await Router.shared.registerModule(UserModule())
```