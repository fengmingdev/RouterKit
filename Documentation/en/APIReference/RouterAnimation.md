# RouterAnimation

The `RouterAnimation` protocol defines methods for creating custom navigation animations in RouterKit.

## Protocol Definition

```swift
public protocol RouterAnimation: AnyObject {
    func animate(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, completion: @escaping () -> Void)
}
```

## Methods

### animate(from:to:container:completion:)

Performs the animation between two view controllers.

```swift
func animate(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, completion: @escaping () -> Void)
```

## Parameters

- `fromVC`: The view controller being navigated away from.
- `toVC`: The view controller being navigated to.
- `container`: The container view for the animation.
- `completion`: A closure to call when the animation is complete.

## Example

```swift
class SlideAnimation: RouterAnimation {
    func animate(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, completion: @escaping () -> Void) {
        // Set initial position of toVC
        toVC.view.frame = CGRect(x: container.bounds.width, y: 0, width: container.bounds.width, height: container.bounds.height)
        container.addSubview(toVC.view)

        // Animate
        UIView.animate(withDuration: 0.3, animations: {
            fromVC.view.frame = CGRect(x: -container.bounds.width, y: 0, width: container.bounds.width, height: container.bounds.height)
            toVC.view.frame = container.bounds
        }, completion: {
            fromVC.view.removeFromSuperview()
            completion()
        })
    }
}

// Register the animation
let slideAnimation = SlideAnimation()
Router.shared.registerAnimation(slideAnimation, for: "slide")

// Use the animation
Router.shared.navigate(to: URL(string: "/detail")!, options: [.animation("slide")])
```