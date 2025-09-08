//
//  AvatarUploadViewController.swift
//  ProfileModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

public class AvatarUploadViewController: UIViewController, Routable {
    public static func viewController(with parameters: RouterParameters?) -> UIViewController? {
        return AvatarUploadViewController()
    }

    public static func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        // 可以在这里实现登录相关的动作
//        completion(nil, nil)
        completion(.failure(RouterError.actionNotFound(action)))
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let currentAvatarImageView = UIImageView()
    private let newAvatarImageView = UIImageView()
    private let selectPhotoButton = UIButton(type: .system)
    private let takePhotoButton = UIButton(type: .system)
    private let uploadButton = UIButton(type: .system)
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let progressLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private var selectedImage: UIImage?
    private var imagePicker: UIImagePickerController?

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentAvatar()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "更换头像"

        // 设置导航栏
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "取消",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )

        // 配置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 配置当前头像
        setupImageView(currentAvatarImageView, title: "当前头像")

        // 配置新头像
        setupImageView(newAvatarImageView, title: "新头像")
        newAvatarImageView.backgroundColor = .systemGray6

        // 配置选择照片按钮
        setupButton(selectPhotoButton, title: "从相册选择", backgroundColor: .systemBlue)
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoButtonTapped), for: .touchUpInside)

        // 配置拍照按钮
        setupButton(takePhotoButton, title: "拍照", backgroundColor: .systemGreen)
        takePhotoButton.addTarget(self, action: #selector(takePhotoButtonTapped), for: .touchUpInside)

        // 配置上传按钮
        setupButton(uploadButton, title: "上传头像", backgroundColor: .systemOrange)
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        uploadButton.isEnabled = false
        uploadButton.alpha = 0.5

        // 配置进度条
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        contentView.addSubview(progressView)

        // 配置进度标签
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "上传中..."
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.textColor = .secondaryLabel
        progressLabel.isHidden = true
        contentView.addSubview(progressLabel)

        // 配置加载指示器
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        setupConstraints()
        setupLabels()
    }

    private func setupImageView(_ imageView: UIImageView, title: String) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        contentView.addSubview(imageView)
    }

    private func setupButton(_ button: UIButton, title: String, backgroundColor: UIColor) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(button)
    }

    private func setupLabels() {
        let currentLabel = createLabel(text: "当前头像")
        let newLabel = createLabel(text: "新头像")

        contentView.addSubview(currentLabel)
        contentView.addSubview(newLabel)

        NSLayoutConstraint.activate([
            // 当前头像标签
            currentLabel.bottomAnchor.constraint(equalTo: currentAvatarImageView.topAnchor, constant: -8),
            currentLabel.centerXAnchor.constraint(equalTo: currentAvatarImageView.centerXAnchor),

            // 新头像标签
            newLabel.bottomAnchor.constraint(equalTo: newAvatarImageView.topAnchor, constant: -8),
            newLabel.centerXAnchor.constraint(equalTo: newAvatarImageView.centerXAnchor)
        ])
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .center
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

            // 当前头像约束
            currentAvatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            currentAvatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60),
            currentAvatarImageView.widthAnchor.constraint(equalToConstant: 120),
            currentAvatarImageView.heightAnchor.constraint(equalToConstant: 120),

            // 新头像约束
            newAvatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            newAvatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60),
            newAvatarImageView.widthAnchor.constraint(equalToConstant: 120),
            newAvatarImageView.heightAnchor.constraint(equalToConstant: 120),

            // 选择照片按钮约束
            selectPhotoButton.topAnchor.constraint(equalTo: currentAvatarImageView.bottomAnchor, constant: 40),
            selectPhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectPhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            selectPhotoButton.heightAnchor.constraint(equalToConstant: 50),

            // 拍照按钮约束
            takePhotoButton.topAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: 16),
            takePhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            takePhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 50),

            // 上传按钮约束
            uploadButton.topAnchor.constraint(equalTo: takePhotoButton.bottomAnchor, constant: 32),
            uploadButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uploadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            uploadButton.heightAnchor.constraint(equalToConstant: 50),

            // 进度条约束
            progressView.topAnchor.constraint(equalTo: uploadButton.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 进度标签约束
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

            // 加载指示器约束
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadCurrentAvatar() {
        guard let profile = ProfileModuleManager.UserProfileManager.shared.getCurrentProfile() else { return }

        if let _ = profile.avatar {
            // 实际项目中这里应该加载网络图片
            currentAvatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            currentAvatarImageView.tintColor = .systemBlue
        } else {
            currentAvatarImageView.image = UIImage(systemName: "person.circle.fill")
            currentAvatarImageView.tintColor = .systemGray3
        }
    }

    @objc private func selectPhotoButtonTapped() {
        print("AvatarUploadViewController: 选择照片")
        presentImagePicker(sourceType: .photoLibrary)
    }

    @objc private func takePhotoButtonTapped() {
        print("AvatarUploadViewController: 拍照")
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showErrorAlert("相机不可用")
            return
        }
        presentImagePicker(sourceType: .camera)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = sourceType
        imagePicker?.allowsEditing = true

        if let picker = imagePicker {
            present(picker, animated: true)
        }
    }

    @objc private func uploadButtonTapped() {
        guard let image = selectedImage else { return }

        print("AvatarUploadViewController: 开始上传头像")

        // 显示上传进度
        progressView.isHidden = false
        progressLabel.isHidden = false
        uploadButton.isEnabled = false

        // 模拟上传进度
        simulateUploadProgress { [weak self] in
            self?.uploadAvatar(image)
        }
    }

    private func simulateUploadProgress(completion: @escaping () -> Void) {
        progressView.progress = 0.0

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.progressView.progress += 0.05

            if self.progressView.progress >= 1.0 {
                timer.invalidate()
                completion()
            }
        }
    }

    private func uploadAvatar(_ image: UIImage) {
        ProfileModuleManager.UserProfileManager.shared.uploadAvatar(image) { [weak self] success, _, error in
            DispatchQueue.main.async {
                self?.progressView.isHidden = true
                self?.progressLabel.isHidden = true
                self?.uploadButton.isEnabled = true

                if success {
                    print("AvatarUploadViewController: 头像上传成功")
                    self?.showSuccessAlert()
                } else {
                    print("AvatarUploadViewController: 头像上传失败 - \(error?.localizedDescription ?? "未知错误")")
                    self?.showErrorAlert(error?.localizedDescription ?? "上传失败")
                }
            }
        }
    }

    @objc private func cancelButtonTapped() {
        print("AvatarUploadViewController: 取消上传")
        Router.pop()
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(title: "成功", message: "头像已更新", preferredStyle: .alert)
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
}

// MARK: - UIImagePickerControllerDelegate
extension AvatarUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        var selectedImage: UIImage?

        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }

        if let image = selectedImage {
            self.selectedImage = image
            newAvatarImageView.image = image

            // 启用上传按钮
            uploadButton.isEnabled = true
            uploadButton.alpha = 1.0
        }

        picker.dismiss(animated: true)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
