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
    let finalPrice: String?
    let discountInPercentage, price: String?
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try? container.decode(Int.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        tier = try? container.decode(Int.self, forKey: .tier)

        // Flexible decode for finalPrice
        if let stringValue = try? container.decode(String.self, forKey: .finalPrice) {
            finalPrice = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .finalPrice) {
            finalPrice = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: .finalPrice) {
            finalPrice = String(doubleValue)
        } else {
            finalPrice = nil
        }

        
        
        // Flexible decode for price
        if let stringValue = try? container.decode(String.self, forKey: .price) {
            price = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .price) {
            price = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: .price) {
            price = String(doubleValue)
        } else {
            price = nil
        }
        
        
        // Flexible decode for discountInPercentage
        if let stringValue = try? container.decode(String.self, forKey: .discountInPercentage) {
            discountInPercentage = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .discountInPercentage) {
            discountInPercentage = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: .discountInPercentage) {
            discountInPercentage = String(doubleValue)
        } else {
            discountInPercentage = nil
        }
        
        duration = try? container.decode(String.self, forKey: .duration)
        itemLimit = try? container.decode(String.self, forKey: .itemLimit)
        type = try? container.decode(TypePlanEnum.self, forKey: .type)
        icon = try? container.decode(String.self, forKey: .icon)
        description = try? container.decode(String.self, forKey: .description)
        status = try? container.decode(Int.self, forKey: .status)
        iosProductID = try? container.decode(String.self, forKey: .iosProductID)
        createdAt = try? container.decode(String.self, forKey: .createdAt)
        updatedAt = try? container.decode(String.self, forKey: .updatedAt)
        categories = try? container.decode(String.self, forKey: .categories)
        isActive = try? container.decode(Bool.self, forKey: .isActive)
        purchaseAllow = try? container.decode(Bool.self, forKey: .purchaseAllow)
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
