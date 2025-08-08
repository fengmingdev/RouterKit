# 路由器(Router)

路由器是RouterKit的核心组件，负责管理路由注册、解析和导航。

## 初始化路由器

RouterKit提供了一个全局共享实例，您也可以创建自定义实例。

```swift
// 使用全局共享实例
let router = Router.shared

// 创建自定义实例
let customRouter = Router()
```

## 注册路由

使用`register`方法注册路由。

```swift
// 基本注册
router.register("/home") { context in
    return HomeViewController()
}

// 带参数的路由
router.register("/user/:id") { context in
    guard let userId = context.parameters["id"] else { return nil }
    return UserViewController(userId: userId)
}

// 带谓词的路由
router.register("/profile", predicate: { context in
    return AuthManager.shared.isLoggedIn
}) { context in
    return ProfileViewController()
}
```

## 导航

使用`navigate`方法执行导航。

```swift
// 基本导航
router.navigate(to: "/home")

// 带参数的导航
router.navigate(to: "/user/123")

// 带选项的导航
router.navigate(to: "/settings", options: [.animated(true), .modal(true)])
```

## 反向路由生成

使用`generateURL`方法根据路由名称和参数生成URL。

```swift
// 生成URL
if let url = router.generateURL(for: "user", parameters: ["id": "123"]) {
    print(url) // 输出: /user/123
}
```

## 路由组

使用`group`方法创建路由组，方便管理相关路由。

```swift
// 创建路由组
router.group("/api") { api in
    api.register("/users") { _ in
        return UsersViewController()
    }
    api.register("/posts") { _ in
        return PostsViewController()
    }
}
```

## 清除路由

使用`removeAllRoutes`方法清除所有已注册的路由。

```swift
// 清除所有路由
router.removeAllRoutes()
```