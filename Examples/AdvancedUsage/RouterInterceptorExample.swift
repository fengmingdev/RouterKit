import RouterKit
import UIKit

// 认证拦截器
class AuthInterceptor: RouterInterceptor {
    var priority: Int = 100

    func shouldNavigate(to url: URL, context: RouteContext) -> Bool {
        // 检查是否需要认证
        if url.path.hasPrefix("/protected") {
            // 检查用户是否已登录
            if !isUserLoggedIn() {
                // 未登录，跳转到登录页面
                let loginVC = LoginViewController()
                if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                    navController.pushViewController(loginVC, animated: true)
                }
                return false
            }
        }
        return true
    }

    func willNavigate(to url: URL, context: RouteContext) {
        print("Will navigate to: \(url)")
        // 可以在这里添加加载指示器
    }

    func didNavigate(to url: URL, context: RouteContext) {
        print("Did navigate to: \(url)")
        // 可以在这里移除加载指示器
    }

    func navigationFailed(to url: URL, error: Error) {
        print("Navigation failed to \(url): \(error)")
        // 显示错误信息
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if let topVC = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() {
            topVC.present(alert, animated: true, completion: nil)
        }
    }

    private func isUserLoggedIn() -> Bool {
        // 实际应用中这里应该检查用户登录状态
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
}

// 登录视图控制器
class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginButton.frame = CGRect(x: 100, y: 200, width: 200, height: 44)
        view.addSubview(loginButton)
    }

    @objc private func login() {
        // 模拟登录
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        navigationController?.popViewController(animated: true)
    }
}

// UIViewController扩展，用于获取最顶层的视图控制器
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? self
        }
        if let tabBar = self as? UITabBarController {
            return tabBar.selectedViewController?.topMostViewController() ?? self
        }
        return self
    }
}

// 使用示例
func setupInterceptor() {
    let router = Router()
    // 添加拦截器
    router.addInterceptor(AuthInterceptor())

    // 注册路由
    router.register("router://protected/content") { _ in
        return ProtectedContentViewController()
    }
}

// 受保护的内容视图控制器
class ProtectedContentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Protected Content"
        view.backgroundColor = .white
        let label = UILabel(frame: CGRect(x: 50, y: 200, width: 300, height: 44))
        label.text = "This is protected content"
        view.addSubview(label)
    }
}