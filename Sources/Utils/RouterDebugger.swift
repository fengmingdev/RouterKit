//
//  RouterDebugger.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/2.
//

import Foundation

/// 路由调试工具
@available(iOS 13.0, macOS 10.15, *)
public actor RouterDebugger {
    public static let shared = RouterDebugger()
    private init() {}
    
    private var isEnabled = false
    private var debugSessions: [String: DebugSession] = [:]
    
    /// 调试会话
    private struct DebugSession {
        let id: String
        let startTime: Date
        var events: [DebugEvent] = []
        var isActive: Bool = true
        
        mutating func addEvent(_ event: DebugEvent) {
            events.append(event)
        }
    }
    
    /// 调试事件
    public struct DebugEvent {
        public let timestamp: Date
        public let type: EventType
        public let message: String
        public let metadata: [String: Any]
        
        public enum EventType {
            case routeRegistration
            case routeMatch
            case routeFailure
            case navigation
            case moduleLoad
            case interceptor
            case performance
            case error
        }
        
        public init(type: EventType, message: String, metadata: [String: Any] = [:]) {
            self.timestamp = Date()
            self.type = type
            self.message = message
            self.metadata = metadata
        }
    }
    
    // MARK: - 调试控制
    
    /// 启用调试模式
    public func enable() {
        isEnabled = true
        await RouterLogger.shared.log("RouterDebugger已启用", level: .info)
    }
    
    /// 禁用调试模式
    public func disable() {
        isEnabled = false
        debugSessions.removeAll()
        await RouterLogger.shared.log("RouterDebugger已禁用", level: .info)
    }
    
    /// 检查是否启用调试
    public func isDebugEnabled() -> Bool {
        return isEnabled
    }
    
    // MARK: - 调试会话管理
    
    /// 开始调试会话
    public func startSession(_ sessionId: String = UUID().uuidString) -> String {
        guard isEnabled else { return "" }
        
        let session = DebugSession(id: sessionId, startTime: Date())
        debugSessions[sessionId] = session
        
        Task {
            await RouterLogger.shared.log("调试会话已开始: \(sessionId)", level: .debug)
        }
        
        return sessionId
    }
    
    /// 结束调试会话
    public func endSession(_ sessionId: String) {
        guard isEnabled, var session = debugSessions[sessionId] else { return }
        
        session.isActive = false
        debugSessions[sessionId] = session
        
        Task {
            await RouterLogger.shared.log("调试会话已结束: \(sessionId)", level: .debug)
        }
    }
    
    /// 记录调试事件
    public func logEvent(_ event: DebugEvent, sessionId: String? = nil) {
        guard isEnabled else { return }
        
        if let sessionId = sessionId, var session = debugSessions[sessionId] {
            session.addEvent(event)
            debugSessions[sessionId] = session
        }
        
        Task {
            await RouterLogger.shared.log("[\(event.type)] \(event.message)", level: .debug)
        }
    }
    
    // MARK: - 路由状态检查
    
    /// 获取路由系统状态
    public func getSystemStatus() async -> SystemStatus {
        let router = RouterCore.shared
        
        let registeredRoutes = await router.getAllRegisteredRoutes()
        let loadedModules = await router.getAllLoadedModules()
        let activeInterceptors = await router.getActiveInterceptors()
        
        return SystemStatus(
            totalRoutes: registeredRoutes.count,
            loadedModules: loadedModules.count,
            activeInterceptors: activeInterceptors.count,
            memoryUsage: getMemoryUsage(),
            uptime: getUptime()
        )
    }
    
    /// 系统状态
    public struct SystemStatus {
        public let totalRoutes: Int
        public let loadedModules: Int
        public let activeInterceptors: Int
        public let memoryUsage: Double // MB
        public let uptime: TimeInterval
        
        public var description: String {
            return """
            路由系统状态:
            - 已注册路由: \(totalRoutes)
            - 已加载模块: \(loadedModules)
            - 活跃拦截器: \(activeInterceptors)
            - 内存使用: \(String(format: "%.2f", memoryUsage)) MB
            - 运行时间: \(String(format: "%.2f", uptime)) 秒
            """
        }
    }
    
    // MARK: - 路由诊断
    
    /// 诊断路由问题
    public func diagnoseRoute(_ url: String) async -> RouteDiagnosis {
        guard let url = URL(string: url) else {
            return RouteDiagnosis(
                url: url,
                isValid: false,
                matchedPattern: nil,
                issues: ["无效的URL格式"]
            )
        }
        
        let router = RouterCore.shared
        var issues: [String] = []
        
        // 检查URL格式
        if url.scheme?.isEmpty ?? true {
            issues.append("缺少URL scheme")
        }
        
        // 尝试匹配路由
        let matchResult = await router.matchRoute(url)
        let matchedPattern = matchResult?.pattern.pattern
        
        if matchResult == nil {
            issues.append("未找到匹配的路由模式")
            
            // 检查相似的路由
            let allRoutes = await router.getAllRegisteredRoutes()
            let similarRoutes = findSimilarRoutes(url.path, in: allRoutes.map { $0.pattern })
            if !similarRoutes.isEmpty {
                issues.append("相似的路由: \(similarRoutes.joined(separator: ", "))")
            }
        }
        
        return RouteDiagnosis(
            url: url.absoluteString,
            isValid: issues.isEmpty,
            matchedPattern: matchedPattern,
            issues: issues
        )
    }
    
    /// 路由诊断结果
    public struct RouteDiagnosis {
        public let url: String
        public let isValid: Bool
        public let matchedPattern: String?
        public let issues: [String]
        
        public var description: String {
            var result = "路由诊断: \(url)\n"
            result += "状态: \(isValid ? "✅ 有效" : "❌ 无效")\n"
            
            if let pattern = matchedPattern {
                result += "匹配模式: \(pattern)\n"
            }
            
            if !issues.isEmpty {
                result += "问题:\n"
                for issue in issues {
                    result += "  - \(issue)\n"
                }
            }
            
            return result
        }
    }
    
    // MARK: - 性能监控
    
    /// 开始性能监控
    public func startPerformanceMonitoring() {
        guard isEnabled else { return }
        
        Task {
            await RouterLogger.shared.log("性能监控已开始", level: .info)
        }
    }
    
    /// 记录性能指标
    public func recordPerformanceMetric(_ name: String, value: Double, unit: String = "ms") {
        guard isEnabled else { return }
        
        let event = DebugEvent(
            type: .performance,
            message: "性能指标: \(name) = \(value) \(unit)",
            metadata: ["metric": name, "value": value, "unit": unit]
        )
        
        logEvent(event)
    }
    
    // MARK: - 调试报告
    
    /// 生成调试报告
    public func generateReport(sessionId: String? = nil) async -> String {
        guard isEnabled else { return "调试模式未启用" }
        
        var report = "# RouterKit 调试报告\n\n"
        report += "生成时间: \(Date())\n\n"
        
        // 系统状态
        let status = await getSystemStatus()
        report += "## 系统状态\n\n"
        report += status.description + "\n\n"
        
        // 会话信息
        if let sessionId = sessionId, let session = debugSessions[sessionId] {
            report += "## 调试会话: \(sessionId)\n\n"
            report += "开始时间: \(session.startTime)\n"
            report += "事件数量: \(session.events.count)\n\n"
            
            report += "### 事件列表\n\n"
            for event in session.events {
                report += "- [\(event.timestamp)] [\(event.type)] \(event.message)\n"
            }
        } else {
            report += "## 所有调试会话\n\n"
            for (id, session) in debugSessions {
                report += "### 会话: \(id)\n"
                report += "- 开始时间: \(session.startTime)\n"
                report += "- 事件数量: \(session.events.count)\n"
                report += "- 状态: \(session.isActive ? "活跃" : "已结束")\n\n"
            }
        }
        
        return report
    }
    
    /// 导出调试数据
    public func exportDebugData() async -> [String: Any] {
        guard isEnabled else { return [:] }
        
        let status = await getSystemStatus()
        
        return [
            "timestamp": Date(),
            "systemStatus": [
                "totalRoutes": status.totalRoutes,
                "loadedModules": status.loadedModules,
                "activeInterceptors": status.activeInterceptors,
                "memoryUsage": status.memoryUsage,
                "uptime": status.uptime
            ],
            "sessions": debugSessions.mapValues { session in
                [
                    "id": session.id,
                    "startTime": session.startTime,
                    "isActive": session.isActive,
                    "eventCount": session.events.count,
                    "events": session.events.map { event in
                        [
                            "timestamp": event.timestamp,
                            "type": "\(event.type)",
                            "message": event.message,
                            "metadata": event.metadata
                        ]
                    }
                ]
            }
        ]
    }
    
    // MARK: - 辅助方法
    
    private func getMemoryUsage() -> Double {
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
            return Double(info.resident_size) / 1024.0 / 1024.0 // 转换为MB
        } else {
            return 0.0
        }
    }
    
    private func getUptime() -> TimeInterval {
        var uptime = timespec()
        if clock_gettime(CLOCK_UPTIME_RAW, &uptime) == 0 {
            return Double(uptime.tv_sec) + Double(uptime.tv_nsec) / 1_000_000_000.0
        }
        return 0.0
    }
    
    private func findSimilarRoutes(_ path: String, in routes: [String]) -> [String] {
        return routes.filter { route in
            let similarity = calculateSimilarity(path, route)
            return similarity > 0.6 // 60%相似度阈值
        }
    }
    
    private func calculateSimilarity(_ str1: String, _ str2: String) -> Double {
        let longer = str1.count > str2.count ? str1 : str2
        let shorter = str1.count > str2.count ? str2 : str1
        
        if longer.isEmpty {
            return 1.0
        }
        
        let editDistance = levenshteinDistance(str1, str2)
        return (Double(longer.count) - Double(editDistance)) / Double(longer.count)
    }
    
    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let str1Array = Array(str1)
        let str2Array = Array(str2)
        let str1Count = str1Array.count
        let str2Count = str2Array.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: str2Count + 1), count: str1Count + 1)
        
        for i in 0...str1Count {
            matrix[i][0] = i
        }
        
        for j in 0...str2Count {
            matrix[0][j] = j
        }
        
        for i in 1...str1Count {
            for j in 1...str2Count {
                if str1Array[i-1] == str2Array[j-1] {
                    matrix[i][j] = matrix[i-1][j-1]
                } else {
                    matrix[i][j] = min(
                        matrix[i-1][j] + 1,    // 删除
                        matrix[i][j-1] + 1,    // 插入
                        matrix[i-1][j-1] + 1   // 替换
                    )
                }
            }
        }
        
        return matrix[str1Count][str2Count]
    }
}

// MARK: - 调试扩展

@available(iOS 13.0, macOS 10.15, *)
extension RouterCore {
    /// 启用调试模式
    public func enableDebugMode() {
        Task {
            await RouterDebugger.shared.enable()
        }
    }
    
    /// 禁用调试模式
    public func disableDebugMode() {
        Task {
            await RouterDebugger.shared.disable()
        }
    }
    
    /// 获取调试报告
    public func getDebugReport() async -> String {
        return await RouterDebugger.shared.generateReport()
    }
    
    /// 诊断路由
    public func diagnoseRoute(_ url: String) async -> RouterDebugger.RouteDiagnosis {
        return await RouterDebugger.shared.diagnoseRoute(url)
    }
}