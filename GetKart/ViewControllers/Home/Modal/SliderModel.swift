//
//  SliderModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import Foundation


struct SliderModelParse: Codable {
    let error: Bool
    let message: Message
    let data: [SliderModel]?
    let code: Int
}

// MARK: - Datum
struct SliderModel: Codable {
    let id: Int?
    let image: String?
    let sequence, thirdPartyLink, createdAt, updatedAt: String?
    let modelType:String?
    let modelID: Int?
    let appRedirection: Bool?
    let redirectionType: String?
    let model: Model?
    let is_campaign:Bool?
    let is_active:Int?
    let campaign_id:Int?
    
    enum CodingKeys: String, CodingKey {
        case id, image, sequence
        case thirdPartyLink = "third_party_link"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case modelType = "model_type"
        case modelID = "model_id"
        case appRedirection, redirectionType, model
        case is_campaign, is_active, campaign_id

    }
}


// MARK: - Model
struct Model: Codable {
    let id, sequence: Int?
    let name: String?
    let image: String?
    let parentCategoryID: Int?
    let description: String?
   // let status: String?
    let createdAt, updatedAt, slug: String?
    let subcategoriesCount: Int?
    let translatedName: String?

    enum CodingKeys: String, CodingKey {
        case id, sequence, name, image
        case parentCategoryID = "parent_category_id"
        case description //, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case slug
        case subcategoriesCount = "subcategories_count"
        case translatedName = "translated_name"
    }
}
