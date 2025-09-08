//
//  AppDelegate.swift
//  MyMainProject
//
//  Created by fengming on 2025/8/8.
//

import UIKit
import RouterKit
import LoginModule
import MessageModule
import ProfileModule
import SettingsModule
import ParameterPassingModule
import InterceptorModule
import ErrorHandlingModule
import AnimationModule
import Foundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // 配置路由
        configureRouter()

        // 注册模块
        registerModules()

        // 创建窗口并设置初始根视图控制器为ViewController
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = ViewController()
        let navVC = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()

        // 处理启动时的深度链接
        if let url = launchOptions?[.url] as? URL {
            _ = DeepLinkHandler.shared.handleLaunchURL(url)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Deep Link Handling

    /// 处理URL Scheme深度链接
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("AppDelegate: 接收到URL Scheme: \(url.absoluteString)")
        return DeepLinkHandler.shared.handleURLScheme(url)
    }

    /// 处理Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }

        print("AppDelegate: 接收到Universal Link: \(url.absoluteString)")
        return DeepLinkHandler.shared.handleUniversalLink(url)
    }

    private func configureRouter() {
        Task {
            // 添加拦截器
            await Router.shared.addInterceptor(LoginInterceptor())
            await Router.shared.addInterceptor(LoggingInterceptor())

            // 注册自定义动画
            await Router.shared.registerAnimation(FadeNavigationAnimation())

            // 添加模块生命周期观察者
            let observer = AppModuleObserver()
            Router.shared.addLifecycleObserver(observer)

            // 配置路由参数
            await Router.shared.setEnableLogging(true)
            await Router.shared.setModuleExpirationTime(300) // 5分钟
            await Router.shared.setCleanupInterval(60) // 1分钟
        }
    }

    private func registerModules() {
        print("AppDelegate: 开始注册模块")
        Task {
            // 注册根模块
            print("AppDelegate: 开始注册 RootModule")
            let rootModule = RootModule()
            await Router.shared.registerModule(rootModule)
            print("AppDelegate: RootModule 注册成功")
            
            // 注册登录模块
            print("AppDelegate: 开始注册 LoginModule")
            let userModule = LoginModule()
            await Router.shared.registerModule(userModule)
            print("AppDelegate: LoginModule 注册成功")

            // 注册消息模块
            print("AppDelegate: 开始注册 MessageModule")
            let authModule = MessageModule()
            await Router.shared.registerModule(authModule)
            print("AppDelegate: MessageModule 注册成功")

            // TODO: 注册用户资料模块 - 需要将模块源文件添加到项目中
             print("AppDelegate: 开始注册 ProfileModule")
             let profileModule = ProfileModuleManager()
             await Router.shared.registerModule(profileModule)
             print("AppDelegate: ProfileModule 注册成功")

            // TODO: 注册其他模块 - 需要将模块源文件添加到项目中
            // 注册设置模块
             print("AppDelegate: 开始注册 SettingsModule")
             let settingsModule = SettingsModule()
             await Router.shared.registerModule(settingsModule)
             print("AppDelegate: SettingsModule 注册成功")

            // 注册参数传递模块
             print("AppDelegate: 开始注册 ParameterPassingModule")
             let parameterPassingModule = ParameterPassingModule()
             await Router.shared.registerModule(parameterPassingModule)
             print("AppDelegate: ParameterPassingModule 注册成功")

            // 注册拦截器模块
             print("AppDelegate: 开始注册 InterceptorModule")
             let interceptorModule = InterceptorModule()
             await Router.shared.registerModule(interceptorModule)
             print("AppDelegate: InterceptorModule 注册成功")

            // 注册错误处理模块
             print("AppDelegate: 开始注册 ErrorHandlingModule")
             let errorHandlingModule = ErrorHandlingModule()
             await Router.shared.registerModule(errorHandlingModule)
             print("AppDelegate: ErrorHandlingModule 注册成功")

            // 注册动画模块
             print("AppDelegate: 开始注册 AnimationModule")
             let animationModule = AnimationModule()
             await Router.shared.registerModule(animationModule)
             print("AppDelegate: AnimationModule 注册成功")
             
             // 等待所有模块注册完成后再注册路由
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                 Task {
                     // 注册根路径路由 - 使用 TabBarController 作为根视图控制器
                     print("AppDelegate: 开始注册根路径路由")
                     do {
                         // 使用动态路由注册根路径，避免模块检查
                         try await Router.shared.registerDynamicRoute("/", for: TabBarController.self)
                         print("AppDelegate: 根路径路由注册成功")
                     } catch {
                         print("AppDelegate: 根路径路由注册失败 - \(error)")
                     }
                     
                     // 注册首页路由 - 这个已经在 RootModule 中注册了，所以这里不需要再注册
                     print("AppDelegate: 首页路由已在 RootModule 中注册")
                 }
             }
        }
    }

}
