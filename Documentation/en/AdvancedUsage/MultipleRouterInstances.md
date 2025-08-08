# Multiple Router Instances

RouterKit allows you to create multiple router instances, which can be useful for isolating routing logic between different parts of your app.

## Creating Multiple Instances

You can create multiple router instances by initializing them with different names:

```swift
// Create main router
let mainRouter = Router.shared

// Create secondary router
let adminRouter = Router(name: "admin")

// Create feature-specific router
let paymentRouter = Router(name: "payment")
```

## Configuring Different Routes

Each router instance can have its own set of routes:

```swift
// Configure main router
mainRouter.register("/home") { context in
    return HomeViewController()
}

// Configure admin router
adminRouter.register("/admin/dashboard") { context in
    return AdminDashboardViewController()
}
```

## Using Different Interceptors

Each router instance can have its own interceptors:

```swift
// Add interceptor to main router
mainRouter.addInterceptor(LoggingInterceptor())

// Add interceptor to admin router
adminRouter.addInterceptor(AuthInterceptor(requiredRole: .admin))
```

## Using Different Animations

Each router instance can have its own default animation and registered animations:

```swift
// Set default animation for main router
mainRouter.defaultAnimation = "slide"

// Set default animation for admin router
adminRouter.defaultAnimation = "fade"
```

## Isolating Router Instances

Router instances are completely isolated from each other. Routes, interceptors, and animations registered with one instance do not affect others:

```swift
// This route is only available on mainRouter
mainRouter.register("/profile") { context in
    return UserProfileViewController()
}

// This will not match any route on adminRouter
adminRouter.navigate(to: URL(string: "/profile")!)
```

## Combining Router Instances

You can create a parent router that delegates to child routers:

```swift
class CompositeRouter: Router {
    let childRouters: [Router]

    init(childRouters: [Router]) {
        self.childRouters = childRouters
        super.init(name: "composite")
    }

    override func match(_ url: URL) -> RouteMatchResult? {
        // Try to match with self first
        if let result = super.match(url) {
            return result
        }

        // Then try child routers
        for router in childRouters {
            if let result = router.match(url) {
                return result
            }
        }

        return nil
    }
}

// Usage
let compositeRouter = CompositeRouter(childRouters: [mainRouter, adminRouter])
```

## Use Cases

- **Modular Apps**: Isolate routing logic between different modules
- **Feature Flags**: Use different routers for different feature flag configurations
- **Testing**: Use a separate router for testing with mock routes
- **Admin vs. User**: Separate admin and user routing logic

## Best Practices

- Keep the number of router instances to a minimum
- Use descriptive names for router instances
- Document which router instance should be used for each part of your app
- Consider using a composite router for shared routing logic
- Be careful with dependencies between router instances