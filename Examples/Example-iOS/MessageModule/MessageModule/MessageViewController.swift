//
//  MessageViewController.swift
//  MessageModule
//
//  Created by fengming on 2025/8/8.
//

import UIKit
import RouterKit_Swift

// 消息视图控制器
public class MessageViewController: UIViewController, Routable {
    
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return MessageViewController()
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        if action == "updateMessage" {
            // 执行更新消息的操作
            completion(.success("消息更新成功"))
        } else {
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 40))
        titleLabel.text = "消息页面"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(titleLabel)
        
        let backButton = UIButton(frame: CGRect(x: (view.bounds.width - 100)/2, y: 200, width: 100, height: 40))
        backButton.setTitle("返回", for: .normal)
        backButton.setTitleColor(.blue, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        Router.popToRoot()
    }
    
    /// 获取消息列表
    /// - Parameters:
    ///   - page: 页码
    ///   - pageSize: 每页条数
    ///   - completion: 完成回调
    func getMessageList(page: Int, pageSize: Int, completion: @escaping ([Message]?, Error?) -> Void) {
        // 模拟网络请求
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // 模拟数据
            let messages = (
                0..<pageSize
            ).map { index in
                Message(
                    id: (page * pageSize + index),
                    title: "消息标题 \(page * pageSize + index + 1)",
                    content: "这是一条测试消息内容 \(page * pageSize + index + 1)",
                    sender: "系统通知",
                    timestamp: Date()
                )
            }
            completion(messages, nil)
        }
    }

    /// 获取消息详情
    /// - Parameters:
    ///   - messageId: 消息ID
    ///   - completion: 完成回调
    func getMessageDetail(messageId: Int, completion: @escaping (Message?, Error?) -> Void) {
        // 模拟网络请求
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let message = Message(
                id: messageId,
                title: "消息标题 \(messageId)",
                content: "这是消息ID为 \(messageId) 的详细内容...",
                sender: "系统通知",
                timestamp: Date()
            )
            completion(message, nil)
        }
    }
}
