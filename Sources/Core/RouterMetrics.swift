//  RouterMetrics.swift
//  RouterKit
//
//  Created by fengming on 2025/8/4.
//

import Foundation
import Combine

/// 路由性能指标
enum RouterMetricType {
    /// 路由解析时间
    case routeParsing
    /// 页面跳转时间
    case navigation
    /// 模块加载时间
    case moduleLoading
    /// 拦截器执行时间
    case interceptorExecution
    /// 参数解析时间
    case parameterParsing
}

/// 路由事件类型
enum RouterEventType {
    /// 路由成功
    case routeSuccess
    /// 路由失败
    case routeFailure
    /// 模块注册
    case moduleRegistered
    /// 模块卸载
    case moduleUnloaded
}

/// 路由统计数据结构
struct RouterMetricsData {
    /// 事件类型
    let eventType: RouterEventType
    /// 路由模式
    let routePattern: String?
    /// 模块名称
    let moduleName: String?
    /// 错误信息（如果有）
    let error: Error?
    /// 时间戳
    let timestamp: Date
    /// 性能指标值（毫秒）
    let metricValue: Double?
    /// 指标类型
    let metricType: RouterMetricType?
}

/// 路由监控和统计类
@available(iOS 13.0, macOS 10.15, *)
final actor RouterMetrics {
    static let shared = RouterMetrics()
    private init() {}
    
    // MARK: - 配置
    /// 是否启用监控
    public var isEnabled = true
    /// 数据保留时长（天）
    public var dataRetentionDays: Int = 7
    
    // MARK: - 数据存储
    private var metricsData: [RouterMetricsData] = []
    private var dataCleanupTimer: Timer?
    
    // MARK: - 初始化
    public func initialize() async {
        // 设置定时清理过期数据
        dataCleanupTimer = Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                Task {
                    await self?.cleanupExpiredData()
                }
            }
        }
    }
    
    // MARK: - 性能计时
    /// 开始计时
    /// - Returns: 计时令牌
    public func startTiming() -> UUID {
        let token = UUID()
        timingData[token] = Date()
        return token
    }
    
    /// 结束计时并记录指标
    /// - Parameters:
    ///   - token: 计时令牌
    ///   - type: 指标类型
    ///   - routePattern: 路由模式
    ///   - moduleName: 模块名称
    /// - Returns: 计时结果（毫秒）
    @discardableResult
    public func endTiming(_ token: UUID, 
                          type: RouterMetricType, 
                          routePattern: String? = nil, 
                          moduleName: String? = nil) -> Double? {
        guard let startTime = timingData.removeValue(forKey: token) else { return nil }
        
        let duration = Date().timeIntervalSince(startTime) * 1000 // 转换为毫秒
        
        // 记录性能指标
        recordMetric(type: type, 
                     value: duration, 
                     routePattern: routePattern, 
                     moduleName: moduleName)
        
        return duration
    }
    
    // MARK: - 事件记录
    /// 记录路由成功事件
    /// - Parameters:
    ///   - routePattern: 路由模式
    ///   - moduleName: 模块名称
    public func recordRouteSuccess(routePattern: String, moduleName: String) {
        recordEvent(type: .routeSuccess, 
                    routePattern: routePattern, 
                    moduleName: moduleName)
    }
    
    /// 记录路由失败事件
    /// - Parameters:
    ///   - routePattern: 路由模式
    ///   - moduleName: 模块名称
    ///   - error: 错误信息
    public func recordRouteFailure(routePattern: String?, 
                                   moduleName: String?, 
                                   error: Error) {
        recordEvent(type: .routeFailure, 
                    routePattern: routePattern, 
                    moduleName: moduleName, 
                    error: error)
    }
    
    /// 记录模块注册事件
    /// - Parameter moduleName: 模块名称
    public func recordModuleRegistered(moduleName: String) {
        recordEvent(type: .moduleRegistered, 
                    moduleName: moduleName)
    }
    
    /// 记录模块卸载事件
    /// - Parameter moduleName: 模块名称
    public func recordModuleUnloaded(moduleName: String) {
        recordEvent(type: .moduleUnloaded, 
                    moduleName: moduleName)
    }
    
    // MARK: - 私有方法
    private var timingData: [UUID: Date] = [:]
    
    private func recordMetric(type: RouterMetricType, 
                             value: Double, 
                             routePattern: String? = nil, 
                             moduleName: String? = nil) {
        guard isEnabled else { return }
        
        let data = RouterMetricsData(eventType: .routeSuccess, 
                                     routePattern: routePattern, 
                                     moduleName: moduleName, 
                                     error: nil, 
                                     timestamp: Date(), 
                                     metricValue: value, 
                                     metricType: type)
        
        saveData(data)
    }
    
    private func recordEvent(type: RouterEventType, 
                            routePattern: String? = nil, 
                            moduleName: String? = nil, 
                            error: Error? = nil) {
        guard isEnabled else { return }
        
        let data = RouterMetricsData(eventType: type, 
                                     routePattern: routePattern, 
                                     moduleName: moduleName, 
                                     error: error, 
                                     timestamp: Date(), 
                                     metricValue: nil, 
                                     metricType: nil)
        
        saveData(data)
    }
    
    private func saveData(_ data: RouterMetricsData) {
        metricsData.append(data)
        
        // 实时发送数据通知
        NotificationCenter.default.post(name: .routerMetricsUpdated, object: data)
    }
    
    private func cleanupExpiredData() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -dataRetentionDays, to: Date())!
        metricsData = metricsData.filter { $0.timestamp >= cutoffDate }
    }
    
    // MARK: - 数据导出
    /// 导出指定时间范围内的统计数据
    /// - Parameter timeRange: 时间范围
    /// - Returns: 统计数据数组
    public func exportData(for timeRange: Range<Date>) -> [RouterMetricsData] {
        return metricsData.filter { timeRange.contains($0.timestamp) }
    }
    
    /// 获取路由成功率统计
    /// - Parameter timeRange: 时间范围
    /// - Returns: 成功率
    public func getRouteSuccessRate(for timeRange: Range<Date>? = nil) -> Double {
        let data = timeRange.map { exportData(for: $0) } ?? getAllData()
        
        let totalRoutes = data.filter { $0.eventType == .routeSuccess || $0.eventType == .routeFailure }.count
        guard totalRoutes > 0 else { return 1.0 }
        
        let successRoutes = data.filter { $0.eventType == .routeSuccess }.count
        return Double(successRoutes) / Double(totalRoutes)
    }
    
    /// 获取平均性能指标
    /// - Parameters:
    ///   - type: 指标类型
    ///   - timeRange: 时间范围
    /// - Returns: 平均指标值（毫秒）
    public func getAverageMetric(for type: RouterMetricType, timeRange: Range<Date>? = nil) -> Double? {
        let data = timeRange.map { exportData(for: $0) } ?? getAllData()
        
        let metrics = data.filter { $0.metricType == type && $0.metricValue != nil }
                          .compactMap { $0.metricValue }
        
        guard !metrics.isEmpty else { return nil }
        return metrics.reduce(0, +) / Double(metrics.count)
    }
    
    /// 获取所有数据（用于调试）
    private func getAllData() -> [RouterMetricsData] {
        return metricsData
    }
    
    /// 按模块获取路由成功率统计
    /// - Parameter timeRange: 时间范围
    /// - Returns: 模块名称到成功率的映射
    public func getRouteSuccessRateByModule(for timeRange: Range<Date>? = nil) -> [String: Double] {
        let data = timeRange.map { exportData(for: $0) } ?? getAllData()
        
        // 按模块分组统计
        var moduleStats: [String: (success: Int, total: Int)] = [:]
        
        data.forEach { item in
            guard let moduleName = item.moduleName else { return }
            
            let stats = moduleStats[moduleName] ?? (0, 0)
            
            if item.eventType == .routeSuccess {
                moduleStats[moduleName] = (stats.success + 1, stats.total + 1)
            } else if item.eventType == .routeFailure {
                moduleStats[moduleName] = (stats.success, stats.total + 1)
            }
        }
        
        // 计算成功率
        var result: [String: Double] = [:]
        moduleStats.forEach { module, stats in
            if stats.total > 0 {
                result[module] = Double(stats.success) / Double(stats.total)
            } else {
                result[module] = 1.0
            }
        }
        
        return result
    }
    
    /// 按模块获取平均路由耗时
    /// - Parameters:
    ///   - type: 指标类型
    ///   - timeRange: 时间范围
    /// - Returns: 模块名称到平均耗时的映射
    public func getAverageMetricByModule(for type: RouterMetricType, timeRange: Range<Date>? = nil) -> [String: Double] {
        let data = timeRange.map { exportData(for: $0) } ?? getAllData()
        
        // 按模块分组统计
        var moduleMetrics: [String: (sum: Double, count: Int)] = [:]
        
        data.forEach { item in
            guard let moduleName = item.moduleName, let value = item.metricValue, item.metricType == type else { return }
            
            let metrics = moduleMetrics[moduleName] ?? (0, 0)
            moduleMetrics[moduleName] = (metrics.sum + value, metrics.count + 1)
        }
        
        // 计算平均值
        var result: [String: Double] = [:]
        moduleMetrics.forEach { module, metrics in
            if metrics.count > 0 {
                result[module] = metrics.sum / Double(metrics.count)
            }
        }
        
        return result
    }
    
    /// 获取模块加载成功率
    /// - Parameter timeRange: 时间范围
    /// - Returns: 模块加载成功率
    public func getModuleLoadingSuccessRate(for timeRange: Range<Date>? = nil) -> Double {
        let data = timeRange.map { exportData(for: $0) } ?? getAllData()
        
        let totalModules = data.filter { $0.eventType == .moduleRegistered || $0.eventType == .moduleUnloaded }.count
        guard totalModules > 0 else { return 1.0 }
        
        let successModules = data.filter { $0.eventType == .moduleRegistered }.count
        return Double(successModules) / Double(totalModules)
    }
}

// MARK: - 通知扩展
extension Notification.Name {
    static let routerMetricsUpdated = Notification.Name("RouterMetricsUpdated")
}
