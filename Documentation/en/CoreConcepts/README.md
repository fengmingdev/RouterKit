# Core Concepts

This section introduces the core concepts of RouterKit to help you understand how it works.

## Router

The `Router` is the central component of RouterKit. It manages route registration, matching, and navigation. You typically use the shared instance:

```swift
let router = Router.shared
```

## Route Pattern

A route pattern defines the format of a URL path that your app can handle. RouterKit supports various pattern formats:

- Static patterns: `/home`, `/settings`
- Dynamic parameters: `/user/:id`, `/product/:category/:productId`
- Wildcards: `/search/*`, `/*`
- Query parameters: `/search?query=router&page=1`

## Route Context

When a route is matched, RouterKit creates a `RouteContext` object that contains information about the matched route, including:

- Parameters extracted from the URL
- Query parameters
- User info passed during navigation
- Navigation options

## Interceptor

Interceptors allow you to intercept and modify the navigation process. You can use them for authentication, logging, or any other cross-cutting concerns.

## Module

Modules are a way to organize your routes. A module can register its own routes and dependencies, making it easy to modularize your app.

## Animation

RouterKit provides a way to customize the navigation animation between view controllers. You can create custom animations by conforming to the `RouterAnimation` protocol.

## Next Steps

Explore the following core concepts in detail:

- [Router](Router.md)
- [Route Pattern](RoutePattern.md)
- [Route Context](RouteContext.md)
- [Interceptor](Interceptor.md)
- [Module](Module.md)
- [Animation](Animation.md)