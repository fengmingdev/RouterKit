# Module

Modules are a way to organize routes and dependencies in RouterKit, making it easier to modularize your app.

## Overview

A module is an object that conforms to the `ModuleProtocol`. It can register its own routes, declare dependencies on other modules, and provide a way to initialize its components.

## Creating a Module

To create a module, conform to the `ModuleProtocol`:

```swift
class UserModule: ModuleProtocol {
    var moduleName: String = "User"
    var dependencies: [ModuleDependency] = []
    var lastUsedTime: Date = Date()

    required init() {}

    func load(completion: @escaping (Bool) -> Void) {
        // Module loading logic
        print("User module loaded")
        completion(true)
    }

    func unload() {
        // Cleanup resources
        print("User module unloaded")
    }

    func suspend() {
        // Suspend module
        print("User module suspended")
    }

    func resume() {
        // Resume module
        lastUsedTime = Date()
        print("User module resumed")
    }
}
```

## Registering Modules

Register modules with the router using the `registerModule` method:

```swift
let userModule = UserModule()
Task {
    await router.registerModule(userModule)
}
```

## Module Dependencies

Modules can declare dependencies on other modules. The router will ensure that dependencies are registered before the module itself:

```swift
class OrderModule: ModuleProtocol {
    var moduleName: String = "Order"
    var dependencies: [ModuleDependency] = [
        ModuleDependency(name: "User", version: "1.0.0"),
        ModuleDependency(name: "Product", version: "1.0.0")
    ]
    var lastUsedTime: Date = Date()

    required init() {}

    func load(completion: @escaping (Bool) -> Void) {
        // Register order-related routes
        Task {
            do {
                try await Router.shared.registerRoute("/order/history", for: OrderHistoryViewController.self)
                try await Router.shared.registerRoute("/order/detail", for: OrderDetailViewController.self)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    func unload() {
        // Cleanup resources
    }

    func suspend() {
        // Suspend module
    }

    func resume() {
        // Resume module
        lastUsedTime = Date()
    }
}
```

## Module Initialization

You can provide custom initialization logic for your modules:

```swift
class PaymentModule: ModuleProtocol {
    var moduleName: String = "Payment"
    var dependencies: [ModuleDependency] = []
    var lastUsedTime: Date = Date()
    private let apiKey: String

    required init(apiKey: String) {
        self.apiKey = apiKey
        // Initialize payment service with apiKey
        PaymentService.shared.apiKey = apiKey
    }

    required init() {
        self.apiKey = ""
    }

    func load(completion: @escaping (Bool) -> Void) {
        // Register payment-related routes
        Task {
            do {
                try await Router.shared.registerRoute("/payment/checkout", for: CheckoutViewController.self)
                try await Router.shared.registerRoute("/payment/confirmation", for: PaymentConfirmationViewController.self)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    func unload() {
        // Cleanup resources
    }

    func suspend() {
        // Suspend module
    }

    func resume() {
        // Resume module
        lastUsedTime = Date()
    }
}

// Register with custom initialization
let paymentModule = PaymentModule(apiKey: "your-api-key")
Task {
    await router.registerModule(paymentModule)
}
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

## Version Update Log

### 1.0.1 (2025-09-08)

- Fixed route name mismatch in ParameterPassingModule
- Fixed syntax error in TabBarController animateTabSelection method
- Fixed case sensitivity issue in ErrorHandlingModule routes
- Fixed UI constraint issues in HomeViewController that prevented quick navigation buttons from being clickable

### 1.0.0 (2025-01-23)

- Initial release