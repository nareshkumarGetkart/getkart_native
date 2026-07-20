//
//  PromotionPkgModal.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/10/25.
//


import Foundation

// MARK: - Welcome
struct PromotionPkg: Codable {
    let error: Bool
    let message: String
    let data: [PlanModel] //[PromotionPkgModal]
    let code: Int
}

// MARK: - Datum
struct PromotionPkgModal: Codable,Identifiable, Equatable  {
    let id: Int
    let name: String
   // let tier: JSONNull?
    let categories: String
    let finalPrice: Int
    let discountInPercentage: Int
    let price: Int
    let duration, itemLimit, type: String
    let icon: String
    let description: String
    let status: Int
  //  let iosProductID: JSONNull?
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, categories //tier
        case finalPrice = "final_price"
        case discountInPercentage = "discount_in_percentage"
        case price, duration
        case itemLimit = "item_limit"
        case type, icon, description, status
       // case iosProductID = "ios_product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


