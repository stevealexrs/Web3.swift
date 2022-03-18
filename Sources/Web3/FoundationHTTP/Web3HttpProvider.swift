//
//  Web3HttpProvider.swift
//  Web3
//
//  Created by Koray Koska on 17.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation

public struct Web3HttpProvider: Web3Provider {

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let queue: DispatchQueue

    let session: URLSession

    static let headers = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]

    public let rpcURL: String

    public init(rpcURL: String, session: URLSession = URLSession(configuration: .default)) {
        self.rpcURL = rpcURL
        self.session = session
        // Concurrent queue for faster concurrent requests
        self.queue = DispatchQueue(label: "Web3HttpProvider", attributes: .concurrent)
    }

    public func send<Params, Result: Codable>(request: RPCRequest<Params>) async -> Web3Response<Result> {
        let body: Data
        do {
            body = try self.encoder.encode(request)
        } catch {
            let err = Web3Response<Result>(error: .requestFailed(error))
            return err
        }

        guard let url = URL(string: self.rpcURL) else {
            let err = Web3Response<Result>(error: .requestFailed(nil))
            return err
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = body
        for (k, v) in type(of: self).headers {
            req.addValue(v, forHTTPHeaderField: k)
        }
        
        let data: Data
        let urlResponse: URLResponse
        do {
            (data, urlResponse) = try await self.session.data(for: req)
            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                let err = Web3Response<Result>(error: .customError("Cannot convert URLResponse to HTTPURLResponse"))
                return err
            }
            
            let status = urlResponse.statusCode
            guard status >= 200 && status < 300 else {
                // This is a non typical rpc error response and should be considered a server error.
                let err = Web3Response<Result>(error: .serverError(nil))
                return err
            }
        } catch {
            return Web3Response<Result>(error: .serverError(error))
        }
        
        do {
            let rpcResponse = try self.decoder.decode(RPCResponse<Result>.self, from: data)
            // We got the Result object
            let res = Web3Response(rpcResponse: rpcResponse)
            return res
        } catch {
            // We don't have the response we expected...
            let err = Web3Response<Result>(error: .decodingError(error))
            return err
        }
    }
}
