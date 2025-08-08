//
//  LoginViewController.swift
//  LoginModule
//
//  Created by fengming on 2025/8/8.
//

import Foundation
import UIKit
import RouterKit

/// 登录视图控制器
public class LoginViewController: UIViewController, Routable {
    // 用户名输入框
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "用户名"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()

    // 密码输入框
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()

    // 登录按钮
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    // 错误信息标签
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // 认证模块引用
    private var loginModule: LoginModule?

    // MARK: - 生命周期

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()

        // 获取认证模块实例
        Task {
            self.loginModule = await Router.shared.getModule(LoginModule.self)
        }
    }

    // MARK: - UI设置

    private func setupUI() {
        view.backgroundColor = .white
        title = "登录"

        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(errorLabel)
    }

    private func setupConstraints() {
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 44),

            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    // MARK: - 事件处理

    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("请输入用户名和密码")
            return
        }

        // 隐藏键盘
        view.endEditing(true)

        // 显示加载状态
        loginButton.setTitle("登录中...", for: .normal)
        loginButton.isEnabled = false
        errorLabel.isHidden = true

        // 调用认证模块进行登录
        loginModule?.login(username: username, password: password) { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // 恢复按钮状态
                self.loginButton.setTitle("登录", for: .normal)
                self.loginButton.isEnabled = true

                if success {
                    // 登录成功，返回上一页
                    self.navigationController?.popViewController(animated: true)
                } else {
                    // 显示错误信息
                    self.showError(error?.localizedDescription ?? "登录失败，请重试")
                }
            }
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    // MARK: - Routable协议实现

    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return LoginViewController()
    }

    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        // 可以在这里实现登录相关的动作
//        completion(nil, nil)
        completion(.failure(RouterError.actionNotFound(action)))
    }
}
