# 深度链接处理 (Deep Link Handling)

本文档介绍了 RouterKit Example 项目中深度链接的实现和使用方法。

## 概述

深度链接允许用户通过特定的URL直接跳转到应用内的特定页面，提升用户体验。本项目支持两种类型的深度链接：

1. **URL Scheme**: `routerkit-example://`
2. **Universal Links**: `https://routerkit.example.com/`

## 功能特性

### 1. URL Scheme 支持

- **格式**: `routerkit-example://path?parameters`
- **示例**:
  - `routerkit-example://login`
  - `routerkit-example://profile/edit?userId=123`
  - `routerkit-example://settings/theme?theme=dark`

### 2. Universal Links 支持

- **格式**: `https://routerkit.example.com/path?parameters`
- **示例**:
  - `https://routerkit.example.com/login`
  - `https://routerkit.example.com/profile/edit?userId=123`
  - `https://routerkit.example.com/settings/notification?enabled=true`

### 3. 路由映射

深度链接会自动映射到对应的内部路由：

| 外部路径 | 内部路由 | 说明 |
|---------|---------|------|
| `/login` | `/LoginModule/login` | 登录页面 |
| `/message` | `/MessageModule/message` | 消息页面 |
| `/profile` | `/ProfileModule/profile` | 个人资料 |
| `/profile/edit` | `/ProfileModule/edit` | 编辑资料 |
| `/profile/avatar` | `/ProfileModule/avatar` | 头像上传 |
| `/settings` | `/SettingsModule/settings` | 设置页面 |
| `/settings/theme` | `/SettingsModule/theme` | 主题设置 |
| `/settings/notification` | `/SettingsModule/notification` | 通知设置 |
| `/settings/about` | `/SettingsModule/about` | 关于页面 |

### 4. 参数传递

支持通过URL查询参数传递数据：

```
routerkit-example://profile?userId=123&tab=info
↓
内部路由: /ProfileModule/profile
参数: {"userId": 123, "tab": "info"}
```

### 5. 自动类型转换

查询参数会自动转换为合适的类型：
- 数字字符串 → `Int`
- 布尔字符串 → `Bool`
- 其他 → `String`

## 核心组件

### DeepLinkHandler

深度链接处理的核心类，提供以下功能：

#### 主要方法

```swift
// 处理URL Scheme
func handleURLScheme(_ url: URL) -> Bool

// 处理Universal Links
func handleUniversalLink(_ url: URL) -> Bool

// 生成URL Scheme链接
func generateURLSchemeLink(route: String, parameters: [String: Any] = [:]) -> URL?

// 生成Universal Link
func generateUniversalLink(route: String, parameters: [String: Any] = [:]) -> URL?

// 分享深度链接
func shareDeepLink(route: String, parameters: [String: Any] = [:], from viewController: UIViewController, useUniversalLink: Bool = true)
```

#### 使用示例

```swift
// 处理深度链接
let success = DeepLinkHandler.shared.handleURLScheme(url)

// 生成分享链接
if let link = DeepLinkHandler.shared.generateUniversalLink(
    route: "/ProfileModule/profile",
    parameters: ["userId": 123]
) {
    print("分享链接: \(link.absoluteString)")
}

// 分享功能
DeepLinkHandler.shared.shareDeepLink(
    route: "/ProfileModule/profile",
    parameters: ["userId": 123],
    from: self
)
```

## 配置说明

### 1. Info.plist 配置

在 `Info-DeepLink.plist` 中配置URL Scheme和Universal Links：

```xml
<!-- URL Scheme 配置 -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>RouterKit Example URL Scheme</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>routerkit-example</string>
        </array>
    </dict>
</array>

<!-- Universal Links 配置 -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:routerkit.example.com</string>
</array>
```

### 2. AppDelegate 集成

在 `AppDelegate.swift` 中添加深度链接处理：

```swift
// 处理URL Scheme
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return DeepLinkHandler.shared.handleURLScheme(url)
}

// 处理Universal Links
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else {
        return false
    }
    return DeepLinkHandler.shared.handleUniversalLink(url)
}
```

## 测试功能

### DeepLinkTestViewController

项目包含一个专门的测试页面，提供以下功能：

1. **URL Scheme 测试**: 测试各种URL Scheme链接
2. **Universal Links 测试**: 测试各种Universal Links
3. **参数传递测试**: 测试带参数的深度链接
4. **批量测试**: 运行所有测试用例
5. **链接生成**: 生成测试链接并复制到剪贴板
6. **分享功能**: 测试深度链接分享

### 测试用例

```swift
// URL Scheme 测试用例
let testCases = [
    "routerkit-example://login",
    "routerkit-example://message?id=123",
    "routerkit-example://profile/edit?userId=456",
    "routerkit-example://settings/theme?theme=dark"
]

// Universal Links 测试用例
let universalLinkTests = [
    "https://routerkit.example.com/login",
    "https://routerkit.example.com/profile",
    "https://routerkit.example.com/settings/notification?enabled=true"
]
```

## 最佳实践

### 1. 错误处理

```swift
func handleDeepLink(_ url: URL) -> Bool {
    guard url.scheme == "routerkit-example" else {
        print("不支持的URL Scheme: \(url.scheme ?? "nil")")
        return false
    }
    
    // 处理逻辑...
    return true
}
```

### 2. 延迟执行

```swift
// 确保应用完全启动后再执行导航
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    Router.push(route, parameters: parameters)
}
```

### 3. 参数验证

```swift
private func buildParameters(from queryItems: [URLQueryItem]?) -> [String: Any] {
    guard let queryItems = queryItems else { return [:] }
    
    var parameters: [String: Any] = [:]
    for item in queryItems {
        if let value = item.value {
            // 类型转换
            if let intValue = Int(value) {
                parameters[item.name] = intValue
            } else if let boolValue = Bool(value) {
                parameters[item.name] = boolValue
            } else {
                parameters[item.name] = value
            }
        }
    }
    
    return parameters
}
```

### 4. 调试支持

```swift
// 启用详细日志
print("DeepLinkHandler: 处理URL: \(url.absoluteString)")
print("DeepLinkHandler: 路径组件: \(pathComponents)")
print("DeepLinkHandler: 查询参数: \(queryItems?.description ?? "无")")
```

## 安全考虑

1. **URL验证**: 验证URL格式和域名
2. **参数过滤**: 过滤和验证传入参数
3. **权限检查**: 确保用户有权限访问目标页面
4. **防止注入**: 避免直接使用用户输入构建路由

## 扩展功能

### 1. 自定义处理器

```swift
class CustomDeepLinkHandler: DeepLinkHandler {
    override func processDeepLink(_ url: URL) -> Bool {
        // 自定义处理逻辑
        return super.processDeepLink(url)
    }
}
```

### 2. 分析统计

```swift
func trackDeepLinkUsage(_ url: URL) {
    // 记录深度链接使用情况
    Analytics.track("deep_link_opened", parameters: [
        "url": url.absoluteString,
        "scheme": url.scheme ?? "unknown"
    ])
}
```

### 3. A/B测试支持

```swift
func handleDeepLinkWithABTest(_ url: URL) -> Bool {
    let variant = ABTestManager.shared.getVariant("deep_link_flow")
    
    switch variant {
    case "v1":
        return handleDeepLinkV1(url)
    case "v2":
        return handleDeepLinkV2(url)
    default:
        return handleDeepLink(url)
    }
}
```

## 故障排除

### 常见问题

1. **URL Scheme不工作**
   - 检查Info.plist配置
   - 确认URL格式正确
   - 验证应用已安装

2. **Universal Links不工作**
   - 检查Associated Domains配置
   - 验证服务器apple-app-site-association文件
   - 确认域名可访问

3. **参数丢失**
   - 检查URL编码
   - 验证参数解析逻辑
   - 确认参数名称正确

### 调试技巧

1. **启用详细日志**
2. **使用测试页面验证**
3. **检查控制台输出**
4. **使用URL调试工具**

## 总结

深度链接处理为RouterKit Example提供了强大的导航能力，支持：

- ✅ URL Scheme和Universal Links
- ✅ 自动路由映射
- ✅ 参数传递和类型转换
- ✅ 分享功能
- ✅ 完整的测试套件
- ✅ 错误处理和调试支持

通过合理使用这些功能，可以大大提升应用的用户体验和功能完整性。