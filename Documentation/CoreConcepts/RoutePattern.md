# 路由模式(Route Pattern)

路由模式定义了URL路径与处理程序之间的映射关系。RouterKit支持多种类型的路由模式。

## 静态路径

静态路径是最简单的路由模式，直接匹配固定的URL路径。

```swift
// 匹配 /home 路径
router.register("/home") { _ in
    return HomeViewController()
}
```

## 动态参数

使用`:param`语法定义动态参数，参数值会被提取到路由上下文中。

```swift
// 匹配 /user/123 路径，其中123会被提取为id参数
router.register("/user/:id") { context in
    guard let userId = context.parameters["id"] else { return nil }
    return UserViewController(userId: userId)
}
```

## 通配符

使用`*`通配符匹配任意路径片段。

```swift
// 匹配以 /files/ 开头的所有路径
router.register("/files/*") { context in
    let filePath = context.path
    return FileViewController(path: filePath)
}
```

## 正则表达式

对于更复杂的匹配需求，可以使用正则表达式。

```swift
// 使用正则表达式匹配数字ID
router.register(Regex("^/user/\\d+$", options: .anchorsMatchLines)) { context in
    let pathComponents = context.path.components(separatedBy: "/")
    let userId = pathComponents[2]
    return UserViewController(userId: userId)
}
```

## 路由命名

可以为路由指定名称，方便反向生成URL。

```swift
// 为路由指定名称
router.register("/user/:id", name: "user") { context in
    guard let userId = context.parameters["id"] else { return nil }
    return UserViewController(userId: userId)
}

// 使用名称反向生成URL
if let url = router.generateURL(for: "user", parameters: ["id": "123"]) {
    print(url) // 输出: /user/123
}
```

## 优先级

当多个路由模式都能匹配同一个URL时，RouterKit会根据优先级选择最具体的路由。静态路径的优先级最高，其次是动态参数，最后是通配符。

```swift
// 优先级: /user/profile > /user/:id > /user/*
router.register("/user/profile") { _ in ... }
router.register("/user/:id") { _ in ... }
router.register("/user/*") { _ in ... }
```