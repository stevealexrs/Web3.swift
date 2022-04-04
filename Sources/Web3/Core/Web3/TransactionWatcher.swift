//
//  TransactionWaiter.swift
//  
//
//  Created by Monterey on 2/4/22.
//

import Foundation
import BigInt

public struct TransactionWatcher {
    let options: Options
    private let eth: Web3.Eth
    
    init(eth: Web3.Eth, options: Options = Options()) {
        self.eth = eth
        self.options = options
    }
    
    public func waitForReceipt(_ hash: EthereumData) -> AsyncThrowingStream<TransactionStatus, Swift.Error> {
        return AsyncThrowingStream { continuation in
            let eth = self.eth
            let task = Task {
                func fetchReceipt(_ hash: EthereumData) async -> EthereumTransactionReceiptObject? {
                    let receiptResponse = await eth.getTransactionReceipt(transactionHash: hash)
                    // Receipt is still pending if response is empty
                    if let error = receiptResponse.error, case .emptyResponse = error as? Web3Response<EthereumTransactionReceiptObject?>.Error {
                        return nil
                    }
                    if let newReceipt = receiptResponse.result {
                        return newReceipt
                    } else {
                        continuation.finish(throwing: Error.ResponseError(receiptResponse.error!))
                        return nil
                    }
                }
                
                func fetchBlockNumber() async -> BigUInt {
                    let response = await eth.blockNumber()
                    if let blocknumber = response.result {
                        return blocknumber.quantity
                    } else {
                        continuation.finish(throwing: Error.ResponseError(response.error!))
                        return 0
                    }
                }
                
                
                var receipt: EthereumTransactionReceiptObject? = nil
                let firstBlockNumber = await fetchBlockNumber()
                var previousBlockNumber: BigUInt = firstBlockNumber
                
                continuation.yield(.pending)
                
                while true {
                    let blockNumber = await fetchBlockNumber()

                    if receipt == nil {
                        receipt = await fetchReceipt(hash)
                    }
                    
                    if let receipt = receipt {
                        if receipt.status == EthereumQuantity(quantity: 0) {
                            continuation.finish(throwing: Error.TransactionFailed)
                        }
                        
                        if previousBlockNumber < blockNumber {
                            
                            if (await fetchReceipt(hash)) != nil {
                                let confirmations = blockNumber - receipt.blockNumber.quantity
                                
                                if confirmations >= options.confirmationBlocks {
                                    continuation.yield(.successful(receipt: receipt))
                                    continuation.finish()
                                } else {
                                    continuation.yield(.confirmed(receipt: receipt, times: Int(confirmations)))
                                }
                            } else {
                                continuation.finish(throwing: Error.ChainReorganized)
                            }
                            
                            previousBlockNumber = blockNumber
                        }
                    } else {
                        
                        if blockNumber > firstBlockNumber && (blockNumber - firstBlockNumber) >= options.blockTimeout {
                            continuation.finish(throwing: Error.BlockTimeout)
                        }
                    }
                    
                    try? await Task.sleep(nanoseconds: UInt64(options.pollingInterval) * 1_000_000_000) // seconds to nanoseconds
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    public enum Error: Swift.Error {
        case ResponseError(Swift.Error)
        case TransactionFailed
        case ChainReorganized
        case BlockTimeout
    }
    
    public struct Options {
        public var blockTimeout: Int = 50
        public var confirmationBlocks: Int = 24
        // seconds
        public var pollingInterval: Double = 1
    }
}
