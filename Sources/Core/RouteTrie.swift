//  RouteTrie.swift
//  RouterKit
//
//  Created by fengming on 2025/8/10.
//

import Foundation

// MARK: - 路由Trie树节点
class RouteTrieNode {
    var children: [String: RouteTrieNode] = [:]
    var parameterChild: RouteTrieNode?
    var wildcardChild: RouteTrieNode?
    var regexChild: (node: RouteTrieNode, pattern: String)?
    var routePatterns: [(pattern: RoutePattern, priority: Int)] = []  // 存储模式和优先级
    var isEndOfPattern: Bool = false
}

// MARK: - 路由Trie树
public actor RouteTrie {
    private let root = RouteTrieNode()

    // MARK: - 插入路由模式
    func insert(_ pattern: RoutePattern, priority: Int = 0) {
        var currentNode = root
        let components = pattern.components

        for component in components {
            switch component {
            case .literal(let value):
                if currentNode.children[value] == nil {
                    currentNode.children[value] = RouteTrieNode()
                }
                currentNode = currentNode.children[value]!

            case .parameter(_, _):
                if currentNode.parameterChild == nil {
                    currentNode.parameterChild = RouteTrieNode()
                }            
                currentNode = currentNode.parameterChild!

            case .regex(let regex, _):
                let pattern = regex.pattern
                if currentNode.regexChild?.pattern != pattern {
                    currentNode.regexChild = (RouteTrieNode(), pattern)
                }            
                currentNode = currentNode.regexChild!.node
            case .wildcard:
                break
            }
        }

        currentNode.isEndOfPattern = true
        
        // 检查模式是否已存在
        if let existingIndex = currentNode.routePatterns.firstIndex(where: { $0.pattern == pattern }) {
            currentNode.routePatterns.remove(at: existingIndex)
        }
        
        // 插入新模式并按优先级排序（降序）
        currentNode.routePatterns.append((pattern: pattern, priority: priority))
        currentNode.routePatterns.sort { $0.priority > $1.priority }
    }

    // MARK: - 查找路由模式
    func find(_ pathComponents: [String]) -> (pattern: RoutePattern, parameters: RouterParameters)? {
        var parameters: RouterParameters = [:]
        var bestMatch: (pattern: RoutePattern, parameters: RouterParameters)?

        findBestMatch(pathComponents, index: 0, node: root, parameters: &parameters, bestMatch: &bestMatch)
        return bestMatch
    }

    // MARK: - 递归查找最佳匹配
    private func findBestMatch(_ components: [String], index: Int, node: RouteTrieNode, parameters: inout RouterParameters, bestMatch: inout (pattern: RoutePattern, parameters: RouterParameters)?) {

        // 已到达路径末尾
        if index == components.count {
            if node.isEndOfPattern && !node.routePatterns.isEmpty {
                // 已按优先级排序，直接取第一个
                let bestPattern = node.routePatterns.first!.pattern
                bestMatch = (bestPattern, parameters)
            }
            return
        }

        let component = components[index]

        // 1. 尝试字面量匹配
        if let childNode = node.children[component] {
            findBestMatch(components, index: index + 1, node: childNode, parameters: &parameters, bestMatch: &bestMatch)
        }

        // 2. 尝试参数匹配
        if let childNode = node.parameterChild {
            // 假设参数组件是RoutePattern中的parameter类型
            // 这里简化处理，实际需要记录参数名称
            parameters["param_\(index)"] = component
            findBestMatch(components, index: index + 1, node: childNode, parameters: &parameters, bestMatch: &bestMatch)
            parameters.removeValue(forKey: "param_\(index)")
        }

        // 3. 尝试正则表达式匹配
        if let (childNode, regexPattern) = node.regexChild {
            do {
                let regex = try NSRegularExpression(pattern: regexPattern)
                let matches = regex.matches(in: component, range: NSRange(location: 0, length: component.utf16.count))
                if !matches.isEmpty {
                    findBestMatch(components, index: index + 1, node: childNode, parameters: &parameters, bestMatch: &bestMatch)
                }
            } catch {
                // 正则表达式错误，忽略
            }
        }

        // 4. 尝试通配符匹配
        if let childNode = node.wildcardChild {
            findBestMatch(components, index: index + 1, node: childNode, parameters: &parameters, bestMatch: &bestMatch)
        }
    }

    // MARK: - 移除路由模式
    func remove(_ pattern: RoutePattern) {
        let components = pattern.components
        _ = removeNode(components, index: 0, node: root, pattern: pattern)
    }

    // MARK: - 递归移除节点
    private func removeNode(_ components: [RoutePattern.Component], index: Int, node: RouteTrieNode, pattern: RoutePattern) -> Bool {
        if index == components.count {
            if node.isEndOfPattern {
                // 移除特定模式
                node.routePatterns.removeAll { $0.pattern == pattern }
                
                // 如果没有模式了，标记为非结束节点
                if node.routePatterns.isEmpty {
                    node.isEndOfPattern = false
                    // 如果没有子节点，可以删除此节点
                    return node.children.isEmpty && node.parameterChild == nil && 
                           node.wildcardChild == nil && node.regexChild == nil
                }
            }
            return false
        }

        let component = components[index]
        var shouldDeleteChild = false

        // 检查组件类型并相应处理
        switch component {
        case .literal(let value):
            if let childNode = node.children[value] {
                shouldDeleteChild = removeNode(components, index: index + 1, node: childNode, pattern: pattern)
                if shouldDeleteChild {
                    node.children.removeValue(forKey: value)
                }
            }
        case .parameter(_, _):
            if let childNode = node.parameterChild {
                shouldDeleteChild = removeNode(components, index: index + 1, node: childNode, pattern: pattern)
                if shouldDeleteChild {
                    node.parameterChild = nil
                }
            }
        case .wildcard:
            if let childNode = node.wildcardChild {
                shouldDeleteChild = removeNode(components, index: index + 1, node: childNode, pattern: pattern)
                if shouldDeleteChild {
                    node.wildcardChild = nil
                }
            }
        case .regex(let regex, _):
            let regexPattern = regex.pattern
            if let (childNode, childPattern) = node.regexChild, childPattern == regexPattern {
                shouldDeleteChild = removeNode(components, index: index + 1, node: childNode, pattern: pattern)
                if shouldDeleteChild {
                    node.regexChild = nil
                }
            }
        }

        // 如果当前节点没有子节点且不是模式结尾，可以删除
        return node.children.isEmpty && node.parameterChild == nil && 
               node.wildcardChild == nil && node.regexChild == nil && !node.isEndOfPattern
    }
}
