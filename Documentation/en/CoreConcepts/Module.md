# Module

Modules are a way to organize routes and dependencies in RouterKit, making it easier to modularize your app.

## Overview

A module is an object that conforms to the `RouterModuleProtocol`. It can register its own routes, declare dependencies on other modules, and provide a way to initialize its components.

## Creating a Module

To create a module, conform to the `RouterModuleProtocol`:

```swift
class UserModule: RouterModuleProtocol {
    var name: String {
        return "User"
    }

    var dependencies: [String] {
        return ["Auth"] // Depends on Auth module
    }

    func registerRoutes(with router: Router) {
        router.register("/user/profile") { context in
            return UserProfileViewController()
        }

        router.register("/user/settings") { context in
            return UserSettingsViewController()
        }
    }
}
```

## Registering Modules

Register modules with the router using the `registerModule` method:

```swift
let userModule = UserModule()
router.registerModule(userModule)
```

## Module Dependencies

Modules can declare dependencies on other modules. The router will ensure that dependencies are registered before the module itself:

```swift
class OrderModule: RouterModuleProtocol {
    var name: String { return "Order" }

    // Depends on User and Product modules
    var dependencies: [String] { return ["User", "Product"] }

    func registerRoutes(with router: Router) {
        // Register order-related routes
    }
}
```

## Module Initialization

You can provide custom initialization logic for your modules:

```swift
class PaymentModule: RouterModuleProtocol {
    var name: String { return "Payment" }
    var dependencies: [String] { return [] }

    init(apiKey: String) {
        // Initialize payment service with apiKey
        PaymentService.shared.apiKey = apiKey
    }

    func registerRoutes(with router: Router) {
        // Register payment-related routes
    }
}

// Register with custom initialization
let paymentModule = PaymentModule(apiKey: "your-api-key")
router.registerModule(paymentModule)
```

## Benefits of Modules

- **Modularity**: Keep related routes and functionality together
- **Reusability**: Easily reuse modules across different projects
- **Dependency Management**: Declare and manage dependencies between modules
- **Testability**: Test modules in isolation

## Best Practices

- Keep modules focused on a specific feature or domain
- Declare explicit dependencies
- Keep module initialization simple
- Avoid tight coupling between modules