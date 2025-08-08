# 拦截器(Interceptor)

拦截器允许您在导航过程中的不同阶段插入自定义逻辑，如权限检查、日志记录等。

## 创建拦截器

要创建拦截器，需要实现`RouterInterceptor`协议。

```swift
class AuthInterceptor: RouterInterceptor {
    func shouldNavigate(to path: String, context: RouteContext) -> Bool {
        // 检查用户是否已登录
        if path.hasPrefix("/profile") && !AuthManager.shared.isLoggedIn {
            // 未登录，导航到登录页面
            Router.shared.navigate(to: "/login")
            return false
        }
        return true
    }
}
```

## 注册拦截器

使用`addInterceptor`方法注册拦截器。

```swift
// 创建拦截器实例
let authInterceptor = AuthInterceptor()

// 注册拦截器
router.addInterceptor(authInterceptor)
```

## 拦截器优先级

可以为拦截器设置优先级，优先级高的拦截器会先执行。

```swift
// 设置拦截器优先级
router.addInterceptor(authInterceptor, priority: 100)
router.addInterceptor(logInterceptor, priority: 50)
```

## 拦截器类型

RouterKit支持以下类型的拦截器：

- `shouldNavigate`: 在导航开始前调用，决定是否允许导航
- `willNavigate`: 在导航即将开始时调用
- `didNavigate`: 在导航完成后调用
- `willDismiss`: 在视图控制器即将消失时调用
- `didDismiss`: 在视图控制器消失后调用

## 全局拦截器和局部拦截器

- 全局拦截器: 对所有路由生效
- 局部拦截器: 只对特定路由生效

```swift
// 全局拦截器
router.addInterceptor(globalInterceptor)

// 局部拦截器
router.register("/profile") { _ in
    return ProfileViewController()
}.addInterceptor(profileInterceptor)
```

## 移除拦截器

使用`removeInterceptor`方法移除拦截器。

```swift
// 移除拦截器
router.removeInterceptor(authInterceptor)
```