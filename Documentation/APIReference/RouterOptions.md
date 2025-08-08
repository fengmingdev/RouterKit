# RouterOptions

`RouterOptions`枚举定义了导航选项，用于配置导航行为。

## 枚举值

```swift
// 是否动画
case animated(Bool)

// 动画类型
case animation(RouterAnimationType)

// 是否模态呈现
case modal(Bool)

// 模态呈现样式
case modalPresentationStyle(UIModalPresentationStyle)

// 模态转换样式
case modalTransitionStyle(UIModalTransitionStyle)

// 是否使用导航控制器
case useNavigationController(Bool)

// 自定义导航控制器
case navigationController(UIViewController)

// 完成回调
case completion(() -> Void)
```

## 动画类型

```swift
// 动画类型
enum RouterAnimationType {
    // 无动画
    case none
    // 推送动画
    case push
    // 弹出动画
    case pop
    // 模态动画
    case modal
    // 消失动画
    case dismiss
    // 自定义动画
    case custom(String)
}
```

## 示例

```swift
// 使用导航选项
router.navigate(to: "/detail", options: [
    .animated(true),
    .animation(.push),
    .modal(false),
    .completion {
        print("Navigation completed")
    }
])

// 使用自定义动画
router.navigate(to: "/modal", options: [
    .animation(.custom("fade")),
    .modal(true),
    .modalPresentationStyle(.automatic)
])
```