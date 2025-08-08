//
//  UIKit+Router..swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation
import UIKit

// MARK: - UIViewController扩展
@MainActor
extension UIViewController {
    /// 从当前控制器push到指定URL
    /// - Parameters:
    ///   - url: 目标URL
    ///   - parameters: 路由参数
    ///   - animated: 是否动画
    ///   - animationId: 自定义动画ID
    ///   - completion: 完成回调
    func push(to url: String,
             parameters: RouterParameters? = nil,
             animated: Bool = true,
             animationId: String? = nil,
             completion: @escaping RouterCompletion = { _ in }) {
        Router.push(
            to: url,
            parameters: parameters,
            from: self,
            animated: animated,
            animationId: animationId,
            completion: completion
        )
    }
    
    /// 从当前控制器present到指定URL
    /// - Parameters:
    ///   - url: 目标URL
    ///   - parameters: 路由参数
    ///   - animated: 是否动画
    ///   - animationId: 自定义动画ID
    ///   - completion: 完成回调
    func present(to url: String,
                parameters: RouterParameters? = nil,
                animated: Bool = true,
                animationId: String? = nil,
                completion: @escaping RouterCompletion = { _ in }) {
        Router.present(
            to: url,
            parameters: parameters,
            from: self,
            animated: animated,
            animationId: animationId,
            completion: completion
        )
    }
    
    /// 替换当前控制器为指定URL对应的页面
    /// - Parameters:
    ///   - url: 目标URL
    ///   - parameters: 路由参数
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    func replace(with url: String,
                parameters: RouterParameters? = nil,
                animated: Bool = true,
                completion: @escaping RouterCompletion = { _ in }) {
        Router.replace(
            to: url,
            parameters: parameters,
            from: self,
            animated: animated,
            completion: completion
        )
    }
}

// MARK: - UIButton扩展
@MainActor
extension UIButton {
    /// 绑定按钮点击事件到指定路由
    /// - Parameters:
    ///   - url: 目标URL
    ///   - parameters: 路由参数
    ///   - sourceVC: 源视图控制器（默认当前所在控制器）
    func setRouterAction(for url: String,
                        parameters: RouterParameters? = nil,
                        sourceVC: UIViewController? = nil) {
        addTarget(self, action: #selector(routerButtonTapped(_:)), for: .touchUpInside)
        setAssociatedObject(url, forKey: &routerURLKey)
        setAssociatedObject(parameters ?? [:], forKey: &routerParamsKey)
        setAssociatedObject(sourceVC, forKey: &routerSourceVCKey)
    }
    
    @objc private func routerButtonTapped(_ sender: UIButton) {
        guard let url = getAssociatedObject(forKey: &routerURLKey) as? String else { return }
        let parameters = getAssociatedObject(forKey: &routerParamsKey) as? RouterParameters
        let sourceVC = getAssociatedObject(forKey: &routerSourceVCKey) as? UIViewController ?? sender.viewController
        
        Router.push(
            to: url,
            parameters: parameters,
            from: sourceVC,
            completion: { result in  // 使用弱引用避免循环引用
                switch result {
                case .success:
                    Router.shared.log("按钮路由成功: \(url)", level: .info)
                case .failure(let error):
                    Router.shared.log("按钮路由失败: \(error)", level: .error)
                }
            }
        )
    }
}

// MARK: - 关联对象工具
private var routerURLKey: UInt8 = 0
private var routerParamsKey: UInt8 = 0
private var routerSourceVCKey: UInt8 = 0

extension NSObject {
    /// 设置关联对象
    fileprivate func setAssociatedObject(_ value: Any?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// 获取关联对象
    fileprivate func getAssociatedObject(forKey key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
}

// MARK: - 视图控制器查找扩展
@MainActor
extension UIView {
    /// 获取当前视图所在的视图控制器
    var viewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
