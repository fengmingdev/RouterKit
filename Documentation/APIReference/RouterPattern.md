# RouterPattern

`RouterPattern`结构体表示路由模式，用于匹配URL路径。

## 初始化

```swift
// 使用字符串创建路由模式
public init(_ pattern: String)

// 使用正则表达式创建路由模式
public init(_ regex: Regex<AnyRegexOutput>)
```

## 属性

```swift
// 原始模式字符串
public let pattern: String

// 正则表达式
public let regex: Regex<AnyRegexOutput>

// 路径组件
public let components: [String]

// 是否包含动态参数
public let hasParameters: Bool

// 参数名称列表
public let parameterNames: [String]
```

## 方法

```swift
// 匹配URL路径
public func matches(_ path: String) -> Bool

// 提取参数
public func extractParameters(from path: String) -> [String: String]?
```

## 示例

```swift
// 创建路由模式
let pattern = RouterPattern("/user/:id")

// 匹配路径
print(pattern.matches("/user/123")) // 输出: true
print(pattern.matches("/user/profile")) // 输出: false

// 提取参数
if let params = pattern.extractParameters(from: "/user/123") {
    print(params) // 输出: ["id": "123"]
}
```