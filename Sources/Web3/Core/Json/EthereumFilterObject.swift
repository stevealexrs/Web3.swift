//
//  EthereumFilterObject.swift
//  
//
//  Created by Monterey on 16/4/22.
//

import Foundation

public struct EthereumFilterObject: Codable {
    
    /// The block number (greater than or equal to) from which to get events on.
    public var fromBlock: EthereumQuantityTag?
    
    /// The block number (less than or equal to) to get events up to.
    public var toBlock: EthereumQuantityTag?
    
    /// Contract address or a list of addresses from which logs should originate.
    public var address: EthereumDataArray?
    
    /// This allows manually setting the topics for the event filter. Each topic can also be a nested array of topics that behaves as “or” operation between the given nested topics.
    public var topics: [EthereumTopic]?
    
    ///  With the addition of EIP-234, blockHash restricts the logs returned to the single block with the 32-byte hash blockHash. Using blockHash is equivalent to fromBlock = toBlock = the block number with hash blockHash. If blockHash is present in in the filter criteria, then neither fromBlock nor toBlock are allowed.
    public var blockhash: EthereumData?
    
    public init(
        fromBlock: EthereumQuantityTag? = nil,
        toBlock: EthereumQuantityTag? = nil,
        address: EthereumDataArray? = nil,
        topics: [EthereumTopic]? = nil,
        blockhash: EthereumData? = nil
    ) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.address = address
        self.topics = topics
        self.blockhash = blockhash
    }
    
}

// MARK: - Hashable

extension EthereumFilterObject: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fromBlock)
        hasher.combine(toBlock)
        hasher.combine(address)
        hasher.combine(topics)
        hasher.combine(blockhash)
    }
}

// MARK: - Equatable

extension EthereumFilterObject: Equatable {
    public static func ==(_ lhs: EthereumFilterObject, _ rhs: EthereumFilterObject) -> Bool {
        return lhs.fromBlock == rhs.fromBlock
            && lhs.toBlock == rhs.toBlock
            && lhs.address == rhs.address
            && lhs.topics == rhs.topics
            && lhs.blockhash == rhs.blockhash
    }
}

