# 自定义路由匹配器

RouterKit允许您创建自定义路由匹配器，以满足特殊的路由匹配需求。

## 什么是自定义路由匹配器

自定义路由匹配器是实现了`CustomRouteMatcher`协议的对象，它可以定义自己的路由匹配逻辑，而不仅仅依赖于默认的URL路径匹配。

## 实现CustomRouteMatcher协议

```swift
// 定义自定义路由匹配器协议
protocol CustomRouteMatcher {
    func matches(_ path: String) -> Bool
    func extractParameters(from path: String) -> [String: String]?
}

// 实现自定义路由匹配器
class RegexRouteMatcher: CustomRouteMatcher {
    private let regex: Regex<AnyRegexOutput>
    private let parameterNames: [String]
    
    init(regex: Regex<AnyRegexOutput>, parameterNames: [String]) {
        self.regex = regex
        self.parameterNames = parameterNames
    }
    
    func matches(_ path: String) -> Bool {
        return path.firstMatch(of: regex) != nil
    }
    
    func extractParameters(from path: String) -> [String: String]? {
        guard let match = path.firstMatch(of: regex) else { return nil }
        var parameters: [String: String] = [:]
        
        for (index, name) in parameterNames.enumerated() {
            if index + 1 < match.output.count {
                parameters[name] = String(describing: match.output[index + 1])
            }
        }
        
        return parameters
    }
}
```

## 注册自定义路由匹配器

```swift
// 创建自定义路由匹配器
let regex = try! Regex("^/user/(\\d+)/posts/(\\w+)$")
let matcher = RegexRouteMatcher(regex: regex, parameterNames: ["userId", "postId"])

// 注册自定义路由匹配器
router.register(matcher: matcher) { context in
    guard let userId = context.parameters["userId"],
          let postId = context.parameters["postId"] else { return nil }
    return PostDetailViewController(userId: userId, postId: postId)
}
```

## 使用自定义路由匹配器

```swift
// 导航到匹配自定义路由的路径
router.navigate(to: "/user/123/posts/abc")
```

## 组合多个路由匹配器

您可以组合多个路由匹配器来处理复杂的路由需求。

```swift
class CompositeRouteMatcher: CustomRouteMatcher {
    private let matchers: [CustomRouteMatcher]
    
    init(matchers: [CustomRouteMatcher]) {
        self.matchers = matchers
    }
    
    func matches(_ path: String) -> Bool {
        return matchers.contains { $0.matches(path) }
    }
    
    func extractParameters(from path: String) -> [String: String]? {
        for matcher in matchers {
            if let params = matcher.extractParameters(from: path) {
                return params
            }
        }
        return nil
    }
}
```

## 优先级

自定义路由匹配器的优先级高于默认的路由匹配逻辑。如果一个路径同时匹配默认路由和自定义路由，将优先使用自定义路由。

```swift
// 默认路由
router.register("/user/:id") { _ in ... }

// 自定义路由匹配器
let customMatcher = ... // 创建自定义路由匹配器
router.register(matcher: customMatcher) { _ in ... } // 优先级更高
```