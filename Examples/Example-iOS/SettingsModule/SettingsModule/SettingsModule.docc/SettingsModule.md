# SettingsModule

设置模块提供了完整的应用设置功能，展示了RouterKit在复杂设置界面中的应用。

## 功能特性

### 路由注册
- `/SettingsModule/settings` - 主设置页面
- `/SettingsModule/theme` - 主题设置页面
- `/SettingsModule/notification` - 通知设置页面
- `/SettingsModule/about` - 关于应用页面

### 数据模型
- `AppTheme` - 应用主题枚举（系统、浅色、深色）
- `NotificationSettings` - 通知设置结构体
- `AppSettings` - 应用设置结构体
- `SettingsManager` - 设置管理器（单例模式）

### 页面功能

#### 主设置页面 (SettingsViewController)
- **外观设置**：主题切换、字体大小调整
- **通知设置**：推送通知、声音设置
- **账户设置**：自动登录、数据同步
- **应用设置**：缓存管理、调试模式
- **关于应用**：版本信息、开发团队
- **重置设置**：恢复默认设置

#### 主题设置页面 (ThemeSettingsViewController)
- **主题选择**：系统、浅色、深色三种主题
- **实时预览**：显示主题切换效果
- **即时生效**：主题设置立即应用
- **持久化存储**：设置在应用重启后保持

#### 通知设置页面 (NotificationSettingsViewController)
- **权限管理**：检查和请求通知权限
- **推送设置**：启用/禁用推送通知和声音
- **消息通知**：消息、评论、点赞通知设置
- **系统通知**：系统、更新、维护通知设置
- **免打扰模式**：设置免打扰时间段
- **权限引导**：引导用户到系统设置开启权限

#### 关于页面 (AboutViewController)
- **应用信息**：名称、版本、构建信息
- **开发团队**：开发者、联系方式、官方链接
- **法律信息**：用户协议、隐私政策、开源许可
- **感谢信息**：使用说明和反馈渠道
- **交互功能**：点击联系方式打开邮件/网页

## 使用示例

### 注册设置模块
```swift
// 在AppDelegate中注册
let settingsModule = SettingsModule()
settingsModule.load()
```

### 导航到设置页面
```swift
// 跳转到主设置页面
Router.push("/SettingsModule/settings")

// 直接跳转到主题设置
Router.push("/SettingsModule/theme")

// 跳转到通知设置
Router.push("/SettingsModule/notification")

// 跳转到关于页面
Router.push("/SettingsModule/about")
```

### 使用设置管理器
```swift
// 获取当前设置
let settings = SettingsManager.shared.getCurrentSettings()

// 更新主题
SettingsManager.shared.updateTheme(.dark)

// 更新通知设置
var notifications = settings.notifications
notifications.pushEnabled = true
SettingsManager.shared.updateNotificationSettings(notifications)

// 重置所有设置
SettingsManager.shared.resetToDefaults()
```

## 技术要点

### 设置持久化
- 使用UserDefaults存储设置数据
- 支持设置的读取、更新和重置
- 提供默认设置配置

### 通知权限管理
- 集成UserNotifications框架
- 检查系统通知权限状态
- 引导用户开启通知权限
- 处理权限请求结果

### 主题系统
- 支持系统、浅色、深色三种主题
- 实时预览主题效果
- 主题设置立即生效

### 用户体验
- 分组设置项，层次清晰
- 提供设置项描述和说明
- 支持开关、选择、跳转等多种交互
- 错误处理和用户反馈

### 自定义组件
- `SwitchTableViewCell` - 带开关的设置项
- 响应式布局适配不同屏幕
- 阴影和圆角美化界面

## 扩展建议

1. **更多主题选项**：添加更多颜色主题
2. **字体设置**：支持字体大小和字体族设置
3. **语言设置**：支持多语言切换
4. **数据导入导出**：支持设置的备份和恢复
5. **高级设置**：开发者选项、调试工具
6. **设置搜索**：在设置中添加搜索功能
7. **设置分类**：按功能模块分类设置项
8. **云同步**：支持设置在多设备间同步