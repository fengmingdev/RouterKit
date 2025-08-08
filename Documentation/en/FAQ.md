# FAQ

## Installation Questions

### Q: How do I install RouterKit?
A: RouterKit supports Swift Package Manager, Cocoapods, and Carthage. See [Installation](README.md#installation) for detailed instructions.

### Q: Which versions of iOS/macOS does RouterKit support?
A: RouterKit supports iOS 12.0+ and macOS 10.14+.

## Route Registration Questions

### Q: Why isn't my route being registered?
A: Make sure you're using the correct route pattern format. Check that you're not using duplicate route patterns, and verify that your module is properly registered with the router.

### Q: Can I register routes dynamically at runtime?
A: Yes, you can register routes at any time during your app's lifecycle. However, it's recommended to register most routes during app initialization for consistency.

## Navigation Questions

### Q: How do I handle navigation between different storyboards?
A: You can register routes that instantiate view controllers from storyboards:
```swift
router.register("/profile") { context in
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
}
```

### Q: How do I pass complex data between view controllers?
A: Use the `context` object to pass data:
```swift
// When navigating
router.navigate(to: "/detail", context: ["item": myComplexObject])

// When handling the route
router.register("/detail") { context in
    if let item = context.userInfo["item"] as? MyComplexObject {
        return DetailViewController(item: item)
    }
    return nil
}
```

## Parameter Questions

### Q: How do I extract query parameters from a URL?
A: Query parameters are automatically extracted into the `context.parameters` dictionary:
```swift
// For URL "/search?query=router&page=1"
router.register("/search") { context in
    let query = context.parameters["query"] // "router"
    let page = context.parameters["page"] // "1"
    return SearchViewController(query: query, page: Int(page) ?? 1)
}
```

## Advanced Questions

### Q: How do I implement deep linking?
A: See [Deep Link Handling](AdvancedUsage/DeepLinkHandling.md) for detailed instructions on setting up and handling deep links.

### Q: Can I use RouterKit with SwiftUI?
A: Yes, RouterKit provides SwiftUI integration. See [SwiftUI Integration](AdvancedUsage/SwiftUIIntegration.md) for more information.