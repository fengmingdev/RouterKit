# 拦截器(Interceptor)

拦截器允许您在导航过程中的不同阶段插入自定义逻辑，如权限检查、日志记录等。

## 创建拦截器

要创建拦截器，需要实现`RouterInterceptor`协议。

```swift
class AuthInterceptor: RouterInterceptor {
    let identifier = "auth"
    let priority = 100
    
    func shouldIntercept(for url: String, parameters: RouterParameters?) async -> Bool {
        // 检查用户是否已登录
        return url.hasPrefix("/profile") && !AuthManager.shared.isLoggedIn
    }
    
    func intercept(for url: String, parameters: RouterParameters?, from sourceVC: UIViewController?) async -> InterceptorResult {
        // 显示登录界面
        let success = await LoginViewController.present()
        return success ? .continue : .stop
    }
}
```

## 注册拦截器

使用`addInterceptor`方法注册拦截器。

```swift
// 创建拦截器实例
let authInterceptor = AuthInterceptor()

// 异步注册拦截器
Task {
    await router.addInterceptor(authInterceptor)
}
```

## 拦截器优先级

拦截器的优先级通过协议属性设置，优先级高的拦截器会先执行。

```swift
class HighPriorityInterceptor: RouterInterceptor {
    let identifier = "high_priority"
    let priority = 100  // 高优先级
    
    // 实现协议方法...
}

class LowPriorityInterceptor: RouterInterceptor {
    let identifier = "low_priority"
    let priority = 50   // 低优先级
    
    // 实现协议方法...
}
```

## 拦截器方法

RouterKit拦截器支持以下方法：

- `shouldIntercept`: 判断是否需要拦截当前导航
- `intercept`: 执行拦截逻辑，返回是否继续导航

```swift
class LogInterceptor: RouterInterceptor {
    let identifier = "log"
    let priority = 10
    
    func shouldIntercept(for url: String, parameters: RouterParameters?) async -> Bool {
        return true  // 总是记录日志
    }
    
    func intercept(for url: String, parameters: RouterParameters?, from sourceVC: UIViewController?) async -> InterceptorResult {
        print("导航到: \(url)")
        return .continue  // 继续导航
    }
}
```

## 拦截器结果

拦截器可以返回不同的结果来控制导航流程：

```swift
enum InterceptorResult {
    case continue    // 继续导航
    case stop        // 停止导航
    case redirect(String)  // 重定向到其他路径
}

class RedirectInterceptor: RouterInterceptor {
    let identifier = "redirect"
    let priority = 80
    
    func intercept(for url: String, parameters: RouterParameters?, from sourceVC: UIViewController?) async -> InterceptorResult {
        if url == "/old-path" {
            return .redirect("/new-path")
        }
        return .continue
    }
}
```

## 移除拦截器

使用`removeInterceptor`方法移除拦截器。

```swift
// 异步移除拦截器
Task {
    await router.removeInterceptor(authInterceptor)
}
```