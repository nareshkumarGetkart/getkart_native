//
//  AreaModal.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/08/25.
//

import Foundation


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let areaModelParse = try? JSONDecoder().decode(AreaModelParse.self, from: jsonData)


// MARK: - AreaModelParse
struct AreaModelParse: Codable {
    let error: Bool
    let message: String
    let data: AreaModelClass?
    let code: Int
}

// MARK: - DataClass
struct AreaModelClass: Codable {
    let currentPage: Int?
    let data: [AreaModal]?
    let firstPageURL: String?
    let from, lastPage: Int?
    let lastPageURL: String?
    let links: [Link]?
    let nextPageURL, path: String?
    let perPage: Int?
  //  let prevPageURL: JSONNull?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case links
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
      //  case prevPageURL = "prev_page_url"
        case to, total
    }
}

// MARK: - Datum
struct AreaModal: Codable,Identifiable {
    let id: Int?
    let name: String?
    let cityID, stateID: Int?
    let stateCode: String?
    let countryID: Int?
    let createdAt, updatedAt: String?
    var latitude, longitude: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case latitude, longitude
        case cityID = "city_id"
        case stateID = "state_id"
        case stateCode = "state_code"
        case countryID = "country_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
  
}



