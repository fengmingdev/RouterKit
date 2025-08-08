# Quick Start

This guide will help you get started with RouterKit quickly.

## Installation

First, install RouterKit using your preferred package manager. See [Installation](README.md#installation) for detailed instructions.

## Basic Setup

### 1. Import RouterKit

```swift
import RouterKit
```

### 2. Create a Router Instance

```swift
let router = Router.shared
```

### 3. Register Routes

```swift
// Register a simple route
router.register("/home") { context in
    return HomeViewController()
}

// Register a route with parameters
router.register("/user/:id") { context in
    guard let userId = context.parameters["id"] else {
        return nil
    }
    return UserViewController(userId: userId)
}
```

### 4. Perform Navigation

```swift
// Navigate to a route
router.navigate(to: "/home")

// Navigate to a route with parameters
router.navigate(to: "/user/123")

// Navigate with options
router.navigate(to: "/settings", options: [.animated(true), .presentationStyle(.modal)])
```

## Next Steps

- Learn about [Core Concepts](CoreConcepts/)
- Explore the [API Reference](APIReference/)
- Check out [Advanced Usage](AdvancedUsage/) for more features