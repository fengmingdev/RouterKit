# ProfileModule

用户资料模块，展示RouterKit在用户信息管理场景中的应用。

## 概述

ProfileModule演示了如何使用RouterKit构建完整的用户资料管理功能，包括：

- 用户资料展示
- 用户信息编辑
- 头像上传功能
- 数据验证和错误处理
- 异步操作和加载状态

## 功能特性

### 路由注册

```swift
// 用户资料主页
try await Router.shared.registerRoute("/ProfileModule/profile", for: ProfileViewController.self)

// 用户信息编辑页
try await Router.shared.registerRoute("/ProfileModule/edit", for: ProfileEditViewController.self)

// 头像上传页
try await Router.shared.registerRoute("/ProfileModule/avatar", for: AvatarUploadViewController.self)
```

### 数据模型

- `UserProfile`: 用户资料数据模型
- `UserProfileManager`: 用户数据管理单例

### 页面功能

1. **ProfileViewController**: 用户资料展示页面
   - 显示用户头像、用户名、邮箱、个人简介
   - 提供编辑和更换头像入口
   - 响应式UI布局

2. **ProfileEditViewController**: 用户信息编辑页面
   - 表单输入和验证
   - 键盘处理
   - 异步保存操作
   - 错误处理和用户反馈

3. **AvatarUploadViewController**: 头像上传页面
   - 相册选择和拍照功能
   - 图片预览和编辑
   - 上传进度显示
   - 完整的用户交互流程

## 使用示例

### 跳转到用户资料页面

```swift
Router.push(to: "/ProfileModule/profile")
```

### 跳转到编辑页面

```swift
Router.push(to: "/ProfileModule/edit")
```

### 跳转到头像上传页面

```swift
Router.push(to: "/ProfileModule/avatar")
```

## 技术要点

- **模块化设计**: 独立的模块，可单独加载和卸载
- **数据管理**: 使用单例模式管理用户数据
- **异步操作**: 网络请求和文件上传的异步处理
- **用户体验**: 加载状态、进度显示、错误处理
- **响应式布局**: 适配不同屏幕尺寸
- **键盘处理**: 输入框和键盘的交互优化