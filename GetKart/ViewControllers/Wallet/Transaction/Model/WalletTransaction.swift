//
//  WalletTransaction.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/06/26.
//

import Foundation


struct WalletTransaction: Identifiable {
    let id = UUID()
    let title: String
    let txnID: String
    let amount: Double
    let date: String
    let time: String
    let status: TransactionStatus
    let type: TransactionType
    let iconSystemName: String
}
