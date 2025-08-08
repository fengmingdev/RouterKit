# RouteContext

The `RouteContext` struct contains information about a matched route and is passed to the route handler during navigation.

## Properties

### url

The URL that was matched.

```swift
let url: URL
```

### parameters

A dictionary of parameters extracted from the URL (dynamic parameters and query parameters).

```swift
var parameters: [String: String]
```

### userInfo

A dictionary of custom information passed during navigation.

```swift
var userInfo: [AnyHashable: Any]
```

### options

The navigation options.

```swift
let options: [RouterOptions]
```

### namespace

The namespace of the matched route.

```swift
let namespace: String?
```

### routeName

The name of the matched route, if any.

```swift
let routeName: String?
```

## Example

```swift
// When registering a route
Router.shared.register("/user/:id") { context in
    // Access parameters
    let userId = context.parameters["id"]
    let mode = context.parameters["mode"] // From query parameter

    // Access user info
    let isAdmin = context.userInfo["isAdmin"] as? Bool ?? false

    // Access options
    let isAnimated = context.options.contains { option in
        if case .animated(let animated) = option { return animated }
        return false
    }

    return UserViewController(userId: userId, mode: mode, isAdmin: isAdmin, animated: isAnimated)
}

// When navigating
Router.shared.navigate(to: URL(string: "/user/123?mode=edit")!, context: ["isAdmin": true])
```