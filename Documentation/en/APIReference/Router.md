# Router

The `Router` class is the central component of RouterKit, responsible for route registration, matching, and navigation.

## Properties

### shared

The shared singleton instance of `Router`.

```swift
static let shared: Router
```

### name

The name of the router instance.

```swift
let name: String
```

### defaultAnimation

The default animation to use for navigation when no animation is specified.

```swift
var defaultAnimation: String?
```

## Initializers

### init(name:)

Creates a new router instance with the specified name.

```swift
init(name: String = "default")
```

## Methods

### register(_:handler:)

Registers a route with a handler.

```swift
func register(_ pattern: String, handler: @escaping RouteHandler)
```

### register(_:options:handler:)

Registers a route with options and a handler.

```swift
func register(_ pattern: String, options: [RouterOptions], handler: @escaping RouteHandler)
```

### register(_:name:handler:)

Registers a route with a name and handler.

```swift
func register(_ pattern: String, name: String, handler: @escaping RouteHandler)
```

### register(_:namespace:handler:)

Registers a route in a namespace with a handler.

```swift
func register(_ pattern: String, namespace: String, handler: @escaping RouteHandler)
```

### navigate(to:options:context:)

Navigates to the specified URL with options and context.

```swift
func navigate(to url: URL, options: [RouterOptions] = [], context: [AnyHashable: Any] = [:]) -> Bool
```

### navigate(to:namespace:options:context:)

Navigates to the specified URL in a namespace with options and context.

```swift
func navigate(to url: URL, namespace: String, options: [RouterOptions] = [], context: [AnyHashable: Any] = [:]) -> Bool
```

### match(_:)

Matches a URL against registered routes and returns the match result.

```swift
func match(_ url: URL) -> RouteMatchResult?
```

### url(for:parameters:)

Generates a URL for a named route with parameters.

```swift
func url(for routeName: String, parameters: [String: Any] = [:]) -> URL?
```

### addInterceptor(_:)

Adds an interceptor to the router.

```swift
func addInterceptor(_ interceptor: RouterInterceptor)
```

### registerModule(_:)

Registers a module with the router.

```swift
func registerModule(_ module: RouterModuleProtocol)
```

### registerAnimation(_:for:)

Registers a custom animation with the router.

```swift
func registerAnimation(_ animation: RouterAnimation, for name: String)
```

## Example

```swift
// Get the shared router instance
let router = Router.shared

// Register routes
router.register("/home") { context in
    return HomeViewController()
}

router.register("/user/:id") { context in
    guard let userId = context.parameters["id"] else {
        return nil
    }
    return UserViewController(userId: userId)
}

// Navigate to a route
router.navigate(to: URL(string: "/home")!)

// Navigate with options
router.navigate(to: URL(string: "/user/123")!, options: [.animated(true)])
```