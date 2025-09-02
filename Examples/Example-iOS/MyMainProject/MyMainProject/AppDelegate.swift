//
//  AppDelegate.swift
//  MyMainProject
//
//  Created by fengming on 2025/8/8.
//

import UIKit
import RouterKit_Swift
import LoginModule
import MessageModule

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 配置路由
        configureRouter()

        // 注册模块
        registerModules()
        
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
        }
    }

}

