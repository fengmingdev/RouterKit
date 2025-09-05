//
//  InterceptorModule.swift
//  InterceptorModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import Foundation
import RouterKit

/// 拦截器示例模块
public class InterceptorModule: ModuleProtocol, @unchecked Sendable {
    
    public var moduleName: String = "InterceptorModule"
    public var dependencies: [ModuleDependency] = []
    public var lastUsedTime: Date = Date()
    public var isLoaded: Bool = false
    public var router: Router?
    
    required public init() {}
    
    public func load(completion: @escaping (Bool) -> Void) {
        print("InterceptorModule: 开始加载模块")
        Task {
            do {
                // 注册拦截器相关路由
                try await Router.shared.registerRoute("/InterceptorModule/interceptor", for: InterceptorViewController.self)
                try await Router.shared.registerRoute("/InterceptorModule/authInterceptor", for: AuthInterceptorViewController.self)
                try await Router.shared.registerRoute("/InterceptorModule/dataPreload", for: DataPreloadViewController.self)
                
                setupInterceptors()
                self.isLoaded = true
                print("InterceptorModule: 模块加载成功")
                completion(true)
            } catch {
                print("InterceptorModule: 模块加载失败 - \(error)")
                completion(false)
            }
        }
    }
    
    public func unload() {
        isLoaded = false
        cleanupInterceptors()
        print("InterceptorModule: 模块已卸载")
    }
    
    public func suspend() {
        lastUsedTime = Date()
        print("InterceptorModule: 模块已暂停")
    }
    
    public func resume() {
        lastUsedTime = Date()
        print("InterceptorModule: 模块已恢复")
    }
    
    private func setupInterceptors() {
        // 注册全局拦截器
        registerGlobalInterceptors()
        
        // 注册路由特定拦截器
        registerRouteSpecificInterceptors()
        
        print("InterceptorModule: 拦截器设置完成")
    }
    
    private func registerGlobalInterceptors() {
        Task {
            // 全局日志拦截器
            let globalLoggingInterceptor = GlobalLoggingInterceptor()
            await Router.shared.addInterceptor(globalLoggingInterceptor)
            
            // 全局性能监控拦截器
            let globalPerformanceInterceptor = GlobalPerformanceInterceptor()
            await Router.shared.addInterceptor(globalPerformanceInterceptor)
            
            // 全局安全检查拦截器
            let globalSecurityInterceptor = GlobalSecurityInterceptor()
            await Router.shared.addInterceptor(globalSecurityInterceptor)
        }
    }
    
    private func registerRouteSpecificInterceptors() {
        Task {
            // 权限检查拦截器 - 应用于需要权限的路由
            let authInterceptor = AuthInterceptor()
            await Router.shared.addInterceptor(authInterceptor)
            
            // 数据预加载拦截器 - 应用于需要预加载数据的路由
            let dataPreloadInterceptor = DataPreloadInterceptor()
            await Router.shared.addInterceptor(dataPreloadInterceptor)
            
            // 缓存拦截器 - 应用于需要缓存的路由
            let cacheInterceptor = CacheInterceptor()
            await Router.shared.addInterceptor(cacheInterceptor)
        }
    }
    
    private func cleanupInterceptors() {
        // 清理拦截器资源
        InterceptorManager.shared.cleanup()
    }
}

// MARK: - 拦截器管理器

/// 拦截器管理器 - 用于管理拦截器的生命周期和状态
class InterceptorManager {
    static let shared = InterceptorManager()
    
    private var interceptorLogs: [InterceptorLog] = []
    private var performanceMetrics: [PerformanceMetric] = []
    private var cacheData: [String: Any] = [:]
    private var securityEvents: [SecurityEvent] = []
    
    private init() {}
    
    // MARK: - 日志管理
    
    func addLog(_ log: InterceptorLog) {
        interceptorLogs.append(log)
        
        // 保持最近1000条日志
        if interceptorLogs.count > 1000 {
            interceptorLogs.removeFirst(interceptorLogs.count - 1000)
        }
    }
    
    func getLogs(limit: Int = 100) -> [InterceptorLog] {
        return Array(interceptorLogs.suffix(limit))
    }
    
    func clearLogs() {
        interceptorLogs.removeAll()
    }
    
    // MARK: - 性能监控
    
    func addPerformanceMetric(_ metric: PerformanceMetric) {
        performanceMetrics.append(metric)
        
        // 保持最近500条性能数据
        if performanceMetrics.count > 500 {
            performanceMetrics.removeFirst(performanceMetrics.count - 500)
        }
    }
    
    func getPerformanceMetrics(limit: Int = 50) -> [PerformanceMetric] {
        return Array(performanceMetrics.suffix(limit))
    }
    
    func getAverageNavigationTime() -> Double {
        let navigationMetrics = performanceMetrics.filter { $0.type == .navigation }
        guard !navigationMetrics.isEmpty else { return 0 }
        
        let totalTime = navigationMetrics.reduce(0) { $0 + $1.duration }
        return totalTime / Double(navigationMetrics.count)
    }
    
    // MARK: - 缓存管理
    
    func setCacheData(_ key: String, value: Any) {
        cacheData[key] = value
    }
    
    func getCacheData(_ key: String) -> Any? {
        return cacheData[key]
    }
    
    func clearCache() {
        cacheData.removeAll()
    }
    
    func getCacheSize() -> Int {
        return cacheData.count
    }
    
    // MARK: - 安全事件
    
    func addSecurityEvent(_ event: SecurityEvent) {
        securityEvents.append(event)
        
        // 保持最近200条安全事件
        if securityEvents.count > 200 {
            securityEvents.removeFirst(securityEvents.count - 200)
        }
    }
    
    func getSecurityEvents(limit: Int = 50) -> [SecurityEvent] {
        return Array(securityEvents.suffix(limit))
    }
    
    // MARK: - 拦截器控制
    
    private var enabledInterceptors: Set<String> = []
    
    func enableInterceptor(_ name: String) {
        enabledInterceptors.insert(name)
    }
    
    func disableInterceptor(_ name: String) {
        enabledInterceptors.remove(name)
    }
    
    func isInterceptorEnabled(_ name: String) -> Bool {
        return enabledInterceptors.contains(name)
    }
    
    // MARK: - 清理
    
    func cleanup() {
        clearLogs()
        clearCache()
        performanceMetrics.removeAll()
        securityEvents.removeAll()
    }
}

// MARK: - 拦截器日志管理器

/// 拦截器日志管理器
class InterceptorLogger {
    static let shared = InterceptorLogger()
    
    private var logs: [String] = []
    
    private init() {}
    
    func log(_ message: String) {
        let timestamp = DateFormatter.interceptorFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] \(message)"
        logs.append(logEntry)
        
        // 保持最近500条日志
        if logs.count > 500 {
            logs.removeFirst(logs.count - 500)
        }
    }
    
    func getLogs() -> [String] {
        return logs
    }
    
    func clearLogs() {
        logs.removeAll()
    }
}

// MARK: - 拦截器统计管理器

/// 拦截器统计管理器
class InterceptorStats {
    static let shared = InterceptorStats()
    
    private var totalRequests: Int = 0
    private var successfulRequests: Int = 0
    private var failedRequests: Int = 0
    private var blockedRequests: Int = 0
    private var averageResponseTime: Double = 0
    private var lastResetTime: Date = Date()
    
    private init() {}
    
    func recordRequest(success: Bool, blocked: Bool = false, responseTime: Double = 0) {
        totalRequests += 1
        
        if blocked {
            blockedRequests += 1
        } else if success {
            successfulRequests += 1
        } else {
            failedRequests += 1
        }
        
        // 更新平均响应时间
        if responseTime > 0 {
            averageResponseTime = (averageResponseTime * Double(totalRequests - 1) + responseTime) / Double(totalRequests)
        }
    }
    
    func getStats() -> [String: Any] {
        return [
            "totalRequests": totalRequests,
            "successfulRequests": successfulRequests,
            "failedRequests": failedRequests,
            "blockedRequests": blockedRequests,
            "averageResponseTime": averageResponseTime,
            "lastResetTime": lastResetTime
        ]
    }
    
    func reset() {
        totalRequests = 0
        successfulRequests = 0
        failedRequests = 0
        blockedRequests = 0
        averageResponseTime = 0
        lastResetTime = Date()
    }
}

// MARK: - 数据模型

/// 拦截器日志
struct InterceptorLog {
    let id: String
    let timestamp: Date
    let interceptorName: String
    let route: String
    let action: String
    let parameters: [String: Any]?
    let result: InterceptorResult
    let duration: TimeInterval
    let message: String?
    
    init(interceptorName: String, route: String, action: String, parameters: [String: Any]? = nil, result: InterceptorResult, duration: TimeInterval, message: String? = nil) {
        self.id = UUID().uuidString
        self.timestamp = Date()
        self.interceptorName = interceptorName
        self.route = route
        self.action = action
        self.parameters = parameters
        self.result = result
        self.duration = duration
        self.message = message
    }
}

/// 拦截器结果
enum InterceptorResult {
    case success
    case failure(Error)
    case blocked(String)
    case modified([String: Any])
}

/// 性能指标
struct PerformanceMetric {
    let id: String
    let timestamp: Date
    let type: MetricType
    let route: String
    let duration: TimeInterval
    let memoryUsage: Int64?
    let additionalInfo: [String: Any]?
    
    enum MetricType {
        case navigation
        case interceptor
        case dataLoad
        case rendering
    }
    
    init(type: MetricType, route: String, duration: TimeInterval, memoryUsage: Int64? = nil, additionalInfo: [String: Any]? = nil) {
        self.id = UUID().uuidString
        self.timestamp = Date()
        self.type = type
        self.route = route
        self.duration = duration
        self.memoryUsage = memoryUsage
        self.additionalInfo = additionalInfo
    }
}

/// 安全事件
struct SecurityEvent {
    let id: String
    let timestamp: Date
    let type: SecurityEventType
    let route: String
    let severity: SecuritySeverity
    let description: String
    let userInfo: [String: Any]?
    
    enum SecurityEventType {
        case unauthorizedAccess
        case suspiciousParameter
        case rateLimitExceeded
        case invalidToken
        case dataValidationFailed
    }
    
    enum SecuritySeverity {
        case low
        case medium
        case high
        case critical
    }
    
    init(type: SecurityEventType, route: String, severity: SecuritySeverity, description: String, userInfo: [String: Any]? = nil) {
        self.id = UUID().uuidString
        self.timestamp = Date()
        self.type = type
        self.route = route
        self.severity = severity
        self.description = description
        self.userInfo = userInfo
    }
}

// MARK: - 工具扩展

extension DateFormatter {
    static let interceptorFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    static let interceptorDetailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}