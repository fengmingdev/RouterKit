//
//  ParameterPassingModule.swift
//  ParameterPassingModule
//
//  Created by RouterKit Example on 2025/1/23.
//

import UIKit
import RouterKit

/// 参数传递示例模块
public class ParameterPassingModule: ModuleProtocol {
    public var moduleName: String = "ParameterPassingModule"
    public var dependencies: [ModuleDependency] = []
    public var lastUsedTime: Date = Date()

    public required init() {}

    public func load(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await registerRoutes()
                completion(true)
            } catch {
                print("ParameterPassingModule: 路由注册失败 - \(error)")
                completion(false)
            }
        }
    }

    public func unload() {
        print("ParameterPassingModule unloaded")
    }

    public func suspend() {
        print("ParameterPassingModule suspended")
    }

    public func resume() {
        lastUsedTime = Date()
        print("ParameterPassingModule resumed")
    }

    func registerRoutes() async throws {
        print("ParameterPassingModule: 开始注册路由")

        // 基础参数传递示例
        try await Router.shared.registerRoute("/ParameterPassingModule/basic", for: BasicParameterViewController.self)
            
        try await Router.shared.registerRoute("/ParameterPassingModule/complex", for: ComplexObjectViewController.self)
        
        try await Router.shared.registerRoute("/ParameterPassingModule/callback", for: CallbackViewController.self)
        
        try await Router.shared.registerRoute("/ParameterPassingModule/global", for: GlobalStateViewController.self)
        
        try await Router.shared.registerRoute("/ParameterPassingModule/dataflow", for: DataFlowViewController.self)

        print("ParameterPassingModule: 路由注册完成")
    }

    func performAction(_ action: String, parameters: RouterParameters?, completion: @escaping RouterCompletion) {
        // 实现模块动作处理
        completion(.failure(RouterError.actionNotFound(action)))
    }
}

// MARK: - 数据模型

/// 用户信息模型
struct UserInfo: Codable {
    let id: Int
    let name: String
    let email: String
    let avatar: String?
    let age: Int?
    let bio: String?
    let isVIP: Bool
    let address: Address?

    init(id: Int, name: String, email: String, avatar: String? = nil, age: Int? = nil, bio: String? = nil, isVIP: Bool = false, address: Address? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.avatar = avatar
        self.age = age
        self.bio = bio
        self.isVIP = isVIP
        self.address = address
    }
}

/// 产品信息模型
struct ProductInfo: Codable {
    let id: String
    let title: String
    let name: String
    let description: String
    let price: Double
    let category: String
    let images: [String]
    let inStock: Bool
    let stock: Int
    let tags: [String]

    init(id: String, title: String, description: String, price: Double, category: String, images: [String] = [], inStock: Bool = true, name: String? = nil, stock: Int = 0, tags: [String] = []) {
        self.id = id
        self.title = title
        self.name = name ?? title
        self.description = description
        self.price = price
        self.category = category
        self.images = images
        self.inStock = inStock
        self.stock = stock
        self.tags = tags
    }
}

/// 订单信息模型
struct OrderInfo: Codable {
    let orderId: String
    let userId: Int
    let products: [ProductInfo]
    let items: [ProductInfo]
    let totalAmount: Double
    let status: OrderStatus
    let createdAt: Date
    let shippingAddress: Address?

    init(orderId: String, userId: Int, products: [ProductInfo], totalAmount: Double, status: String, createdAt: Date, shippingAddress: Address?) {
        self.orderId = orderId
        self.userId = userId
        self.products = products
        self.items = products // items和products使用相同的数据
        self.totalAmount = totalAmount
        self.status = OrderStatus(rawValue: status) ?? .pending
        self.createdAt = createdAt
        self.shippingAddress = shippingAddress
    }

    enum OrderStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case confirmed = "confirmed"
        case shipped = "shipped"
        case delivered = "delivered"
        case cancelled = "cancelled"

        var displayName: String {
            switch self {
            case .pending: return "待处理"
            case .confirmed: return "已确认"
            case .shipped: return "已发货"
            case .delivered: return "已送达"
            case .cancelled: return "已取消"
            }
        }
    }
}

/// 地址信息模型
struct Address: Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String

    var fullAddress: String {
        return "\(street), \(city), \(state) \(zipCode), \(country)"
    }
}

// MARK: - 回调类型定义

/// 基础回调类型
typealias BasicCallback = (String) -> Void
typealias DataCallback<T> = (T) -> Void
typealias ResultCallback<T> = (Result<T, Error>) -> Void

/// 用户选择回调
typealias UserSelectionCallback = (UserInfo) -> Void

/// 产品操作回调
typealias ProductActionCallback = (ProductInfo, ProductAction) -> Void

enum ProductAction {
    case view
    case addToCart
    case purchase
    case share
    case favorite
}

/// 表单提交回调
typealias FormSubmissionCallback = (FormData, @escaping (Bool) -> Void) -> Void

/// 成功回调
typealias SuccessCallback = (String) -> Void

/// 失败回调
typealias FailureCallback = (Error) -> Void

/// 完成回调
typealias CompletionCallback = () -> Void

/// 进度回调
typealias ProgressCallback = (Float) -> Void

/// 数据更新回调
typealias DataUpdateCallback = ([String: Any]) -> Void

/// 数据删除回调
typealias DataDeletionCallback = (String) -> Void

/// 数据选择回调
typealias DataSelectionCallback = ([String: Any]) -> Void

struct FormData {
    let fields: [String: Any]
    let timestamp: Date

    init(fields: [String: Any]) {
        self.fields = fields
        self.timestamp = Date()
    }
}

// MARK: - 回调管理

/// 回调管理器
class CallbackManager {
    static let shared = CallbackManager()

    private init() {}

    private var callbacks: [String: Any] = [:]

    func registerCallback<T>(_ key: String, callback: T) {
        callbacks[key] = callback
    }

    func getCallback<T>(_ key: String, as type: T.Type) -> T? {
        return callbacks[key] as? T
    }

    func removeCallback(_ key: String) {
        callbacks.removeValue(forKey: key)
    }

    func clearAllCallbacks() {
        callbacks.removeAll()
    }

    func extractCallbacks(from parameters: [String: Any]?) -> [String: Any] {
        guard let params = parameters else { return [:] }
        var extractedCallbacks: [String: Any] = [:]

        for (key, value) in params {
            if key.hasSuffix("_callback") || key.contains("callback") {
                extractedCallbacks[key] = value
            }
        }

        return extractedCallbacks
    }

    func encodeCallbacks(_ callbacks: [String: Any]) -> [String: Any] {
        return callbacks
    }
}

// MARK: - 全局状态管理

/// 全局状态管理器
class GlobalStateManager {
    static let shared = GlobalStateManager()

    private init() {}

    // MARK: - 用户状态
    private var _currentUser: UserInfo?
    var currentUser: UserInfo? {
        get { _currentUser }
        set {
            _currentUser = newValue
            NotificationCenter.default.post(name: .userStateChanged, object: newValue)
        }
    }

    // MARK: - 购物车状态
    private var _cartItems: [ProductInfo] = []
    var cartItems: [ProductInfo] {
        get { _cartItems }
        set {
            _cartItems = newValue
            NotificationCenter.default.post(name: .cartStateChanged, object: newValue)
        }
    }

    // MARK: - 应用设置
    private var _appSettings: [String: Any] = [:]
    var appSettings: [String: Any] {
        get { _appSettings }
        set {
            _appSettings = newValue
            NotificationCenter.default.post(name: .settingsChanged, object: newValue)
        }
    }

    // MARK: - 便利方法
    func addToCart(_ product: ProductInfo) {
        if !_cartItems.contains(where: { $0.id == product.id }) {
            _cartItems.append(product)
            NotificationCenter.default.post(name: .cartStateChanged, object: _cartItems)
        }
    }

    func removeFromCart(_ productId: String) {
        _cartItems.removeAll { $0.id == productId }
        NotificationCenter.default.post(name: .cartStateChanged, object: _cartItems)
    }

    func clearCart() {
        _cartItems.removeAll()
        NotificationCenter.default.post(name: .cartStateChanged, object: _cartItems)
    }

    func updateSetting(key: String, value: Any) {
        _appSettings[key] = value
        NotificationCenter.default.post(name: .settingsChanged, object: _appSettings)
    }

    func setUserState(_ state: [String: Any]) {
        // 从字典中提取用户信息并设置
        if let userId = state["id"] as? Int,
           let name = state["name"] as? String,
           let email = state["email"] as? String {
            let user = UserInfo(id: userId, name: name, email: email,
                              avatar: state["avatar"] as? String,
                              age: state["age"] as? Int,
                              bio: state["bio"] as? String)
            currentUser = user
        }
    }

    func setAppState(_ state: [String: Any]) {
        _appSettings = state
    }

    // MARK: - Additional State Management Methods

    private var globalStates: [String: Any] = [:]

    func getState(for key: String) -> Any? {
        return globalStates[key]
    }

    func updateStates(_ states: [String: Any]) {
        for (key, value) in states {
            globalStates[key] = value
        }
    }

    func getAllStates() -> [String: Any] {
        return globalStates
    }

    func clearAllStates() {
        globalStates.removeAll()
    }

    func setState(_ value: Any, for key: String) {
        globalStates[key] = value
    }

    func removeState(for key: String) {
        globalStates.removeValue(forKey: key)
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let userStateChanged = Notification.Name("userStateChanged")
    static let cartStateChanged = Notification.Name("cartStateChanged")
    static let settingsChanged = Notification.Name("settingsChanged")
    static let dataFlowUpdate = Notification.Name("dataFlowUpdate")
}

// MARK: - 数据流管理

/// 数据流管理器
class DataFlowManager {
    static let shared = DataFlowManager()

    private init() {}

    private var dataStreams: [String: Any] = [:]
    private var subscribers: [String: [(Any) -> Void]] = [:]

    /// 创建数据流
    func createStream<T>(name: String, initialValue: T) {
        dataStreams[name] = initialValue
        subscribers[name] = []
    }

    /// 订阅数据流
    func subscribe<T>(to streamName: String, callback: @escaping (T) -> Void) {
        if subscribers[streamName] == nil {
            subscribers[streamName] = []
        }

        let wrappedCallback: (Any) -> Void = { value in
            if let typedValue = value as? T {
                callback(typedValue)
            }
        }

        subscribers[streamName]?.append(wrappedCallback)

        // 立即发送当前值
        if let currentValue = dataStreams[streamName] as? T {
            callback(currentValue)
        }
    }

    /// 更新数据流
    func updateStream<T>(name: String, value: T) {
        dataStreams[name] = value

        subscribers[name]?.forEach { callback in
            callback(value)
        }

        // 发送通知
        NotificationCenter.default.post(
            name: .dataFlowUpdate,
            object: nil,
            userInfo: ["streamName": name, "value": value]
        )
    }

    /// 获取数据流当前值
    func getValue<T>(from streamName: String, as type: T.Type) -> T? {
        return dataStreams[streamName] as? T
    }

    /// 移除数据流
    func removeStream(name: String) {
        dataStreams.removeValue(forKey: name)
        subscribers.removeValue(forKey: name)
    }

    func publish(to streamId: String, data: [String: Any]) {
        updateStream(name: streamId, value: data)
    }

    func subscribe(streamId: String, subscriber: String, callback: @escaping ([String: Any]) -> Void) {
        subscribe(to: streamId, callback: callback)
    }

    func unsubscribeAll(for subscriber: Any) {
        // 简单实现，实际应该根据subscriber移除特定订阅
        subscribers.removeAll()
    }

    func clearAll() {
        dataStreams.removeAll()
        subscribers.removeAll()
    }
}

// MARK: - 参数传递工具类

/// 参数传递工具类
class ParameterPassingUtils {

    /// 编码对象为字典
    static func encode<T: Codable>(_ object: T) -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(object)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            print("ParameterPassingUtils: 编码失败 - \(error)")
            return nil
        }
    }

    /// 从字典解码对象
    static func decode<T: Codable>(_ dictionary: [String: Any], as type: T.Type) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            print("ParameterPassingUtils: 解码失败 - \(error)")
            return nil
        }
    }

    /// 安全获取参数
    static func safeGetParameter<T>(_ parameters: [String: Any], key: String, as type: T.Type, defaultValue: T? = nil) -> T? {
        if let value = parameters[key] as? T {
            return value
        }

        if let defaultValue = defaultValue {
            print("ParameterPassingUtils: 参数 '\(key)' 不存在或类型不匹配，使用默认值")
            return defaultValue
        }

        print("ParameterPassingUtils: 参数 '\(key)' 不存在或类型不匹配")
        return nil
    }

    /// 验证必需参数
    static func validateRequiredParameters(_ parameters: [String: Any], requiredKeys: [String]) -> [String] {
        var missingKeys: [String] = []

        for key in requiredKeys {
            if parameters[key] == nil {
                missingKeys.append(key)
            }
        }

        return missingKeys
    }

    /// 从参数中获取对象
    static func getObject<T: Codable>(from parameters: [String: Any], key: String, type: T.Type) -> T? {
        guard let dictionary = parameters[key] as? [String: Any] else {
            print("ParameterPassingUtils: 参数 '\(key)' 不存在或不是字典类型")
            return nil
        }

        return decode(dictionary, as: type)
    }

    /// 编码对象为字典（别名方法）
    static func encodeObject<T: Codable>(_ object: T) -> [String: Any]? {
        return encode(object)
    }

    /// 对象转字典（别名方法）
    static func objectToDictionary<T: Codable>(_ object: T) -> [String: Any]? {
        return encode(object)
    }
}
