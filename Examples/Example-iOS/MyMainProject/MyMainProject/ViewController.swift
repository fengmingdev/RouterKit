//
//  ViewController.swift
//  MyMainProject
//
//  Created by fengming on 2025/8/8.
//

import UIKit
import RouterKit

class ViewController: UIViewController, Routable {

    // MARK: - Routable Protocol Implementation
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return ViewController()
    }

    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        switch action {
        case "navigateToLogin":
            Router.push(to: "/LoginModule/login")
            completion(.success("已跳转到登录页面"))
        case "navigateToMessage":
            Router.push(to: "/MessageModule/message")
            completion(.success("已跳转到消息页面"))
        default:
            completion(.failure(RouterError.actionNotFound(action)))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // 添加标题
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 40))
        titleLabel.text = "主页面"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(titleLabel)

        // 添加登录按钮
        let loginButton = UIButton(frame: CGRect(x: 50, y: 200, width: view.bounds.width - 100, height: 50))
        loginButton.setTitle("跳转到登录页面", for: .normal)
        loginButton.backgroundColor = .blue
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)

        // 添加消息按钮
        let messageButton = UIButton(frame: CGRect(x: 50, y: 280, width: view.bounds.width - 100, height: 50))
        messageButton.setTitle("跳转到消息页面", for: .normal)
        messageButton.backgroundColor = .green
        messageButton.layer.cornerRadius = 8
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        view.addSubview(messageButton)

        title = "主页面"
    }

    @objc private func loginButtonTapped() {
         // 跳转到登录页面
         print("ViewController: 尝试跳转到 /LoginModule/login")
        Router.push(to: "/LoginModule/login")
     }

     @objc private func messageButtonTapped() {
         // 跳转到消息页面
         print("ViewController: 尝试跳转到 /MessageModule/message")
         Router.push(to: "/MessageModule/message")
     }
}
