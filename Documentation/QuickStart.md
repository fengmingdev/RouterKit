# 快速开始

本指南将帮助您快速上手RouterKit库。

## 安装

RouterKit支持多种安装方式：

### Swift Package Manager

1. 在Xcode中打开您的项目
2. 选择File > Add Packages...
3. 输入仓库URL: https://github.com/fengmingdev/RouterKit.git
4. 点击Add Package

### CocoaPods

1. 确保已安装CocoaPods
2. 在Podfile中添加: `pod 'RouterKit'`
3. 运行: `pod install`

### Carthage

1. 确保已安装Carthage
2. 在Cartfile中添加: `github "fengmingdev/RouterKit"`
3. 运行: `carthage update --platform iOS`

## 基本使用

### 导入RouterKit

```swift
import RouterKit
```

### 初始化路由器

```swift
// 创建全局路由器实例
let router = Router.shared
```

### 注册路由

```swift
// 注册路由
router.register("/home") { context in
    return HomeViewController()
}

router.register("/user/:id") { context in
    guard let userId = context.parameters["id"] else { return nil }
    return UserViewController(userId: userId)
}
```

### 执行导航

```swift
// 导航到首页
router.navigate(to: "/home")

// 导航到用户页面
router.navigate(to: "/user/123")
```

## 下一步

- 了解[核心概念](CoreConcepts/README.md)
- 查看完整的[API参考](APIReference/README.md)
- 探索[高级用法](AdvancedUsage/README.md)