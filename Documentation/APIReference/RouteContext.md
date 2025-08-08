# RouteContext

`RouteContext`类包含了导航过程中的所有信息，如路径、参数、来源控制器等。

## 初始化

```swift
// 初始化路由上下文
public init(path: String, source: UIViewController? = nil, options: [RouterOptions] = [], userInfo: [AnyHashable: Any] = [:])
```

## 属性

```swift
// 当前导航的URL路径
public let path: String

// 从URL路径中提取的参数
public var parameters: [String: String] { get set }

// URL查询参数
public var queryParameters: [String: String] { get set }

// 来源视图控制器
public weak var source: UIViewController? { get set }

// 导航选项
public var options: [RouterOptions] { get set }

// 自定义用户信息
public var userInfo: [AnyHashable: Any] { get set }

// 匹配的路由
public weak var route: Route? { get set }
```

## 方法

```swift
// 解析URL查询参数
public func parseQueryParameters()

// 获取参数值
public func value(forKey key: String) -> Any?

// 设置参数值
public func setValue(_ value: Any?, forKey key: String)
```

## 示例

```swift
// 创建路由上下文
let context = RouteContext(
    path: "/user/123",
    source: self,
    options: [.animated(true)],
    userInfo: ["theme": "dark"]
)

// 访问属性
print(context.path) // 输出: /user/123
print(context.parameters) // 输出: ["id": "123"]
print(context.options) // 输出: [.animated(true)]
```