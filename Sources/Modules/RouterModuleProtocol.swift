//
//  RouterModuleProtocol.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

// MARK: - 模块依赖结构
/// 定义模块之间的依赖关系
public struct ModuleDependency {
    let moduleName: String  // 依赖的模块名称
    let isRequired: Bool    // 是否为必需依赖（true: 缺少则无法运行；false: 可选）
}

// MARK: - 模块核心协议
/// 所有业务模块必须遵循的核心协议（类专属协议），用于定义模块的基本行为和生命周期
/// - 使用场景：每个独立的业务模块（如用户模块、消息模块等）都应实现此协议
/// - 注意事项：
///   1. 模块名称必须全局唯一，避免冲突
///   2. 依赖关系应明确声明，便于框架自动解析
///   3. 实现时需注意线程安全，特别是在多模块交互时
public protocol ModuleProtocol: AnyObject, Sendable {
    /// 模块唯一标识（不可重复），建议使用模块的类名作为标识
    var moduleName: String { get }
    
    /// 模块依赖列表，声明当前模块运行所需的其他模块
    var dependencies: [ModuleDependency] { get }
    
    /// 最后使用时间（用于自动清理），框架会定期检查并卸载长时间未使用的模块
    var lastUsedTime: Date { get set }
    
    /// 加载模块资源
    /// - 使用场景：模块首次被访问时由框架自动调用
    /// - 参数 completion: 加载完成回调（success: 是否加载成功）
    /// - 注意事项：
    ///   1. 应在此方法中完成模块的初始化工作，如注册路由、初始化服务等
    ///   2. 异步加载操作应在此方法中执行
    ///   3. 加载失败时应提供明确的错误信息
    func load(completion: @escaping (Bool) -> Void)
    
    /// 卸载模块资源
    /// - 使用场景：模块长时间未使用或内存紧张时由框架自动调用
    /// - 注意事项：
    ///   1. 应在此方法中释放所有占用的资源
    ///   2. 取消所有正在进行的异步任务
    ///   3. 移除所有注册的通知和观察者
    func unload()
    
    /// 暂停模块业务（如进入后台）
    /// - 使用场景：应用进入后台或模块暂时不可见时调用
    /// - 注意事项：应暂停耗时操作、定时器等，但保留必要的状态
    func suspend()
    
    /// 恢复模块业务（如回到前台）
    /// - 使用场景：应用回到前台或模块重新可见时调用
    /// - 注意事项：恢复之前暂停的操作和定时器
    func resume()
    
    /// 模块的初始化方法
    /// - 注意事项：初始化方法应保持轻量级，避免在此处执行耗时操作
    init()
}

// MARK: - 模块生命周期观察者协议
/// 监听模块生命周期状态变化的协议（类专属协议）
public protocol ModuleLifecycleObserver: AnyObject {
    /// 模块状态变化回调
    /// - Parameters:
    ///   - module: 发生状态变化的模块
    ///   - state: 新的状态
    func module(_ module: ModuleProtocol, didChangeState state: ModuleState)
}
