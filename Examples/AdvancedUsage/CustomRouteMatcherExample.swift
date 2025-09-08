import RouterKit

// 自定义路由匹配器 - 支持正则表达式
class RegexRouteMatcher: CustomRouteMatcher {
    let pattern: String
    let regex: NSRegularExpression

    init(pattern: String) {
        self.pattern = pattern
        do {
            self.regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            fatalError("Invalid regex pattern: \(error)")
        }
    }

    func matches(_ url: URL) -> Bool {
        let path = url.path
        let range = NSRange(location: 0, length: path.utf16.count)
        return regex.firstMatch(in: path, options: [], range: range) != nil
    }

    func extractParameters(from url: URL) -> [String: String] {
        let path = url.path
        let range = NSRange(location: 0, length: path.utf16.count)
        guard let match = regex.firstMatch(in: path, options: [], range: range) else {
            return [:]
        }

        var parameters: [String: String] = [:]
        // 提取捕获组参数
        for i in 1..<match.numberOfRanges {
            let name = "param\(i)"
            let range = match.range(at: i)
            if range.location != NSNotFound {
                let start = path.index(path.startIndex, offsetBy: range.location)
                let end = path.index(start, offsetBy: range.length)
                parameters[name] = String(path[start..<end])
            }
        }

        return parameters
    }
}

// 创建支持自定义匹配器的视图控制器
class UserProfileViewController: UIViewController, Routable {
    let userId: String?

    init(userId: String?) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func viewController(with parameters: RouterParameters?) -> UIViewController {
        let userId = parameters?.getValue(forKey: "param1") as? String
        return UserProfileViewController(userId: userId)
    }
}

// 使用示例
func setupCustomRouteMatcher() async {
    let router = Router.shared

    // 创建并注册自定义匹配器
    let regexMatcher = RegexRouteMatcher(pattern: "/user/(\\d+)/profile")

    // 使用新的API注册路由
    do {
        try await router.registerRoute(matcher: regexMatcher, for: UserProfileViewController.self)
        print("Custom route matcher registered successfully")
    } catch {
        print("Failed to register custom route matcher: \(error)")
    }

    // 测试匹配和导航
    let url1 = URL(string: "router://app/user/123/profile")!
    let url2 = URL(string: "router://app/user/abc/profile")!

    print("URL1 matches: \(await router.canNavigate(to: url1))") // true
    print("URL2 matches: \(await router.canNavigate(to: url2))") // false

    // 执行导航
    Router.push(to: "/user/123/profile") { result in
        switch result {
        case .success:
            print("Navigation successful")
        case .failure(let error):
            print("Navigation failed: \(error)")
        }
    }
}
