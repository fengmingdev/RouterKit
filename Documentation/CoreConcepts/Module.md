# 模块(Module)

模块系统允许您将应用程序划分为独立的功能模块，每个模块可以注册自己的路由，实现模块化开发。

## 创建模块

要创建模块，需要实现`RouterModuleProtocol`协议。

```swift
class UserModule: RouterModuleProtocol {
    var name: String { return "user" }
    
    func registerRoutes(with router: Router) {
        // 注册模块内的路由
        router.register("/user/profile") { _ in
            return ProfileViewController()
        }
        
        router.register("/user/settings") { _ in
            return SettingsViewController()
        }
    }
}
```

## 注册模块

使用`registerModule`方法注册模块。

```swift
// 创建模块实例
let userModule = UserModule()

// 注册模块
router.registerModule(userModule)
```

## 模块依赖

模块可以依赖其他模块。

```swift
class OrderModule: RouterModuleProtocol {
    var name: String { return "order" }
    var dependencies: [String] { return ["user"] }
    
    func registerRoutes(with router: Router) {
        // 注册订单相关路由
        router.register("/order/list") { _ in
            return OrderListViewController()
        }
    }
}
```

## 模块初始化顺序

RouterKit会根据模块依赖关系自动确定初始化顺序。依赖其他模块的模块会在被依赖模块之后初始化。

## 模块通信

模块之间可以通过以下方式通信：

1. 通过路由导航
2. 通过共享数据模型
3. 通过通知中心
4. 通过依赖注入

```swift
// 模块间通过路由导航通信
router.navigate(to: "/user/profile")

// 模块间通过共享数据模型通信
UserManager.shared.currentUser = newUser
```

## 动态加载模块

RouterKit支持动态加载模块，您可以在运行时根据需要加载或卸载模块。

```swift
// 动态加载模块
if let moduleClass = NSClassFromString("MyApp.AdminModule") as? RouterModuleProtocol.Type {
    let module = moduleClass.init()
    router.registerModule(module)
}

// 卸载模块
router.unregisterModule("admin")
```