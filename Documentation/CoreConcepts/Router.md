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

使用`registerRoute`方法注册路由，需要实现`Routable`协议。

```swift
// 异步注册路由
Task {
    try await router.registerRoute("/home", for: HomeViewController.self)
    try await router.registerRoute("/user/:id", for: UserViewController.self)
}

// 链式调用注册
router.register("/home", for: HomeViewController.self)
router.register("/user/:id", for: UserViewController.self)

// 带权限的路由
let permission = RoutePermission(requiredRoles: ["user"])
try await router.registerRoute("/profile", for: ProfileViewController.self, permission: permission)
```

## 导航

使用`navigate`方法执行导航，支持多种导航类型。

```swift
// 基本导航
router.navigate(to: "/home") { result in
    switch result {
    case .success:
        print("导航成功")
    case .failure(let error):
        print("导航失败: \(error)")
    }
}

// 带参数的导航
let parameters = RouterParameters()
parameters.setValue("123", forKey: "id")
router.navigate(to: "/user/:id", parameters: parameters, type: .push) { _ in }

// 使用静态方法导航
Router.push(to: "/home")
Router.present(to: "/settings", animated: true)
Router.pop(animated: true)
```

## 路由匹配

使用`matchRoute`方法匹配路由并获取参数。

```swift
// 匹配路由
Task {
    if let match = await router.matchRoute(URL(string: "/user/123")!) {
        print("匹配的模式: \(match.pattern)")
        print("参数: \(match.parameters)")
        print("类型: \(match.type)")
    }
}
```

## 模块管理

使用模块系统组织相关路由。

```swift
// 创建模块
class APIModule: ModuleProtocol {
    let name = "API"
    let version = "1.0.0"
    
    func registerRoutes() async throws {
        try await Router.shared.registerRoute("/api/users", for: UsersViewController.self)
        try await Router.shared.registerRoute("/api/posts", for: PostsViewController.self)
    }
}

// 注册模块
Task {
    await router.registerModule(APIModule())
}
```

## 清除路由

使用`removeAllRoutes`方法清除所有已注册的路由。

```swift
// 清除所有路由
router.removeAllRoutes()
```