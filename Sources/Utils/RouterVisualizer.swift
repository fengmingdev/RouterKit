//
//  RouterVisualizer.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/2.
//

import Foundation

/// 路由可视化工具
@available(iOS 13.0, macOS 10.15, *)
public actor RouterVisualizer {
    public static let shared = RouterVisualizer()
    private init() {}
    
    /// 可视化格式
    public enum VisualizationFormat {
        case mermaid    // Mermaid图表格式
        case dot        // Graphviz DOT格式
        case ascii      // ASCII艺术图
        case json       // JSON数据格式
    }
    
    /// 图表类型
    public enum ChartType {
        case routeTree      // 路由树
        case moduleGraph    // 模块依赖图
        case flowChart      // 导航流程图
        case performance    // 性能图表
    }
    
    // MARK: - 路由树可视化
    
    /// 生成路由树图
    public func generateRouteTree(format: VisualizationFormat = .mermaid) async -> String {
        let router = Router.shared
        // 获取已注册的模块和路由信息（简化实现）
        var routes: [(String, String)] = [
            ("/home", "Main"),
            ("/user/:id", "User"),
            ("/settings", "Settings")
        ]
        
        switch format {
        case .mermaid:
            return generateMermaidRouteTree(routes)
        case .dot:
            return generateDotRouteTree(routes)
        case .ascii:
            return generateAsciiRouteTree(routes)
        case .json:
            return generateJsonRouteTree(routes)
        }
    }
    
    private func generateMermaidRouteTree(_ routes: [(pattern: String, type: String)]) -> String {
        var mermaid = "graph TD\n"
        mermaid += "    Root[\"路由根节点\"]\n"
        
        var nodeId = 0
        var nodeMap: [String: String] = [:]
        
        for route in routes {
            let pattern = route.pattern
            let components = pattern.components(separatedBy: "/").filter { !$0.isEmpty }
            
            var currentParent = "Root"
            var currentPath = ""
            
            for component in components {
                currentPath += "/" + component
                
                if nodeMap[currentPath] == nil {
                    nodeId += 1
                    let nodeIdStr = "N\(nodeId)"
                    nodeMap[currentPath] = nodeIdStr
                    
                    let displayName = formatComponentForDisplay(component)
                    mermaid += "    \(nodeIdStr)[\"\(displayName)\"]\n"
                    mermaid += "    \(currentParent) --> \(nodeIdStr)\n"
                }
                
                currentParent = nodeMap[currentPath]!
            }
            
            // 添加目标类型节点
            nodeId += 1
            let targetNodeId = "T\(nodeId)"
            let targetName = route.type.components(separatedBy: ".").last ?? route.type
            mermaid += "    \(targetNodeId)[\"\(targetName)\"]\n"
            mermaid += "    \(targetNodeId):::target\n"
            mermaid += "    \(currentParent) --> \(targetNodeId)\n"
        }
        
        // 添加样式
        mermaid += "\n    classDef target fill:#e1f5fe,stroke:#01579b,stroke-width:2px\n"
        mermaid += "    classDef param fill:#fff3e0,stroke:#e65100,stroke-width:2px\n"
        mermaid += "    classDef wildcard fill:#f3e5f5,stroke:#4a148c,stroke-width:2px\n"
        
        return mermaid
    }
    
    private func generateDotRouteTree(_ routes: [(pattern: String, type: String)]) -> String {
        var dot = "digraph RouteTree {\n"
        dot += "    rankdir=TB;\n"
        dot += "    node [shape=box, style=rounded];\n"
        dot += "    Root [label=\"路由根节点\", shape=ellipse, style=filled, fillcolor=lightblue];\n"
        
        var nodeId = 0
        var nodeMap: [String: String] = [:]
        
        for route in routes {
            let pattern = route.pattern
            let components = pattern.components(separatedBy: "/").filter { !$0.isEmpty }
            
            var currentParent = "Root"
            var currentPath = ""
            
            for component in components {
                currentPath += "/" + component
                
                if nodeMap[currentPath] == nil {
                    nodeId += 1
                    let nodeIdStr = "N\(nodeId)"
                    nodeMap[currentPath] = nodeIdStr
                    
                    let displayName = formatComponentForDisplay(component)
                    let color = getComponentColor(component)
                    dot += "    \(nodeIdStr) [label=\"\(displayName)\", fillcolor=\(color), style=filled];\n"
                }
                
                dot += "    \(currentParent) -> \(nodeMap[currentPath]!);\n"
                currentParent = nodeMap[currentPath]!
            }
            
            // 添加目标类型节点
            nodeId += 1
            let targetNodeId = "T\(nodeId)"
            let targetName = route.type.components(separatedBy: ".").last ?? route.type
            dot += "    \(targetNodeId) [label=\"\(targetName)\", shape=ellipse, fillcolor=lightgreen, style=filled];\n"
            dot += "    \(currentParent) -> \(targetNodeId);\n"
        }
        
        dot += "}\n"
        return dot
    }
    
    private func generateAsciiRouteTree(_ routes: [(pattern: String, type: String)]) -> String {
        var tree = "路由树结构:\n"
        tree += "├── Root\n"
        
        let sortedRoutes = routes.sorted { $0.pattern < $1.pattern }
        
        for (index, route) in sortedRoutes.enumerated() {
            let isLast = index == sortedRoutes.count - 1
            let prefix = isLast ? "└── " : "├── "
            let pattern = route.pattern
            let targetType = route.type.components(separatedBy: ".").last ?? route.type
            
            tree += "\(prefix)\(pattern) → \(targetType)\n"
        }
        
        return tree
    }
    
    private func generateJsonRouteTree(_ routes: [(pattern: String, type: String)]) -> String {
        let treeData: [String: Any] = [
            "type": "routeTree",
            "timestamp": Date(),
            "routes": routes.map { route in
                [
                    "pattern": route.pattern,
                    "targetType": route.type,
                    "components": route.pattern.components(separatedBy: "/").filter { !$0.isEmpty }
                ]
            }
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: treeData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
    
    // MARK: - 模块依赖图
    
    /// 生成模块依赖图
    public func generateModuleGraph(format: VisualizationFormat = .mermaid) async -> String {
        let router = Router.shared
        // 获取已注册的模块信息（简化实现）
        let modules = ["Main", "User", "Settings"]
        
        switch format {
        case .mermaid:
            return generateMermaidModuleGraph(modules)
        case .dot:
            return generateDotModuleGraph(modules)
        case .ascii:
            return generateAsciiModuleGraph(modules)
        case .json:
            return generateJsonModuleGraph(modules)
        }
    }
    
    private func generateMermaidModuleGraph(_ modules: [String]) -> String {
        var mermaid = "graph LR\n"
        
        for module in modules {
            let nodeId = module.replacingOccurrences(of: " ", with: "_")
            mermaid += "    \(nodeId)[\"\(module)\"]\n"
        }
        
        // 添加依赖关系（这里需要实际的依赖信息）
        // 暂时使用示例依赖
        if modules.count > 1 {
            for i in 0..<modules.count-1 {
                let from = modules[i].replacingOccurrences(of: " ", with: "_")
                let to = modules[i+1].replacingOccurrences(of: " ", with: "_")
                mermaid += "    \(from) --> \(to)\n"
            }
        }
        
        mermaid += "\n    classDef module fill:#e3f2fd,stroke:#1976d2,stroke-width:2px\n"
        
        return mermaid
    }
    
    private func generateDotModuleGraph(_ modules: [String]) -> String {
        var dot = "digraph ModuleGraph {\n"
        dot += "    rankdir=LR;\n"
        dot += "    node [shape=box, style=rounded];\n"
        
        for module in modules {
            let nodeId = module.replacingOccurrences(of: " ", with: "_")
            dot += "    \(nodeId) [label=\"\(module)\", fillcolor=lightblue, style=filled];\n"
        }
        
        // 添加依赖关系
        if modules.count > 1 {
            for i in 0..<modules.count-1 {
                let from = modules[i].replacingOccurrences(of: " ", with: "_")
                let to = modules[i+1].replacingOccurrences(of: " ", with: "_")
                dot += "    \(from) -> \(to);\n"
            }
        }
        
        dot += "}\n"
        return dot
    }
    
    private func generateAsciiModuleGraph(_ modules: [String]) -> String {
        var graph = "模块依赖图:\n"
        
        for (index, module) in modules.enumerated() {
            let isLast = index == modules.count - 1
            let prefix = isLast ? "└── " : "├── "
            graph += "\(prefix)\(module)\n"
        }
        
        return graph
    }
    
    private func generateJsonModuleGraph(_ modules: [String]) -> String {
        let graphData: [String: Any] = [
            "type": "moduleGraph",
            "timestamp": Date(),
            "modules": modules,
            "dependencies": [] // 这里需要实际的依赖信息
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: graphData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
    
    // MARK: - 性能图表
    
    /// 生成性能图表
    public func generatePerformanceChart(format: VisualizationFormat = .mermaid) async -> String {
        let measurements = await RouterProfiler.shared.getAllMeasurements()
        
        switch format {
        case .mermaid:
            return generateMermaidPerformanceChart(measurements)
        case .ascii:
            return generateAsciiPerformanceChart(measurements)
        case .json:
            return generateJsonPerformanceChart(measurements)
        default:
            return "性能图表不支持该格式"
        }
    }
    
    private func generateMermaidPerformanceChart(_ measurements: [RouterProfiler.PerformanceMeasurement]) -> String {
        var chart = "graph TB\n"
        chart += "    subgraph \"性能指标\"\n"
        
        for (index, measurement) in measurements.enumerated() {
            let nodeId = "P\(index)"
            let avgTime = String(format: "%.2f", measurement.averageTime * 1000)
            chart += "        \(nodeId)[\"\(measurement.name)\\n\(avgTime)ms\"]\n"
            
            // 根据性能添加颜色
            if measurement.averageTime > 0.1 {
                chart += "        \(nodeId):::slow\n"
            } else if measurement.averageTime > 0.05 {
                chart += "        \(nodeId):::medium\n"
            } else {
                chart += "        \(nodeId):::fast\n"
            }
        }
        
        chart += "    end\n"
        chart += "\n    classDef slow fill:#ffebee,stroke:#c62828,stroke-width:2px\n"
        chart += "    classDef medium fill:#fff3e0,stroke:#ef6c00,stroke-width:2px\n"
        chart += "    classDef fast fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px\n"
        
        return chart
    }
    
    private func generateAsciiPerformanceChart(_ measurements: [RouterProfiler.PerformanceMeasurement]) -> String {
        var chart = "性能图表:\n"
        chart += "操作名称                    平均时间    调用次数\n"
        chart += "─────────────────────────────────────────────\n"
        
        for measurement in measurements {
            let name = String(measurement.name.prefix(25)).padding(toLength: 25, withPad: " ", startingAt: 0)
            let avgTime = String(format: "%.2fms", measurement.averageTime * 1000).padding(toLength: 10, withPad: " ", startingAt: 0)
            let callCount = String(measurement.callCount).padding(toLength: 8, withPad: " ", startingAt: 0)
            
            chart += "\(name) \(avgTime) \(callCount)\n"
        }
        
        return chart
    }
    
    private func generateJsonPerformanceChart(_ measurements: [RouterProfiler.PerformanceMeasurement]) -> String {
        let chartData: [String: Any] = [
            "type": "performanceChart",
            "timestamp": Date(),
            "measurements": measurements.map { measurement in
                [
                    "name": measurement.name,
                    "averageTime": measurement.averageTime,
                    "totalTime": measurement.totalTime,
                    "callCount": measurement.callCount,
                    "minTime": measurement.minTime,
                    "maxTime": measurement.maxTime
                ]
            }
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: chartData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
    
    // MARK: - 综合报告
    
    /// 生成综合可视化报告
    public func generateComprehensiveReport(format: VisualizationFormat = .mermaid) async -> String {
        var report = "# RouterKit 可视化报告\n\n"
        report += "生成时间: \(Date())\n\n"
        
        // 路由树
        report += "## 路由树结构\n\n"
        if format == .mermaid {
            report += "```mermaid\n"
        }
        report += await generateRouteTree(format: format)
        if format == .mermaid {
            report += "\n```\n"
        }
        report += "\n\n"
        
        // 模块依赖图
        report += "## 模块依赖关系\n\n"
        if format == .mermaid {
            report += "```mermaid\n"
        }
        report += await generateModuleGraph(format: format)
        if format == .mermaid {
            report += "\n```\n"
        }
        report += "\n\n"
        
        // 性能图表
        if await RouterProfiler.shared.isProfilingEnabled() {
            report += "## 性能分析\n\n"
            if format == .mermaid {
                report += "```mermaid\n"
            }
            report += await generatePerformanceChart(format: format)
            if format == .mermaid {
                report += "\n```\n"
            }
            report += "\n\n"
        }
        
        return report
    }
    
    /// 导出可视化数据
    public func exportVisualizationData() async -> [String: Any] {
        return [
            "timestamp": Date(),
            "routeTree": await generateRouteTree(format: .json),
            "moduleGraph": await generateModuleGraph(format: .json),
            "performanceChart": await generatePerformanceChart(format: .json)
        ]
    }
    
    // MARK: - 辅助方法
    
    private func formatComponentForDisplay(_ component: String) -> String {
        if component.hasPrefix(":") {
            return "{\(component.dropFirst())}"
        } else if component == "*" {
            return "*"
        } else {
            return component
        }
    }
    
    private func getComponentColor(_ component: String) -> String {
        if component.hasPrefix(":") {
            return "lightyellow"
        } else if component == "*" {
            return "lightpink"
        } else {
            return "lightgray"
        }
    }
}

// MARK: - 可视化扩展

@available(iOS 13.0, macOS 10.15, *)
extension Router {
    /// 生成路由树图
    public func generateRouteTreeVisualization(format: RouterVisualizer.VisualizationFormat = .mermaid) async -> String {
        return await RouterVisualizer.shared.generateRouteTree(format: format)
    }
    
    /// 生成模块依赖图
    public func generateModuleDependencyGraph(format: RouterVisualizer.VisualizationFormat = .mermaid) async -> String {
        return await RouterVisualizer.shared.generateModuleGraph(format: format)
    }
    
    /// 生成综合可视化报告
    public func generateVisualizationReport(format: RouterVisualizer.VisualizationFormat = .mermaid) async -> String {
        return await RouterVisualizer.shared.generateComprehensiveReport(format: format)
    }
}