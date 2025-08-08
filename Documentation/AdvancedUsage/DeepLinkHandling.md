# 深度链接处理

RouterKit支持处理外部深度链接，允许用户从应用外部通过URL打开应用内的特定页面。

## 配置URL Scheme

要处理深度链接，首先需要在Xcode中配置URL Scheme。

1. 打开项目设置
2. 选择TARGETS > Info > URL Types
3. 点击+按钮添加新的URL Type
4. 在URL Schemes字段中输入您的自定义scheme（例如：routerkit）

## 处理深度链接

在AppDelegate或SceneDelegate中处理深度链接。

### AppDelegate

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // 处理深度链接
    return Router.shared.navigate(to: url)
}
```

### SceneDelegate

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    // 处理深度链接
    Router.shared.navigate(to: url)
}
```

## 验证深度链接

可以使用拦截器验证深度链接的合法性。

```swift
class DeepLinkInterceptor: RouterInterceptor {
    func shouldNavigate(to path: String, context: RouteContext) -> Bool {
        // 验证深度链接
        if path.hasPrefix("/deep-link") {
            // 检查签名或权限
            if let token = context.queryParameters["token"], validateToken(token) {
                return true
            } else {
                // 验证失败，导航到错误页面
                Router.shared.navigate(to: "/error")
                return false
            }
        }
        return true
    }
}
```

## 测试深度链接

可以使用以下方法测试深度链接：

### 使用Xcode

1. 选择Product > Scheme > Edit Scheme...
2. 选择Run > Arguments > Arguments Passed On Launch
3. 添加参数：-u routerkit://home

### 使用终端

```bash
xcrun simctl openurl booted routerkit://user/123
```

## 通用链接

RouterKit也支持Apple的通用链接。要使用通用链接，需要：

1. 配置Associated Domains
2. 上传apple-app-site-association文件到您的服务器
3. 在AppDelegate或SceneDelegate中处理通用链接

```swift
// AppDelegate
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
        return Router.shared.navigate(to: url)
    }
    return false
}
```