//
//  Interceptors.swift
//  InterceptorModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import Foundation
import RouterKit

// MARK: - 权限检查拦截器

/// 权限检查拦截器 - 检查用户是否有访问特定路由的权限
class AuthInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .normal
    var isAsync: Bool = true
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        let startTime = Date()
        
        // 模拟权限检查
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            let duration = Date().timeIntervalSince(startTime)
            
            // 检查用户登录状态
            let isLoggedIn = UserSession.shared.isLoggedIn
            
            if !isLoggedIn {
                let log = InterceptorLog(
                    interceptorName: "AuthInterceptor",
                    route: url,
                    action: "permission_check",
                    parameters: parameters,
                    result: .blocked("用户未登录"),
                    duration: duration,
                    message: "用户未登录，拒绝访问"
                )
                InterceptorManager.shared.addLog(log)
                
                DispatchQueue.main.async {
                    completion(false, "/login", "用户未登录", nil, nil)
                }
                return
            }
            
            // 检查特定权限
            let requiredPermission = parameters["requiredPermission"] as? String
            if let permission = requiredPermission {
                let hasPermission = UserSession.shared.hasPermission(permission)
                
                if !hasPermission {
                    let log = InterceptorLog(
                        interceptorName: "AuthInterceptor",
                        route: url,
                        action: "permission_check",
                        parameters: parameters,
                        result: .blocked("权限不足: \(permission)"),
                        duration: duration,
                        message: "用户缺少必要权限: \(permission)"
                    )
                    InterceptorManager.shared.addLog(log)
                    
                    DispatchQueue.main.async {
                        completion(false, nil, "权限不足: \(permission)", nil, nil)
                    }
                    return
                }
            }
            
            // 权限检查通过
            let log = InterceptorLog(
                interceptorName: "AuthInterceptor",
                route: url,
                action: "permission_check",
                parameters: parameters,
                result: .success,
                duration: duration,
                message: "权限检查通过"
            )
            InterceptorManager.shared.addLog(log)
            
            DispatchQueue.main.async {
                completion(true, nil, nil, nil, nil)
            }
        }
    }
}

// MARK: - 数据预加载拦截器

/// 数据预加载拦截器 - 在导航前预加载必要的数据
class DataPreloadInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .normal
    var isAsync: Bool = true
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        let startTime = Date()
        
        // 获取需要预加载的数据类型
        let preloadTypes = parameters["preloadData"] as? [String] ?? []
        
        if preloadTypes.isEmpty {
            let log = InterceptorLog(
                interceptorName: "DataPreloadInterceptor",
                route: url,
                action: "preload_data",
                parameters: parameters,
                result: .success,
                duration: Date().timeIntervalSince(startTime),
                message: "无需预加载数据"
            )
            InterceptorManager.shared.addLog(log)
            completion(true, nil, nil, nil, nil)
            return
        }
        
        // 并行预加载数据
        let group = DispatchGroup()
        var preloadedData: [String: Any] = [:]
        var errors: [Error] = []
        
        for dataType in preloadTypes {
            group.enter()
            preloadData(type: dataType) { result in
                switch result {
                case .success(let data):
                    preloadedData[dataType] = data
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let duration = Date().timeIntervalSince(startTime)
            
            if !errors.isEmpty {
                let log = InterceptorLog(
                    interceptorName: "DataPreloadInterceptor",
                    route: url,
                    action: "preload_data",
                    parameters: parameters,
                    result: .failure(errors.first!),
                    duration: duration,
                    message: "数据预加载失败: \(errors.count) 个错误"
                )
                InterceptorManager.shared.addLog(log)
                completion(false, "数据预加载失败", nil, nil, nil)
            } else {
                // 将预加载的数据添加到路由参数中
                var modifiedParameters = parameters
                modifiedParameters["preloadedData"] = preloadedData
                
                let log = InterceptorLog(
                    interceptorName: "DataPreloadInterceptor",
                    route: url,
                    action: "preload_data",
                    parameters: parameters,
                    result: .modified(modifiedParameters),
                    duration: duration,
                    message: "成功预加载 \(preloadedData.count) 项数据"
                )
                InterceptorManager.shared.addLog(log)
                
                // 传递修改后的参数
                completion(true, nil, nil, modifiedParameters, nil)
            }
        }
    }
    
    private func preloadData(type: String, completion: @escaping (Result<Any, Error>) -> Void) {
        // 模拟数据加载
        DispatchQueue.global().asyncAfter(deadline: .now() + Double.random(in: 0.1...0.5)) {
            switch type {
            case "userProfile":
                let profile = [
                    "id": Int.random(in: 1000...9999),
                    "name": "预加载用户\(Int.random(in: 1...100))",
                    "email": "user@example.com",
                    "avatar": "https://example.com/avatar.jpg"
                ]
                completion(.success(profile))
                
            case "userSettings":
                let settings = [
                    "theme": "dark",
                    "language": "zh-CN",
                    "notifications": true,
                    "autoSync": false
                ]
                completion(.success(settings))
                
            case "productList":
                let products = (1...10).map { i in
                    [
                        "id": "P\(1000 + i)",
                        "name": "产品\(i)",
                        "price": Double.random(in: 10...1000)
                    ]
                }
                completion(.success(products))
                
            case "messageList":
                let messages = (1...5).map { i in
                    [
                        "id": "M\(1000 + i)",
                        "title": "消息\(i)",
                        "content": "这是第\(i)条预加载的消息",
                        "timestamp": Date().timeIntervalSince1970 - Double(i * 3600)
                    ]
                }
                completion(.success(messages))
                
            default:
                completion(.failure(DataPreloadError.unknownDataType(type)))
            }
        }
    }
}

// MARK: - 全局日志拦截器

/// 全局日志拦截器 - 记录所有路由导航的日志
class GlobalLoggingInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .low
    var isAsync: Bool = false
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        let startTime = Date()
        
        // 记录导航开始
        let navigationId = UUID().uuidString
        print("[GlobalLogging] 🚀 导航开始 [\(navigationId)] -> \(url)")
        
        // 记录参数（过滤敏感信息）
        let filteredParameters = filterSensitiveParameters(parameters)
        if !filteredParameters.isEmpty {
            print("[GlobalLogging] 📋 参数: \(filteredParameters)")
        }
        
        // 继续执行
        completion(true, nil, nil, nil, nil)
        
        // 异步记录日志
        DispatchQueue.global().async {
            let duration = Date().timeIntervalSince(startTime)
            
            let log = InterceptorLog(
                interceptorName: "GlobalLoggingInterceptor",
                route: url,
                action: "navigation_log",
                parameters: filteredParameters,
                result: .success,
                duration: duration,
                message: "导航日志记录 [\(navigationId)]"
            )
            InterceptorManager.shared.addLog(log)
            
            print("[GlobalLogging] ✅ 导航完成 [\(navigationId)] 耗时: \(String(format: "%.2f", duration * 1000))ms")
        }
    }
    
    private func filterSensitiveParameters(_ parameters: [String: Any]) -> [String: Any] {
        let sensitiveKeys = ["password", "token", "secret", "key", "credential"]
        var filtered = parameters
        
        for key in sensitiveKeys {
            if filtered[key] != nil {
                filtered[key] = "[FILTERED]"
            }
        }
        
        return filtered
    }
}

// MARK: - 全局性能监控拦截器

/// 全局性能监控拦截器 - 监控导航性能
class GlobalPerformanceInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .low
    var isAsync: Bool = false
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        let startTime = Date()
        let memoryBefore = getMemoryUsage()
        
        // 继续执行
        completion(true, nil, nil, nil, nil)
        
        // 异步记录性能数据
        DispatchQueue.global().async {
            let duration = Date().timeIntervalSince(startTime)
            let memoryAfter = self.getMemoryUsage()
            
            let metric = PerformanceMetric(
                type: .navigation,
                route: url,
                duration: duration,
                memoryUsage: memoryAfter - memoryBefore,
                additionalInfo: [
                    "memoryBefore": memoryBefore,
                    "memoryAfter": memoryAfter,
                    "parameterCount": parameters.count
                ]
            )
            InterceptorManager.shared.addPerformanceMetric(metric)
            
            // 性能警告
            if duration > 1.0 {
                print("[Performance] ⚠️ 慢导航警告: \(url) 耗时 \(String(format: "%.2f", duration * 1000))ms")
            }
            
            if memoryAfter - memoryBefore > 10 * 1024 * 1024 { // 10MB
                print("[Performance] ⚠️ 内存使用警告: \(url) 增加 \((memoryAfter - memoryBefore) / 1024 / 1024)MB")
            }
        }
    }
    
    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        } else {
            return 0
        }
    }
}

// MARK: - 全局安全检查拦截器

/// 全局安全检查拦截器 - 检查路由安全性
class GlobalSecurityInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .high
    var isAsync: Bool = false
    
    private let rateLimiter = RateLimiter()
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        let startTime = Date()
        
        // 速率限制检查
        if !rateLimiter.allowRequest(for: url) {
            let event = SecurityEvent(
                type: .rateLimitExceeded,
                route: url,
                severity: .medium,
                description: "路由访问频率过高",
                userInfo: ["route": url]
            )
            InterceptorManager.shared.addSecurityEvent(event)
            
            let log = InterceptorLog(
                interceptorName: "GlobalSecurityInterceptor",
                route: url,
                action: "rate_limit_check",
                parameters: parameters,
                result: .blocked("访问频率过高"),
                duration: Date().timeIntervalSince(startTime),
                message: "触发速率限制"
            )
            InterceptorManager.shared.addLog(log)
            
            completion(false, SecurityError.rateLimitExceeded.localizedDescription, nil, nil, nil)
            return
        }
        
        // 参数安全检查
        if let securityIssue = validateParameters(parameters) {
            let event = SecurityEvent(
                type: .suspiciousParameter,
                route: url,
                severity: .high,
                description: securityIssue,
                userInfo: parameters
            )
            InterceptorManager.shared.addSecurityEvent(event)
            
            let log = InterceptorLog(
                interceptorName: "GlobalSecurityInterceptor",
                route: url,
                action: "parameter_validation",
                parameters: parameters,
                result: .blocked(securityIssue),
                duration: Date().timeIntervalSince(startTime),
                message: "参数安全检查失败: \(securityIssue)"
            )
            InterceptorManager.shared.addLog(log)
            
            completion(false, SecurityError.suspiciousParameter(securityIssue).localizedDescription, nil, nil, nil)
            return
        }
        
        // 安全检查通过
        let log = InterceptorLog(
            interceptorName: "GlobalSecurityInterceptor",
            route: url,
            action: "security_check",
            parameters: parameters,
            result: .success,
            duration: Date().timeIntervalSince(startTime),
            message: "安全检查通过"
        )
        InterceptorManager.shared.addLog(log)
        
        completion(true, nil, nil, nil, nil)
    }
    
    private func validateParameters(_ parameters: [String: Any]) -> String? {
        // 检查SQL注入
        for (key, value) in parameters {
            if let stringValue = value as? String {
                if containsSQLInjection(stringValue) {
                    return "检测到SQL注入尝试: \(key)"
                }
                
                if containsXSS(stringValue) {
                    return "检测到XSS尝试: \(key)"
                }
                
                if containsPathTraversal(stringValue) {
                    return "检测到路径遍历尝试: \(key)"
                }
            }
        }
        
        return nil
    }
    
    private func containsSQLInjection(_ input: String) -> Bool {
        let sqlPatterns = ["'", "--", "/*", "*/", "xp_", "sp_", "union", "select", "insert", "delete", "update", "drop"]
        let lowercased = input.lowercased()
        return sqlPatterns.contains { lowercased.contains($0) }
    }
    
    private func containsXSS(_ input: String) -> Bool {
        let xssPatterns = ["<script", "javascript:", "onload=", "onerror=", "onclick="]
        let lowercased = input.lowercased()
        return xssPatterns.contains { lowercased.contains($0) }
    }
    
    private func containsPathTraversal(_ input: String) -> Bool {
        return input.contains("../") || input.contains("..\\")
    }
}

// MARK: - 缓存拦截器

/// 缓存拦截器 - 缓存路由结果
class CacheInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .normal
    var isAsync: Bool = false
    
    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        let startTime = Date()
        let cacheKey = generateCacheKey(route: url, parameters: parameters)
        
        // 检查缓存
        if let cachedData = InterceptorManager.shared.getCacheData(cacheKey) {
            let log = InterceptorLog(
                interceptorName: "CacheInterceptor",
                route: url,
                action: "cache_hit",
                parameters: parameters,
                result: .success,
                duration: Date().timeIntervalSince(startTime),
                message: "缓存命中: \(cacheKey)"
            )
            InterceptorManager.shared.addLog(log)
            
            // 将缓存数据添加到参数中
            var modifiedParameters = parameters
            modifiedParameters["cachedData"] = cachedData
            
            completion(true, nil, nil, modifiedParameters, nil)
            return
        }
        
        // 缓存未命中，继续执行并缓存结果
        let log = InterceptorLog(
            interceptorName: "CacheInterceptor",
            route: url,
            action: "cache_miss",
            parameters: parameters,
            result: .success,
            duration: Date().timeIntervalSince(startTime),
            message: "缓存未命中: \(cacheKey)"
        )
        InterceptorManager.shared.addLog(log)
        
        // 模拟数据生成并缓存
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            let generatedData = self.generateDataForRoute(url)
            InterceptorManager.shared.setCacheData(cacheKey, value: generatedData)
            
            DispatchQueue.main.async {
                var modifiedParameters = parameters
                modifiedParameters["generatedData"] = generatedData
                
                completion(true, nil, nil, modifiedParameters, nil)
            }
        }
    }
    
    private func generateCacheKey(route: String, parameters: [String: Any]) -> String {
        let parameterString = parameters.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: "&")
        return "\(route)?\(parameterString)".data(using: .utf8)?.base64EncodedString() ?? route
    }
    
    private func generateDataForRoute(_ route: String) -> [String: Any] {
        return [
            "route": route,
            "timestamp": Date().timeIntervalSince1970,
            "data": "缓存数据 for \(route)",
            "cacheId": UUID().uuidString
        ]
    }
}

// MARK: - 辅助类

/// 速率限制器
class RateLimiter {
    private var requestCounts: [String: [Date]] = [:]
    private let maxRequestsPerMinute = 60
    private let timeWindow: TimeInterval = 60 // 1分钟
    
    func allowRequest(for route: String) -> Bool {
        let now = Date()
        let cutoffTime = now.addingTimeInterval(-timeWindow)
        
        // 清理过期记录
        requestCounts[route] = requestCounts[route]?.filter { $0 > cutoffTime } ?? []
        
        // 检查是否超过限制
        let currentCount = requestCounts[route]?.count ?? 0
        if currentCount >= maxRequestsPerMinute {
            return false
        }
        
        // 记录新请求
        requestCounts[route, default: []].append(now)
        return true
    }
}

/// 用户会话管理
class UserSession {
    static let shared = UserSession()
    
    private init() {}
    
    var isLoggedIn: Bool {
        // 模拟登录状态
        return true
    }
    
    func hasPermission(_ permission: String) -> Bool {
        // 模拟权限检查
        let userPermissions = ["read", "write", "admin"]
        return userPermissions.contains(permission)
    }
}

// MARK: - 错误定义

enum AuthError: Error, LocalizedError {
    case notLoggedIn
    case insufficientPermission(String)
    
    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "用户未登录"
        case .insufficientPermission(let permission):
            return "权限不足: \(permission)"
        }
    }
}

enum DataPreloadError: Error, LocalizedError {
    case unknownDataType(String)
    case loadTimeout
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .unknownDataType(let type):
            return "未知数据类型: \(type)"
        case .loadTimeout:
            return "数据加载超时"
        case .networkError:
            return "网络错误"
        }
    }
}

enum SecurityError: Error, LocalizedError {
    case rateLimitExceeded
    case suspiciousParameter(String)
    case invalidToken
    
    var errorDescription: String? {
        switch self {
        case .rateLimitExceeded:
            return "访问频率过高"
        case .suspiciousParameter(let detail):
            return "可疑参数: \(detail)"
        case .invalidToken:
            return "无效令牌"
        }
    }
}
