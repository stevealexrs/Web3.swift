//
//  SolidityTypedInvocation.swift
//  
//
//  Created by Monterey on 28/3/22.
//

import Foundation
#if !Web3CocoaPods
    import Web3
#endif

// Currently, the codegen generate the casting closure because converting dictionary of [String: Any] to struct is difficult
public struct SolidityTypedInvocation<T> {
    public var invocation: SolidityInvocation
    private var cast: ([String: Any]) throws -> T
    
    public init(invocation: SolidityInvocation, _ cast: @escaping ([String: Any]) throws -> T) {
        self.cast = cast
        self.invocation = invocation
    }
    
    /// Read data from the blockchain. Only available for constant functions.
    public func call(block: EthereumQuantityTag = .latest) async -> (T?, Error?) {
        let (dictionary, error) = await invocation.call(block: block)
        if let dictionary = dictionary, error == nil {
            do {
                return (try cast(dictionary), nil)
            } catch {
                return (nil, InvocationError.decodingError)
            }
        } else {
            return (nil, error)
        }
    }
    
    /// Generates an EthereumCall object
    public func createCall() -> EthereumCall? {
        return self.invocation.createCall()
    }
    
    /// Generates an EthereumTransaction object
    public func createTransaction(nonce: EthereumQuantity?, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) -> EthereumTransaction? {
        return self.invocation.createTransaction(nonce: nonce, from: from, value: value, gas: gas, gasPrice: gasPrice)
    }
    
    /// Write data to the blockchain. Only available for non-constant functions.
    public func send(nonce: EthereumQuantity?, from: EthereumAddress, value: EthereumQuantity?, gas: EthereumQuantity, gasPrice: EthereumQuantity?) async -> (EthereumData?, Error?) {
        return await self.invocation.send(nonce: nonce, from: from, value: value, gas: gas, gasPrice: gasPrice)
    }
    
    /// Estimate how much gas is needed to execute this transaction.
    public func estimateGas(from: EthereumAddress?, gas: EthereumQuantity?, value: EthereumQuantity?) async -> (EthereumQuantity?, Error?) {
        return await self.invocation.estimateGas(from: from, gas: gas, value: value)
    }
}
