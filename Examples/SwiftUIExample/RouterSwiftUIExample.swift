import SwiftUI
import RouterKit

// SwiftUI视图控制器包装器
class SwiftUIViewController<Content: View>: UIViewController, Routable {
    private let content: (RouterParameters?) -> Content
    
    init(@ViewBuilder content: @escaping (RouterParameters?) -> Content) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewController(with parameters: RouterParameters?) -> UIViewController {
        return UIHostingController(rootView: content(parameters))
    }
}

// 主视图
struct ContentView: View {
    @StateObject private var routerState = RouterState()

    var body: some View {
        NavigationStack(path: $routerState.path) {
            VStack(spacing: 20) {
                Text("SwiftUI Router Example")
                    .font(.title)

                Button("Go to Detail") {
                    Router.push(to: "/detail")
                }

                Button("Go to Detail with ID 123") {
                    Router.push(to: "/detail/123")
                }

                Button("Go to Settings") {
                    Router.push(to: "/settings")
                }
            }
            .navigationDestination(for: String.self) { path in
                routerState.destinationView(for: path)
            }
        }
        .environmentObject(routerState)
    }
}

// 路由状态管理
class RouterState: ObservableObject {
    @Published var path: [String] = []

    func destinationView(for path: String) -> some View {
        switch path {
        case "detail":
            return AnyView(DetailView())
        case let id where id.hasPrefix("detail/"):
            let itemId = id.components(separatedBy: "/").last ?? ""
            return AnyView(DetailView(itemId: itemId))
        case "settings":
            return AnyView(SettingsView())
        default:
            return AnyView(UnknownView())
        }
    }
}

// 详情视图
struct DetailView: View {
    var itemId: String?

    var body: some View {
        VStack {
            if let itemId = itemId {
                Text("Detail View - Item ID: \(itemId)")
            } else {
                Text("Detail View")
            }
            NavigationLink("Go to Sub Detail", destination: SubDetailView())
        }
        .navigationTitle("Detail")
    }
}

// 子详情视图
struct SubDetailView: View {
    var body: some View {
        Text("Sub Detail View")
            .navigationTitle("Sub Detail")
    }
}

// 设置视图
struct SettingsView: View {
    var body: some View {
        Text("Settings View")
            .navigationTitle("Settings")
    }
}

// 未知视图
struct UnknownView: View {
    var body: some View {
        Text("Unknown View")
            .navigationTitle("Unknown")
    }
}

// 应用入口
@main
struct RouterSwiftUIExampleApp: App {
    init() {
        setupRouter()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func setupRouter() {
        Task {
            let router = Router.shared

            do {
                // 注册SwiftUI视图
                try await router.registerRoute("/detail", for: SwiftUIViewController { _ in
                    DetailView()
                }.self)

                try await router.registerRoute("/detail/:id", for: SwiftUIViewController { parameters in
                    let itemId = parameters?.getValue(forKey: "id") as? String
                    return DetailView(itemId: itemId)
                }.self)

                try await router.registerRoute("/settings", for: SwiftUIViewController { _ in
                    SettingsView()
                }.self)
                
                print("SwiftUI routes registered successfully")
            } catch {
                print("Failed to register SwiftUI routes: \(error)")
            }
        }
    }
}
