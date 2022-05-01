//
//  EthereumTopic.swift
//  
//
//  Created by Monterey on 17/4/22.
//

import Foundation

public struct EthereumTopic {
    public enum TopicType {
        case data(Bytes?)
        case array([Bytes?])
    }
    
    public let topicType: TopicType
    
    public init(topicType: TopicType) {
        self.topicType = topicType
    }
}

public extension EthereumTopic {
    static func data(_ bytes: Bytes?) -> EthereumTopic {
        return .init(topicType: .data(bytes))
    }
    
    static func array(_ bytesArray: [Bytes?]) -> EthereumTopic {
        return .init(topicType: .array(bytesArray))
    }
}

extension EthereumTopic: EthereumValueConvertible {
    public init(ethereumValue: EthereumValue) throws {
        if let data = ethereumValue.ethereumData {
            topicType = .data(data.bytes)
        } else if ethereumValue.valueType == .nil {
            topicType = .data(nil)
        } else if let array = ethereumValue.array {
            var mappedArray: [Bytes?] = []
            for item in array {
                mappedArray.append(item.ethereumData?.bytes)
            }
            
            topicType = .array(mappedArray)
        } else {
            throw EthereumValueInitializableError.notInitializable
        }
    }

    public func ethereumValue() -> EthereumValue {
        switch topicType {
        case .array(let bytesArray):
            return EthereumValue(array: bytesArray.map{ $0 != nil ? EthereumValue(stringLiteral: $0!.hexString(prefix: true)) : EthereumValue(valueType: .nil) })
        case .data(let bytes):
            return bytes != nil ? EthereumValue(stringLiteral: bytes!.hexString(prefix: true)) : EthereumValue(valueType: .nil)
        }
    }
}

// MARK: - Equatable

extension EthereumTopic.TopicType: Equatable {

    public static func ==(lhs: EthereumTopic.TopicType, rhs: EthereumTopic.TopicType) -> Bool {
        switch lhs {
        case .array(let left):
            if case .array(let right) = rhs {
                return left == right
            }
            return false
        case .data(let left):
            if case .data(let right) = rhs {
                return left == right
            }
            return false
        }
    }
}

extension EthereumTopic: Equatable {

    public static func ==(_ lhs: EthereumTopic, _ rhs: EthereumTopic) -> Bool {
        return lhs.topicType == rhs.topicType
    }
}

// MARK: - Hashable

extension EthereumTopic.TopicType: Hashable {

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .data(let bytes):
            hasher.combine(0x00)
            hasher.combine(bytes)
        case .array(let bytesArray):
            hasher.combine(0x01)
            hasher.combine(bytesArray)
        }
    }
}

extension EthereumTopic: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(topicType)
    }
}


