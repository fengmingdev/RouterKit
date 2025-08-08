# Route Priority

RouterKit uses a priority system to determine which route to match when multiple routes could potentially match a URL.

## Default Priority Order

By default, RouterKit uses the following priority order when matching routes:

1. Custom route matchers (highest priority)
2. Static routes (e.g., "/home")
3. Routes with dynamic parameters (e.g., "/user/:id")
4. Wildcard routes (e.g., "/search/*")

## Explicit Priority

You can set an explicit priority when registering routes to override the default order:

```swift
// Set explicit priority when registering a route
router.register("/user/profile", priority: 10) { context in
    return UserProfileViewController()
}
```

## Priority for Custom Matchers

Custom route matchers have a `priority` property that determines their evaluation order:

```swift
class HighPriorityMatcher: CustomRouteMatcher {
    let priority: Int = 100 // Higher priority
    // ...
}
```

## Route Groups

You can set a priority for a group of routes by using a namespace:

```swift
// Set priority for all routes in the "admin" namespace
router.setNamespacePriority("admin", priority: 50)

// Register routes in the namespace
router.register("/dashboard", namespace: "admin") { context in
    return AdminDashboardViewController()
}
```

## Conflict Resolution

When two routes with the same priority could match a URL, RouterKit uses the order in which the routes were registered. Routes registered earlier have higher priority.

```swift
// This route will be matched first if there's a conflict
router.register("/user/:id") { context in
    return UserViewController(userId: context.parameters["id"])
}

// This route will be matched only if the first route doesn't match
router.register("/user/*") { context in
    return UserFallbackViewController()
}
```

##查看路由优先级

You can view the priority of all registered routes using the `describeRoutes` method:

```swift
print(router.describeRoutes())
```

## Best Practices

- Use explicit priorities sparingly
- Prefer the default priority order when possible
- Document any non-standard priority settings
- Use namespaces to group related routes and set their priorities
- Test route matching with URLs that could match multiple routes
- Avoid registering routes with the same pattern and priority