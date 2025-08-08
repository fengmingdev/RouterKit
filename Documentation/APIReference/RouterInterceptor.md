# RouterInterceptor

`RouterInterceptor`协议定义了拦截器的接口，允许您在导航过程中的不同阶段插入自定义逻辑。

## 方法

```swift
// 在导航开始前调用，决定是否允许导航
func shouldNavigate(to path: String, context: RouteContext) -> Bool

// 在导航即将开始时调用
func willNavigate(to path: String, context: RouteContext)

// 在导航完成后调用
func didNavigate(to path: String, context: RouteContext)

// 在视图控制器即将消失时调用
func willDismiss(viewController: UIViewController, context: RouteContext)

// 在视图控制器消失后调用
func didDismiss(viewController: UIViewController, context: RouteContext)
```

## 示例

```swift
// 实现RouterInterceptor协议
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
    
    func willNavigate(to path: String, context: RouteContext) {
        // 记录导航日志
        print("Navigating to: \(path)")
    }
}
```

## 优先级

拦截器可以设置优先级，优先级高的拦截器会先执行。

```swift
// 添加带优先级的拦截器
router.addInterceptor(authInterceptor, priority: 100)
```