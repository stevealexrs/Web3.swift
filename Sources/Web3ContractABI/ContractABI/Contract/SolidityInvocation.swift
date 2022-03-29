//
//  Invocation.swift
//  Web3
//
//  Created by Josh Pyles on 6/5/18.
//

import Foundation
#if !Web3CocoaPods
    import Web3
#endif

public enum InvocationError: Error {
    case contractNotDeployed
    case invalidConfiguration
    case invalidInvocation
    case encodingError
    case decodingError
}

/// Represents invoking a given contract method with parameters
public protocol SolidityInvocation {
    /// The function that was invoked
    var method: SolidityFunction { get }
    
    /// Parameters method was invoked with
    var parameters: [SolidityWrappedValue] { get }
    
    /// Handler for submitting calls and sends
    var handler: SolidityFunctionHandler { get }
    
    /// Generates an EthereumCall object
    func createCall() -> EthereumCall?
    
    /// Generates an EthereumTransaction object
    func createTransaction(nonce: EthereumQuantity?, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) -> EthereumTransaction?
    
    /// Read data from the blockchain. Only available for constant functions.
    func call(block: EthereumQuantityTag) async -> ([String: Any]?, Error?)
    
    /// Write data to the blockchain. Only available for non-constant functions.
    func send(nonce: EthereumQuantity?, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) async -> (EthereumData?, Error?)
    
    /// Estimate how much gas is needed to execute this transaction.
    func estimateGas(from: EthereumAddress?, gas: EthereumQuantity?, value: EthereumQuantity?) async -> (EthereumQuantity?, Error?)
    
    /// Encodes the ABI for this invocation
    func encodeABI() -> EthereumData?
    
    init(method: SolidityFunction, parameters: [ABIEncodable], handler: SolidityFunctionHandler)
}

// MARK: - Read Invocation

/// An invocation that is read-only. Should only use .call()
public struct SolidityReadInvocation: SolidityInvocation {
    
    public let method: SolidityFunction
    public let parameters: [SolidityWrappedValue]
    
    public let handler: SolidityFunctionHandler
    
    public init(method: SolidityFunction, parameters: [ABIEncodable], handler: SolidityFunctionHandler) {
        self.method = method
        self.parameters = zip(parameters, method.inputs).map { SolidityWrappedValue(value: $0, type: $1.type) }
        self.handler = handler
    }
    
    public func call(block: EthereumQuantityTag = .latest) async -> ([String: Any]?, Error?) {
        guard handler.address != nil else {
            return (nil, InvocationError.contractNotDeployed)
        }
        guard let call = createCall() else {
            return (nil, InvocationError.encodingError)
        }
        let outputs = method.outputs ?? []
        return await handler.call(call, outputs: outputs, block: block)
    }
    
    public func send(nonce: EthereumQuantity? = nil, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) async -> (EthereumData?, Error?) {
        return (nil, InvocationError.invalidInvocation)
    }
    
    public func createCall() -> EthereumCall? {
        guard let data = encodeABI() else { return nil }
        guard let to = handler.address else { return nil }
        return EthereumCall(from: nil, to: to, gas: nil, gasPrice: nil, value: nil, data: data)
    }
    
    public func createTransaction(nonce: EthereumQuantity?, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) -> EthereumTransaction? {
        return nil
    }
    
}

// MARK: - Payable Invocation

/// An invocation that writes to the blockchain and can receive ETH. Should only use .send()
public struct SolidityPayableInvocation: SolidityInvocation {
    
    public let method: SolidityFunction
    public let parameters: [SolidityWrappedValue]
    
    public let handler: SolidityFunctionHandler
    
    public init(method: SolidityFunction, parameters: [ABIEncodable], handler: SolidityFunctionHandler) {
        self.method = method
        self.parameters = zip(parameters, method.inputs).map { SolidityWrappedValue(value: $0, type: $1.type) }
        self.handler = handler
    }
    
    public func createTransaction(nonce: EthereumQuantity? = nil, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) -> EthereumTransaction? {
        guard let data = encodeABI() else { return nil }
        guard let to = handler.address else { return nil }
        return EthereumTransaction(nonce: nonce, gasPrice: gasPrice, gas: gas, from: from, to: to, value: value ?? 0, data: data)
    }
    
    public func createCall() -> EthereumCall? {
        return nil
    }
    
    public func call(block: EthereumQuantityTag = .latest) async -> ([String: Any]?, Error?) {
        return (nil, InvocationError.invalidInvocation)
    }
    
    public func send(nonce: EthereumQuantity? = nil, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) async -> (EthereumData?, Error?) {
        guard handler.address != nil else {
            return (nil, InvocationError.contractNotDeployed)
        }
        guard let transaction = createTransaction(nonce: nonce, from: from, value: value, gas: gas, gasPrice: gasPrice) else {
            return (nil, InvocationError.encodingError)
        }
        return await handler.send(transaction)
    }
}

// MARK: - Non Payable Invocation

/// An invocation that writes to the blockchain and cannot receive ETH. Should only use .send().
public struct SolidityNonPayableInvocation: SolidityInvocation {
    public let method: SolidityFunction
    public let parameters: [SolidityWrappedValue]
    
    public let handler: SolidityFunctionHandler
    
    public init(method: SolidityFunction, parameters: [ABIEncodable], handler: SolidityFunctionHandler) {
        self.method = method
        self.parameters = zip(parameters, method.inputs).map { SolidityWrappedValue(value: $0, type: $1.type) }
        self.handler = handler
    }
    
    public func createTransaction(nonce: EthereumQuantity? = nil, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) -> EthereumTransaction? {
        guard let data = encodeABI() else { return nil }
        guard let to = handler.address else { return nil }
        return EthereumTransaction(nonce: nonce, gasPrice: gasPrice, gas: gas, from: from, to: to, value: value ?? 0, data: data)
    }
    
    public func createCall() -> EthereumCall? {
        return nil
    }
    
    public func call(block: EthereumQuantityTag = .latest) async -> ([String: Any]?, Error?){
        return (nil, InvocationError.invalidInvocation)
    }
    
    public func send(nonce: EthereumQuantity? = nil, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) async -> (EthereumData?, Error?) {
        guard handler.address != nil else {
            return (nil, InvocationError.contractNotDeployed)
        }
        guard let transaction = createTransaction(nonce: nonce, from: from, value: value, gas: gas, gasPrice: gasPrice) else {
            return (nil, InvocationError.encodingError)
        }
        return await handler.send(transaction)
    }
}

// MARK: - PromiseKit convenience

public extension SolidityInvocation {
    
    // Default Implementations
    
    func call() async -> ([String: Any]?, Error?) {
        return await self.call(block: .latest)
    }
    
    func estimateGas(from: EthereumAddress? = nil, gas: EthereumQuantity? = nil, value: EthereumQuantity? = nil) async -> (EthereumQuantity?, Error?) {
        guard let data = encodeABI() else {
            return (nil, InvocationError.encodingError)
        }
        guard let to = handler.address else {
            return (nil, InvocationError.contractNotDeployed)
        }
        let call = EthereumCall(from: from, to: to, gas: gas, gasPrice: nil, value: value, data: data)
        return await handler.estimateGas(call)
    }
    
    func encodeABI() -> EthereumData? {
        if let hexString = try? ABI.encodeFunctionCall(self) {
            return try? EthereumData(ethereumValue: hexString)
        }
        return nil
    }
}

// MARK: - Contract Creation

/// Represents a contract creation invocation
public struct SolidityConstructorInvocation {
    public let byteCode: EthereumData
    public let parameters: [SolidityWrappedValue]
    public let payable: Bool
    public let handler: SolidityFunctionHandler
    
    public init(byteCode: EthereumData, parameters: [SolidityWrappedValue], payable: Bool, handler: SolidityFunctionHandler) {
        self.byteCode = byteCode
        self.parameters = parameters
        self.handler = handler
        self.payable = payable
    }
    
    public func createTransaction(nonce: EthereumQuantity? = nil, from: EthereumAddress, value: EthereumQuantity = 0, gas: EthereumQuantity, gasPrice: EthereumQuantity?) -> EthereumTransaction? {
        guard let data = encodeABI() else { return nil }
        return EthereumTransaction(nonce: nonce, gasPrice: gasPrice, gas: gas, from: from, to: nil, value: value, data: data)
    }
    
    public func send(nonce: EthereumQuantity? = nil, from: EthereumAddress, value: EthereumQuantity = 0, gas: EthereumQuantity, gasPrice: EthereumQuantity?) async -> (EthereumData?, Error?) {
        guard payable == true || value == 0 else {
            return (nil, InvocationError.invalidInvocation)
        }
        guard let transaction = createTransaction(nonce: nonce, from: from, value: value, gas: gas, gasPrice: gasPrice) else {
            return (nil, InvocationError.encodingError)
        }
        return await handler.send(transaction)
    }
    
    public func encodeABI() -> EthereumData? {
        // The data for creating a new contract is the bytecode of the contract + any input params serialized in the standard format.
        var dataString = "0x"
        dataString += byteCode.hex().replacingOccurrences(of: "0x", with: "")
        if parameters.count > 0, let encodedParams = try? ABI.encodeParameters(parameters) {
            dataString += encodedParams.replacingOccurrences(of: "0x", with: "")
        }
        return try? EthereumData(ethereumValue: dataString)
    }
}
