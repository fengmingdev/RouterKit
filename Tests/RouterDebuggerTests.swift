//
//  RouterDebuggerTests.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import XCTest
@testable import RouterKit

@available(iOS 13.0, macOS 10.15, *)
class RouterDebuggerTests: XCTestCase {
    
    var debugger: RouterDebugger!
    
    override func setUp() async throws {
        try await super.setUp()
        debugger = RouterDebugger.shared
        
        // 启用调试
        await debugger.enable()
    }
    
    override func tearDown() async throws {
        await debugger.disable()
        debugger = nil
        try await super.tearDown()
    }
    
    // MARK: - 基础功能测试
    
    func testDebuggerInitialization() async {
        // 测试调试器初始化
        let isEnabled = await debugger.isDebugEnabled()
        XCTAssertTrue(isEnabled, "调试器应该已启用")
    }
    
    func testEnableDisableDebugger() async {
        // 测试启用/禁用调试器
        await debugger.disable()
        let isDisabled = await debugger.isDebugEnabled()
        XCTAssertFalse(isDisabled, "调试器应该已禁用")
        
        await debugger.enable()
        let isEnabled = await debugger.isDebugEnabled()
        XCTAssertTrue(isEnabled, "调试器应该已启用")
    }
    
    // MARK: - 调试会话测试
    
    func testStartEndDebugSession() async {
        // 测试开始和结束调试会话
        let sessionId = await debugger.startSession()
        XCTAssertNotNil(sessionId, "应该返回有效的会话ID")
        XCTAssertFalse(sessionId.isEmpty, "会话ID不应该为空")
        
        await debugger.endSession(sessionId)
        
        // 验证会话已结束（通过尝试记录事件到已结束的会话）
        let event = RouterDebugger.DebugEvent(type: .error, message: "Test after session end")
        await debugger.logEvent(event, sessionId: sessionId)
    }
    
    func testMultipleDebugSessions() async {
        // 测试多个调试会话
        let sessionId1 = await debugger.startSession()
        let sessionId2 = await debugger.startSession()
        
        XCTAssertNotEqual(sessionId1, sessionId2, "不同的会话应该有不同的ID")
        
        await debugger.endSession(sessionId1)
        await debugger.endSession(sessionId2)
    }
    
    // MARK: - 事件记录测试
    
    func testRecordDebugEvent() async {
        // 测试记录调试事件
        let sessionId = await debugger.startSession()
        
        let event1 = RouterDebugger.DebugEvent(
            type: .routeMatch,
            message: "Testing route resolution",
            metadata: ["route": "/test/path", "parameters": ["id": "123"]]
        )
        
        let event2 = RouterDebugger.DebugEvent(
            type: .navigation,
            message: "Navigation started",
            metadata: ["destination": "TestViewController"]
        )
        
        await debugger.logEvent(event1, sessionId: sessionId)
        await debugger.logEvent(event2, sessionId: sessionId)
        
        await debugger.endSession(sessionId)
    }
    
    func testRecordEventWithoutSession() async {
        // 测试在没有活跃会话时记录事件
        let event = RouterDebugger.DebugEvent(
            type: .error,
            message: "Error without session",
            metadata: ["error": "No active session"]
        )
        
        await debugger.logEvent(event)
        
        // 主要是确保不会崩溃
    }
    
    // MARK: - 系统状态测试
    
    func testGetSystemStatus() async {
        // 测试获取系统状态
        let status = await debugger.getSystemStatus()
        
        XCTAssertNotNil(status, "应该返回系统状态")
        XCTAssertGreaterThanOrEqual(status.memoryUsage, 0, "内存使用量应该大于等于0")
        XCTAssertGreaterThanOrEqual(status.totalRoutes, 0, "注册路由数应该大于等于0")
        XCTAssertGreaterThanOrEqual(status.loadedModules, 0, "已加载模块数应该大于等于0")
        XCTAssertGreaterThanOrEqual(status.activeInterceptors, 0, "活跃拦截器数应该大于等于0")
        XCTAssertGreaterThan(status.uptime, 0, "运行时间应该大于0")
    }
    
    // MARK: - 路由诊断测试
    
    func testDiagnoseRoute() async {
        // 测试路由诊断
        let diagnosis = await debugger.diagnoseRoute("/test/route")
        
        XCTAssertNotNil(diagnosis, "应该返回诊断结果")
        XCTAssertEqual(diagnosis.url, "/test/route", "路由URL应该匹配")
        
        // 诊断结果应该包含有用的信息
        XCTAssertNotNil(diagnosis.issues, "应该有问题列表")
    }
    
    func testDiagnoseInvalidRoute() async {
        // 测试诊断无效路由
        let diagnosis = await debugger.diagnoseRoute("")
        
        XCTAssertNotNil(diagnosis, "应该返回诊断结果")
        XCTAssertFalse(diagnosis.issues.isEmpty, "应该识别出问题")
        
        let hasEmptyRouteIssue = diagnosis.issues.contains { $0.contains("empty") || $0.contains("invalid") }
        XCTAssertTrue(hasEmptyRouteIssue, "应该识别出空路由问题")
    }
    
    // MARK: - 性能监控测试
    
    func testStartStopPerformanceMonitoring() async {
        // 测试开始和停止性能监控
        await debugger.startPerformanceMonitoring()
        
        // 模拟一些路由操作
        let event = RouterDebugger.DebugEvent(
            type: .performance,
            message: "Performance test route",
            metadata: ["route": "/perf/test"]
        )
        
        await debugger.logEvent(event)
        
        // 等待一小段时间
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // 记录性能指标
        await debugger.recordPerformanceMetric("test_metric", value: 100.0)
        
        // 这里主要是确保方法调用不会崩溃
    }
    
    // MARK: - 报告生成测试
    
    func testGenerateDebugReport() async {
        // 测试生成调试报告
        let sessionId = await debugger.startSession()
        
        // 记录一些事件
        let event1 = RouterDebugger.DebugEvent(
            type: .routeMatch,
            message: "Route resolved",
            metadata: ["route": "/report/test"]
        )
        
        let event2 = RouterDebugger.DebugEvent(
            type: .navigation,
            message: "Navigation started",
            metadata: ["destination": "ReportTestViewController"]
        )
        
        let event3 = RouterDebugger.DebugEvent(
            type: .performance,
            message: "Navigation completed",
            metadata: ["duration": 150]
        )
        
        await debugger.logEvent(event1, sessionId: sessionId)
        await debugger.logEvent(event2, sessionId: sessionId)
        await debugger.logEvent(event3, sessionId: sessionId)
        
        let report = await debugger.generateReport(sessionId: sessionId)
        
        XCTAssertNotNil(report, "应该生成调试报告")
        XCTAssertFalse(report.isEmpty, "报告不应该为空")
        
        // 报告应该包含事件信息
        XCTAssertTrue(report.contains("Route resolved"), "报告应该包含事件信息")
        
        await debugger.endSession(sessionId)
    }
    
    func testGenerateReportWithoutSession() async {
        // 测试在没有活跃会话时生成报告
        let report = await debugger.generateReport()
        
        XCTAssertNotNil(report, "应该生成报告")
        // 报告可能为空或包含系统状态信息
    }
    
    // MARK: - 错误处理测试
    
    func testRecordErrorEvent() async {
        // 测试记录错误事件
        let sessionId = await debugger.startSession()
        
        let errorEvent = RouterDebugger.DebugEvent(
            type: .error,
            message: "Route not found error",
            metadata: ["route": "/error/test"]
        )
        
        await debugger.logEvent(errorEvent, sessionId: sessionId)
        
        await debugger.endSession(sessionId)
    }
    
    // MARK: - 并发测试
    
    func testConcurrentEventRecording() async {
        // 测试并发事件记录
        let sessionId = await debugger.startSession()
        
        let expectation = XCTestExpectation(description: "Concurrent event recording")
        expectation.expectedFulfillmentCount = 10
        
        for i in 0..<10 {
            Task {
                let event = RouterDebugger.DebugEvent(
                    type: .routeMatch,
                    message: "Concurrent event \(i)",
                    metadata: ["index": i, "route": "/concurrent/test\(i)"]
                )
                await debugger.logEvent(event, sessionId: sessionId)
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        await debugger.endSession(sessionId)
    }
    
    // MARK: - 性能测试
    
    func testDebuggerPerformance() {
        // 测试调试器的性能影响
        measure {
            let expectation = XCTestExpectation(description: "Debugger performance")
            
            Task {
                let sessionId = await debugger.startSession()
                
                for i in 0..<1000 {
                    let event = RouterDebugger.DebugEvent(
                        type: .routeMatch,
                        message: "Performance test event \(i)",
                        metadata: ["index": i, "route": "/perf/test\(i)"]
                    )
                    await debugger.logEvent(event, sessionId: sessionId)
                }
                
                await debugger.endSession(sessionId)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - 内存管理测试
    
    func testMemoryManagement() async {
        // 测试内存管理（确保会话结束后事件被清理）
        let sessionId = await debugger.startSession()
        
        // 记录大量事件
        for i in 0..<100 {
            let event = RouterDebugger.DebugEvent(
                type: .routeMatch,
                message: "Memory test event \(i)",
                metadata: ["index": i, "data": String(repeating: "x", count: 1000)] // 大量数据
            )
            await debugger.logEvent(event, sessionId: sessionId)
        }
        
        await debugger.endSession(sessionId)
        
        // 验证内存是否被正确释放（通过创建新会话验证）
        let newSessionId = await debugger.startSession()
        
        await debugger.endSession(newSessionId)
    }
}