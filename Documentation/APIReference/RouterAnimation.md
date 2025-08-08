# RouterAnimation

`RouterAnimation`协议定义了动画的接口，允许您自定义导航过渡效果。

## 方法

```swift
// 执行动画
func animate(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, completion: @escaping () -> Void)
```

## 示例

```swift
// 实现RouterAnimation协议
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

## 注册和使用

```swift
// 注册自定义动画
router.registerAnimation("fade", animation: FadeAnimation())

// 使用自定义动画
router.navigate(to: "/detail", options: [.animation(.custom("fade"))])
```