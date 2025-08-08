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
    case invalidURL(String)               // 无效的URL
    case viewControllerNotFound(String)   // 未找到对应的视图控制器
    case parameterError(String, String?)  // 参数错误（消息，建议）
    case moduleNotRegistered(String)      // 模块未注册
    case moduleDependencyError(String)    // 模块依赖错误
    case unsupportedAction(String)        // 不支持的操作
    case navigationError(String)          // 导航错误
    case interceptorRejected(String)      // 路由被拦截
    case configError(String)              // 配置文件错误
    
    // 扩展错误
    case patternSyntaxError(String)       // 路由模式语法错误
    case animationNotFound(String)        // 未找到指定动画
    case actionNotFound(String)           // 操作未找到
    case moduleLoadFailed(String)         // 模块加载失败
    case routeAlreadyExists(String)       // 路由已存在
    case routeNotFound(String)            // 路由未找到
    case maxRetriesExceeded(Int)          // 超过最大重试次数
    case interceptorReleased              // 拦截器已释放
    
    /// 错误描述信息
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "无效的URL: \(url)"
        case .viewControllerNotFound(let path): return "未找到对应的视图控制器: \(path)"
        case .parameterError(let msg, _): return "参数错误: \(msg)"
        case .moduleNotRegistered(let module): return "模块未注册: \(module)"
        case .moduleDependencyError(let msg): return "模块依赖错误: \(msg)"
        case .unsupportedAction(let action): return "不支持的操作: \(action)"
        case .navigationError(let msg): return "导航错误: \(msg)"
        case .interceptorRejected(let reason): return "路由被拦截: \(reason)"
        case .configError(let msg): return "配置错误: \(msg)"
        case .patternSyntaxError(let pattern): return "路由模式语法错误: \(pattern)"
        case .animationNotFound(let name): return "未找到指定动画: \(name)"
        case .actionNotFound(let action): return "操作未找到: \(action)"
        case .moduleLoadFailed(let module): return "模块加载失败: \(module)"
        case .routeAlreadyExists(let path): return "路由已存在: \(path)"
        case .routeNotFound(let path): return "路由未找到: \(path)"
        case .maxRetriesExceeded(let count): return "超过最大重试次数: \(count)"
        case .interceptorReleased: return "拦截器已释放"
        }
    }
    
    /// 错误恢复建议
    public var recoverySuggestion: String? {
        switch self {
        case .parameterError(_, let suggestion):
            return suggestion
        case .moduleNotRegistered(let module):
            return "请先注册模块: \(module)"
        case .maxRetriesExceeded:
            return "请检查网络连接或稍后再试"
        default:
            return nil
        }
    }
    
    /// 判断错误是否可重试
    public var isRetryable: Bool {
        switch self {
        case .navigationError, .moduleLoadFailed, .interceptorRejected:
            return true
        default:
            return false
        }
    }
    
    /// 用户友好的错误信息
    public var userFriendlyMessage: String {
        switch self {
        case .invalidURL(let url): return "链接无效: \(url)"
        case .viewControllerNotFound(let path): return "未找到对应的页面: \(path)"
        case .parameterError(let msg, _): return "参数错误: \(msg)"
        case .moduleNotRegistered(let module): return "模块未注册: \(module)"
        case .moduleDependencyError(let msg): return "模块依赖错误: \(msg)"
        case .unsupportedAction(let action): return "不支持的操作: \(action)"
        case .navigationError(let msg): return "导航失败: \(msg)"
        case .interceptorRejected(let reason): return "无法导航: \(reason)"
        case .configError(let msg): return "配置错误: \(msg)"
        case .patternSyntaxError(let pattern): return "路由格式错误: \(pattern)"
        case .animationNotFound(let name): return "未找到指定动画: \(name)"
        case .actionNotFound(let action): return "操作未找到: \(action)"
        case .moduleLoadFailed(let module): return "模块加载失败: \(module)"
        case .routeAlreadyExists(let path): return "路由已存在: \(path)"
        case .routeNotFound(let path): return "未找到路由: \(path)"
        case .maxRetriesExceeded(let count): return "已超过最大重试次数 (\(count))"
        case .interceptorReleased: return "拦截器已释放，无法完成导航"
        }
    }
}
