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
2. 在Podfile中添加: `pod 'RouterKit-Swift', '~> 1.0.1'`
3. 运行: `pod install`

### Carthage

1. 确保已安装Carthage
2. 在Cartfile中添加: `github "fengmingdev/RouterKit" ~> 1.0.1`
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
// 注册路由（使用Routable协议）
Task {
    try await router.registerRoute("/home", for: HomeViewController.self)
    try await router.registerRoute("/user/:id", for: UserViewController.self)
}

// 或使用链式调用
router.register("/home", for: HomeViewController.self).register()
router.register("/user/:id", for: UserViewController.self).register()
```

### 执行导航

```swift
// 导航到首页
router.navigate(to: "/home") { result in
    switch result {
    case .success:
        print("导航成功")
    case .failure(let error):
        print("导航失败: \(error)")
    }
}

// 导航到用户页面（带参数）
let parameters = RouterParameters()
parameters.setValue("123", forKey: "id")
router.navigate(to: "/user/:id", parameters: parameters) { result in
    // 处理导航结果
}

// 使用静态方法导航
Router.push(to: "/home")
Router.present(to: "/user/123")
```

## 版本更新日志

### 1.0.1 (2025-09-08)

- 修复了ParameterPassingModule中的路由名称不匹配问题
- 修复了TabBarController中animateTabSelection方法的语法错误
- 修复了ErrorHandlingModule中路由大小写不匹配的问题
- 修复了HomeViewController中快速导航按钮无法点击的UI约束问题

### 1.0.0 (2025-01-23)

- 初始版本发布

## 下一步

- 了解[核心概念](CoreConcepts/README.md)
- 查看完整的[API参考](APIReference/README.md)
- 探索[高级用法](AdvancedUsage/README.md)