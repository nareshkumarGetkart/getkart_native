//
//  TransactionModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import Foundation



// MARK: - Transaction
struct TransactionParse: Codable {
    let error: Bool?
    let message: String?
    let data: [TransactionModel]?
    let code: Int?
}

// MARK: - Datum
struct TransactionModel: Codable,Identifiable {
    let id, userID, amount: Int?
    let paymentGateway, orderID, paymentStatus, createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case amount = "amount"
        case paymentGateway = "payment_gateway"
        case orderID = "order_id"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
