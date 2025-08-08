//
//  Message.swift
//  MessageModule
//
//  Created by fengming on 2025/8/8.
//

import Foundation
/// 消息模型
struct Message: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let content: String
    public let sender: String
    public let timestamp: Date
    
    init(id: Int, title: String, content: String, sender: String, timestamp: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
}
