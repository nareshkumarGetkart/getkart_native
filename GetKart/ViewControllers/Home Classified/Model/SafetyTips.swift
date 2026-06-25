//
//  SafetyTips.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/03/25.
//

import Foundation

struct SafetyTipsParse: Codable {
    let error: Bool?
    let message: String?
    let data: [TipsModel]?
    let code: Int?
}
// MARK: - Datum
struct TipsModel: Codable,Identifiable {
    let id: Int?
    let description, translatedName: String?
    let translations: [JSONAny]?
    let icon:String?
    enum CodingKeys: String, CodingKey {
        case id, description, icon
        case translatedName
        case translations
    }
}


