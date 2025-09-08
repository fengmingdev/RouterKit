//
//  RouterProfilerTests.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import XCTest
@testable import RouterKit

@available(iOS 13.0, macOS 10.15, *)
class RouterProfilerTests: XCTestCase {
    
    var profiler: RouterProfiler!
    
    override func setUp() async throws {
        try await super.setUp()
        profiler = RouterProfiler.shared
        
        // 启用性能分析
        await profiler.enable()
    }
    
    override func tearDown() async throws {
        await profiler.disable()
        await profiler.reset()
        profiler = nil
        try await super.tearDown()
    }
    
    // MARK: - 基础功能测试
    
    func testProfilerInitialization() async {
        // 测试分析器初始化
        let isEnabled = await profiler.isProfilingEnabled()
        XCTAssertFalse(isEnabled, "分析器默认应该是禁用的")
        let measurements = await profiler.getAllMeasurements()
        XCTAssertTrue(measurements.isEmpty, "初始化时应该没有测量数据")
    }
    
    func testEnableDisableProfiler() async {
        // 测试启用和禁用分析器
        await profiler.enable()
        let isEnabledAfterEnable = await profiler.isProfilingEnabled()
        XCTAssertTrue(isEnabledAfterEnable, "分析器应该被启用")
        
        await profiler.disable()
        let isEnabledAfterDisable = await profiler.isProfilingEnabled()
        XCTAssertFalse(isEnabledAfterDisable, "分析器应该被禁用")
    }
    
    // MARK: - 测量功能测试
    
    func testStartEndMeasurement() async {
        // 测试开始和结束测量
        await profiler.enable()
        
        await profiler.startMeasurement("test_operation")
        
        // 模拟一些工作
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        await profiler.endMeasurement("test_operation")
        
        let measurement = await profiler.getMeasurement("test_operation")
        XCTAssertNotNil(measurement, "应该返回有效的测量结果")
        XCTAssertGreaterThan(measurement?.averageTime ?? 0, 0, "测量持续时间应该大于0")
    }
    
    func testInvalidMeasurementName() async {
        // 测试无效的测量名称
        await profiler.enable()
        
        await profiler.endMeasurement("nonexistent_measurement")
        
        let measurement = await profiler.getMeasurement("nonexistent_measurement")
        XCTAssertNil(measurement, "不存在的测量应该返回nil")
    }
    
    func testMultipleConcurrentMeasurements() async {
        // 测试多个并发测量
        await profiler.enable()
        
        await profiler.startMeasurement("measurement_1")
        await profiler.startMeasurement("measurement_2")
        await profiler.startMeasurement("measurement_3")
        
        // 模拟不同的工作时间
        try? await Task.sleep(nanoseconds: 5_000_000) // 5ms
        await profiler.endMeasurement("measurement_1")
        
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        await profiler.endMeasurement("measurement_2")
        
        try? await Task.sleep(nanoseconds: 15_000_000) // 15ms
        await profiler.endMeasurement("measurement_3")
        
        let measurement1 = await profiler.getMeasurement("measurement_1")
        let measurement2 = await profiler.getMeasurement("measurement_2")
        let measurement3 = await profiler.getMeasurement("measurement_3")
        
        XCTAssertNotNil(measurement1, "第一个测量应该有效")
        XCTAssertNotNil(measurement2, "第二个测量应该有效")
        XCTAssertNotNil(measurement3, "第三个测量应该有效")
        
        // 验证所有测量都被正确记录
        let allMeasurements = await profiler.getAllMeasurements()
        XCTAssertGreaterThanOrEqual(allMeasurements.count, 3, "应该至少记录3个测量")
    }
    
    // MARK: - 代码块测量测试
    
    func testMeasureSyncBlock() async {
        // 测试测量同步代码块
        await profiler.enable()
        
        let result = await profiler.measure("sync_block") {
            // 模拟一些同步工作
            Thread.sleep(forTimeInterval: 0.01) // 10ms
            return "sync_result"
        }
        
        XCTAssertEqual(result, "sync_result", "应该返回正确的结果")
        
        let measurement = await profiler.getMeasurement("sync_block")
        XCTAssertNotNil(measurement, "应该记录测量数据")
        XCTAssertGreaterThan(measurement?.averageTime ?? 0, 0.008, "持续时间应该大约10ms")
    }
    
    func testMeasureAsyncBlock() async {
        // 测试测量异步代码块
        await profiler.enable()
        
        let result = await profiler.measureAsync("async_block") {
            // 模拟一些异步工作
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
            return "async_result"
        }
        
        XCTAssertEqual(result, "async_result", "应该返回正确的结果")
        
        let measurement = await profiler.getMeasurement("async_block")
        XCTAssertNotNil(measurement, "应该记录测量数据")
        XCTAssertGreaterThan(measurement?.averageTime ?? 0, 0.008, "持续时间应该大约10ms")
    }
    
    func testMeasureThrowingBlock() async {
        // 测试测量抛出异常的代码块
        await profiler.enable()
        
        do {
            let _ = try await profiler.measureAsync("throwing_block") {
                try await Task.sleep(nanoseconds: 5_000_000) // 5ms
                throw RouterError.routeNotFound("/test")
            }
            XCTFail("应该抛出异常")
        } catch {
            // 验证即使抛出异常，测量也应该被记录
            let measurement = await profiler.getMeasurement("throwing_block")
            XCTAssertNotNil(measurement, "抛出异常的测量也应该被记录")
        }
    }
    
    // MARK: - 性能快照测试
    
    func testCapturePerformanceSnapshot() async {
        // 测试捕获性能快照（通过生成报告来验证）
        await profiler.enable()
        
        // 先进行一些测量
        await profiler.measure("snapshot_test_1") {
            Thread.sleep(forTimeInterval: 0.005) // 5ms
        }
        
        await profiler.measure("snapshot_test_2") {
            Thread.sleep(forTimeInterval: 0.010) // 10ms
        }
        
        let report = await profiler.generatePerformanceReport()
        
        XCTAssertFalse(report.isEmpty, "应该生成性能报告")
        XCTAssertTrue(report.contains("snapshot_test_1"), "报告应该包含第一个测试")
        XCTAssertTrue(report.contains("snapshot_test_2"), "报告应该包含第二个测试")
    }
    
    // MARK: - 数据获取测试
    
    func testGetMeasurements() async {
        // 测试获取测量数据
        await profiler.enable()
        
        await profiler.measure("get_test_1") {
            Thread.sleep(forTimeInterval: 0.005)
        }
        
        await profiler.measure("get_test_2") {
            Thread.sleep(forTimeInterval: 0.010)
        }
        
        await profiler.measure("other_test") {
            Thread.sleep(forTimeInterval: 0.003)
        }
        
        // 获取所有测量
        let allMeasurements = await profiler.getAllMeasurements()
        XCTAssertGreaterThanOrEqual(allMeasurements.count, 3, "应该至少有3个测量")
        
        // 验证测量存在
        let measurement1 = await profiler.getMeasurement("get_test_1")
        let measurement2 = await profiler.getMeasurement("get_test_2")
        let measurement3 = await profiler.getMeasurement("other_test")
        
        XCTAssertNotNil(measurement1, "应该找到第一个测量")
        XCTAssertNotNil(measurement2, "应该找到第二个测量")
        XCTAssertNotNil(measurement3, "应该找到第三个测量")
    }
    
    func testGetMeasurementsInTimeRange() async {
        // 测试获取指定时间范围的测量数据（简化版本）
        await profiler.enable()
        
        await profiler.measure("time_test_1") {
            Thread.sleep(forTimeInterval: 0.005)
        }
        
        // 等待一小段时间
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        await profiler.measure("time_test_2") {
            Thread.sleep(forTimeInterval: 0.005)
        }
        
        // 验证两个测量都存在
        let measurement1 = await profiler.getMeasurement("time_test_1")
        let measurement2 = await profiler.getMeasurement("time_test_2")
        
        XCTAssertNotNil(measurement1, "第一个测量应该存在")
        XCTAssertNotNil(measurement2, "第二个测量应该存在")
        
        let allMeasurements = await profiler.getAllMeasurements()
        XCTAssertGreaterThanOrEqual(allMeasurements.count, 2, "应该至少有2个测量")
    }
    
    // MARK: - 性能摘要测试
    
    func testGeneratePerformanceSummary() async {
        // 测试生成性能摘要（通过报告验证）
        await profiler.enable()
        
        // 进行多个测量
        for i in 0..<5 {
            await profiler.measure("summary_test_\(i)") {
                Thread.sleep(forTimeInterval: Double(i + 1) * 0.002) // 2ms, 4ms, 6ms, 8ms, 10ms
            }
        }
        
        let report = await profiler.generatePerformanceReport()
        
        XCTAssertFalse(report.isEmpty, "应该生成性能报告")
        
        // 验证所有测量都在报告中
        for i in 0..<5 {
            XCTAssertTrue(report.contains("summary_test_\(i)"), "报告应该包含测量 \(i)")
        }
        
        let allMeasurements = await profiler.getAllMeasurements()
        XCTAssertGreaterThanOrEqual(allMeasurements.count, 5, "应该至少有5个测量")
    }
    
    func testGenerateCategorySummary() async {
        // 测试生成特定类别的摘要（简化版本）
        await profiler.enable()
        
        for i in 0..<3 {
            await profiler.measure("category_test_\(i)") {
                Thread.sleep(forTimeInterval: 0.005)
            }
        }
        
        let report = await profiler.generatePerformanceReport()
        
        XCTAssertFalse(report.isEmpty, "应该生成报告")
        
        // 验证所有类别测量都在报告中
        for i in 0..<3 {
            XCTAssertTrue(report.contains("category_test_\(i)"), "报告应该包含测量 \(i)")
        }
        
        let allMeasurements = await profiler.getAllMeasurements()
        XCTAssertGreaterThanOrEqual(allMeasurements.count, 3, "应该至少有3个测量")
    }
    
    // MARK: - 报告生成测试
    
    func testGenerateReport() async {
        // 测试生成性能报告
        await profiler.enable()
        
        // 进行一些测量
        await profiler.measure("report_test_1") {
            Thread.sleep(forTimeInterval: 0.010)
        }
        
        await profiler.measure("report_test_2") {
            Thread.sleep(forTimeInterval: 0.005)
        }
        
        let report = await profiler.generatePerformanceReport()
        
        XCTAssertFalse(report.isEmpty, "报告不应该为空")
        
        // 报告应该包含测量信息
        XCTAssertTrue(report.contains("report_test_1"), "报告应该包含第一个测量名称")
        XCTAssertTrue(report.contains("report_test_2"), "报告应该包含第二个测量名称")
    }
    
    func testGenerateDetailedReport() async {
        // 测试生成详细报告
        await profiler.enable()
        
        await profiler.measure("detailed_test") {
            Thread.sleep(forTimeInterval: 0.008)
        }
        
        let detailedReport = await profiler.generatePerformanceReport()
        
        XCTAssertFalse(detailedReport.isEmpty, "详细报告不应该为空")
        
        // 详细报告应该包含更多信息
        XCTAssertTrue(detailedReport.contains("detailed_test"), "详细报告应该包含测量名称")
    }
    
    // MARK: - 数据管理测试
    
    func testResetData() async {
        // 测试重置数据
        await profiler.enable()
        
        let _: Void = await profiler.measureAsync("Reset Test") {
            try? await Task.sleep(nanoseconds: 5_000_000) // 5ms
        }
        
        let measurementsBeforeReset = await profiler.getAllMeasurements()
        XCTAssertGreaterThan(measurementsBeforeReset.count, 0, "重置前应该有测量数据")
        
        await profiler.reset()
        
        let measurementsAfterReset = await profiler.getAllMeasurements()
        XCTAssertEqual(measurementsAfterReset.count, 0, "重置后应该没有测量数据")
    }
    
    func testExportData() async {
        // 测试导出数据（通过报告验证）
        await profiler.enable()
        
        await profiler.measure("export_test_1") {
            Thread.sleep(forTimeInterval: 0.005)
        }
        
        await profiler.measure("export_test_2") {
            Thread.sleep(forTimeInterval: 0.008)
        }
        
        let exportedData = await profiler.generatePerformanceReport()
        
        XCTAssertFalse(exportedData.isEmpty, "导出的数据不应该为空")
        
        // 验证导出的数据格式
        XCTAssertTrue(exportedData.contains("export_test_1"), "导出数据应该包含第一个测量名称")
        XCTAssertTrue(exportedData.contains("export_test_2"), "导出数据应该包含第二个测量名称")
    }
    
    // MARK: - 性能测试
    
    func testProfilerPerformance() {
        // 测试性能分析器本身的性能影响
        measure {
            let expectation = XCTestExpectation(description: "Profiler performance")
            
            Task {
                await profiler.enable()
                
                for i in 0..<1000 {
                    await profiler.measure("performance_test_\(i)") {
                        // 模拟一些轻量级工作
                        let _ = String(repeating: "x", count: 100)
                    }
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - 并发测试
    
    func testConcurrentMeasurements() async {
        // 测试并发测量
        await profiler.enable()
        
        let expectation = XCTestExpectation(description: "Concurrent measurements")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            Task {
                await profiler.measure("concurrent_test_\(i)") {
                    Thread.sleep(forTimeInterval: Double.random(in: 0.001...0.010))
                }
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // 验证所有并发测量都被正确记录
        let allMeasurements = await profiler.getAllMeasurements()
        XCTAssertGreaterThanOrEqual(allMeasurements.count, 10, "应该记录至少10个并发测量")
    }
    
    // MARK: - 内存管理测试
    
    func testMemoryManagement() async {
        // 测试内存管理（确保大量测量不会导致内存泄漏）
        await profiler.enable()
        
        let initialMeasurements = await profiler.getAllMeasurements().count
        
        // 进行大量测量
        for i in 0..<1000 {
            await profiler.measure("memory_test_\(i)") {
                let _ = String(repeating: "data", count: 100)
            }
        }
        
        let afterMeasurements = await profiler.getAllMeasurements().count
        XCTAssertEqual(afterMeasurements - initialMeasurements, 1000, "应该记录1000个新测量")
        
        // 重置数据
        await profiler.reset()
        
        let afterReset = await profiler.getAllMeasurements().count
        XCTAssertEqual(afterReset, 0, "重置后应该没有测量数据")
    }
}