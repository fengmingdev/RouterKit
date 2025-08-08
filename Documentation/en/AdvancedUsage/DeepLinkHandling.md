# Deep Link Handling

RouterKit makes it easy to handle deep links from outside your app, such as URLs clicked in Safari or sent via email.

## Overview

Deep links are URLs that launch your app and navigate to a specific screen. RouterKit provides tools to handle these URLs and integrate them with your existing routing logic.

## Setup

### 1. Configure URL Schemes

In Xcode, go to your project settings, select your target, and navigate to the "Info" tab. Add a URL scheme under "URL Types":

- Identifier: `com.yourcompany.yourapp`
- URL Schemes: `yourapp`

### 2. Handle URLs in AppDelegate

Add the following code to your `AppDelegate.swift`:

```swift
import RouterKit

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return Router.shared.handleDeepLink(url)
}
```

### 3. Handle URLs in SceneDelegate (iOS 13+)

If your app uses Scenes, add the following code to your `SceneDelegate.swift`:

```swift
import RouterKit

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    Router.shared.handleDeepLink(url)
}
```

## Handling Deep Links

### Basic Handling

The `handleDeepLink` method will try to match the URL with your registered routes and navigate accordingly:

```swift
Router.shared.handleDeepLink(url)
```

### Custom Handling

You can customize how deep links are handled by implementing a `DeepLinkHandler`:

```swift
class CustomDeepLinkHandler: DeepLinkHandler {
    func handleDeepLink(_ url: URL) -> Bool {
        // Custom handling logic
        if url.host == "special" {
            // Handle special deep link
            return true
        }
        // Fall back to default handling
        return Router.shared.matchAndNavigate(to: url)
    }
}

// Set custom handler
Router.shared.deepLinkHandler = CustomDeepLinkHandler()
```

## Interceptor Validation

You can use interceptors to validate deep links before navigation:

```swift
class DeepLinkInterceptor: RouterInterceptor {
    func shouldNavigate(to url: URL, context: RouteContext) -> Bool {
        // Check if the deep link is valid
        if url.path.starts(with: "/secure") {
            return isUserAuthenticated()
        }
        return true
    }
}
```

## Testing Deep Links

### Using Xcode

You can test deep links in Xcode by adding a URL to the "Arguments Passed On Launch" in the scheme editor:

`-u yourapp://home`

### Using Terminal

You can also test deep links from Terminal:

```bash
xcrun simctl openurl booted yourapp://user/123
```

## Universal Links

RouterKit also supports Universal Links. To set up Universal Links:

1. Configure your app and website according to Apple's documentation
2. Add the following code to your `AppDelegate` or `SceneDelegate`:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
        return Router.shared.handleDeepLink(url)
    }
    return false
}
```

## Best Practices

- Validate all deep links before navigation
- Provide feedback to the user if a deep link is invalid
- Use interceptors to handle authentication for protected deep links
- Test deep links thoroughly on different devices and iOS versions
- Consider using Universal Links for a better user experience