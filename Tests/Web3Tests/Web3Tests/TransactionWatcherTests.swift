//
//  TransactionWatcherTests.swift
//  
//
//  Created by Monterey on 3/4/22.
//

import XCTest
@testable import Web3
import BigInt

// Confirmations will take very long time, not feasible for testing without mocking
final class TransactionWatcherTests: XCTestCase {

    let testnetUrl = "https://ropsten.infura.io/v3/362c324f295a4032b2fe87d910aaa33a"
    
    func testWaitForTransactionReceipt() async throws {
        let web3 = Web3(rpcURL: testnetUrl)
        let watcher = TransactionWatcher(eth: web3.eth, options: .init(blockTimeout: 3, confirmationBlocks: 1, pollingInterval: 5))
        
        let address = try! EthereumAddress(hex: "0x58b1757Dee32FC17Bc271914Ed7b6a7c1E573E1F", eip55: false)
        
        let transactionResponse = await web3.eth.getTransactionCount(address: address, block: .pending)
        XCTAssertTrue(transactionResponse.status.isSuccess)
        XCTAssertNotNil(transactionResponse.result)
        let nonce = transactionResponse.result!
        print("nonce: \(nonce.hex())")
        
        let gasResponse = await web3.eth.estimateGas(call: EthereumCall(from: address, to: address, gas: nil, gasPrice: nil, value: .init(quantity: 0), data: nil))
        XCTAssertTrue(gasResponse.status.isSuccess)
        XCTAssertNotNil(gasResponse.result)
        let gasPrice = gasResponse.result!
        print("suggested gas price: \(gasPrice.hex())")
            
        let transaction = try! EthereumTransaction(nonce: nonce, gasPrice: EthereumQuantity(quantity: gasPrice.quantity), gas: EthereumQuantity(quantity: 21000), from: address, to: address, value: 0).sign(with: try! EthereumPrivateKey(hexPrivateKey: "4d31d96f7456c3e9a4714ed3f3b8baadd62d95f6e9064f3ecb092bad1fdbf1a2"), chainId: 3)
        
        let response = await web3.eth.sendRawTransaction(transaction: transaction)
        XCTAssertTrue(response.status.isSuccess)
        XCTAssertNotNil(response.result)
        let hash = response.result!
        
        print("hash: \(hash.hex())")
        do {
            for try await status in watcher.waitForReceipt(hash) {
                switch status {
                case .pending:
                    print("pending")
                    continue
                    // pending
                case .confirmed(receipt: _, times: let times):
                    // confirming
                    print("confirmed: \(times)")
                    continue
                case .successful(let receipt):
                    print(receipt.blockNumber)
                }
            }
        } catch let error as TransactionWatcher.Error {
            switch error {
            case .BlockTimeout:
                throw XCTSkip("block timeout")
            default:
                XCTFail("\(error)")
            }
            
        }
    }
}
