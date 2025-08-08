# RouterPattern

The `RouterPattern` struct defines a pattern for matching URLs in RouterKit.

## Initializers

### init(_:)

Creates a route pattern from a string.

```swift
init(_ pattern: String)
```

### init(regex:)

Creates a route pattern from a regular expression.

```swift
init(regex: NSRegularExpression)
```

## Properties

### pattern

The original pattern string.

```swift
let pattern: String
```

### regex

The regular expression used for matching.

```swift
let regex: NSRegularExpression
```

### isStatic

A boolean indicating whether the pattern is static (no dynamic parameters or wildcards).

```swift
let isStatic: Bool
```

### parameterNames

An array of parameter names extracted from the pattern.

```swift
let parameterNames: [String]
```

## Methods

### matches(_:)

Checks if the pattern matches a URL.

```swift
func matches(_ url: URL) -> Bool
```

### extractParameters(from:)

Extracts parameters from a URL that matches the pattern.

```swift
func extractParameters(from url: URL) -> [String: String]?
```

## Example

```swift
// Create a pattern from a string
let pattern = RouterPattern("/user/:id")

// Check if a URL matches
let url = URL(string: "/user/123")!
if pattern.matches(url) {
    // Extract parameters
    let params = pattern.extractParameters(from: url)
    print(params?["id"]) // Output: "123"
}

// Create a pattern from a regular expression
do {
    let regex = try NSRegularExpression(pattern: "^/product/\\d+$", options: [])
    let productPattern = RouterPattern(regex: regex)
}
```