# 动画(Animation)

RouterKit支持自定义导航动画，您可以为不同的路由定义不同的过渡效果。

## 使用内置动画

RouterKit提供了多种内置动画。

```swift
// 使用内置动画
router.navigate(to: "/detail", options: [.animation(.push)])
router.navigate(to: "/modal", options: [.animation(.modal), .modal(true)])
```

## 创建自定义动画

要创建自定义动画，需要实现`RouterAnimation`协议。

```swift
class FadeAnimation: RouterAnimation {
    func animate(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, completion: @escaping () -> Void) {
        // 设置初始状态
        toVC.view.alpha = 0
        container.addSubview(toVC.view)
        
        // 执行动画
        UIView.animate(withDuration: 0.3) {
            toVC.view.alpha = 1
            fromVC.view.alpha = 0
        } completion: {
            fromVC.view.removeFromSuperview()
            completion()
        }
    }
}
```

## 注册动画

使用`registerAnimation`方法注册自定义动画。

```swift
// 注册自定义动画
router.registerAnimation("fade", animation: FadeAnimation())
```

## 使用自定义动画

在导航时指定动画名称。

```swift
// 使用自定义动画
router.navigate(to: "/detail", options: [.animation(.custom("fade"))])
```

## 为路由指定默认动画

可以为特定路由指定默认动画。

```swift
// 为路由指定默认动画
router.register("/detail") { _ in
    return DetailViewController()
}.animation(.custom("fade"))
```

## 动画选项

RouterKit提供了以下动画选项：

- `push`: 标准推送动画
- `pop`: 标准弹出动画
- `modal`: 模态呈现动画
- `dismiss`: 模态消失动画
- `none`: 无动画
- `custom`: 自定义动画

```swift
// 组合动画选项
router.navigate(to: "/detail", options: [.animation(.push), .animated(true)])
```