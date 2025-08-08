# RouterModuleProtocol

`RouterModuleProtocol`协议定义了模块的接口，允许您将应用程序划分为独立的功能模块。

## 属性

```swift
// 模块名称
var name: String { get }

// 模块依赖
var dependencies: [String] { get }
```

## 方法

```swift
// 注册模块路由
func registerRoutes(with router: Router)
```

## 示例

```swift
// 实现RouterModuleProtocol协议
class UserModule: RouterModuleProtocol {
    var name: String { return "user" }
    var dependencies: [String] { return [] }
    
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

```swift
// 注册模块
let userModule = UserModule()
router.registerModule(userModule)
```