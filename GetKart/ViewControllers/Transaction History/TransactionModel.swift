//
//  TransactionModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import Foundation


struct TransactionModel: Identifiable {
    let id = UUID()
    let platform: String
    let transactionId: String
    let amount: String
}
