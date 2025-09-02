//
//  RouterBasicTypes.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

// MARK: - 类型别名
/// 路由参数字典，用于页面间传递数据
public typealias RouterParameters = [String: Any]
/// 路由完成回调，返回结果或错误
public typealias RouterCompletion = (Result<Any?, RouterError>) -> Void

// MARK: - 导航类型枚举
/// 定义页面跳转的方式
public enum NavigationType {
    case push              // 导航控制器压栈
    case present           // 模态展示
    case replace           // 替换当前页面
    case popToRoot         // 返回根页面
    case popTo             // 返回指定页面
}

// MARK: - 模块状态枚举
/// 定义模块生命周期的各种状态
public enum ModuleState {
    case willLoad      // 即将加载
    case didLoad       // 加载完成
    case willUnload    // 即将卸载
    case didUnload     // 卸载完成
    case suspended     // 已暂停
    case resumed       // 已恢复
}

// MARK: - 路由错误枚举
/// 定义路由系统可能出现的错误类型
public enum RouterError: Error, LocalizedError, Equatable {
    // 基础错误
    case invalidURL(String, debugInfo: String? = nil)               // 无效的URL
    case viewControllerNotFound(String, debugInfo: String? = nil)   // 未找到对应的视图控制器
    case parameterError(String, suggestion: String? = nil, debugInfo: String? = nil)  // 参数错误
    case moduleNotRegistered(String, debugInfo: String? = nil)      // 模块未注册
    case moduleDependencyError(String, debugInfo: String? = nil)    // 模块依赖错误
    case unsupportedAction(String, debugInfo: String? = nil)        // 不支持的操作
    case navigationError(String, debugInfo: String? = nil)          // 导航错误
    case interceptorRejected(String, debugInfo: String? = nil)      // 路由被拦截
    case configError(String, debugInfo: String? = nil)              // 配置文件错误
    
    // 扩展错误
    case patternSyntaxError(String, debugInfo: String? = nil)       // 路由模式语法错误
    case animationNotFound(String, debugInfo: String? = nil)        // 未找到指定动画
    case actionNotFound(String, debugInfo: String? = nil)           // 操作未找到
    case moduleLoadFailed(String, reason: String? = nil, debugInfo: String? = nil)         // 模块加载失败
    case routeAlreadyExists(String, debugInfo: String? = nil)       // 路由已存在
    case routeNotFound(String, debugInfo: String? = nil)            // 路由未找到
    case maxRetriesExceeded(Int, debugInfo: String? = nil)          // 超过最大重试次数
    case interceptorReleased(debugInfo: String? = nil)              // 拦截器已释放
    
    // 新增错误类型
    case permissionDenied(String, debugInfo: String? = nil)         // 权限被拒绝
    case networkError(String, debugInfo: String? = nil)             // 网络错误
    case timeoutError(String, debugInfo: String? = nil)             // 超时错误
    case memoryError(String, debugInfo: String? = nil)              // 内存错误
    case concurrencyError(String, debugInfo: String? = nil)         // 并发错误
    
    /// 错误描述信息
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url, _): return "无效的URL: \(url)"
        case .viewControllerNotFound(let path, _): return "未找到对应的视图控制器: \(path)"
        case .parameterError(let msg, _, _): return "参数错误: \(msg)"
        case .moduleNotRegistered(let module, _): return "模块未注册: \(module)"
        case .moduleDependencyError(let msg, _): return "模块依赖错误: \(msg)"
        case .unsupportedAction(let action, _): return "不支持的操作: \(action)"
        case .navigationError(let msg, _): return "导航错误: \(msg)"
        case .interceptorRejected(let reason, _): return "路由被拦截: \(reason)"
        case .configError(let msg, _): return "配置错误: \(msg)"
        case .patternSyntaxError(let pattern, _): return "路由模式语法错误: \(pattern)"
        case .animationNotFound(let name, _): return "未找到指定动画: \(name)"
        case .actionNotFound(let action, _): return "操作未找到: \(action)"
        case .moduleLoadFailed(let module, let reason, _): 
            var desc = "模块加载失败: \(module)"
            if let reason = reason { desc += " - \(reason)" }
            return desc
        case .routeAlreadyExists(let path, _): return "路由已存在: \(path)"
        case .routeNotFound(let path, _): return "路由未找到: \(path)"
        case .maxRetriesExceeded(let count, _): return "超过最大重试次数: \(count)"
        case .interceptorReleased(_): return "拦截器已释放"
        case .permissionDenied(let msg, _): return "权限被拒绝: \(msg)"
        case .networkError(let msg, _): return "网络错误: \(msg)"
        case .timeoutError(let msg, _): return "超时错误: \(msg)"
        case .memoryError(let msg, _): return "内存错误: \(msg)"
        case .concurrencyError(let msg, _): return "并发错误: \(msg)"
        }
    }
    
    /// 错误恢复建议
    public var recoverySuggestion: String? {
        switch self {
        case .parameterError(_, let suggestion, _):
            return suggestion ?? "请检查参数格式和类型是否正确"
        case .moduleNotRegistered(let module, _):
            return "请先注册模块: \(module)，或检查模块名称是否正确"
        case .maxRetriesExceeded(_, _):
            return "请检查网络连接或稍后再试，也可以尝试重启应用"
        case .invalidURL(_, _):
            return "请检查URL格式是否正确，确保包含正确的协议和路径"
        case .viewControllerNotFound(_, _):
            return "请确认路由已正确注册，或检查路径拼写是否正确"
        case .moduleLoadFailed(_, _, _):
            return "请检查模块依赖是否满足，或尝试重新加载模块"
        case .navigationError(_, _):
            return "请检查导航上下文是否正确，或尝试使用其他导航方式"
        case .interceptorRejected(_, _):
            return "请检查拦截器逻辑，确认是否需要满足特定条件"
        case .permissionDenied(_, _):
            return "请检查应用权限设置，或联系管理员获取访问权限"
        case .networkError(_, _):
            return "请检查网络连接，确保设备已连接到互联网"
        case .timeoutError(_, _):
            return "操作超时，请稍后重试或检查网络状况"
        case .memoryError(_, _):
            return "内存不足，请关闭其他应用或重启设备"
        case .concurrencyError(_, _):
            return "并发冲突，请稍后重试或避免同时执行相同操作"
        case .routeNotFound(_, _):
            return "请检查路由路径是否正确，或确认路由已正确注册"
        case .patternSyntaxError(_, _):
            return "请检查路由模式语法，确保符合规范格式"
        case .animationNotFound(_, _):
            return "请检查动画名称是否正确，或使用默认动画"
        case .actionNotFound(_, _):
            return "请检查操作名称是否正确，或查看支持的操作列表"
        default:
            return "请尝试重新操作，如问题持续存在请联系技术支持"
        }
    }
    
    /// 判断错误是否可重试
    public var isRetryable: Bool {
        switch self {
        case .navigationError(_, _), .moduleLoadFailed(_, _, _), .interceptorRejected(_, _):
            return true
        case .networkError(_, _), .timeoutError(_, _), .maxRetriesExceeded(_, _):
            return true
        case .concurrencyError(_, _):
            return true
        case .invalidURL(_, _), .viewControllerNotFound(_, _), .parameterError(_, _, _):
            return false
        case .moduleNotRegistered(_, _), .moduleDependencyError(_, _):
            return false
        case .permissionDenied(_, _), .memoryError(_, _):
            return false
        case .patternSyntaxError(_, _), .configError(_, _):
            return false
        case .routeAlreadyExists(_, _), .routeNotFound(_, _):
            return false
        case .animationNotFound(_, _), .actionNotFound(_, _):
            return false
        case .unsupportedAction(_, _), .interceptorReleased(_):
            return false
        }
    }
    
    /// 用户友好的错误信息
    public var userFriendlyMessage: String {
        switch self {
        case .invalidURL(let url, _): return "链接无效: \(url)"
        case .viewControllerNotFound(let path, _): return "未找到对应的页面: \(path)"
        case .parameterError(let msg, _, _): return "参数错误: \(msg)"
        case .moduleNotRegistered(let module, _): return "模块未注册: \(module)"
        case .moduleDependencyError(let msg, _): return "模块依赖错误: \(msg)"
        case .unsupportedAction(let action, _): return "不支持的操作: \(action)"
        case .navigationError(let msg, _): return "导航失败: \(msg)"
        case .interceptorRejected(let reason, _): return "无法导航: \(reason)"
        case .configError(let msg, _): return "配置错误: \(msg)"
        case .patternSyntaxError(let pattern, _): return "路由格式错误: \(pattern)"
        case .animationNotFound(let name, _): return "未找到指定动画: \(name)"
        case .actionNotFound(let action, _): return "操作未找到: \(action)"
        case .moduleLoadFailed(let module, _, _): return "模块加载失败: \(module)"
        case .routeAlreadyExists(let path, _): return "路由已存在: \(path)"
        case .routeNotFound(let path, _): return "未找到路由: \(path)"
        case .maxRetriesExceeded(let count, _): return "已超过最大重试次数 (\(count))"
        case .interceptorReleased(_): return "拦截器已释放，无法完成导航"
        case .permissionDenied(let msg, _): return "权限不足: \(msg)"
        case .networkError(let msg, _): return "网络连接失败: \(msg)"
        case .timeoutError(let msg, _): return "操作超时: \(msg)"
        case .memoryError(let msg, _): return "内存不足: \(msg)"
        case .concurrencyError(let msg, _): return "操作冲突: \(msg)"
        }
    }
    
    /// 错误代码（用于日志记录和调试）
    public var errorCode: String {
        switch self {
        case .invalidURL(_, _): return "ROUTER_001"
        case .viewControllerNotFound(_, _): return "ROUTER_002"
        case .parameterError(_, _, _): return "ROUTER_003"
        case .moduleNotRegistered(_, _): return "ROUTER_004"
        case .moduleDependencyError(_, _): return "ROUTER_005"
        case .unsupportedAction(_, _): return "ROUTER_006"
        case .navigationError(_, _): return "ROUTER_007"
        case .interceptorRejected(_, _): return "ROUTER_008"
        case .configError(_, _): return "ROUTER_009"
        case .patternSyntaxError(_, _): return "ROUTER_010"
        case .animationNotFound(_, _): return "ROUTER_011"
        case .actionNotFound(_, _): return "ROUTER_012"
        case .moduleLoadFailed(_, _, _): return "ROUTER_013"
        case .routeAlreadyExists(_, _): return "ROUTER_014"
        case .routeNotFound(_, _): return "ROUTER_015"
        case .maxRetriesExceeded(_, _): return "ROUTER_016"
        case .interceptorReleased(_): return "ROUTER_017"
        case .permissionDenied(_, _): return "ROUTER_018"
        case .networkError(_, _): return "ROUTER_019"
        case .timeoutError(_, _): return "ROUTER_020"
        case .memoryError(_, _): return "ROUTER_021"
        case .concurrencyError(_, _): return "ROUTER_022"
        }
    }
    
    /// 调试信息（仅在调试模式下显示）
    public var debugInfo: String? {
        switch self {
        case .invalidURL(_, let debugInfo): return debugInfo
        case .viewControllerNotFound(_, let debugInfo): return debugInfo
        case .parameterError(_, _, let debugInfo): return debugInfo
        case .moduleNotRegistered(_, let debugInfo): return debugInfo
        case .moduleDependencyError(_, let debugInfo): return debugInfo
        case .unsupportedAction(_, let debugInfo): return debugInfo
        case .navigationError(_, let debugInfo): return debugInfo
        case .interceptorRejected(_, let debugInfo): return debugInfo
        case .configError(_, let debugInfo): return debugInfo
        case .patternSyntaxError(_, let debugInfo): return debugInfo
        case .animationNotFound(_, let debugInfo): return debugInfo
        case .actionNotFound(_, let debugInfo): return debugInfo
        case .moduleLoadFailed(_, _, let debugInfo): return debugInfo
        case .routeAlreadyExists(_, let debugInfo): return debugInfo
        case .routeNotFound(_, let debugInfo): return debugInfo
        case .maxRetriesExceeded(_, let debugInfo): return debugInfo
        case .interceptorReleased(let debugInfo): return debugInfo
        case .permissionDenied(_, let debugInfo): return debugInfo
        case .networkError(_, let debugInfo): return debugInfo
        case .timeoutError(_, let debugInfo): return debugInfo
        case .memoryError(_, let debugInfo): return debugInfo
        case .concurrencyError(_, let debugInfo): return debugInfo
        }
    }
}
