# Interceptor

Interceptors allow you to intercept and modify the navigation process in RouterKit. They provide a way to implement cross-cutting concerns like authentication, logging, and analytics.

## Overview

Interceptors are objects that conform to the `RouterInterceptor` protocol. They can be registered with the router and will be called during the navigation process.

## Creating an Interceptor

To create an interceptor, conform to the `RouterInterceptor` protocol:

```swift
class AuthInterceptor: RouterInterceptor {
    func shouldNavigate(to url: URL, context: RouteContext) -> Bool {
        // Check if user is authenticated
        if isUserAuthenticated() {
            return true
        } else {
            // Redirect to login page
            Router.shared.navigate(to: "/login")
            return false
        }
    }
}
```

## Registering Interceptors

Register interceptors with the router using the `addInterceptor` method:

```swift
let authInterceptor = AuthInterceptor()
router.addInterceptor(authInterceptor)
```

## Interceptor Methods

The `RouterInterceptor` protocol defines the following methods:

### shouldNavigate

Called before navigation occurs. Return `true` to allow navigation, `false` to cancel it.

```swift
func shouldNavigate(to url: URL, context: RouteContext) -> Bool
```

### willNavigate

Called after `shouldNavigate` has returned `true` but before the view controller is presented.

```swift
func willNavigate(to url: URL, context: RouteContext)
```

### didNavigate

Called after the view controller has been presented.

```swift
func didNavigate(to url: URL, context: RouteContext, viewController: UIViewController?)
```

### navigationFailed

Called if navigation fails for any reason.

```swift
func navigationFailed(to url: URL, context: RouteContext, error: Error?)
```

## Interceptor Priority

You can set a priority for interceptors to control the order in which they are called:

```swift
authInterceptor.priority = 100 // Higher priority means it will be called first
```

## Use Cases

### Authentication

Check if the user is authenticated before allowing access to protected routes.

### Logging

Log navigation events for debugging or analytics purposes.

### Redirects

Redirect users from old routes to new ones.

### Analytics

Track which routes are being accessed by users.

## Best Practices

- Keep interceptors focused on a single responsibility
- Use priority to control the order of interceptor execution
- Be mindful of performance (avoid heavy operations in interceptors)
- Use interceptors for cross-cutting concerns, not for business logic specific to a single route