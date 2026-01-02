//
//  PopupModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/08/25.
//

import Foundation


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let popupModel = try? JSONDecoder().decode(PopupModel.self, from: jsonData)

import Foundation

// MARK: - PopupModel
struct PopupParseModel: Codable {
    let error: Bool
    let message: String
    let data: PopupModel
    let code: Int
}

// MARK: - DataClass
struct PopupModel: Codable {
    let userID: Int?
    let title, subtitle, description: String?
    let image: String?
    let mandatoryClick: Bool?
    let buttonTitle: String?
    let type, itemID: Int?
    let secondButtonTitle:String?
    

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case title, subtitle, description, image
        case mandatoryClick = "mandatory_click"
        case buttonTitle, type
        case itemID = "item_id"
        case secondButtonTitle
    }
}
