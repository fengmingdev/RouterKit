//
//  ProfileViewController.swift
//  ProfileModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

public class ProfileViewController: UIViewController, Routable {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let emailLabel = UILabel()
    private let bioLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let changeAvatarButton = UIButton(type: .system)
    
    private var userProfile: ProfileModuleManager.UserProfile?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProfile()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次显示时刷新数据
        loadUserProfile()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "个人资料"
        
        // 设置导航栏
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "编辑",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        
        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 配置头像
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray3
        contentView.addSubview(avatarImageView)
        
        // 配置用户名标签
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        usernameLabel.textAlignment = .center
        usernameLabel.textColor = .label
        contentView.addSubview(usernameLabel)
        
        // 配置邮箱标签
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textAlignment = .center
        emailLabel.textColor = .secondaryLabel
        contentView.addSubview(emailLabel)
        
        // 配置个人简介标签
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.font = UIFont.systemFont(ofSize: 14)
        bioLabel.textAlignment = .center
        bioLabel.textColor = .secondaryLabel
        bioLabel.numberOfLines = 0
        contentView.addSubview(bioLabel)
        
        // 配置更换头像按钮
        changeAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        changeAvatarButton.setTitle("更换头像", for: .normal)
        changeAvatarButton.backgroundColor = .systemBlue
        changeAvatarButton.setTitleColor(.white, for: .normal)
        changeAvatarButton.layer.cornerRadius = 8
        changeAvatarButton.addTarget(self, action: #selector(changeAvatarButtonTapped), for: .touchUpInside)
        contentView.addSubview(changeAvatarButton)
        
        // 配置编辑按钮
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("编辑资料", for: .normal)
        editButton.backgroundColor = .systemGreen
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 8
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        contentView.addSubview(editButton)
        
        setupConstraints()
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
            
            // 头像约束
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // 用户名约束
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 邮箱约束
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 个人简介约束
            bioLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 更换头像按钮约束
            changeAvatarButton.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 40),
            changeAvatarButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            changeAvatarButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            changeAvatarButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 编辑按钮约束
            editButton.topAnchor.constraint(equalTo: changeAvatarButton.bottomAnchor, constant: 16),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func loadUserProfile() {
        userProfile = ProfileModuleManager.UserProfileManager.shared.getCurrentProfile()
        updateUI()
    }
    
    private func updateUI() {
        guard let profile = userProfile else { return }
        
        usernameLabel.text = profile.username
        emailLabel.text = profile.email
        bioLabel.text = profile.bio ?? "暂无个人简介"
        
        // 加载头像（这里简化处理）
        if let _ = profile.avatar {
            // 实际项目中这里应该加载网络图片
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarImageView.tintColor = .systemBlue
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
        }
    }
    
    @objc private func editButtonTapped() {
        print("ProfileViewController: 跳转到编辑页面")
        Router.push(to: "/ProfileModule/edit")
    }
    
    @objc private func changeAvatarButtonTapped() {
        print("ProfileViewController: 跳转到头像上传页面")
        Router.push(to: "/ProfileModule/avatar")
    }
}

// MARK: - Routable
extension ProfileViewController {
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return ProfileViewController()
    }
    
    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        completion(.failure(RouterError.actionNotFound(action)))
    }
}