//
//  Web3.swift
//  Web3
//
//  Created by Koray Koska on 30.12.17.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation

public struct Web3 {
    public typealias BasicWeb3ResponseCompletion = Web3Response<EthereumValue>

    public static let jsonrpc = "2.0"

    // MARK: - Properties

    public let properties: Properties

    public struct Properties {

        public let provider: Web3Provider
        public let rpcId: Int
    }

    // MARK: - Convenient properties

    public var provider: Web3Provider {
        return properties.provider
    }

    public var rpcId: Int {
        return properties.rpcId
    }

    /// The struct holding all `net` requests
    public let net: Net

    /// The struct holding all `eth` requests
    public let eth: Eth

    // MARK: - Initialization

    /**
     * Initializes a new instance of `Web3` with the given custom provider.
     *
     * - parameter provider: The provider which handles all requests and responses.
     * - parameter rpcId: The rpc id to be used in all requests. Defaults to 1.
     */
    public init(provider: Web3Provider, rpcId: Int = 1) {
        let properties = Properties(provider: provider, rpcId: rpcId)
        self.properties = properties
        self.net = Net(properties: properties)
        self.eth = Eth(properties: properties)
    }

    // MARK: - Web3 methods

    /**
     * Returns the current client version.
     *
     * e.g.: "Mist/v0.9.3/darwin/go1.4.1"
     *
     * - parameter response: The response handler. (Returns `String` - The current client version)
     */
    public func clientVersion() async -> Web3Response<String> {
        let req = BasicRPCRequest(id: rpcId, jsonrpc: type(of: self).jsonrpc, method: "web3_clientVersion", params: [])

        return await provider.send(request: req)
    }

    // MARK: - Net methods

    public struct Net {

        public let properties: Properties

        /**
         * Returns the current network id (chain id).
         *
         * e.g.: "1" - Ethereum Mainnet, "2" - Morden testnet, "3" - Ropsten Testnet
         *
         * - parameter response: The response handler. (Returns `String` - The current network id)
         */
        public func version() async -> Web3Response<String> {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "net_version", params: [])

            return await properties.provider.send(request: req)
        }

        /**
         * Returns number of peers currently connected to the client.
         *
         * e.g.: 0x2 - 2
         *
         * - parameter response: The response handler. (Returns `EthereumQuantity` - Integer of the number of connected peers)
         */
        public func peerCount() async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "net_peerCount", params: [])

            return await properties.provider.send(request: req)
        }
    }

    // MARK: - Eth methods

    public struct Eth {

        public let properties: Properties
        
        // MARK: - Methods

        public func protocolVersion() async -> Web3Response<String> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_protocolVersion",
                params: []
            )

            return await properties.provider.send(request: req)
        }

        public func syncing() async -> Web3Response<EthereumSyncStatusObject> {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_syncing", params: [])

            return await properties.provider.send(request: req)
        }

        public func mining() async -> Web3Response<Bool> {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_mining", params: [])

            return await properties.provider.send(request: req)
        }

        public func hashrate() async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_hashrate", params: [])

            return await properties.provider.send(request: req)
        }

        public func gasPrice() async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_gasPrice", params: [])

            return await properties.provider.send(request: req)
        }

        public func accounts() async -> Web3Response<[EthereumAddress]> {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_accounts", params: [])

            return await properties.provider.send(request: req)
        }

        public func blockNumber() async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_blockNumber",
                params: []
            )

            return await properties.provider.send(request: req)
        }

        public func getBalance(
            address: EthereumAddress,
            block: EthereumQuantityTag
        ) async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBalance",
                params: [address, block]
            )

            return await properties.provider.send(request: req)
        }

        public func getStorageAt(
            address: EthereumAddress,
            position: EthereumQuantity,
            block: EthereumQuantityTag
        ) async -> Web3Response<EthereumData> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getStorageAt",
                params: [address, position, block]
            )

            return await properties.provider.send(request: req)
        }

        public func getTransactionCount(
            address: EthereumAddress,
            block: EthereumQuantityTag
        ) async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionCount",
                params: [address, block]
            )

            return await properties.provider.send(request: req)
        }

        public func getBlockTransactionCountByHash(
            blockHash: EthereumData
        ) async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBlockTransactionCountByHash",
                params: [blockHash]
            )

            return await properties.provider.send(request: req)
        }

        public func getBlockTransactionCountByNumber(
            block: EthereumQuantityTag
        ) async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBlockTransactionCountByNumber",
                params: [block]
            )

            return await properties.provider.send(request: req)
        }

        public func getUncleCountByBlockHash(
            blockHash: EthereumData
        ) async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getUncleCountByBlockHash",
                params: [blockHash]
            )

            return await properties.provider.send(request: req)
        }

        public func getUncleCountByBlockNumber(
            block: EthereumQuantityTag
        ) async -> Web3Response<EthereumQuantity> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getUncleCountByBlockNumber",
                params: [block]
            )

            return await properties.provider.send(request: req)
        }

        public func getCode(
            address: EthereumAddress,
            block: EthereumQuantityTag
        ) async -> Web3Response<EthereumData> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getCode",
                params: [address, block]
            )

            return await properties.provider.send(request: req)
        }
        
        public func sendTransaction(
            transaction: EthereumTransaction
        ) async -> Web3Response<EthereumData> {
            guard transaction.from != nil else {
                let error = Web3Response<EthereumData>(error: .requestFailed(nil))
                return error
            }
            let req = RPCRequest<[EthereumTransaction]>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_sendTransaction",
                params: [transaction]
            )
            return await properties.provider.send(request: req)
        }

        public func sendRawTransaction(
            transaction: EthereumSignedTransaction
        ) async -> Web3Response<EthereumData> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_sendRawTransaction",
                params: [transaction.rlp()]
            )

            return await properties.provider.send(request: req)
        }

        public func call(
            call: EthereumCall,
            block: EthereumQuantityTag
        ) async -> Web3Response<EthereumData> {
            let req = RPCRequest<EthereumCallParams>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_call",
                params: EthereumCallParams(call: call, block: block)
            )

            return await properties.provider.send(request: req)
        }

        public func estimateGas(call: EthereumCall) async -> Web3Response<EthereumQuantity> {
            let req = RPCRequest<[EthereumCall]>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_estimateGas",
                params: [call]
            )

            return await properties.provider.send(request: req)
        }

        public func getBlockByHash(
            blockHash: EthereumData,
            fullTransactionObjects: Bool
        ) async -> Web3Response<EthereumBlockObject?> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBlockByHash",
                params: [blockHash, fullTransactionObjects]
            )

            return await properties.provider.send(request: req)
        }

        public func getBlockByNumber(
            block: EthereumQuantityTag,
            fullTransactionObjects: Bool
        ) async -> Web3Response<EthereumBlockObject?> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBlockByNumber",
                params: [block, fullTransactionObjects]
            )

            return await properties.provider.send(request: req)
        }

        public func getTransactionByHash(
            blockHash: EthereumData
        ) async -> Web3Response<EthereumTransactionObject?> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionByHash",
                params: [blockHash]
            )

            return await properties.provider.send(request: req)
        }

        public func getTransactionByBlockHashAndIndex(
            blockHash: EthereumData,
            transactionIndex: EthereumQuantity
        ) async -> Web3Response<EthereumTransactionObject?> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionByBlockHashAndIndex",
                params: [blockHash, transactionIndex]
            )

            return await properties.provider.send(request: req)
        }

        public func getTransactionByBlockNumberAndIndex(
            block: EthereumQuantityTag,
            transactionIndex: EthereumQuantity
        ) async -> Web3Response<EthereumTransactionObject?> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionByBlockNumberAndIndex",
                params: [block, transactionIndex]
            )

            return await properties.provider.send(request: req)
        }

        public func getTransactionReceipt(
            transactionHash: EthereumData
        ) async -> Web3Response<EthereumTransactionReceiptObject?>  {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionReceipt",
                params: [transactionHash]
            )

            return await properties.provider.send(request: req)
        }

        public func getUncleByBlockHashAndIndex(
            blockHash: EthereumData,
            uncleIndex: EthereumQuantity
        ) async -> Web3Response<EthereumBlockObject?>  {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getUncleByBlockHashAndIndex",
                params: [blockHash, uncleIndex]
            )

            return await properties.provider.send(request: req)
        }

        public func getUncleByBlockNumberAndIndex(
            block: EthereumQuantityTag,
            uncleIndex: EthereumQuantity
        ) async -> Web3Response<EthereumBlockObject?> {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getUncleByBlockNumberAndIndex",
                params: [block, uncleIndex]
            )

            return await properties.provider.send(request: req)
        }
        
        public func getLogs(
            filter: EthereumFilterObject
        ) async -> Web3Response<[EthereumLogObject]> {
            let req = RPCRequest<[EthereumFilterObject]>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getLogs",
                params: [filter]
            )
            
            return await properties.provider.send(request: req)
        }
    }
}
