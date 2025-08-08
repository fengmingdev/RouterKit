# 多路由器实例

RouterKit允许您在同一应用中创建多个路由器实例，以满足不同的路由需求。

## 创建多个路由器实例

```swift
// 创建主路由器
let mainRouter = Router.shared

// 创建自定义路由器
let adminRouter = Router()
let userRouter = Router()
```

## 配置不同的路由器实例

您可以为不同的路由器实例配置不同的路由、拦截器和动画。

```swift
// 配置主路由器
mainRouter.register("/home") { _ in
    return HomeViewController()
}

// 配置管理员路由器
adminRouter.register("/admin/dashboard") { _ in
    return AdminDashboardViewController()
}

// 配置用户路由器
userRouter.register("/user/profile") { _ in
    return UserProfileViewController()
}
```

## 使用多个路由器实例

```swift
// 使用主路由器
mainRouter.navigate(to: "/home")

// 使用管理员路由器
adminRouter.navigate(to: "/admin/dashboard")

// 使用用户路由器
userRouter.navigate(to: "/user/profile")
```

## 路由器实例隔离

不同的路由器实例是完全隔离的，它们不会共享路由、拦截器或动画。

```swift
// 主路由器中注册的路由不会影响管理员路由器
mainRouter.register("/about") { _ in ... }
print(adminRouter.routes.count) // 输出: 0
```

## 组合多个路由器实例

您可以创建一个主路由器来协调多个子路由器。

```swift
class CompositeRouter {
    let mainRouter: Router
    let adminRouter: Router
    let userRouter: Router
    
    init() {
        self.mainRouter = Router.shared
        self.adminRouter = Router()
        self.userRouter = Router()
    }
    
    func navigate(to path: String, from source: UIViewController? = nil) -> Bool {
        if path.hasPrefix("/admin") {
            return adminRouter.navigate(to: path, from: source)
        } else if path.hasPrefix("/user") {
            return userRouter.navigate(to: path, from: source)
        } else {
            return mainRouter.navigate(to: path, from: source)
        }
    }
}
```

## 适用场景

多路由器实例适用于以下场景：

1. 大型应用程序，不同模块需要独立的路由管理
2. 应用程序包含多个独立的功能区域
3. 需要为不同的用户角色提供不同的路由系统
4. 测试环境中需要隔离路由

## 最佳实践

1. 尽量使用全局共享实例，只在必要时创建多个路由器实例
2. 为每个路由器实例设置清晰的职责边界
3. 使用组合模式协调多个路由器实例
4. 避免在多个路由器实例之间共享状态