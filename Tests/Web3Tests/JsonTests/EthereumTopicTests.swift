//
//  EthereumTopicTests.swift
//  
//
//  Created by Monterey on 17/4/22.
//

import Foundation
@testable import Web3
import XCTest

final class EthereumTopicTests: XCTestCase {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func testCodable() throws {
        let _nilTopic = EthereumTopic.data(nil)
        let nilTopic = try decoder.decode(EthereumTopic.self, from: encoder.encode(_nilTopic))
        let _dataTopic = EthereumTopic.data("0x10000".bytes)
        let dataTopic = try decoder.decode(EthereumTopic.self, from: encoder.encode(_dataTopic))
        let _arrayTopic = EthereumTopic.array([nil, "0x1000".bytes, nil])
        let arrayTopic = try decoder.decode(EthereumTopic.self, from: encoder.encode(_arrayTopic))
        
        XCTAssertEqual(nilTopic, _nilTopic)
        XCTAssertEqual(dataTopic, _dataTopic)
        XCTAssertEqual(arrayTopic, _arrayTopic)
    }
}
