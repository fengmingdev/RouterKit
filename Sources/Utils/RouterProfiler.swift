//
//  RouterProfiler.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/2.
//

import Foundation

/// 路由性能分析器
@available(iOS 13.0, macOS 10.15, *)
public actor RouterProfiler {
    public static let shared = RouterProfiler()
    private init() {}

    private var isEnabled = false
    private var measurements: [String: PerformanceMeasurement] = [:]
    private var ongoingMeasurements: [String: Date] = [:]
    private var performanceHistory: [PerformanceSnapshot] = []
    private let maxHistorySize = 1000

    /// 性能测量数据
    public struct PerformanceMeasurement {
        public let name: String
        public let totalTime: TimeInterval
        public let averageTime: TimeInterval
        public let minTime: TimeInterval
        public let maxTime: TimeInterval
        public let callCount: Int
        public let lastCallTime: Date

        public var description: String {
            return """
            \(name):
              总时间: \(String(format: "%.3f", totalTime * 1000))ms
              平均时间: \(String(format: "%.3f", averageTime * 1000))ms
              最小时间: \(String(format: "%.3f", minTime * 1000))ms
              最大时间: \(String(format: "%.3f", maxTime * 1000))ms
              调用次数: \(callCount)
              最后调用: \(lastCallTime)
            """
        }
    }

    /// 性能快照
    public struct PerformanceSnapshot {
        public let timestamp: Date
        public let measurements: [String: PerformanceMeasurement]
        public let systemMetrics: SystemMetrics

        public struct SystemMetrics {
            public let memoryUsage: Double // MB
            public let cpuUsage: Double // %
            public let activeThreads: Int
        }
    }

    // MARK: - 性能分析控制

    /// 启用性能分析
    public func enable() {
        isEnabled = true
        startPerformanceMonitoring()

        Task {
            await RouterLogger.shared.log("RouterProfiler已启用", level: .info)
        }
    }

    /// 禁用性能分析
    public func disable() {
        isEnabled = false
        measurements.removeAll()
        ongoingMeasurements.removeAll()
        performanceHistory.removeAll()

        Task {
            await RouterLogger.shared.log("RouterProfiler已禁用", level: .info)
        }
    }

    /// 检查是否启用性能分析
    public func isProfilingEnabled() -> Bool {
        return isEnabled
    }

    // MARK: - 性能测量

    /// 开始测量
    public func startMeasurement(_ name: String) {
        guard isEnabled else { return }
        ongoingMeasurements[name] = Date()
    }

    /// 结束测量
    public func endMeasurement(_ name: String) {
        guard isEnabled,
              let startTime = ongoingMeasurements.removeValue(forKey: name) else {
            return
        }

        let duration = Date().timeIntervalSince(startTime)
        recordMeasurement(name: name, duration: duration)
    }

    /// 测量代码块执行时间
    public func measure<T>(_ name: String, block: () throws -> T) rethrows -> T {
        startMeasurement(name)
        defer { endMeasurement(name) }
        return try block()
    }

    /// 测量异步代码块执行时间
    public func measureAsync<T>(_ name: String, block: () async throws -> T) async rethrows -> T {
        startMeasurement(name)
        defer { endMeasurement(name) }
        return try await block()
    }

    /// 记录测量结果
    private func recordMeasurement(name: String, duration: TimeInterval) {
        let now = Date()

        if let existing = measurements[name] {
            let newCallCount = existing.callCount + 1
            let newTotalTime = existing.totalTime + duration
            let newAverageTime = newTotalTime / Double(newCallCount)
            let newMinTime = min(existing.minTime, duration)
            let newMaxTime = max(existing.maxTime, duration)

            measurements[name] = PerformanceMeasurement(
                name: name,
                totalTime: newTotalTime,
                averageTime: newAverageTime,
                minTime: newMinTime,
                maxTime: newMaxTime,
                callCount: newCallCount,
                lastCallTime: now
            )
        } else {
            measurements[name] = PerformanceMeasurement(
                name: name,
                totalTime: duration,
                averageTime: duration,
                minTime: duration,
                maxTime: duration,
                callCount: 1,
                lastCallTime: now
            )
        }

        // 记录到调试器
        Task {
            let event = RouterDebugger.DebugEvent(
                type: .performance,
                message: "\(name): \(String(format: "%.3f", duration * 1000))ms",
                metadata: ["operation": name, "duration": duration]
            )
            await RouterDebugger.shared.logEvent(event)
        }
    }

    // MARK: - 性能监控

    private func startPerformanceMonitoring() {
        Task {
            while isEnabled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5秒
                capturePerformanceSnapshot()
            }
        }
    }

    private func capturePerformanceSnapshot() {
        let systemMetrics = PerformanceSnapshot.SystemMetrics(
            memoryUsage: getMemoryUsage(),
            cpuUsage: getCPUUsage(),
            activeThreads: getActiveThreadCount()
        )

        let snapshot = PerformanceSnapshot(
            timestamp: Date(),
            measurements: measurements,
            systemMetrics: systemMetrics
        )

        performanceHistory.append(snapshot)

        // 限制历史记录大小
        if performanceHistory.count > maxHistorySize {
            performanceHistory.removeFirst(performanceHistory.count - maxHistorySize)
        }
    }

    // MARK: - 性能报告

    /// 获取所有性能测量结果
    public func getAllMeasurements() -> [PerformanceMeasurement] {
        return Array(measurements.values).sorted { $0.averageTime > $1.averageTime }
    }

    /// 获取特定操作的性能测量结果
    public func getMeasurement(_ name: String) -> PerformanceMeasurement? {
        return measurements[name]
    }

    /// 获取性能统计摘要
    public func getPerformanceSummary() -> PerformanceSummary {
        let allMeasurements = Array(measurements.values)

        let totalOperations = allMeasurements.reduce(0) { $0 + $1.callCount }
        let totalTime = allMeasurements.reduce(0) { $0 + $1.totalTime }
        let averageTime = totalTime / Double(max(totalOperations, 1))

        let slowestOperation = allMeasurements.max { $0.averageTime < $1.averageTime }
        let fastestOperation = allMeasurements.min { $0.averageTime < $1.averageTime }
        let mostCalledOperation = allMeasurements.max { $0.callCount < $1.callCount }

        return PerformanceSummary(
            totalOperations: totalOperations,
            totalTime: totalTime,
            averageTime: averageTime,
            slowestOperation: slowestOperation,
            fastestOperation: fastestOperation,
            mostCalledOperation: mostCalledOperation,
            measurementCount: allMeasurements.count
        )
    }

    /// 性能摘要
    public struct PerformanceSummary {
        public let totalOperations: Int
        public let totalTime: TimeInterval
        public let averageTime: TimeInterval
        public let slowestOperation: PerformanceMeasurement?
        public let fastestOperation: PerformanceMeasurement?
        public let mostCalledOperation: PerformanceMeasurement?
        public let measurementCount: Int

        public var description: String {
            var result = "性能摘要:\n"
            result += "  总操作数: \(totalOperations)\n"
            result += "  总时间: \(String(format: "%.3f", totalTime * 1000))ms\n"
            result += "  平均时间: \(String(format: "%.3f", averageTime * 1000))ms\n"
            result += "  测量项目数: \(measurementCount)\n\n"

            if let slowest = slowestOperation {
                result += "最慢操作: \(slowest.name) (\(String(format: "%.3f", slowest.averageTime * 1000))ms)\n"
            }

            if let fastest = fastestOperation {
                result += "最快操作: \(fastest.name) (\(String(format: "%.3f", fastest.averageTime * 1000))ms)\n"
            }

            if let mostCalled = mostCalledOperation {
                result += "最频繁操作: \(mostCalled.name) (\(mostCalled.callCount)次)\n"
            }

            return result
        }
    }

    /// 生成性能报告
    public func generatePerformanceReport() -> String {
        guard isEnabled else { return "性能分析未启用" }

        var report = "# RouterKit 性能报告\n\n"
        report += "生成时间: \(Date())\n\n"

        // 性能摘要
        let summary = getPerformanceSummary()
        report += "## 性能摘要\n\n"
        report += summary.description + "\n\n"

        // 详细测量结果
        report += "## 详细测量结果\n\n"
        let sortedMeasurements = getAllMeasurements()
        for measurement in sortedMeasurements {
            report += "### \(measurement.name)\n\n"
            report += measurement.description + "\n\n"
        }

        // 性能趋势
        if !performanceHistory.isEmpty {
            report += "## 性能趋势\n\n"
            report += "历史快照数量: \(performanceHistory.count)\n"

            if let latest = performanceHistory.last {
                report += "最新系统指标:\n"
                report += "  内存使用: \(String(format: "%.2f", latest.systemMetrics.memoryUsage)) MB\n"
                report += "  CPU使用: \(String(format: "%.2f", latest.systemMetrics.cpuUsage))%\n"
                report += "  活跃线程: \(latest.systemMetrics.activeThreads)\n\n"
            }
        }

        return report
    }

    /// 重置性能数据
    public func reset() {
        measurements.removeAll()
        ongoingMeasurements.removeAll()
        performanceHistory.removeAll()

        Task {
            await RouterLogger.shared.log("性能数据已重置", level: .info)
        }
    }

    /// 导出性能数据
    public func exportPerformanceData() -> [String: Any] {
        return [
            "timestamp": Date(),
            "isEnabled": isEnabled,
            "measurements": measurements.mapValues { measurement in
                [
                    "name": measurement.name,
                    "totalTime": measurement.totalTime,
                    "averageTime": measurement.averageTime,
                    "minTime": measurement.minTime,
                    "maxTime": measurement.maxTime,
                    "callCount": measurement.callCount,
                    "lastCallTime": measurement.lastCallTime
                ]
            },
            "summary": [
                "totalOperations": getPerformanceSummary().totalOperations,
                "totalTime": getPerformanceSummary().totalTime,
                "averageTime": getPerformanceSummary().averageTime,
                "measurementCount": getPerformanceSummary().measurementCount
            ],
            "historyCount": performanceHistory.count
        ]
    }

    // MARK: - 系统指标

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
            return Double(info.resident_size) / 1024.0 / 1024.0
        } else {
            return 0.0
        }
    }

    private func getCPUUsage() -> Double {
        var info = task_thread_times_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_thread_times_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(TASK_THREAD_TIMES_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            let totalTime = Double(info.user_time.seconds + info.system_time.seconds) +
                           Double(info.user_time.microseconds + info.system_time.microseconds) / 1_000_000.0
            return totalTime * 100.0 // 简化的CPU使用率计算
        } else {
            return 0.0
        }
    }

    private func getActiveThreadCount() -> Int {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t(0)

        let kerr = task_threads(mach_task_self_, &threadList, &threadCount)

        if kerr == KERN_SUCCESS {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadList), vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.size))
            return Int(threadCount)
        } else {
            return 0
        }
    }
}

// MARK: - 性能分析扩展

@available(iOS 13.0, macOS 10.15, *)
extension Router {
    /// 启用性能分析
    public func enableProfiling() {
        Task {
            await RouterProfiler.shared.enable()
        }
    }

    /// 禁用性能分析
    public func disableProfiling() {
        Task {
            await RouterProfiler.shared.disable()
        }
    }

    /// 获取性能报告
    public func getPerformanceReport() async -> String {
        return await RouterProfiler.shared.generatePerformanceReport()
    }

    /// 重置性能数据
    public func resetPerformanceData() {
        Task {
            await RouterProfiler.shared.reset()
        }
    }
}
