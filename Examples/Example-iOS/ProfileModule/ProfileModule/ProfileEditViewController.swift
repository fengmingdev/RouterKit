//
//  ProfileEditViewController.swift
//  ProfileModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

public class ProfileEditViewController: UIViewController, Routable {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let usernameTextField = UITextField()
    private let emailTextField = UITextField()
    private let bioTextView = UITextView()
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private var userProfile: ProfileModuleManager.UserProfile?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProfile()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "编辑资料"
        
        // 设置导航栏
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "取消",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "保存",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 配置用户名输入框
        setupTextField(usernameTextField, placeholder: "用户名")
        
        // 配置邮箱输入框
        setupTextField(emailTextField, placeholder: "邮箱")
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        
        // 配置个人简介输入框
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.font = UIFont.systemFont(ofSize: 16)
        bioTextView.layer.borderColor = UIColor.systemGray4.cgColor
        bioTextView.layer.borderWidth = 1
        bioTextView.layer.cornerRadius = 8
        bioTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        contentView.addSubview(bioTextView)
        
        // 配置加载指示器
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        setupConstraints()
        setupLabels()
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        contentView.addSubview(textField)
    }
    
    private func setupLabels() {
        let usernameLabel = createLabel(text: "用户名")
        let emailLabel = createLabel(text: "邮箱")
        let bioLabel = createLabel(text: "个人简介")
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(bioLabel)
        
        NSLayoutConstraint.activate([
            // 用户名标签
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 邮箱标签
            emailLabel.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 个人简介标签
            bioLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 内容视图约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 用户名输入框约束
            usernameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            usernameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // 邮箱输入框约束
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // 个人简介输入框约束
            bioTextView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 50),
            bioTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bioTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bioTextView.heightAnchor.constraint(equalToConstant: 120),
            bioTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // 加载指示器约束
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // 添加点击手势隐藏键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func loadUserProfile() {
        userProfile = ProfileModuleManager.UserProfileManager.shared.getCurrentProfile()
        updateUI()
    }
    
    private func updateUI() {
        guard let profile = userProfile else { return }
        
        usernameTextField.text = profile.username
        emailTextField.text = profile.email
        bioTextView.text = profile.bio
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        print("ProfileEditViewController: 取消编辑")
        Router.pop()
    }
    
    @objc private func saveButtonTapped() {
        guard validateInput() else { return }
        
        print("ProfileEditViewController: 保存用户资料")
        
        // 显示加载状态
        loadingIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // 创建更新后的用户资料
        guard var updatedProfile = userProfile else { return }
        updatedProfile.username = usernameTextField.text ?? ""
        updatedProfile.email = emailTextField.text ?? ""
        updatedProfile.bio = bioTextView.text
        
        // 保存用户资料
        ProfileModuleManager.UserProfileManager.shared.updateProfile(updatedProfile) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                
                if success {
                    print("ProfileEditViewController: 保存成功")
                    self?.showSuccessAlert()
                } else {
                    print("ProfileEditViewController: 保存失败 - \(error?.localizedDescription ?? "未知错误")")
                    self?.showErrorAlert(error?.localizedDescription ?? "保存失败")
                }
            }
        }
    }
    
    private func validateInput() -> Bool {
        guard let username = usernameTextField.text, !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            showErrorAlert("请输入用户名")
            return false
        }
        
        guard let email = emailTextField.text, !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            showErrorAlert("请输入邮箱")
            return false
        }
        
        // 简单的邮箱格式验证
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            showErrorAlert("请输入有效的邮箱地址")
            return false
        }
        
        return true
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "成功", message: "用户资料已保存", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            Router.pop()
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Routable
extension ProfileEditViewController {
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return ProfileEditViewController()
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.failure(RouterError.actionNotFound(action)))
    }
}