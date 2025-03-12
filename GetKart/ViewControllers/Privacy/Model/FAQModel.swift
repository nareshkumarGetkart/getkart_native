//
//  FAQModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/03/25.
//

import Foundation

// MARK: - FAQ
struct FAQParse: Codable {
    let error: Bool?
    let message: String?
    let data: [FAQ]?
    let code: Int?
}

// MARK: - Datum
struct FAQ: Codable,Identifiable {
    let id: Int?
    let question, answer, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, question, answer
        case createdAt
        case updatedAt
    }
}
