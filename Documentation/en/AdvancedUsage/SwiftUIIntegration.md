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

Register SwiftUI views as routes using the `registerRoute` method with SwiftUIRoutable:

```swift
// Create SwiftUI Routable classes
class HomeRoutable: UIViewController, Routable {
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return UIHostingController(rootView: HomeView())
    }
}

class UserRoutable: UIViewController, Routable {
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        guard let userId = context.parameters["id"] else {
            return UIHostingController(rootView: ErrorView(message: "Invalid user ID"))
        }
        return UIHostingController(rootView: UserView(userId: userId))
    }
}

// Register the routes
Task {
    try await Router.shared.registerRoute("/home", for: HomeRoutable.self)
    try await Router.shared.registerRoute("/user/:id", for: UserRoutable.self)
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
// Create a Routable class for product view
class ProductRoutable: UIViewController, Routable {
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        guard let productId = context.parameters["id"] else {
            return UIHostingController(rootView: ErrorView(message: "Invalid product ID"))
        }
        return UIHostingController(rootView: ProductView(productId: productId))
    }
}

// Register the route
Task {
    try await Router.shared.registerRoute("/product/:id", for: ProductRoutable.self)
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
// Create a Routable class for settings view
class SettingsRoutable: UIViewController, Routable {
    static func createViewController(context: RouteContext) async throws -> UIViewController {
        return UIHostingController(rootView: SettingsView())
    }
}

// Register the route
Task {
    try await Router.shared.registerRoute("/settings", for: SettingsRoutable.self)
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
- Use `registerRoute` with `UIHostingController` for SwiftUI views
- Use `RouterState` to observe and manipulate the current route
- Keep route parameters simple and pass only what's needed
- Use interceptors for cross-cutting concerns like authentication
- Test navigation flows thoroughly in SwiftUI previews