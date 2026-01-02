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
struct TransactionModel: Codable,Identifiable {
    var id, userID, packageID: Int?
    let startDate, endDate: String?
    let totalLimit, usedLimit: Int?
    let paymentTransactionsID: Int?
    let createdAt, updatedAt: String?
    let remainingDays :String?
    let remainingItemLimit: Int?
    let user: User?
    let package: Package?
    let paymentTransaction: PaymentTransaction?
    let banners: [Banner]?
    let invoiceNo :String?
    let invoiceId: Int?
    let transactionPackage:TransactionPackage?
    let items:[Item]?

    enum CodingKeys: String, CodingKey {
        case id,banners
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
        case invoiceNo = "invoice_no"
        case invoiceId = "invoice_id"
        case transactionPackage = "transaction_package"
        case items

    }
}


struct Item: Codable,Identifiable {
    let id:Int?
    let startDate:String?
    let endDate:String?
    let packageId:Int?
    let createdAt:String?
    let updatedAt:String?
    let itemId:Int?
    let userPurchasedPackageId:Int?
    enum CodingKeys:String,CodingKey{
        
        case id
        case startDate = "start_date"
        case endDate = "end_date"
        case packageId = "package_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case itemId = "item_id"
        case userPurchasedPackageId = "user_purchased_package_id"
    }

}


                
struct TransactionPackage:Codable{
    
    let id: Int?
    let createdAt: String?
    let description: String?
    let name: String?
    let price: Int?
    let status: Int?
    let type: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id,name,price,type,status,description
        case updatedAt = "updated_at"
        case createdAt = "created_at"
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


// MARK: - Banner
struct Banner: Codable {
    let id, userID, userPurchasedPackageID: Int?
    let campaignID: Int?
    let imagePath: String?
    let fileType: Int?
    let country, state: String?
    let city: String?
    let area, pincode: String?
    let latitude, longitude: String?
    let radius: Int?
    let type: String?
    let url: String?
    let status: String?
    let isActive: Int?
    let rejectionReason: String?
    let startDate: String?
    let endDate: String?
    let createdAt, updatedAt: String?
    let deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case userPurchasedPackageID = "user_purchased_package_id"
        case campaignID = "campaign_id"
        case imagePath = "image_path"
        case fileType = "file_type"
        case country, state, city, area, pincode, latitude, longitude, radius, type, url, status
        case isActive = "is_active"
        case rejectionReason = "rejection_reason"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
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
