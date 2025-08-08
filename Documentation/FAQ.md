# 常见问题

## 安装问题

### Q: 无法安装RouterKit怎么办？

A: 请检查以下几点：
1. 确保您使用的是支持的安装方式（Swift Package Manager、CocoaPods或Carthage）
2. 确保您的Xcode版本符合要求（Xcode 13.0+）
3. 确保您的项目使用的是Swift 5.7+版本
4. 检查网络连接，确保可以访问GitHub

如果问题仍然存在，请提交issue。

## 路由注册问题

### Q: 路由注册后无法匹配怎么办？

A: 请检查以下几点：
1. 确保路由模式正确，注意斜杠和参数格式
2. 检查是否有优先级更高的路由匹配了相同的路径
3. 确保没有路由冲突
4. 尝试使用`router.routes`查看已注册的路由

### Q: 可以为同一个路径注册多个路由吗？

A: 可以，但只有优先级最高或最先注册的路由会被调用。建议避免为同一个路径注册多个路由，以免引起混淆。

## 导航问题

### Q: 导航没有反应怎么办？

A: 请检查以下几点：
1. 确保路由已正确注册
2. 检查拦截器是否阻止了导航
3. 确保来源视图控制器存在且可见
4. 检查控制台是否有错误信息

### Q: 如何在导航完成后执行回调？

A: 可以使用`RouterOptions`的`completion`选项：

```swift
router.navigate(to: "/detail", options: [
    .completion {
        print("Navigation completed")
    }
])
```

## 参数问题

### Q: 如何获取URL查询参数？

A: 可以通过`RouteContext`的`queryParameters`属性获取：

```swift
router.register("/search") { context in
    let query = context.queryParameters["query"] ?? ""
    return SearchViewController(query: query)
}
```

### Q: 如何传递复杂参数？

A: 可以使用`userInfo`参数传递复杂数据：

```swift
router.navigate(to: "/detail", userInfo: ["data": complexData])

router.register("/detail") { context in
    if let data = context.userInfo["data"] as? ComplexDataType {
        return DetailViewController(data: data)
    }
    return DetailViewController()
}
```

## 其他问题

### Q: RouterKit支持SwiftUI吗？

A: 支持。请参考[与SwiftUI集成](AdvancedUsage/SwiftUIIntegration.md)文档。

### Q: 如何处理深度链接？

A: 请参考[深度链接处理](AdvancedUsage/DeepLinkHandling.md)文档。

### Q: 如何贡献代码？

A: 欢迎贡献代码！请阅读[CONTRIBUTING.md](../CONTRIBUTING.md)文档了解贡献指南。