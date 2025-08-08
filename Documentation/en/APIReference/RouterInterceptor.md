# RouterInterceptor

The `RouterInterceptor` protocol defines methods for intercepting and modifying the navigation process in RouterKit.

## Protocol Definition

```swift
public protocol RouterInterceptor: AnyObject {
    var priority: Int { get set }
    func shouldNavigate(to url: URL, context: RouteContext) -> Bool
    func willNavigate(to url: URL, context: RouteContext)
    func didNavigate(to url: URL, context: RouteContext, viewController: UIViewController?)
    func navigationFailed(to url: URL, context: RouteContext, error: Error?)
}
```

## Properties

### priority

The priority of the interceptor. Higher priority interceptors are called first.

```swift
var priority: Int { get set }
```

## Methods

### shouldNavigate(to:context:)

Called before navigation occurs. Return `true` to allow navigation, `false` to cancel it.

```swift
func shouldNavigate(to url: URL, context: RouteContext) -> Bool
```

### willNavigate(to:context:)

Called after `shouldNavigate` has returned `true` but before the view controller is presented.

```swift
func willNavigate(to url: URL, context: RouteContext)
```

### didNavigate(to:context:viewController:)

Called after the view controller has been presented.

```swift
func didNavigate(to url: URL, context: RouteContext, viewController: UIViewController?)
```

### navigationFailed(to:context:error:)

Called if navigation fails for any reason.

```swift
func navigationFailed(to url: URL, context: RouteContext, error: Error?)
```

## Default Implementations

RouterKit provides default implementations for all methods except `shouldNavigate`, which means you only need to implement the methods you care about.

## Example

```swift
class AuthInterceptor: RouterInterceptor {
    var priority: Int = 100

    func shouldNavigate(to url: URL, context: RouteContext) -> Bool {
        // Check if the route is protected
        if url.path.starts(with: "/protected") {
            // Check if user is authenticated
            if !isAuthenticated() {
                // Redirect to login
                Router.shared.navigate(to: URL(string: "/login")!)
                return false
            }
        }
        return true
    }

    // Optional: Implement other methods if needed
    func didNavigate(to url: URL, context: RouteContext, viewController: UIViewController?) {
        // Log navigation event
        print("Navigated to: \(url.path)")
    }
}

// Register the interceptor
let authInterceptor = AuthInterceptor()
Router.shared.addInterceptor(authInterceptor)
```