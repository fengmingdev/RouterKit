# 路由上下文(Route Context)

路由上下文包含了导航过程中的所有信息，如路径、参数、来源控制器等。处理程序可以通过上下文获取必要的信息来创建和配置视图控制器。

## 上下文属性

路由上下文提供了以下主要属性：

- `path`: 当前导航的URL路径
- `parameters`: 从URL路径中提取的参数
- `queryParameters`: URL查询参数
- `source`: 来源视图控制器
- `options`: 导航选项
- `userInfo`: 自定义用户信息

## 访问参数

使用`parameters`属性访问从URL路径中提取的参数。

```swift
router.register("/user/:id") { context in
    // 访问id参数
    guard let userId = context.parameters["id"] else { return nil }
    return UserViewController(userId: userId)
}
```

## 访问查询参数

使用`queryParameters`属性访问URL查询参数。

```swift
// 导航到 /search?query=router
router.navigate(to: "/search?query=router")

// 注册路由
router.register("/search") { context in
    // 访问查询参数
    let query = context.queryParameters["query"] ?? ""
    return SearchViewController(query: query)
}
```

## 访问来源控制器

使用`source`属性访问来源视图控制器。

```swift
router.register("/detail") { context in
    // 访问来源控制器
    if let sourceVC = context.source as? ListViewController {
        // 从来源控制器获取数据
        let data = sourceVC.selectedData
        return DetailViewController(data: data)
    }
    return DetailViewController()
}
```

## 导航选项

使用`options`属性访问导航选项。

```swift
router.register("/modal") { context in
    // 检查是否需要以模态方式呈现
    let isModal = context.options.contains(.modal(true))
    let vc = ModalViewController()
    vc.modalPresentationStyle = isModal ? .automatic : .fullScreen
    return vc
}
```

## 自定义用户信息

使用`userInfo`属性传递自定义信息。

```swift
// 传递自定义信息
router.navigate(to: "/settings", userInfo: ["theme": "dark"])

// 访问自定义信息
router.register("/settings") { context in
    let theme = context.userInfo["theme"] as? String ?? "light"
    return SettingsViewController(theme: theme)
}
```