//
//  PlanModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/04/25.
//

import Foundation


// MARK: - Plan
struct Plan: Codable {
    let error: Bool?
    let message: String?
    let data: [[PlanModel]]?
    let code: Int?
}

// MARK: - Datum
struct PlanModel: Codable {
    let id: Int?
    let name: String?
    let tier: Int?
    let finalPrice, discountInPercentage, price: Int?
    let duration, itemLimit: String?
    let type: TypePlanEnum?
    let icon: String?
    let description: String?
    let status: Int?
    let iosProductID: String?
    let createdAt, updatedAt: String?
    let categories: String?
    let isActive, purchaseAllow: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, tier
        case finalPrice = "final_price"
        case discountInPercentage = "discount_in_percentage"
        case price, duration
        case itemLimit = "item_limit"
        case type, icon, description, status
        case iosProductID = "ios_product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case categories
        case isActive = "is_active"
        case purchaseAllow
    }
}

enum TypePlanEnum: String, Codable {
    case advertisement = "advertisement"
    case itemListing = "item_listing"
    case itemListingAutoboost = "item_listing_autoboost"
}





struct PlanBanner: Codable {
    let error: Bool?
    let message: String?
    let data: [String]?
    let code: Int?
}
