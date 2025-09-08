//
//  ErrorHandlingModule.swift
//  ErrorHandlingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 错误处理模块
public class ErrorHandlingModule: ModuleProtocol {

    public var moduleName: String = "ErrorHandlingModule"
    public var dependencies: [ModuleDependency] = []
    public var lastUsedTime: Date = Date()

    required public init() {}

    public func load(completion: @escaping (Bool) -> Void) {
        // 注册全局错误处理器
        setupGlobalErrorHandlers()
        
        // 注册路由
        Task {
            do {
                // 注册错误处理示例主页面
                try await Router.shared.registerRoute("/ErrorHandlingModule/errorHandling", for: ErrorHandlingViewController.self)
        
                // 注册路由错误页面
                try await Router.shared.registerRoute("/ErrorHandlingModule/routeError", for: RouteErrorViewController.self)
        
                // 注册网络错误页面
                try await Router.shared.registerRoute("/ErrorHandlingModule/networkError", for: NetworkErrorViewController.self)
        
                // 注册错误恢复页面
                try await Router.shared.registerRoute("/ErrorHandlingModule/errorRecovery", for: ErrorRecoveryViewController.self)
        
                // 注册错误日志页面
                try await Router.shared.registerRoute("/ErrorHandlingModule/errorLogging", for: ErrorLogViewController.self)

                print("ErrorHandlingModule: 模块注册完成")
                completion(true)
            } catch {
                print("ErrorHandlingModule: 路由注册失败 - \(error)")
                completion(false)
            }
        }
    }

    public func unload() {
        // 清理资源
    }

    public func suspend() {
        // 暂停模块
    }

    public func resume() {
        // 恢复模块
    }

    private func register() {
        Task {
            do {
                // 注册错误处理示例主页面
                try await Router.shared.registerRoute("/ErrorHandlingModule/errorHandling", for: ErrorHandlingViewController.self)
        
        // 注册路由错误页面
        try await Router.shared.registerRoute("/ErrorHandlingModule/routeError", for: RouteErrorViewController.self)
        
        // 注册网络错误页面
        try await Router.shared.registerRoute("/ErrorHandlingModule/networkError", for: NetworkErrorViewController.self)
        
        // 注册错误恢复页面
        try await Router.shared.registerRoute("/ErrorHandlingModule/errorRecovery", for: ErrorRecoveryViewController.self)
        
        // 注册错误日志页面
        try await Router.shared.registerRoute("/ErrorHandlingModule/errorLogging", for: ErrorLogViewController.self)

                print("ErrorHandlingModule: 模块注册完成")
            } catch {
                print("ErrorHandlingModule: 路由注册失败 - \(error)")
            }
        }

        // 注册全局错误处理器
        setupGlobalErrorHandlers()
    }

    private func setupGlobalErrorHandlers() {
        // 注册错误处理拦截器
        let errorInterceptor = ErrorHandlingInterceptor()
        Task {
            await Router.shared.addInterceptor(errorInterceptor)
        }
    }
}

// MARK: - Error Manager

/// 错误管理器
class ErrorManager {

    static let shared = ErrorManager()

    private var errorLogs: [ErrorLog] = []
    private var errorHandlers: [String: (Error, RouteContext?) -> Void] = [:]
    private var retryStrategies: [String: RetryStrategy] = [:]

    private init() {
        setupDefaultErrorHandlers()
        setupDefaultRetryStrategies()
    }

    // MARK: - Error Handling

    func handleError(_ error: Error, context: RouteContext?) {
        let errorLog = ErrorLog(
            error: error,
            context: context,
            timestamp: Date(),
            stackTrace: Thread.callStackSymbols
        )

        errorLogs.append(errorLog)

        // 根据错误类型选择处理策略
        if let routerError = error as? RouterKit.RouterError {
            handleRouterError(routerError, context: context, log: errorLog)
        } else if let networkError = error as? NetworkError {
            handleNetworkError(networkError, context: context, log: errorLog)
        } else {
            handleGenericError(error, context: context, log: errorLog)
        }

        // 发送错误通知
        NotificationCenter.default.post(
            name: .errorOccurred,
            object: errorLog
        )
    }

    func handleInterceptorError(_ error: Error, context: RouteContext?) {
        let errorLog = ErrorLog(
            error: error,
            context: context,
            timestamp: Date(),
            stackTrace: Thread.callStackSymbols,
            errorType: .interceptor
        )

        errorLogs.append(errorLog)

        // 拦截器错误处理
        print("拦截器错误: \(error.localizedDescription)")

        // 根据错误类型决定是否继续路由
        if error is AuthError {
            // 认证错误，跳转到登录页面
            DispatchQueue.main.async {
                _ = Router.shared.navigate(to: "/LoginModule/login")
            }
        }
    }

    private func handleRouterError(_ error: RouterKit.RouterError, context: RouteContext?, log: ErrorLog) {
        switch error {
        case .routeNotFound(let route):
            print("路由未找到: \(route)")
            showErrorAlert(title: "路由错误", message: "未找到路由: \(route)")

        case .moduleNotRegistered(let module):
            print("模块未注册: \(module)")
            showErrorAlert(title: "模块错误", message: "模块未注册: \(module)")

        case .parameterError(let message, _, _):
            print("参数错误: \(message)")
            showErrorAlert(title: "参数错误", message: message)

        case .navigationError(let message, _):
            print("导航失败: \(message)")
            showErrorAlert(title: "导航错误", message: message)

        case .invalidURL(let url, _):
            print("无效URL: \(url)")
            showErrorAlert(title: "URL错误", message: "无效URL: \(url)")

        case .viewControllerNotFound(let path, _):
            print("视图控制器未找到: \(path)")
            showErrorAlert(title: "视图控制器错误", message: "未找到视图控制器: \(path)")

        case .permissionDenied(let message, _):
            print("权限不足: \(message)")
            showErrorAlert(title: "权限错误", message: "权限不足: \(message)")

        case .timeoutError(let message, _):
            print("超时错误: \(message)")
            showErrorAlert(title: "超时错误", message: message)

        case .actionNotFound(let action, _):
            print("动作未找到: \(action)")
            showErrorAlert(title: "动作错误", message: "未找到动作: \(action)")

        default:
            print("其他路由错误: \(error.localizedDescription)")
            showErrorAlert(title: "路由错误", message: error.localizedDescription)
        }
    }

    private func handleNetworkError(_ error: NetworkError, context: RouteContext?, log: ErrorLog) {
        switch error {
        case .noConnection:
            showErrorAlert(title: "网络错误", message: "无网络连接")

        case .timeout:
            showErrorAlert(title: "网络错误", message: "请求超时")

        case .serverError(let code):
            showErrorAlert(title: "服务器错误", message: "服务器错误 (\(code))")

        case .invalidResponse:
            showErrorAlert(title: "网络错误", message: "无效的服务器响应")

        case .connectionTimeout:
            showErrorAlert(title: "网络错误", message: "连接超时")

        case .requestTimeout:
            showErrorAlert(title: "网络错误", message: "请求超时")

        case .networkUnavailable:
            showErrorAlert(title: "网络错误", message: "网络不可用")

        case .clientError(let code):
            showErrorAlert(title: "客户端错误", message: "客户端错误 (\(code))")

        case .dnsFailure:
            showErrorAlert(title: "网络错误", message: "DNS解析失败")

        case .sslError:
            showErrorAlert(title: "网络错误", message: "SSL证书错误")

        case .unknown(let message):
            showErrorAlert(title: "未知错误", message: message)
        }
    }

    private func handleGenericError(_ error: Error, context: RouteContext?, log: ErrorLog) {
        print("通用错误: \(error.localizedDescription)")
        showErrorAlert(title: "错误", message: error.localizedDescription)
    }

    // MARK: - Error Recovery

    func retryOperation(for errorLog: ErrorLog, completion: @escaping (Bool) -> Void) {
        guard let strategy = getRetryStrategy(for: errorLog) else {
            completion(false)
            return
        }

        strategy.retry(errorLog: errorLog, completion: completion)
    }

    private func getRetryStrategy(for errorLog: ErrorLog) -> RetryStrategy? {
        if errorLog.error is NetworkError {
            return retryStrategies["network"]
        } else if errorLog.error is RouterKit.RouterError {
            return retryStrategies["router"]
        }
        return retryStrategies["default"]
    }

    // MARK: - Error Logging

    func getErrorLogs() -> [ErrorLog] {
        return errorLogs
    }

    func clearErrorLogs() {
        errorLogs.removeAll()
    }

    func exportErrorLogs() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var logString = "RouterKit Error Logs\n"
        logString += "Generated: \(formatter.string(from: Date()))\n\n"

        for (index, log) in errorLogs.enumerated() {
            logString += "[\(index + 1)] \(formatter.string(from: log.timestamp))\n"
            logString += "Type: \(log.errorType.rawValue)\n"
            logString += "Error: \(log.error.localizedDescription)\n"
            if let context = log.context {
                logString += "Route: \(context.url)\n"
                logString += "Parameters: \(context.parameters)\n"
            }
            logString += "Stack Trace:\n"
            for trace in log.stackTrace {
                logString += "  \(trace)\n"
            }
            logString += "\n"
        }

        return logString
    }

    // MARK: - Setup Methods

    private func setupDefaultErrorHandlers() {
        // 设置默认错误处理器
        errorHandlers["default"] = { error, _ in
            print("默认错误处理: \(error.localizedDescription)")
        }
    }

    private func setupDefaultRetryStrategies() {
        // 网络错误重试策略
        retryStrategies["network"] = NetworkRetryStrategy()

        // 路由错误重试策略
        retryStrategies["router"] = RouterRetryStrategy()

        // 默认重试策略
        retryStrategies["default"] = DefaultRetryStrategy()
    }

    // MARK: - Helper Methods

    private func showErrorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            guard let topViewController = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() else {
                return
            }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            topViewController.present(alert, animated: true)
        }
    }
}

// MARK: - Error Types

/// 网络错误类型
enum NetworkError: Error, LocalizedError {
    case noConnection
    case timeout
    case serverError(Int)
    case invalidResponse
    case connectionTimeout
    case requestTimeout
    case networkUnavailable
    case clientError(Int)
    case dnsFailure
    case sslError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "无网络连接"
        case .timeout:
            return "请求超时"
        case .serverError(let code):
            return "服务器错误 (\(code))"
        case .invalidResponse:
            return "无效的服务器响应"
        case .connectionTimeout:
            return "连接超时"
        case .requestTimeout:
            return "请求超时"
        case .networkUnavailable:
            return "网络不可用"
        case .clientError(let code):
            return "客户端错误 (\(code))"
        case .dnsFailure:
            return "DNS解析失败"
        case .sslError:
            return "SSL证书错误"
        case .unknown(let message):
            return "未知错误: \(message)"
        }
    }
}

/// 认证错误类型
enum AuthError: Error, LocalizedError {
    case notLoggedIn
    case insufficientPermissions
    case tokenExpired

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "用户未登录"
        case .insufficientPermissions:
            return "权限不足"
        case .tokenExpired:
            return "登录已过期"
        }
    }
}

// MARK: - Error Log

/// 错误日志
struct ErrorLog {
    let id = UUID()
    let error: Error
    let context: RouteContext?
    let timestamp: Date
    let stackTrace: [String]
    let errorType: ErrorType

    init(error: Error, context: RouteContext?, timestamp: Date, stackTrace: [String], errorType: ErrorType = .general) {
        self.error = error
        self.context = context
        self.timestamp = timestamp
        self.stackTrace = stackTrace
        self.errorType = errorType
    }
}

/// 错误类型
enum ErrorType: String, CaseIterable {
    case general = "General"
    case router = "Router"
    case network = "Network"
    case auth = "Authentication"
    case interceptor = "Interceptor"
    case module = "Module"
}

// MARK: - Retry Strategies

/// 重试策略协议
protocol RetryStrategy {
    func retry(errorLog: ErrorLog, completion: @escaping (Bool) -> Void)
}

/// 网络重试策略
class NetworkRetryStrategy: RetryStrategy {
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0

    func retry(errorLog: ErrorLog, completion: @escaping (Bool) -> Void) {
        // 模拟网络重试
        DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
            let success = Bool.random() // 模拟重试结果
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}

/// 路由重试策略
class RouterRetryStrategy: RetryStrategy {
    func retry(errorLog: ErrorLog, completion: @escaping (Bool) -> Void) {
        // 尝试重新导航
        if let context = errorLog.context {
            Task { @MainActor in
                Router.shared.navigate(to: context.url) { result in
                    switch result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            }
        } else {
            completion(false)
        }
    }
}

/// 默认重试策略
class DefaultRetryStrategy: RetryStrategy {
    func retry(errorLog: ErrorLog, completion: @escaping (Bool) -> Void) {
        // 默认不重试
        completion(false)
    }
}

// MARK: - Extensions

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? self
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? self
        }

        return self
    }
}

/// 错误处理拦截器
class ErrorHandlingInterceptor: RouterInterceptor {
    var priority: InterceptorPriority = .high
    var isAsync: Bool = false

    func intercept(url: String, parameters: RouterParameters, completion: @escaping InterceptorCompletion) {
        // 允许导航继续，但在完成后处理可能的错误
        completion(true, nil, nil, parameters, nil)
    }
}

extension Notification.Name {
    static let errorOccurred = Notification.Name("ErrorOccurred")
}
