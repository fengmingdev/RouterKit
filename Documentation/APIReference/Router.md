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
// 注册一个路由
@discardableResult
public func register(_ pattern: String, name: String? = nil, predicate: ((RouteContext) -> Bool)? = nil, handler: @escaping (RouteContext) -> UIViewController?) -> Route

// 使用正则表达式注册路由
@discardableResult
public func register(_ regex: Regex<AnyRegexOutput>, name: String? = nil, predicate: ((RouteContext) -> Bool)? = nil, handler: @escaping (RouteContext) -> UIViewController?) -> Route

// 创建路由组
public func group(_ prefix: String, configure: (Router) -> Void)
```

## 导航

```swift
// 导航到指定路径
@discardableResult
public func navigate(to path: String, from source: UIViewController? = nil, options: [RouterOptions] = [], userInfo: [AnyHashable: Any] = [:]) -> Bool

// 导航到指定URL
@discardableResult
public func navigate(to url: URL, from source: UIViewController? = nil, options: [RouterOptions] = [], userInfo: [AnyHashable: Any] = [:]) -> Bool

// 关闭当前视图控制器
public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil)
```

## 反向路由生成

```swift
// 根据名称和参数生成URL路径
public func generateURL(for name: String, parameters: [String: Any] = [:]) -> String?

// 根据名称和参数生成URL
public func generateURLObject(for name: String, parameters: [String: Any] = [:]) -> URL?
```

## 拦截器

```swift
// 添加拦截器
public func addInterceptor(_ interceptor: RouterInterceptor, priority: Int = 0)

// 移除拦截器
public func removeInterceptor(_ interceptor: RouterInterceptor)
```

## 动画

```swift
// 注册动画
public func registerAnimation(_ name: String, animation: RouterAnimation)

// 移除动画
public func removeAnimation(_ name: String)
```

## 模块

```swift
// 注册模块
public func registerModule(_ module: RouterModuleProtocol)

// 卸载模块
public func unregisterModule(_ name: String)
```

## 清除

```swift
// 清除所有路由
public func removeAllRoutes()

// 清除所有拦截器
public func removeAllInterceptors()

// 清除所有动画
public func removeAllAnimations()

// 清除所有模块
public func removeAllModules()
```