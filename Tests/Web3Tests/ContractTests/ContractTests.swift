//
//  ContractTests.swift
//  Web3_Tests
//
//  Created by Josh Pyles on 6/7/18.
//

import Quick
import Nimble
@testable import Web3
import BigInt
import Foundation
#if canImport(Web3ContractABI)
    @testable import Web3ContractABI
#endif

public extension QuickSpec {

    func loadStub(named: String) -> Data? {
        return JSONStubs.stubs[named]?.data(using: .utf8)
    }
}

class MockWeb3Provider: Web3Provider {

    var stubs: [String: Data] = [:]

    func addStub(method: String, data: Data) {
        stubs[method] = data
    }

    func removeStub(method: String) {
        stubs[method] = nil
    }

    func send<Params, Result>(request: RPCRequest<Params>) async -> Web3Response<Result> {
        if let stubbedData = stubs[request.method] {
            do {
                let rpcResponse = try JSONDecoder().decode(RPCResponse<Result>.self, from: stubbedData)
                let res = Web3Response<Result>(rpcResponse: rpcResponse)
                return res
            } catch {
                let err = Web3Response<Result>(error: .decodingError(error))
                return err
            }
        } else {
            let err = Web3Response<Result>(error: .serverError(nil))
            return err
        }
    }

}

// Example of subclassing a common token implementation
class TestContract: GenericERC721Contract {

    private let byteCode = try! EthereumData(ethereumValue: "0x0123456789ABCDEF")

    // Example of a static constructor
    func deploy(name: String) -> SolidityConstructorInvocation {
        let constructor = SolidityConstructor(inputs: [SolidityFunctionParameter(name: "_name", type: .string)], handler: self)
        return constructor.invoke(byteCode: byteCode, parameters: [name])
    }

    // Example of a static function
    func buyToken() -> SolidityInvocation {
        let method = SolidityPayableFunction(name: "buyToken", inputs: [], outputs: nil, handler: self)
        return method.invoke()
    }
}

class ContractTests: QuickSpec {

    func stubResponses(provider: MockWeb3Provider) {
        if let transactionData = loadStub(named: "sendTransaction") {
            provider.addStub(method: "eth_sendTransaction", data: transactionData)
        }

        if let receiptData = loadStub(named: "getTransactionReceipt") {
            provider.addStub(method: "eth_getTransactionReceipt", data: receiptData)
        }

        if let callData = loadStub(named: "call_getBalance") {
            provider.addStub(method: "eth_call", data: callData)
        }

        if let gasData = loadStub(named: "estimateGas") {
            provider.addStub(method: "eth_estimateGas", data: gasData)
        }
    }

    override func spec() {

        describe("Contract") {
            let provider = MockWeb3Provider()
            stubResponses(provider: provider)
            let web3 = Web3(provider: provider)
            let contract = web3.eth.Contract(type: TestContract.self, address: .testAddress)

            describe("Constructor method") {
                it("should be able to be deployed") {
                    waitUntil { done in
                        Task {
                            let (hash, error) = await contract.deploy(name: "Test Instance").send(from: .testAddress, value: 0, gas: 15000, gasPrice: nil)
                                
                            if let error = error {
                                fail(error.localizedDescription)
                            }
                            if (hash != nil) {
                                done()
                            }
                        }
                    }
                }
            }

            describe("Constant method") {

                let invocation = contract.balanceOf(address: .testAddress)

                it("should succeed with call") {
                    waitUntil { done in
                        Task {
                            let (values, error) = await invocation.call()
                            if let error = error {
                                fail(error.localizedDescription)
                            }
                            
                            expect(values).to(equal(1))
                            done()
                        }
                    }
                }

                it("should fail with send") {
                    waitUntil { done in
                        Task {
                            let (_, error) = await invocation.send(nonce: nil, from: .testAddress, value: nil, gas: 0, gasPrice: 0)
                            expect(error as? InvocationError).to(equal(InvocationError.invalidInvocation))
                            done()
                        }
                    }
                }

            }

            describe("Payable method") {

                let invocation = contract.buyToken()

                it("should estimate gas") {
                    waitUntil { done in
                        Task {
                            let (gas, error) = await invocation.estimateGas(from: .testAddress, value: EthereumQuantity(quantity: 1.eth))
                            
                            if let error = error {
                                fail(error.localizedDescription)
                            }
                            
                            if (gas != nil) {
                                done()
                            }
                        }
                    }
                }

                it("should succeed with send") {
                    let expectedHash = try! EthereumData(ethereumValue: "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331")
                    waitUntil { done in
                        Task {
                            let (hash, error) = await invocation.send(nonce: nil, from: .testAddress, value: EthereumQuantity(quantity: 1.eth), gas: 21000, gasPrice: nil)
                            
                            if let error = error {
                                fail(error.localizedDescription)
                            }
                            
                            expect(hash).to(equal(expectedHash))
                            done()
                        }
                    }
                }

                it("should fail with call") {
                    waitUntil { done in
                        Task {
                            let (_, error) = await invocation.call()
                            
                            expect(error as? InvocationError).to(equal(.invalidInvocation))
                            done()
                        }
                    }
                }

            }

            describe("Non payable method") {

                let invocation = contract.transfer(to: .testAddress, tokenId: 1)

                it("should succeed with send") {
                    let expectedHash = try! EthereumData(ethereumValue: "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331")
                    waitUntil { done in
                        Task {
                            let (hash, error) = await invocation.send(nonce: nil, from: .testAddress, value: nil, gas: 12000, gasPrice: 700000)
                            
                            if let error = error {
                                fail(error.localizedDescription)
                            }
                            
                            expect(hash).to(equal(expectedHash))
                            done()
                        }
                    }
                }

                it("should fail with call") {
                    waitUntil { done in
                        Task {
                            let (_, error) = await invocation.call()
                            
                            expect(error as? InvocationError).to(equal(.invalidInvocation))
                            done()
                        }
                    }
                }
            }

            describe("Event") {
                let hash = try! EthereumData(ethereumValue: "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331")

                it("should be decoded from a matching log") {
                    waitUntil { done in
                        Task {
                            let response = await web3.eth.getTransactionReceipt(transactionHash: hash)
                            
                            switch response.status {
                            case .failure(let error):
                                fail(error.localizedDescription)
                            case .success(let receipt):
                                if let logs = receipt?.logs {
                                    for log in logs {
                                        if let _ = try? ABI.decodeLog(event: TestContract.Transfer, from: log) {
                                            done()
                                            break
                                        }
                                    }
                                }
                            }
        
                            
                        }
                    }
                }

            }
        }

    }

}
