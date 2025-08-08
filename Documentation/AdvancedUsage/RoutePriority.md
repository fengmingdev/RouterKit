# 路由优先级

当多个路由模式都能匹配同一个URL时，RouterKit会根据优先级选择最具体的路由。

## 优先级规则

RouterKit的路由优先级遵循以下规则：

1. **自定义路由匹配器**：优先级最高
2. **静态路径**：优先级次之
3. **带动态参数的路径**：优先级再次之
4. **通配符路径**：优先级最低

```swift
// 优先级: 1 (最高)
router.register(matcher: customMatcher) { _ in ... }

// 优先级: 2
router.register("/user/profile") { _ in ... }

// 优先级: 3
router.register("/user/:id") { _ in ... }

// 优先级: 4 (最低)
router.register("/user/*") { _ in ... }
```

## 显式设置优先级

您可以显式设置路由的优先级。

```swift
// 显式设置优先级
router.register("/user/special", priority: 10) { _ in
    return SpecialUserViewController()
}

router.register("/user/:id", priority: 5) { _ in
    return UserViewController()
}
```

## 路由组优先级

路由组中的路由会继承组的优先级。

```swift
// 路由组优先级
router.group("/api", priority: 20) { api in
    // 继承优先级20
    api.register("/users") { _ in ... }
    api.register("/posts") { _ in ... }
}
```

## 优先级冲突

如果两个路由具有相同的优先级，将按照注册顺序选择，先注册的路由优先。

```swift
// 相同优先级，先注册的优先
router.register("/user/:id", priority: 10) { _ in
    return UserViewController()
}

router.register("/user/:name", priority: 10) { _ in
    return UserProfileViewController() // 不会被调用，因为前一个路由先注册
}
```

## 查看路由优先级

您可以查看已注册路由的优先级。

```swift
// 查看路由优先级
for route in router.routes {
    print("Path: \(route.pattern), Priority: \(route.priority)")
}
```

## 最佳实践

1. 为特殊路由设置较高的优先级
2. 避免使用过多的高优先级路由
3. 尽量使用默认的优先级规则，只在必要时显式设置优先级
4. 保持路由模式的一致性，避免优先级冲突