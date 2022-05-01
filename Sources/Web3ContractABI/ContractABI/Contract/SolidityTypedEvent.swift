//
//  SolidityTypedEvent.swift
//  
//
//  Created by Monterey on 1/5/22.
//

import Foundation
#if !Web3CocoaPods
    import Web3
#endif

public struct SolidityTypedEvent<T> {
    public var event: SolidityEvent
    private var cast: ([String: Any]) throws -> T
    
    public init(event: SolidityEvent, _ cast: @escaping ([String: Any]) throws -> T) {
        self.cast = cast
        self.event = event
    }
    
    public func decode(log: EthereumLogObject) -> Result<T, Error> {
        do {
            return try .success(cast(ABI.decodeLog(event: event, from: log)))
        } catch {
            return .failure(error)
        }
    }
}
