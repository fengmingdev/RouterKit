import SwiftUI
import RouterKit

// SwiftUI视图注册扩展
 extension Router {
    func registerSwiftUI<Content: View>(_ pattern: String, @ViewBuilder content: @escaping (RouteContext) -> Content) {
        register(pattern) { context in
            UIHostingController(rootView: content(context))
        }
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
                    Router.shared.navigate(to: "router://detail")
                }

                Button("Go to Detail with ID 123") {
                    Router.shared.navigate(to: "router://detail/123")
                }

                Button("Go to Settings") {
                    Router.shared.navigate(to: "router://settings")
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
        let router = Router.shared

        // 注册SwiftUI视图
        router.registerSwiftUI("router://detail") { _ in
            DetailView()
        }

        router.registerSwiftUI("router://detail/:id") { context in
            DetailView(itemId: context.parameters["id"])
        }

        router.registerSwiftUI("router://settings") { _ in
            SettingsView()
        }
    }
}
