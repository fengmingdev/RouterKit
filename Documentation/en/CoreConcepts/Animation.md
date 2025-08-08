# Animation

RouterKit provides a way to customize the navigation animation between view controllers. You can create custom animations by conforming to the `RouterAnimation` protocol.

## Overview

Animations in RouterKit are objects that conform to the `RouterAnimation` protocol. They define how view controllers are presented and dismissed during navigation.

## Creating a Custom Animation

To create a custom animation, conform to the `RouterAnimation` protocol:

```swift
class FadeAnimation: RouterAnimation {
    func animate(from fromVC: UIViewController, to toVC: UIViewController, container: UIView, completion: @escaping () -> Void) {
        // Set initial state
        toVC.view.alpha = 0.0
        container.addSubview(toVC.view)

        // Animate
        UIView.animate(withDuration: 0.3) {
            toVC.view.alpha = 1.0
            fromVC.view.alpha = 0.0
        } completion: {
            fromVC.view.removeFromSuperview()
            completion()
        }
    }
}
```

## Registering Animations

Register animations with the router using the `registerAnimation` method:

```swift
let fadeAnimation = FadeAnimation()
router.registerAnimation(fadeAnimation, for: "fade")
```

## Using Animations

Specify an animation when navigating:

```swift
router.navigate(to: "/detail", options: [.animation("fade")])
```

Or set a default animation for all routes:

```swift
router.defaultAnimation = "fade"
```

## Built-in Animations

RouterKit provides several built-in animations:

- `push`: Standard push animation (UINavigationController style)
- `modal`: Standard modal presentation
- `fade`: Fade in/out animation
- `slide`: Slide animation
- `none`: No animation

## Animation Options

You can customize animation behavior using options:

```swift
router.navigate(to: "/detail", options: [
    .animation("slide"),
    .animationDuration(0.5),
    .animationOptions([.curveEaseInOut])
])
```

## Best Practices

- Keep animations simple and performant
- Test animations on different devices and screen sizes
- Provide fallback animations for older iOS versions if needed
- Use consistent animations throughout your app
- Avoid overusing custom animations (they can be distracting)