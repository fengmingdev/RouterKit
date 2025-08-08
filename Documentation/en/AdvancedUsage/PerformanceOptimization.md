# Performance Optimization

RouterKit is designed for high performance, but there are several techniques you can use to optimize routing in large applications.

## Route Prefixing

Group routes with common prefixes to improve matching performance:

```swift
// Instead of registering individual routes
router.register("/user/profile") { ... }
router.register("/user/settings") { ... }
router.register("/user/favorites") { ... }

// Group routes with a common prefix
let userGroup = router.group("/user")
userGroup.register("/profile") { ... }
userGroup.register("/settings") { ... }
userGroup.register("/favorites") { ... }
```

## Lazy Loading Routes

Defer route registration until they're needed:

```swift
// Register basic routes immediately
router.register("/home") { ... }
router.register("/login") { ... }

// Lazy load feature routes when first accessed
router.lazyRegister("/dashboard") {
    // Load module dynamically
    let dashboardModule = try! DashboardModule()
    return dashboardModule.makeViewController()
}

// Lazy load entire modules
router.lazyRegisterModule("AdminModule") {
    // Load and return module
    return AdminModule()
}
```

## Route Caching

Enable route caching to improve performance for frequently accessed routes:

```swift
// Enable caching for all routes
router.enableRouteCaching()

// Set cache size (default is 100)
router.routeCacheSize = 200

// Disable caching for specific routes
router.register("/dynamic-content", cacheable: false) { ... }
```

## Optimizing Route Patterns

Use more specific route patterns to reduce matching time:

```swift
// Instead of general patterns
router.register("/item/*") { ... }

// Use specific patterns
router.register("/item/:id") { ... }
router.register("/item/:id/reviews") { ... }
```

## Measuring Performance

Use RouterKit's built-in metrics to identify performance bottlenecks:

```swift
// Enable metrics collection
router.enableMetricsCollection()

// Access metrics data
let metrics = router.metrics
print("Average matching time: \(metrics.averageMatchingTime)ms")
print("Slowest route: \(metrics.slowestRoute?.pattern ?? "N/A")")
```

## Avoiding Route Conflicts

Prevent route conflicts to ensure routes match correctly the first time:

```swift
// Check for conflicts when registering routes
router.register("/user/:id") { ... }
if router.hasConflict("/user/profile") {
    print("Route conflict detected!")
}

// Resolve conflicts by adjusting priorities
router.register("/user/profile", priority: 10) { ... }
```

## Best Practices

- Keep route patterns simple and specific
- Group related routes with common prefixes
- Lazy load routes for rarely used features
- Use route caching for frequently accessed routes
- Measure performance in production to identify bottlenecks
- Avoid using regular expressions for simple patterns
- Register routes during app initialization when possible