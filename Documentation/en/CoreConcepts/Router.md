# Router

The `Router` is the central component of RouterKit that manages route registration, matching, and navigation.

## Overview

The router acts as a mediator between your app's views and the routes they can navigate to. It provides a unified interface for registering routes, handling navigation, and managing the navigation stack.

## Creating a Router Instance

You can use the shared singleton instance:

```swift
let router = Router.shared
```

Or create a custom instance:

```swift
let customRouter = Router(name: "CustomRouter")
```

## Registering Routes

Use the `register` method to register routes:

```swift
// Basic route registration
router.register("/home") { context in
    return HomeViewController()
}

// Route with parameters
router.register("/user/:id") { context in
    guard let userId = context.parameters["id"] else {
        return nil
    }
    return UserViewController(userId: userId)
}

// Route with options
router.register("/settings", options: [.animated(false)]) { context in
    return SettingsViewController()
}
```

## Navigating to Routes

Use the `navigate` method to perform navigation:

```swift
// Basic navigation
router.navigate(to: "/home")

// Navigation with options
router.navigate(to: "/profile", options: [.animated(true), .presentationStyle(.modal)])

// Navigation with user info
router.navigate(to: "/detail", context: ["itemId": 123])
```

## Matching Routes

You can check if a URL matches any registered route using the `match` method:

```swift
if let matchResult = router.match("/user/123") {
    let viewController = matchResult.handler(matchResult.context)
    // Present the view controller
}
```

## Advanced Features

### Namespace

You can use namespaces to isolate routes:

```swift
router.register("/settings", namespace: "admin") { context in
    return AdminSettingsViewController()
}

// Navigate to namespace route
router.navigate(to: "/settings", namespace: "admin")
```

### Reverse Routing

Generate URLs from route names and parameters:

```swift
router.register("/user/:id", name: "userDetail") { context in
    // Handler code
}

if let url = router.url(for: "userDetail", parameters: ["id": "123"]) {
    // Use the generated URL
}
```

## Best Practices

- Register routes during app initialization or module loading
- Use meaningful route patterns that reflect your app's structure
- Take advantage of namespaces for modular apps
- Use interceptors for cross-cutting concerns like authentication