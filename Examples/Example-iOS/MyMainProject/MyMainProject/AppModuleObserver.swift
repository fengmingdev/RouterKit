//
//  AppModuleObserver.swift
//  MyMainProject
//
//  Created by fengming on 2025/8/8.
//

import RouterKit
// MARK: 创建模块生命周期观察者

/// 模块生命周期观察者
class AppModuleObserver: ModuleLifecycleObserver {
    func module(_ module: ModuleProtocol, didChangeState state: ModuleState) {
        print("[模块生命周期] \(module.moduleName) 状态变更为: \(state)")

        switch state {
        case .willLoad:
            // 模块即将加载
            break
        case .didLoad:
            // 模块加载完成
            break
        case .willUnload:
            // 模块即将卸载
            break
        case .didUnload:
            // 模块卸载完成
            break
        case .suspended:
            // 模块已暂停
            break
        case .resumed:
            // 模块已恢复
            break
        }
    }
}
