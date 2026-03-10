//
//  FavoriteModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/03/25.
//

import Foundation


// MARK: - Favorite
struct FavoriteParse: Codable {
    let error: Bool?
    let message: String?
    let data: FavoriteClass?
    let code: Int?
}

// MARK: - DataClass
struct FavoriteClass: Codable {
    let currentPage: Int?
    let data: [ItemModel]?
    let firstPageURL: String?
    let from, lastPage: Int?
    let lastPageURL: String?
    let links: [Link]?
    let nextPageURL: String?
    let path: String?
    let perPage: Int?
    let prevPageURL: String?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage
        case data
        case firstPageURL
        case from
        case lastPage
        case lastPageURL
        case links
        case nextPageURL
        case path
        case perPage
        case prevPageURL
        case to, total
    }
}

