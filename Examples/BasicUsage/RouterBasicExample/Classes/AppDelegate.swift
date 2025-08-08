import UIKit
import RouterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var router: Router!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化路由
        router = Router()
        setupRoutes()

        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = ViewController()
        window?.rootViewController = UINavigationController(rootViewController: rootVC)
        window?.makeKeyAndVisible()

        return true
    }

    private func setupRoutes() {
        // 注册路由
        router.register("router://home") { context in
            return ViewController()
        }

        router.register("router://detail/:id") { context in
            guard let id = context.parameters["id"] else { return nil }
            let detailVC = DetailViewController()
            detailVC.itemId = id
            return detailVC
        }
    }

    // 处理外部链接
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return router.navigate(to: url)
    }
}