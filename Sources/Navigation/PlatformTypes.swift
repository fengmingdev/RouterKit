//
//  PlatformTypes.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/23.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 跨平台类型别名

#if canImport(UIKit)
/// iOS/tvOS 平台的视图控制器类型别名
public typealias PlatformViewController = UIViewController
/// iOS/tvOS 平台的视图类型别名
public typealias PlatformView = UIView
/// iOS/tvOS 平台的应用程序类型别名
public typealias PlatformApplication = UIApplication
/// iOS/tvOS 平台的导航控制器类型别名
public typealias PlatformNavigationController = UINavigationController
/// iOS/tvOS 平台的标签栏控制器类型别名
public typealias PlatformTabBarController = UITabBarController
/// iOS/tvOS 平台的窗口场景类型别名
public typealias PlatformWindowScene = UIWindowScene

typealias PlatformUserActivity = NSUserActivity

typealias PlatformOpenURLOptionsKey = UIApplication.OpenURLOptionsKey

typealias PlatformScreen = UIScreen

typealias PlatformContextTransitioning = UIViewControllerContextTransitioning

#elseif canImport(AppKit)
/// macOS 平台的视图控制器类型别名
public typealias PlatformViewController = NSViewController
/// macOS 平台的视图类型别名
public typealias PlatformView = NSView
/// macOS 平台的应用程序类型别名
public typealias PlatformApplication = NSApplication
/// macOS 平台的导航控制器类型别名（使用NSViewController作为基础）
public typealias PlatformNavigationController = NSViewController
/// macOS 平台的标签栏控制器类型别名（使用NSViewController作为基础）
public typealias PlatformTabBarController = NSViewController
/// macOS 平台的窗口场景类型别名（使用NSWindow）
public typealias PlatformWindowScene = NSWindow

public typealias UIApplication = NSApplication

public typealias UIApplicationDelegate = NSObjectProtocol

typealias PlatformScreen = NSScreen

typealias PlatformOpenURLOptionsKey = NSApplication.OpenURLOptionsKey

// macOS上没有对应的转场上下文类型，使用Any作为占位符
typealias PlatformContextTransitioning = Any

// MARK: - 跨平台协议扩展

// topMostViewController方法已在Router+NavigationActions.swift中定义
extension NSApplication {
    struct OpenURLOptionsKey: Hashable, Equatable, RawRepresentable {
        let rawValue: String
        static let sourceApplication = OpenURLOptionsKey(rawValue: "sourceApplication")
    }
}

#endif
