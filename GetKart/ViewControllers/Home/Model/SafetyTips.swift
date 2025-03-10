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

    enum CodingKeys: String, CodingKey {
        case id, description
        case translatedName
        case translations
    }
}


