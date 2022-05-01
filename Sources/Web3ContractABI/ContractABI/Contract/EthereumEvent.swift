//
//  EthereumEvent.swift
//  
//
//  Created by Monterey on 1/5/22.
//

import Foundation
#if !Web3CocoaPods
    import Web3
#endif

public struct EthereumEvent<T> {
    /// Name of the event
    public let name: String
    
    /// A string representing the signature of the event
    public let signature: String
    
    /// Address this event originated from
    public let address: EthereumAddress?
    
    /// Return values
    public let result: T
    
    /// Integer of the log index position in the block. nil when its pending log.
    public let logIndex: EthereumQuantity?

    /// Integer of the transactions index position log was created from. nil when its pending log.
    public let transactionIndex: EthereumQuantity?

    /// 32 Bytes - hash of the transactions this log was created from. nil when its pending log.
    public let transactionHash: EthereumData?

    /// 32 Bytes - hash of the block where this log was in. nil when its pending. nil when its pending log.
    public let blockHash: EthereumData?

    /// The block number where this log was in. nil when its pending. nil when its pending log.
    public let blockNumber: EthereumQuantity?
    
    public let raw: Raw
    
    public struct Raw {
        /// Contains one or more 32 Bytes non-indexed arguments of the log.
        public let data: EthereumData

        /**
         * Array of 0 to 4 32 Bytes DATA of indexed log arguments.
         *
         * In solidity: The first topic is the hash of the signature of the event (e.g. Deposit(address,bytes32,uint256))
         * except you declared the event with the anonymous specifier.)
         */
        public let topics: [EthereumData]
    }
}

public extension EthereumEvent {
    init(event: SolidityTypedEvent<T>, log: EthereumLogObject, address: EthereumAddress?) throws {
        self.name = event.event.name
        self.signature = event.event.signature
        self.address = address
        self.result = try event.decode(log: log).get()
        self.logIndex = log.logIndex
        self.transactionIndex = log.transactionIndex
        self.transactionHash = log.transactionHash
        self.blockHash = log.blockHash
        self.blockNumber = log.blockNumber
        self.raw = .init(
            data: log.data,
            topics: log.topics
        )
    }
}
