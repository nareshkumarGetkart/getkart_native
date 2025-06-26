//
//  SearchModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/06/25.
//

import Foundation



// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let searchSuggestion = try? JSONDecoder().decode(SearchSuggestion.self, from: jsonData)

import Foundation

// MARK: - SearchSuggestion
struct SearchSuggestion: Codable {
    let error: Bool
    let message: String
    let data: [Search]?
    let code: Int
}

// MARK: - Datum
struct Search: Codable {
    let categoryID: Int?
    let categoryName: String?
    let categoryImage: String?
    let keyword: String?

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case categoryImage = "category_image"
        case keyword
    }
}
