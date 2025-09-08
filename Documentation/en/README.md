# RouterKit

RouterKit is a powerful, flexible and type-safe routing framework for iOS/macOS applications. It provides a unified way to handle navigation, deep linking, and module communication in your app.

## Documentation Structure

- [Quick Start](QuickStart.md) - Get started with RouterKit quickly
- [Core Concepts](CoreConcepts/) - Understand the fundamental concepts of RouterKit
- [API Reference](APIReference/) - Detailed documentation of RouterKit's APIs
- [Advanced Usage](AdvancedUsage/) - Learn about advanced features and best practices
- [FAQ](FAQ.md) - Frequently asked questions

## Installation

RouterKit supports multiple installation methods:

### Swift Package Manager
Add the following to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/RouterKit.git", from: "1.0.1")
]
```

### Cocoapods
Add the following to your Podfile:
```ruby
pod 'RouterKit-Swift', '~> 1.0.1'
```

### Carthage
Add the following to your Cartfile:
```
github "yourusername/RouterKit" ~> 1.0.1
```

## Version Update Log

### 1.0.1 (2025-09-08)

- Fixed route name mismatch in ParameterPassingModule
- Fixed syntax error in TabBarController animateTabSelection method
- Fixed case sensitivity issue in ErrorHandlingModule routes
- Fixed UI constraint issues in HomeViewController that prevented quick navigation buttons from being clickable

### 1.0.0 (2025-01-23)

- Initial release

## Contributing

We welcome contributions to RouterKit! Please see [CONTRIBUTING.md](../../../CONTRIBUTING.md) for more information.

## License

RouterKit is available under the MIT license. See the [LICENSE](../../../LICENSE) file for more information.