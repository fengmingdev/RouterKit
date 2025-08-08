# Custom Route Matcher

RouterKit allows you to create custom route matchers for complex routing scenarios that can't be handled with standard route patterns.

## Overview

A custom route matcher is an object that conforms to the `CustomRouteMatcher` protocol. It can be used to implement complex matching logic that goes beyond simple string patterns or regular expressions.

## Creating a Custom Route Matcher

To create a custom route matcher, conform to the `CustomRouteMatcher` protocol:

```swift
class RegexRouteMatcher: CustomRouteMatcher {
    let regex: NSRegularExpression
    let priority: Int

    init(regex: NSRegularExpression, priority: Int = 0) {
        self.regex = regex
        self.priority = priority
    }

    func matches(_ url: URL) -> Bool {
        let path = url.path
        return regex.firstMatch(in: path, options: [], range: NSRange(location: 0, length: path.utf16.count)) != nil
    }

    func extractParameters(from url: URL) -> [String: String] {
        let path = url.path
        let match = regex.firstMatch(in: path, options: [], range: NSRange(location: 0, length: path.utf16.count))
        guard let match = match else { return [:] }

        var parameters: [String: String] = [:]
        // Extract parameters from regex match
        // ...
        return parameters
    }
}
```

## Registering a Custom Route Matcher

Register your custom route matcher with the router using the `registerCustomMatcher` method:

```swift
do {
    let regex = try NSRegularExpression(pattern: "^/api/[vV]\\d+/users/\\d+$", options: [])
    let apiMatcher = RegexRouteMatcher(regex: regex, priority: 10)
    router.registerCustomMatcher(apiMatcher) { context in
        // Handle matched route
        return APIDetailViewController(context: context)
    }
}
```

## Matcher Priority

Custom route matchers have a `priority` property that determines the order in which they are evaluated. Matchers with higher priority are evaluated first.

```swift
// High priority matcher
let highPriorityMatcher = MyCustomMatcher(priority: 100)

// Low priority matcher
let lowPriorityMatcher = MyCustomMatcher(priority: 10)
```

## Combining Matchers

You can register multiple custom matchers, and RouterKit will evaluate them in order of priority. The first matcher that returns `true` for `matches(_:)` will be used.

```swift
// Register multiple matchers
router.registerCustomMatcher(apiMatcher) { context in /* ... */ }
router.registerCustomMatcher(deepLinkMatcher) { context in /* ... */ }
router.registerCustomMatcher(fallbackMatcher) { context in /* ... */ }
```

## Best Practices

- Keep custom matchers focused on a specific routing scenario
- Use priority to control the order of matcher evaluation
- Make sure your matcher's `matches(_:)` method is efficient
- Document your custom matchers so other developers understand how they work
- Test your matchers with a variety of URLs to ensure they work as expected