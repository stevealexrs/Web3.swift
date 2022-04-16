//
//  EthereumDataArray.swift
//  
//
//  Created by Monterey on 16/4/22.
//

import Foundation

public struct EthereumDataArray {
    public enum DataType {
        case data(Bytes)
        case array([Bytes])
    }
    
    public let dataType: DataType
    
    public init(dataType: DataType) {
        self.dataType = dataType
    }
}

public extension EthereumDataArray {
    static func data(_ bytes: Bytes) -> EthereumDataArray {
        return .init(dataType: .data(bytes))
    }
    
    static func array(_ bytesArray: [Bytes]) -> EthereumDataArray {
        return .init(dataType: .array(bytesArray))
    }
}

extension EthereumDataArray: EthereumValueConvertible {
    public init(ethereumValue: EthereumValue) throws {
        if let data = ethereumValue.ethereumData {
            dataType = .data(data.bytes)
        } else if let array = ethereumValue.array {
            var mappedArray: [Bytes] = []
            for item in array {
                guard let data = item.ethereumData else {
                    throw EthereumValueInitializableError.notInitializable
                }
                mappedArray.append(data.bytes)
            }
            
            dataType = .array(mappedArray)
        } else {
            throw EthereumValueInitializableError.notInitializable
        }
    }

    public func ethereumValue() -> EthereumValue {
        switch dataType {
        case .array(let bytesArray):
            return EthereumValue(array: bytesArray.map{ EthereumValue(stringLiteral: $0.hexString(prefix: true)) })
        case .data(let bytes):
            return EthereumValue(stringLiteral: bytes.hexString(prefix: true))
        }
    }
}

// MARK: - Equatable

extension EthereumDataArray.DataType: Equatable {

    public static func ==(lhs: EthereumDataArray.DataType, rhs: EthereumDataArray.DataType) -> Bool {
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

extension EthereumDataArray: Equatable {

    public static func ==(_ lhs: EthereumDataArray, _ rhs: EthereumDataArray) -> Bool {
        return lhs.dataType == rhs.dataType
    }
}

// MARK: - Hashable

extension EthereumDataArray.DataType: Hashable {

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

extension EthereumDataArray: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(dataType)
    }
}

