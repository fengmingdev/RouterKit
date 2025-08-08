# 与SwiftUI集成

RouterKit支持与SwiftUI集成，允许您在SwiftUI应用中使用路由功能。

## 基本集成

使用`Router+SwiftUI.swift`中的扩展来在SwiftUI中使用RouterKit。

```swift
import SwiftUI
import RouterKit

// SwiftUI视图
struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home View")
            Button("Go to Detail") {
                // 导航到详情页
                Router.shared.navigate(to: "/detail")
            }
        }
    }
}

// 注册路由
Router.shared.register("/home") { _ in
    UIHostingController(rootView: HomeView())
}

Router.shared.register("/detail") { _ in
    UIHostingController(rootView: DetailView())
}
```

## 使用RouterView

`RouterView`是一个SwiftUI视图，用于显示当前路由对应的内容。

```swift
// 定义RouterView
struct RouterView: View {
    @StateObject private var routerState = RouterState()
    
    var body: some View {
        Group {
            if let viewController = routerState.currentViewController {
                UIViewControllerRepresentable(controller: viewController)
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            // 初始导航
            Router.shared.navigate(to: "/home")
        }
    }
}

// UIViewControllerRepresentable实现
struct UIViewControllerRepresentable: UIViewControllerRepresentable {
    let controller: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 不需要更新
    }
}
```

## 响应式路由状态

使用`RouterState`来监控路由状态变化。

```swift
class RouterState: ObservableObject {
    @Published var currentViewController: UIViewController?
    
    init() {
        // 监听路由变化
        NotificationCenter.default.addObserver(self, selector: #selector(routeChanged), name: NSNotification.Name("RouteChanged"), object: nil)
    }
    
    @objc func routeChanged(notification: Notification) {
        if let viewController = notification.userInfo?["viewController"] as? UIViewController {
            currentViewController = viewController
        }
    }
}
```

## 在SwiftUI中使用路由参数

您可以在SwiftUI视图中访问路由参数。

```swift
struct UserView: View {
    let userId: String
    
    var body: some View {
        Text("User ID: \(userId)")
    }
}

// 注册路由
Router.shared.register("/user/:id") { context in
    guard let userId = context.parameters["id"] else { return nil }
    return UIHostingController(rootView: UserView(userId: userId))
}
```

## SwiftUI导航样式

您可以自定义SwiftUI视图的导航样式。

```swift
// 自定义导航样式
struct CustomNavigationView: View {
    var body: some View {
        NavigationView {
            RouterView()
                .navigationTitle("RouterKit")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

## 最佳实践

1. 使用`UIHostingController`包装SwiftUI视图
2. 使用`RouterState`监控路由状态变化
3. 保持SwiftUI视图和路由逻辑分离
4. 避免在SwiftUI视图中直接依赖路由器实例
5. 使用环境对象传递路由相关数据