//
//  RouterLogger.swift
//  CoreModuleTest
//
//  Created by fengming on 2025/8/4.
//

import Foundation

/// 日志级别
public enum LogLevel: Int, Comparable {
    case verbose  // 详细调试信息
    case debug    // 调试信息
    case info     // 普通信息
    case warning  // 警告
    case error    // 错误
    
    // 实现比较运算符，用于日志级别过滤
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// 日志输出协议，支持自定义日志输出方式
protocol LogOutput {
    func log(_ message: String, level: LogLevel, file: String, line: Int, function: String)
}

/// 控制台日志输出
class ConsoleLogOutput: LogOutput {
    func log(_ message: String, level: LogLevel, file: String, line: Int, function: String) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = Date().toString(format: "yyyy-MM-dd HH:mm:ss.SSS")
        print("\(timestamp) [\(level)] \(fileName):\(line)\n \(function) - \(message)\n")
    }
}

/// 文件日志输出（支持按日期轮转）
class FileLogOutput: LogOutput {
    private let logDirectory: URL
    private let maxFileSize: UInt64 = 10 * 1024 * 1024 // 10MB
    
    init() {
        // 获取文档目录中的日志文件夹路径
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        logDirectory = documentsDir.appendingPathComponent("Logs")
        
        // 创建日志文件夹（如果不存在）
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
    }
    
    func log(_ message: String, level: LogLevel, file: String, line: Int, function: String) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = Date().toString(format: "yyyy-MM-dd HH:mm:ss.SSS")
        let logLine = "\(timestamp) [\(level)] \(fileName):\(line) \(function) - \(message)\n"
        
        // 异步写入日志
        DispatchQueue.global().async {
            if let data = logLine.data(using: .utf8) {
                let logFileURL = self.getLogFileURL()
                
                // 检查文件大小，如果超过限制则创建新文件
                self.checkAndRotateLogFile(logFileURL)
                
                if FileManager.default.fileExists(atPath: logFileURL.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } else {
                    try? data.write(to: logFileURL)
                }
            }
        }
    }
    
    // 获取当前日志文件URL（按日期命名）
    private func getLogFileURL() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        return logDirectory.appendingPathComponent("router_log_\(dateString).txt")
    }
    
    // 检查并轮转日志文件
    private func checkAndRotateLogFile(_ fileURL: URL) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? UInt64, fileSize >= maxFileSize {
                // 文件超过大小限制，重命名现有文件
                let timestamp = Date().toString(format: "yyyy-MM-dd_HH-mm-ss")
                let rotatedFileName = "router_log_\(timestamp).txt"
                let rotatedFileURL = logDirectory.appendingPathComponent(rotatedFileName)
                try FileManager.default.moveItem(at: fileURL, to: rotatedFileURL)
            }
        } catch {
            print("Failed to check log file size: \(error)")
        }
    }
}

/// 远程日志输出
class RemoteLogOutput: LogOutput {
    private let serverURL: URL
    private let apiKey: String?
    private let queue = DispatchQueue(label: "com.routerkit.remoteLog")
    private var logBuffer: [String] = []
    private let batchSize = 10
    private var isUploading = false
    
    init(serverURL: URL, apiKey: String? = nil) {
        self.serverURL = serverURL
        self.apiKey = apiKey
    }
    
    func log(_ message: String, level: LogLevel, file: String, line: Int, function: String) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = Date().toString(format: "yyyy-MM-dd HH:mm:ss.SSS")
        let logLine = "\(timestamp) [\(level)] \(fileName):\(line) \(function) - \(message)"
        
        // 添加到缓冲区
        queue.async {
            self.logBuffer.append(logLine)
            // 达到批量上传阈值时上传
            if self.logBuffer.count >= self.batchSize && !self.isUploading {
                self.uploadLogs()
            }
        }
    }
    
    // 上传日志到服务器
    private func uploadLogs() {
        queue.async {
            guard !self.logBuffer.isEmpty else { return }
            
            self.isUploading = true
            let logsToUpload = self.logBuffer
            self.logBuffer.removeAll()
            
            // 构建请求
            var request = URLRequest(url: self.serverURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // 添加API密钥（如果有）
            if let apiKey = self.apiKey {
                request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            }
            
            // 准备日志数据
            let logData = ["logs": logsToUpload]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: logData)
            } catch {
                print("Failed to serialize log data: \(error)")
                self.isUploading = false
                return
            }
            
            // 发送请求
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                self.queue.async {
                    self.isUploading = false
                    
                    if let error = error {
                        print("Failed to upload logs: \(error)")
                        // 失败时将日志重新添加到缓冲区
                        self.logBuffer.insert(contentsOf: logsToUpload, at: 0)
                    } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                        print("Log upload failed with status code: \(httpResponse.statusCode)")
                        // 失败时将日志重新添加到缓冲区
                        self.logBuffer.insert(contentsOf: logsToUpload, at: 0)
                    }
                    
                    // 如果还有未上传的日志，继续上传
                    if self.logBuffer.count >= self.batchSize {
                        self.uploadLogs()
                    }
                }
            }
            task.resume()
        }
    }
}

// MARK: - 日志管理器
public actor RouterLogger {
    public static let shared = RouterLogger()
    private init() {}

    private var _minimumLevel: LogLevel = .info  // 最小日志级别
    private var _outputs: [LogOutput] = [ConsoleLogOutput()]  // 日志输出渠道

    public var minimumLevel: LogLevel {
        get {
            _minimumLevel
        }
        set {
            _minimumLevel = newValue
        }
    }

    /// 添加日志输出渠道
    public func addOutput(_ output: LogOutput) {
        _outputs.append(output)
    }

    /// 设置最小日志级别
    public func setMinimumLogLevel(_ level: LogLevel) async {
        minimumLevel = level
        await log("日志级别已设置为: \(level)", level: .info)
    }

    /// 从远程配置更新日志级别
    /// - Parameter configURL: 远程配置URL
    public func updateLogLevelFromRemoteConfig(configURL: URL) {
        URLSession.shared.dataTask(with: configURL) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch remote log config: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let config = try JSONSerialization.jsonObject(with: data) as? [String: String],
                   let logLevelString = config["logLevel"],
                   let logLevel = LogLevel(rawValue: Int(logLevelString) ?? -1) {
                    Task {
                        await RouterLogger.shared.setMinimumLogLevel(logLevel)
                    }
                }
            } catch {
                print("Failed to parse remote log config: \(error)")
            }
        }.resume()
    }

    /// 输出日志
    public func log(_ message: String,
             level: LogLevel,
             file: String = #file,
             line: Int = #line,
             function: String = #function) async {
        // 过滤低于最小级别的日志
        guard level >= minimumLevel else { return }

        // 读取当前输出渠道的快照
        let outputs = _outputs

        // 向所有输出渠道发送日志
        outputs.forEach {
            $0.log(message, level: level, file: file, line: line, function: function)
        }
    }
}

// MARK: - 日期格式化扩展
extension Date {
    /// 转换为指定格式的字符串
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}

// MARK: - LogLevel扩展（便于打印）
extension LogLevel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
}
