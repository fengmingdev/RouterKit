# SwiftUI Integration

RouterKit provides integration with SwiftUI, allowing you to use routing in your SwiftUI applications.

## Basic Integration

### RouterView

Use `RouterView` to display the current route in your SwiftUI hierarchy:

```swift
import SwiftUI
import RouterKit

struct ContentView: View {
    var body: some View {
        RouterView(router: Router.shared)
    }
}
```

### Registering SwiftUI Views

Register SwiftUI views as routes using the `registerSwiftUI` method:

```swift
// Register a SwiftUI view
Router.shared.registerSwiftUI("/home") { context in
    HomeView()
}

// Register a SwiftUI view with parameters
Router.shared.registerSwiftUI("/user/:id") { context in
    guard let userId = context.parameters["id"] else {
        return AnyView(ErrorView(message: "Invalid user ID"))
    }
    return AnyView(UserView(userId: userId))
}
```

## RouterState

Use `RouterState` to observe and manipulate the current route in SwiftUI:

```swift
struct NavigationBarView: View {
    @ObservedObject var routerState = RouterState(router: Router.shared)

    var body: some View {
        HStack {
            Button("Home") {
                routerState.navigate(to: "/home")
            }
            Button("Profile") {
                routerState.navigate(to: "/profile")
            }
            Spacer()
            Text("Current route: \(routerState.currentURL?.path ?? "none")")
        }
    }
}
```

## Passing Parameters to SwiftUI Views

You can pass parameters from the route context to your SwiftUI views:

```swift
// Register a route with parameters
Router.shared.registerSwiftUI("/product/:id") { context in
    guard let productId = context.parameters["id"] else {
        return AnyView(ErrorView(message: "Invalid product ID"))
    }
    return AnyView(ProductView(productId: productId))
}

// SwiftUI view that accepts parameters
struct ProductView: View {
    let productId: String

    var body: some View {
        Text("Product ID: \(productId)")
    }
}
```

## Navigation Style

Customize the navigation style for SwiftUI routes:

```swift
// Set navigation style for a route
Router.shared.registerSwiftUI("/settings", navigationStyle: .sheet) { context in
    SettingsView()
}

// Available navigation styles
enum NavigationStyle {
    case push
    case sheet
    case fullScreenCover
}
```

## Intercepting Navigation in SwiftUI

Use interceptors to handle navigation events in SwiftUI:

```swift
class AuthInterceptor: RouterInterceptor {
    func shouldNavigate(to url: URL, context: RouteContext) -> Bool {
        if url.path.starts(with: "/protected") {
            if !isAuthenticated() {
                // Show login sheet
                Router.shared.navigate(to: "/login", options: [.presentationStyle(.formSheet)])
                return false
            }
        }
        return true
    }
}

// Register interceptor
Router.shared.addInterceptor(AuthInterceptor())
```

## Best Practices

- Use `RouterView` as the root view of your SwiftUI hierarchy
- Prefer `registerSwiftUI` over `register` for SwiftUI views
- Use `RouterState` to observe and manipulate the current route
- Keep route parameters simple and pass only what's needed
- Use interceptors for cross-cutting concerns like authentication
- Test navigation flows thoroughly in SwiftUI previews