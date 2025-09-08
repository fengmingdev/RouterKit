//
//  RouterVisualizer.swift
//  RouterKit
//
//  Created by RouterKit on 2025/1/27.
//

import Foundation

/// 可视化格式枚举
public enum VisualizationFormat {
    case mermaid
    case plantuml
    case dot
    case ascii
    case json
}

/// 路由可视化工具类
@available(iOS 13.0, macOS 10.15, *)
public class RouterVisualizer {
    
    /// 生成路由树图
    public func generateRouteTree(format: VisualizationFormat = .mermaid) async -> String {
        // 获取已注册的模块和路由信息（简化实现）
        let routes: [(String, String)] = [
            ("/home", "Main"),
            ("/user/:id", "User"),
            ("/settings", "Settings"),
            ("/profile", "User")
        ]
        
        switch format {
        case .mermaid:
            var mermaid = "graph TD\n"
            for (route, module) in routes {
                mermaid += "    \(module) --> \(route)\n"
            }
            return mermaid
            
        case .plantuml:
            var plantuml = "@startuml\n"
            for (route, module) in routes {
                plantuml += "\(module) --> \(route)\n"
            }
            plantuml += "@enduml\n"
            return plantuml
            
        case .dot:
            var dot = "digraph RouteTree {\n"
            for (route, module) in routes {
                dot += "    \"\(module)\" -> \"\(route)\";\n"
            }
            dot += "}\n"
            return dot
            
        case .ascii:
            var ascii = "Route Tree:\n"
            for (route, module) in routes {
                ascii += "\(module)\n"
                ascii += "  |\n"
                ascii += "  +-- \(route)\n"
            }
            return ascii
            
        case .json:
            var json = "{\n  \"routes\": [\n"
            for (index, (route, module)) in routes.enumerated() {
                json += "    {\n"
                json += "      \"route\": \"\(route)\",\n"
                json += "      \"module\": \"\(module)\"\n"
                json += "    }"
                if index < routes.count - 1 {
                    json += ","
                }
                json += "\n"
            }
            json += "  ]\n}"
            return json
        }
    }
    
    /// 生成模块依赖图
    public func generateModuleGraph(format: VisualizationFormat = .mermaid) async -> String {
        // 获取已注册的模块信息（简化实现）
        let modules = ["Main", "User", "Settings"]
        let dependencies = [("Main", "User"), ("Main", "Settings")]
        
        switch format {
        case .mermaid:
            var mermaid = "graph TD\n"
            for module in modules {
                mermaid += "    \(module)[\(module)]\n"
            }
            for (from, to) in dependencies {
                mermaid += "    \(from) --> \(to)\n"
            }
            return mermaid
            
        case .plantuml:
            var plantuml = "@startuml\n"
            for module in modules {
                plantuml += "[\(module)] as \(module)\n"
            }
            for (from, to) in dependencies {
                plantuml += "\(from) --> \(to)\n"
            }
            plantuml += "@enduml\n"
            return plantuml
            
        case .dot:
            var dot = "digraph ModuleGraph {\n"
            for module in modules {
                dot += "    \"\(module)\";\n"
            }
            for (from, to) in dependencies {
                dot += "    \"\(from)\" -> \"\(to)\";\n"
            }
            dot += "}\n"
            return dot
            
        case .ascii:
            var ascii = "Module Dependencies:\n"
            for module in modules {
                ascii += "\(module)\n"
            }
            for (from, to) in dependencies {
                ascii += "\(from) --> \(to)\n"
            }
            return ascii
            
        case .json:
            var json = "{\n  \"modules\": ["
            for (index, module) in modules.enumerated() {
                json += "\"\(module)\""
                if index < modules.count - 1 {
                    json += ", "
                }
            }
            json += "],\n  \"dependencies\": [\n"
            for (index, (from, to)) in dependencies.enumerated() {
                json += "    {\"from\": \"\(from)\", \"to\": \"\(to)\"}"
                if index < dependencies.count - 1 {
                    json += ","
                }
                json += "\n"
            }
            json += "  ]\n}"
            return json
        }
    }
    
    /// 生成路由性能分析图
    public func generatePerformanceGraph(format: VisualizationFormat = .mermaid) async -> String {
        // 模拟性能数据（简化实现）
        let performanceData = [
            ("/home", 15.2),
            ("/user/:id", 22.8),
            ("/settings", 8.5),
            ("/profile", 18.3)
        ]
        
        switch format {
        case .mermaid:
            var mermaid = "graph TD\n"
            for (route, time) in performanceData {
                mermaid += "    \(route)[\(route)<br/>\(String(format: "%.1f", time))ms]\n"
            }
            return mermaid
            
        case .plantuml:
            var plantuml = "@startuml\n"
            for (route, time) in performanceData {
                plantuml += "[\(route)\\n\(String(format: "%.1f", time))ms] as \(route.replacingOccurrences(of: "/", with: "_"))\n"
            }
            plantuml += "@enduml\n"
            return plantuml
            
        case .dot:
            var dot = "digraph Performance {\n"
            for (route, time) in performanceData {
                dot += "    \"\(route)\" [label=\"\(route)\\n\(String(format: "%.1f", time))ms\"];\n"
            }
            dot += "}\n"
            return dot
            
        case .ascii:
            var ascii = "Performance Analysis:\n"
            for (route, time) in performanceData {
                ascii += "\(route): \(String(format: "%.1f", time))ms\n"
            }
            return ascii
            
        case .json:
            var json = "{\n  \"performance\": [\n"
            for (index, (route, time)) in performanceData.enumerated() {
                json += "    {\n"
                json += "      \"route\": \"\(route)\",\n"
                json += "      \"time\": \(time)\n"
                json += "    }"
                if index < performanceData.count - 1 {
                    json += ","
                }
                json += "\n"
            }
            json += "  ]\n}"
            return json
        }
    }
}