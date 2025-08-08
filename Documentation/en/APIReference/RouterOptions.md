# RouterOptions

The `RouterOptions` enum defines options for navigation and presentation in RouterKit.

## Enum Definition

```swift
public enum RouterOptions: Equatable {
    case animated(Bool)
    case presentationStyle(UIModalPresentationStyle)
    case transitionStyle(UIModalTransitionStyle)
    case animation(String)
    case animationDuration(TimeInterval)
    case animationOptions(UIView.AnimationOptions)
    case prefersStatusBarHidden(Bool)
    case completion(() -> Void)
}
```

## Cases

### animated(Bool)

Specifies whether the navigation should be animated.

```swift
.animated(true)
```

### presentationStyle(UIModalPresentationStyle)

Specifies the presentation style for modal view controllers.

```swift
.presentationStyle(.formSheet)
```

### transitionStyle(UIModalTransitionStyle)

Specifies the transition style for modal view controllers.

```swift
.transitionStyle(.crossDissolve)
```

### animation(String)

Specifies the name of a custom animation to use.

```swift
.animation("fade")
```

### animationDuration(TimeInterval)

Specifies the duration of the animation in seconds.

```swift
.animationDuration(0.5)
```

### animationOptions(UIView.AnimationOptions)

Specifies additional animation options.

```swift
.animationOptions([.curveEaseInOut, .allowUserInteraction])
```

### prefersStatusBarHidden(Bool)

Specifies whether the status bar should be hidden during navigation.

```swift
.prefersStatusBarHidden(true)
```

### completion(() -> Void)

A closure to call when the navigation is complete.

```swift
.completion { print("Navigation completed") }
```

## Example

```swift
// Use options when navigating
Router.shared.navigate(to: URL(string: "/detail")!, options: [
    .animated(true),
    .animation("slide"),
    .animationDuration(0.5),
    .presentationStyle(.fullScreen),
    .completion { print("Navigation to detail completed") }
])
```