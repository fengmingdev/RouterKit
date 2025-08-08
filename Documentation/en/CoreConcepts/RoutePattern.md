# Route Pattern

A route pattern defines the format of a URL path that your app can handle. RouterKit supports various pattern formats to match different URL structures.

## Pattern Types

### Static Patterns

Static patterns match exact URL paths:

```swift
// Matches "/home" exactly
router.register("/home") { context in
    return HomeViewController()
}
```

### Dynamic Parameters

Use `:` to define dynamic parameters in a route pattern. These parameters will be extracted into the `context.parameters` dictionary:

```swift
// Matches "/user/123", "/user/456", etc.
router.register("/user/:id") { context in
    guard let userId = context.parameters["id"] else {
        return nil
    }
    return UserViewController(userId: userId)
}

// Multiple parameters
router.register("/product/:category/:productId") { context in
    let category = context.parameters["category"]
    let productId = context.parameters["productId"]
    return ProductDetailViewController(category: category, productId: productId)
}
```

### Wildcards

Use `*` to match any remaining part of the URL path:

```swift
// Matches "/search/anything", "/search/anything/else", etc.
router.register("/search/*") { context in
    return SearchResultsViewController()
}

// Matches any URL
router.register("/*") { context in
    return NotFoundViewController()
}
```

### Query Parameters

Query parameters are automatically extracted into the `context.parameters` dictionary:

```swift
// For URL "/search?query=router&page=1"
router.register("/search") { context in
    let query = context.parameters["query"] // "router"
    let page = context.parameters["page"] // "1"
    return SearchViewController(query: query, page: Int(page) ?? 1)
}
```

## Regular Expressions

For more complex pattern matching, you can use regular expressions:

```swift
// Match URLs with numeric user IDs
let pattern = RouterPattern(regex: #"^/user/\d+$"#)
router.register(pattern) { context in
    let path = context.url.path
    let userId = path.components(separatedBy: "/").last
    return UserViewController(userId: userId)
}
```

## Pattern Matching Priority

RouterKit uses the following priority order when matching routes:

1. Static patterns (e.g., "/home")
2. Patterns with dynamic parameters (e.g., "/user/:id")
3. Wildcard patterns (e.g., "/search/*")

## Best Practices

- Use descriptive parameter names (e.g., `:userId` instead of `:id` when possible)
- Keep patterns simple and readable
- Avoid overly broad wildcard patterns
- Use regular expressions only when necessary