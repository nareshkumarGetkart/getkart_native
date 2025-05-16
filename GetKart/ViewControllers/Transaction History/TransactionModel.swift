//
//  TransactionModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import Foundation

/*

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

*/
// MARK: - TransactionHistory
struct TransactionParse: Codable {
    let error: Bool?
    let message: String?
    let data: TransactionClass?
    let code: Int?
}

// MARK: - DataClass
struct TransactionClass: Codable {
    let currentPage, lastPage, perPage, total: Int?
    let data: [TransactionModel]?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total, data
    }
}

// MARK: - Datum
struct TransactionModel: Codable {
    let id, userID, packageID: Int?
    let startDate, endDate: String?
    let totalLimit, usedLimit: Int?
    let paymentTransactionsID: Int?
    let createdAt, updatedAt: String?
    let remainingDays :String?
    let remainingItemLimit: Int?
    let user: User?
    let package: Package?
    let paymentTransaction: PaymentTransaction?


    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case packageID = "package_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case totalLimit = "total_limit"
        case usedLimit = "used_limit"
        case paymentTransactionsID = "payment_transactions_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case remainingDays = "remaining_days"
        case remainingItemLimit = "remaining_item_limit"
        case user, package
        case paymentTransaction = "payment_transaction"

    }
}

// MARK: - Package
struct Package: Codable {
    let id: Int?
    let name: String?
    let tier: Int?
    let categories: String?
    let finalPrice: Double?
    let discountInPercentage, price: Int?
    let duration, itemLimit, type: String?
    let icon: String?
    let description: String?
    let status: Int?
    let iosProductID: String?
    let createdAt, updatedAt: String?
    let category :String?

    enum CodingKeys: String, CodingKey {
        case id, name, tier, categories
        case finalPrice = "final_price"
        case discountInPercentage = "discount_in_percentage"
        case price, duration
        case itemLimit = "item_limit"
        case type, icon, description, status
        case iosProductID = "ios_product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case category
    }
}

// MARK: - PaymentTransaction
struct PaymentTransaction: Codable {
    let id, userID: Int?
    let amount: Double?
    let paymentGateway, orderID, paymentStatus, createdAt: String?
    let updatedAt: String?
    let city:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case amount
        case city
        case paymentGateway = "payment_gateway"
        case orderID = "order_id"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/*// MARK: - User
struct User: Codable {
    let id: Int?
    let name, email, mobile: String?
    let mobileVisibility: Int?
    let emailVerifiedAt: JSONNull?
    let profile: String?
    let type, fcmID: String?
    let notification: Int?
    let firebaseID, address, createdAt, updatedAt: String?
    let deletedAt: JSONNull?
    let countryCode: String?
    let showPersonalDetails, isVerified: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, email, mobile, mobileVisibility
        case emailVerifiedAt = "email_verified_at"
        case profile, type
        case fcmID = "fcm_id"
        case notification
        case firebaseID = "firebase_id"
        case address
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case countryCode = "country_code"
        case showPersonalDetails = "show_personal_details"
        case isVerified = "is_verified"
    }
}
*/
