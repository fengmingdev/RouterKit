# RouterKit

A powerful, modular routing framework for iOS applications.

## Features
- Flexible route matching with support for parameters, regex, and wildcards
- Modular architecture with lifecycle management
- Custom navigation animations
- Route interceptors for authentication and validation
- Thread-safe implementation using Swift concurrency

## Installation

RouterKit supports multiple installation methods:

### Swift Package Manager
Add the following to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/fengmingdev/RouterKit.git", from: "1.0.0")
]
```

### CocoaPods
Add the following to your Podfile:

```ruby
pod 'RouterKit', '~> 1.0'
```

### Carthage
Add the following to your Cartfile:

```
github "fengmingdev/RouterKit" ~> 1.0
```

## Usage

### Basic Setup

```swift
import RouterKit

// Initialize the router
let router = Router.shared

// Register routes
router.register("/home") { parameters in
    return HomeViewController()
}

router.register("/user/:id") { parameters in
    guard let userId = parameters["id"] as? String else {
        return nil
    }
    return UserViewController(userId: userId)
}

// Navigate to a route
router.navigate(to: "/home")
router.navigate(to: "/user/123")
```

### Advanced Usage

#### Custom Animations

```swift
// Register a custom animation
router.registerAnimation("fade") {
    return FadeAnimation()
}

// Use the custom animation when navigating
router.navigate(to: "/settings", animationId: "fade")
```

#### Route Interceptors

```swift
// Create an authentication interceptor
class AuthInterceptor: BaseInterceptor {
    override func intercept(url: URL, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        if isUserLoggedIn() {
            completion(.allow)
        } else {
            completion(.redirect(to: "/login"))
        }
    }
}

// Register the interceptor
router.addInterceptor(AuthInterceptor())
```

## Documentation

Full documentation is available in the [Documentation](Documentation/) directory.

## Examples

Check out the [Examples](Examples/) directory for sample projects demonstrating different use cases.