# 模块(Module)

模块系统允许您将应用程序划分为独立的功能模块，每个模块可以注册自己的路由，实现模块化开发。

## 创建模块

要创建模块，需要实现`ModuleProtocol`协议。

```swift
class UserModule: ModuleProtocol {
    let name = "User"
    let version = "1.0.1"
    
    func initialize() async throws {
        // 模块初始化逻辑
        print("用户模块初始化")
    }
    
    func registerRoutes() async throws {
        // 注册模块内的路由
        try await Router.shared.registerRoute("/user/profile", for: ProfileViewController.self)
        try await Router.shared.registerRoute("/user/settings", for: SettingsViewController.self)
    }
    
    func cleanup() async {
        // 清理资源
        print("用户模块清理")
    }
}
```

## 注册模块

使用`registerModule`方法注册模块。

```swift
// 创建模块实例
let userModule = UserModule()

// 异步注册模块
Task {
    await router.registerModule(userModule)
}
```

## 模块管理

可以检查模块状态和获取模块实例。

```swift
// 检查模块是否已加载
Task {
    let isLoaded = await router.isModuleLoaded("User")
    print("用户模块已加载: \(isLoaded)")
    
    // 获取模块实例
    if let userModule = await router.getModule("User") {
        print("获取到用户模块: \(userModule.name)")
    }
    
    // 通过类型获取模块
    if let userModule = await router.getModule(UserModule.self) {
        print("通过类型获取用户模块: \(userModule.name)")
    }
}
```

## 模块生命周期

模块具有完整的生命周期管理：

1. `load()`: 模块加载，在注册时调用
2. `unload()`: 模块卸载，在注销时调用
3. `suspend()`: 模块暂停
4. `resume()`: 模块恢复

## 模块通信

模块之间可以通过以下方式通信：

1. 通过路由导航
2. 通过共享数据模型
3. 通过通知中心
4. 通过依赖注入

```swift
// 模块间通过路由导航通信
Router.push(to: "/user/profile")

// 模块间通过共享数据模型通信
UserManager.shared.currentUser = newUser

// 模块间通过参数传递数据
let parameters = RouterParameters()
parameters.setValue(userId, forKey: "userId")
Router.push(to: "/order/detail", parameters: parameters)
```

## 动态加载模块

RouterKit支持动态加载模块，您可以在运行时根据需要加载或卸载模块。

```swift
// 动态创建模块
if let module = router.createModule(named: "AdminModule") {
    Task {
        await router.registerModule(module)
    }
}

// 卸载模块
Task {
    await router.unregisterModule("Admin")
}
```

## 版本更新日志

### 1.0.1 (2025-09-08)

- 修复了ParameterPassingModule中的路由名称不匹配问题
- 修复了TabBarController中animateTabSelection方法的语法错误
- 修复了ErrorHandlingModule中路由大小写不匹配的问题
- 修复了HomeViewController中快速导航按钮无法点击的UI约束问题

### 1.0.0 (2025-01-23)

- 初始版本发布