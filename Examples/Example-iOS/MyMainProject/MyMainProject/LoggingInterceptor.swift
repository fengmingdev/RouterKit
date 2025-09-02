//
//  LoggingInterceptor.swift
//  MyMainProject
//
//  Created by fengming on 2025/8/8.
//

import RouterKit_Swift

/// 日志拦截器 - 记录所有路由操作
class LoggingInterceptor: BaseInterceptor {
    // 重写为最低优先级
    override var priority: InterceptorPriority {
        get { .lowest }
        set { /* 固定为最低优先级，不允许修改 */ }
    }
    
    override func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        print("[路由日志] 访问: \(url), 参数: \(parameters)")
        // 继续执行（允许路由，不修改URL和参数）
        completion(true, nil, nil, nil, nil)
    }
}
