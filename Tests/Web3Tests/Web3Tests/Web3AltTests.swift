//
//  Web3AltTests.swift
//  
//
//  Created by Monterey on 16/4/22.
//

import XCTest
@testable import Web3

final class Web3AltTests: XCTestCase {
    static let testnetUrl = "https://ropsten.infura.io/v3/362c324f295a4032b2fe87d910aaa33a"
    let web3 = Web3(rpcURL: testnetUrl)

    func testGetLogs() async throws {
        let filter = EthereumFilterObject(
            fromBlock: .block(12199952),
            toBlock: .block(12199952),
            address: .data(.init(hex: "e54bd661dda41649a1c84b9d22eb95bd1fc9bb58"))
        )
        
        let response = await web3.eth.getLogs(filter: filter)
        switch response.status {
        case .success(let result):
            try XCTAssert(result[0].data == .string("0x0000000000000000000000000000000000000000000000000000000000000001"))
        case .failure(let error):
            XCTFail("\(error)")
        }
    }
    
}


