//
//  TransactionStatus.swift
//  
//
//  Created by Monterey on 2/4/22.
//

import Foundation

public enum TransactionStatus {
    case pending
    case confirmed(receipt: EthereumTransactionReceiptObject, times: Int)
    case successful(receipt: EthereumTransactionReceiptObject)
}
