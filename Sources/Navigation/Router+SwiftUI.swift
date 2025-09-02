//
//  Router+SwiftUI..swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import SwiftUI
#if canImport(UIKit)
import UIKit

// MARK: - SwiftUI视图路由协议
protocol SwiftUIRoutable: Routable {
    associatedtype Content: View
    static func view(with parameters: RouterParameters?) -> Content
}

// MARK: - 实现默认的UIViewController创建方法
extension SwiftUIRoutable {
    static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        UIHostingController(rootView: Self.view(with: parameters))
    }
}

// MARK: - SwiftUI路由视图容器
struct RouterView: View {
    let url: String
    let parameters: RouterParameters?
    
    var body: some View {
        // 实际项目中可根据URL动态创建对应的SwiftUI视图
        // 这里简化实现，实际应通过Router查找对应的Routable类型
        EmptyView()
            .onAppear {
                // 可在这里添加视图出现时的逻辑
            }
    }
}

// MARK: - SwiftUI导航扩展
extension View {
    /// SwiftUI视图中导航到指定URL
    func navigate(to url: String,
                 parameters: RouterParameters? = nil,
                 type: NavigationType = .push,
                 animated: Bool = true) -> some View {
        modifier(RouterNavigationModifier(
            url: url,
            parameters: parameters,
            type: type,
            animated: animated
        ))
    }
}

/// 导航修饰符
@MainActor struct RouterNavigationModifier: ViewModifier {
    let url: String
    let parameters: RouterParameters?
    let type: NavigationType
    let animated: Bool
    @Environment(\.presentationMode) var presentationMode
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                // 获取当前的UIViewController
                switch type {
                case .push:
                    Router.push(to: url, parameters: parameters, animated: animated)
                case .present:
                    Router.present(to: url, parameters: parameters, animated: animated)
                case .popToRoot:
                    Router.popToRoot(animated: animated)
                case .replace:
                    Router.replace(to: url, parameters: parameters, animated: animated)
                case .popTo:
                    Router.popTo(url: url, animated: animated)
                }
            }
    }
}

// MARK: - UIApplication扩展（获取顶层控制器）
extension UIApplication {
    /// 获取当前最顶层的视图控制器
    @MainActor func topMostViewController() -> UIViewController? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.rootViewController?
            .topMostViewController()
    }
}

extension UIViewController {
    /// 递归获取最顶层的视图控制器
    @MainActor func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        return self
    }
}

#endif
