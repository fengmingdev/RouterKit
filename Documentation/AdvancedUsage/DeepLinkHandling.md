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
    Router.shared.navigate(to: url.absoluteString) { result in
        switch result {
        case .success:
            print("深度链接导航成功")
        case .failure(let error):
            print("深度链接导航失败: \(error)")
        }
    }
    return true
}
```

### SceneDelegate

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    // 处理深度链接
    Router.shared.navigate(to: url.absoluteString) { result in
        switch result {
        case .success:
            print("深度链接导航成功")
        case .failure(let error):
            print("深度链接导航失败: \(error)")
        }
    }
}
```

## 验证深度链接

可以使用拦截器验证深度链接的合法性。

```swift
class DeepLinkInterceptor: RouterInterceptor {
    let identifier = "deeplink"
    let priority = 90
    
    func shouldIntercept(for url: String, parameters: RouterParameters?) async -> Bool {
        return url.hasPrefix("/deep-link")
    }
    
    func intercept(for url: String, parameters: RouterParameters?, from sourceVC: UIViewController?) async -> InterceptorResult {
        // 验证深度链接
        if let token = parameters?.getValue(forKey: "token") as? String,
           validateToken(token) {
            return .continue
        } else {
            // 验证失败，重定向到错误页面
            return .redirect("/error")
        }
    }
    
    private func validateToken(_ token: String) -> Bool {
        // 实现token验证逻辑
        return !token.isEmpty
    }
}

// 注册拦截器
Task {
    await Router.shared.addInterceptor(DeepLinkInterceptor())
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
        Router.shared.navigate(to: url.absoluteString) { result in
            switch result {
            case .success:
                print("通用链接导航成功")
            case .failure(let error):
                print("通用链接导航失败: \(error)")
            }
        }
        return true
    }
    return false
}
```