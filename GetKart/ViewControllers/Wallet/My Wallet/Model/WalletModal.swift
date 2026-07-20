//
//  WalletModal.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/07/26.
//

import Foundation


import Foundation

// MARK: - WalletResponse
struct WalletResponse: Codable {
    let code: Int
    let data: WalletModal?
    let error: Bool
    let message: String
}

// MARK: - WalletData
struct WalletModal: Codable {
    
    let id: Int
    let userId: Int
    let balance: Int
    let totalAdded: Int
    let bonusAmount: Int
    let banner: String
    let howItWorks: [String]
    let createdAt: String?
    let updatedAt: String?
    let bonusAmountTermsCondition:[String]?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case balance
        case totalAdded = "total_added"
        case bonusAmount = "bonus_amount"
        case banner
        case howItWorks = "how_it_works"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case bonusAmountTermsCondition = "bonus_amount_terms_condition"
    }
}


