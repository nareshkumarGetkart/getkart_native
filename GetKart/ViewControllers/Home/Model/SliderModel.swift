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
    let id: Int
    let image: String
    let sequence, thirdPartyLink, createdAt, updatedAt: String
    let modelType, modelID: JSONNull?
    let appRedirection: Bool
    let redirectionType: String
    let model: JSONNull?

    enum CodingKeys: String, CodingKey {
        case id, image, sequence
        case thirdPartyLink = "third_party_link"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case modelType = "model_type"
        case modelID = "model_id"
        case appRedirection, redirectionType, model
    }
}

