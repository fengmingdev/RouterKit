# Route Context

The `RouteContext` is an object that contains information about a matched route and is passed to the route handler when navigation occurs.

## Overview

When a route is matched, RouterKit creates a `RouteContext` instance that encapsulates all relevant information about the navigation request. This includes parameters extracted from the URL, query parameters, user-provided data, and navigation options.

## Accessing Context Data

### Parameters

Dynamic parameters and query parameters are available in the `parameters` dictionary:

```swift
router.register("/user/:id") { context in
    // Access dynamic parameter
    let userId = context.parameters["id"]

    // Access query parameter (e.g., from "/user/123?mode=edit")
    let mode = context.parameters["mode"]

    return UserViewController(userId: userId, mode: mode)
}
```

### User Info

You can pass custom data when navigating, which is available in the `userInfo` dictionary:

```swift
// When navigating
router.navigate(to: "/detail", context: ["item": myItem])

// In the route handler
router.register("/detail") { context in
    if let item = context.userInfo["item"] as? MyItemType {
        return DetailViewController(item: item)
    }
    return nil
}
```

### URL

The original URL that was matched is available via the `url` property:

```swift
router.register("/search/*") { context in
    let searchPath = context.url.path
    return SearchViewController(path: searchPath)
}
```

### Options

Navigation options are available via the `options` property:

```swift
router.register("/settings") { context in
    let isAnimated = context.options.contains(.animated(true))
    return SettingsViewController(animated: isAnimated)
}
```

## Modifying Context

You can modify the context in interceptors to pass additional information to the route handler:

```swift
class AuthInterceptor: RouterInterceptor {
    func shouldNavigate(to url: URL, context: RouteContext) -> Bool {
        if isAuthenticated() {
            // Add user info to context
            context.userInfo["user"] = currentUser
            return true
        } else {
            // Redirect to login
            router.navigate(to: "/login")
            return false
        }
    }
}
```

## Best Practices

- Use the context to pass only necessary data
- Avoid modifying the context in route handlers (prefer interceptors for that)
- Use type casting when accessing `userInfo` values
- Keep the context lightweight to maintain performance