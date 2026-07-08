//
//  WalletTransaction.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/06/26.
//

import Foundation

//
//struct WalletTransaction: Identifiable {
//    let id = UUID()
//    let title: String
//    let txnID: String
//    let amount: Double
//    let date: String
//    let time: String
//    let status: TransactionStatus
//    let type: TransactionType
//    let iconSystemName: String
//}




// MARK: - Wallet History Response
struct WalletHistoryResponse: Codable {
    let code: Int?
    let data: WalletHistoryData?
    let error: Bool?
    let message: String?
}

// MARK: - Pagination Data
struct WalletHistoryData: Codable {
    let currentPage: Int
    let data: [WalletTransaction]
    let firstPageURL: String
    let from: Int?
    let lastPage: Int
    let lastPageURL: String
    //let links: [PaginationLink]
    let nextPageURL: String?
    let path: String
    let perPage: Int
    let prevPageURL: String?
    let to: Int?
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
       // case links
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to
        case total
    }
}

// MARK: - Wallet Transaction
struct WalletTransaction: Codable, Identifiable {
    let id: Int
    let amount: String
    let createdAt: String
    let description: String?
    let meta: WalletMeta?
    let paymentTransactionID: Int
    let status: String
    let title: String
    let txnID: String
    let type: String
    let updatedAt: String
    let userID: Int
    let walletID: Int

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case createdAt = "created_at"
        case description
        case meta
        case paymentTransactionID = "payment_transaction_id"
        case status
        case title
        case txnID = "txn_id"
        case type
        case updatedAt = "updated_at"
        case userID = "user_id"
        case walletID = "wallet_id"
    }
}

// MARK: - Bonus Meta
struct WalletMeta: Codable {
    let baseAmount: Int?
    let bonus: Int?

    enum CodingKeys: String, CodingKey {
        case baseAmount = "base_amount"
        case bonus
    }
}

// MARK: - Pagination Link
struct PaginationLink: Codable {
    let active: Bool
    let label: String
    let url: String?
}
