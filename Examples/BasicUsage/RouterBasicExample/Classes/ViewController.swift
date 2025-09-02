import UIKit
import RouterKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        // 创建按钮
        let detailButton = UIButton(type: .system)
        detailButton.setTitle("Go to Detail", for: .normal)
        detailButton.addTarget(self, action: #selector(goToDetail), for: .touchUpInside)
        detailButton.frame = CGRect(x: 100, y: 200, width: 200, height: 44)
        view.addSubview(detailButton)

        let parameterButton = UIButton(type: .system)
        parameterButton.setTitle("Go to Detail with ID 123", for: .normal)
        parameterButton.addTarget(self, action: #selector(goToDetailWithParameter), for: .touchUpInside)
        parameterButton.frame = CGRect(x: 100, y: 260, width: 250, height: 44)
        view.addSubview(parameterButton)

        let deepLinkButton = UIButton(type: .system)
        deepLinkButton.setTitle("Test Deep Link", for: .normal)
        deepLinkButton.addTarget(self, action: #selector(testDeepLink), for: .touchUpInside)
        deepLinkButton.frame = CGRect(x: 100, y: 320, width: 200, height: 44)
        view.addSubview(deepLinkButton)
    }

    @objc private func goToDetail() {
        // 无参数路由
        Router.shared.navigate(to: "router://home")
    }

    @objc private func goToDetailWithParameter() {
        // 带参数路由
        Router.shared.navigate(to: "router://detail/123")
    }

    @objc private func testDeepLink() {
        // 测试深度链接
        if let url = URL(string: "router://detail/456") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
