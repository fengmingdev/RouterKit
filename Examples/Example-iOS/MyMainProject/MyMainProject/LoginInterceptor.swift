//
//  LoginInterceptor.swift
//  MyMainProject
//
//  Created by fengming on 2025/8/8.
//
// MARK: 创建拦截器
import RouterKit_Swift

/// 登录拦截器 - 检查用户是否已登录
///// 验证用户登录状态的拦截器（高优先级）
public class LoginInterceptor: BaseInterceptor {

    // 重写为最高优先级（计算属性实现）
    public override var priority: InterceptorPriority {
        get { .highest }
        set { /* 固定为最高优先级，不允许修改 */ }
    }

    /// 拦截需要登录的路由
    public override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        Task {
            await log("开始登录状态检查：\(url)")

            // 需要登录的路由列表
            let needLoginRoutes: [String] = ["/MessageModule/message"]

            // 检查当前URL是否需要登录
            if needLoginRoutes.contains(where: { url.hasPrefix($0) }) {
                let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                if !isLoggedIn {
                    await log("未登录，拦截路由并跳转到登录页")
                    // 拦截路由，重定向到登录页，并携带来源URL
                    completion(false, "需要登录才能访问", "/LoginModule/login", ["from": url], .present)
                    return
                }
            }

            await log("登录状态验证通过，允许路由")
            completion(true, nil, nil, nil, nil)
        }
    }
}
