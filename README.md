# RouterKit

A powerful, modular routing framework for iOS applications.

## Features
- Flexible route matching with support for parameters, regex, and wildcards
- Modular architecture with lifecycle management
- Custom navigation animations
- Route interceptors for authentication and validation
- Thread-safe implementation using Swift concurrency

## Installation

RouterKit supports multiple installation methods to suit your project needs:

### Swift Package Manager
Swift Package Manager is the recommended installation method for RouterKit.

1. In Xcode, open your project and navigate to **File > Swift Packages > Add Package Dependency**
2. Enter the repository URL: `https://github.com/fengmingdev/RouterKit.git`
3. Click **Next** and select the latest version or a specific version
4. Click **Finish** to add the package to your project

Alternatively, add the following to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/fengmingdev/RouterKit.git", from: "1.0.0")
]
```

### CocoaPods
1. If you haven't already, install CocoaPods by running `sudo gem install cocoapods`
2. Create a Podfile in your project directory if you don't have one: `pod init`
3. Add the following line to your Podfile:

```ruby
pod 'RouterKit-Swift', '~> 1.0'
```

4. Run `pod install` to install the dependency
5. Open your project using the `.xcworkspace` file instead of the `.xcodeproj` file

### Carthage
1. If you haven't already, install Carthage by following the instructions on the [official website](https://github.com/Carthage/Carthage)
2. Create a Cartfile in your project directory if you don't have one
3. Add the following line to your Cartfile:

```
github "fengmingdev/RouterKit" ~> 1.0
```

4. Run `carthage update --platform iOS` to build the framework
5. Drag the built `RouterKit.framework` from the `Carthage/Build/iOS` directory into your Xcode project
6. Add a Run Script phase to your project with the command: `/usr/local/bin/carthage copy-frameworks` and add `$(SRCROOT)/Carthage/Build/iOS/RouterKit.framework` to the input files

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