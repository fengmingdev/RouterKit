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
                guard let nextNode = currentNode.children[value] else {
                    return // 无法继续插入
                }
                currentNode = nextNode

            case .parameter:
                if currentNode.parameterChild == nil {
                    currentNode.parameterChild = RouteTrieNode()
                }
                guard let paramNode = currentNode.parameterChild else {
                    return // 无法继续插入
                }
                currentNode = paramNode

            case .regex(let regex, _):
                let pattern = regex.pattern
                if currentNode.regexChild?.pattern != pattern {
                    currentNode.regexChild = (RouteTrieNode(), pattern)
                }
                guard let regexNode = currentNode.regexChild?.node else {
                    return // 无法继续插入
                }
                currentNode = regexNode
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

    // MARK: - 查找路由模式（优化版本）
    func find(_ pathComponents: [String]) -> (pattern: RoutePattern, parameters: RouterParameters)? {
        return findInTrie(pathComponents, node: root, componentIndex: 0, parameters: [:])
    }

    // MARK: - 在Trie树中递归查找
    private func findInTrie(_ pathComponents: [String], node: RouteTrieNode, componentIndex: Int, parameters: RouterParameters) -> (pattern: RoutePattern, parameters: RouterParameters)? {
        // 如果已经匹配完所有路径组件
        if componentIndex == pathComponents.count {
            if node.isEndOfPattern && !node.routePatterns.isEmpty {
                // 返回优先级最高的模式（已按优先级排序）
                let bestPattern = node.routePatterns[0]
                return (bestPattern.pattern, parameters)
            }
            return nil
        }

        let currentComponent = pathComponents[componentIndex]
        var bestMatch: (pattern: RoutePattern, parameters: RouterParameters)?
        var bestPriority = Int.min

        // 1. 尝试精确匹配（字面量）
        if let literalChild = node.children[currentComponent] {
            if let match = findInTrie(pathComponents, node: literalChild, componentIndex: componentIndex + 1, parameters: parameters) {
                let priority = getPriorityForPattern(match.pattern, in: literalChild)
                if priority > bestPriority {
                    bestMatch = match
                    bestPriority = priority
                }
            }
        }

        // 2. 尝试参数匹配
        if let paramChild = node.parameterChild {
            // 获取参数名（从第一个匹配的模式中提取）
            if let paramName = getParameterName(from: paramChild, componentIndex: componentIndex) {
                var newParameters = parameters
                newParameters[paramName] = currentComponent

                if let match = findInTrie(pathComponents, node: paramChild, componentIndex: componentIndex + 1, parameters: newParameters) {
                    let priority = getPriorityForPattern(match.pattern, in: paramChild)
                    if priority > bestPriority {
                        bestMatch = match
                        bestPriority = priority
                    }
                }
            }
        }

        // 3. 尝试正则表达式匹配
        if let (regexChild, regexPattern) = node.regexChild {
            if let regex = try? NSRegularExpression(pattern: regexPattern) {
                let range = NSRange(location: 0, length: currentComponent.utf16.count)
                if let match = regex.firstMatch(in: currentComponent, range: range) {
                    var newParameters = parameters

                    // 提取捕获组（如果有的话）
                    if let captureNames = getCaptureNames(from: regexChild, componentIndex: componentIndex) {
                        for (captureIndex, captureName) in captureNames.enumerated() {
                            let captureRange = match.range(at: captureIndex + 1)
                            if captureRange.location != NSNotFound {
                                let captureValue = (currentComponent as NSString).substring(with: captureRange)
                                newParameters[captureName] = captureValue
                            }
                        }
                    }

                    if let trieMatch = findInTrie(pathComponents, node: regexChild, componentIndex: componentIndex + 1, parameters: newParameters) {
                        let priority = getPriorityForPattern(trieMatch.pattern, in: regexChild)
                        if priority > bestPriority {
                            bestMatch = trieMatch
                            bestPriority = priority
                        }
                    }
                }
            }
        }

        // 4. 尝试通配符匹配（优先级最低）
        if let wildcardChild = node.wildcardChild {
            if let match = findInTrie(pathComponents, node: wildcardChild, componentIndex: componentIndex + 1, parameters: parameters) {
                let priority = getPriorityForPattern(match.pattern, in: wildcardChild)
                if priority > bestPriority {
                    bestMatch = match
                    bestPriority = priority
                }
            }
        }

        return bestMatch
    }

    // MARK: - 辅助方法

    /// 获取模式的优先级
    private func getPriorityForPattern(_ pattern: RoutePattern, in node: RouteTrieNode) -> Int {
        return node.routePatterns.first { $0.pattern == pattern }?.priority ?? Int.min
    }

    /// 从节点中获取参数名
    private func getParameterName(from node: RouteTrieNode, componentIndex: Int) -> String? {
        for (pattern, _) in node.routePatterns {
            if componentIndex < pattern.components.count {
                if case .parameter(let name, _) = pattern.components[componentIndex] {
                    return name
                }
            }
        }
        return nil
    }

    /// 从节点中获取捕获组名称
    private func getCaptureNames(from node: RouteTrieNode, componentIndex: Int) -> [String]? {
        for (pattern, _) in node.routePatterns {
            if componentIndex < pattern.components.count {
                if case .regex(_, let captureNames) = pattern.components[componentIndex] {
                    return captureNames
                }
            }
        }
        return nil
    }

    // MARK: - 获取所有注册的模式
    private func getAllPatterns() -> [(RoutePattern, Int)] {
        var allPatterns: [(RoutePattern, Int)] = []
        collectPatterns(from: root, patterns: &allPatterns)
        return allPatterns
    }

    // MARK: - 递归收集所有模式
    private func collectPatterns(from node: RouteTrieNode, patterns: inout [(RoutePattern, Int)]) {
        if node.isEndOfPattern {
            patterns.append(contentsOf: node.routePatterns)
        }

        for child in node.children.values {
            collectPatterns(from: child, patterns: &patterns)
        }

        if let paramChild = node.parameterChild {
            collectPatterns(from: paramChild, patterns: &patterns)
        }

        if let wildcardChild = node.wildcardChild {
            collectPatterns(from: wildcardChild, patterns: &patterns)
        }

        if let regexChild = node.regexChild {
            collectPatterns(from: regexChild.node, patterns: &patterns)
        }
    }

    // MARK: - 匹配单个模式
    private func matchPattern(_ pattern: RoutePattern, with pathComponents: [String]) -> RouterParameters? {
        guard pattern.components.count == pathComponents.count else {
            return nil
        }

        var parameters: RouterParameters = [:]

        for (index, component) in pattern.components.enumerated() {
            let pathComponent = pathComponents[index]

            switch component {
            case .literal(let value):
                if value != pathComponent {
                    return nil
                }

            case .parameter(let name, let isOptional):
                if pathComponent.isEmpty && !isOptional {
                    return nil
                }
                if !pathComponent.isEmpty {
                    parameters[name] = pathComponent
                }

            case .wildcard:
                // 通配符匹配任何值
                break

            case .regex(let regex, let captureNames):
                let range = NSRange(location: 0, length: pathComponent.utf16.count)
                guard let match = regex.firstMatch(in: pathComponent, range: range) else {
                    return nil
                }

                // 提取捕获组
                for (captureIndex, captureName) in captureNames.enumerated() {
                    let captureRange = match.range(at: captureIndex + 1)
                    if captureRange.location != NSNotFound {
                        let captureValue = (pathComponent as NSString).substring(with: captureRange)
                        parameters[captureName] = captureValue
                    }
                }
            }
        }

        return parameters
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
        case .parameter:
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
