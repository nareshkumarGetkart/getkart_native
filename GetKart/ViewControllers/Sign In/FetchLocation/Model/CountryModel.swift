//
//  CountryModel.swift
//  GetKart
//
//  Created by gurmukh singh on 3/4/25.
//



//   let countryParse = try? JSONDecoder().decode(CountryParse.self, from: jsonData)

import Foundation

// MARK: - CountryParse
struct CountryParse: Codable {
    var error: Bool?
    var message: String?
    var data: CountryModelClass?
    var code: Int?
}

// MARK: - DataClass
struct CountryModelClass: Codable {
    var currentPage: Int?
    var data: [CountryModel]?
    var firstPageURL: String?
    var from, lastPage: Int?
    var lastPageURL: String?
    var links: [Link]?
    var nextPageURL: String?
    var path: String?
    var perPage: Int?
    var prevPageURL: String?
    var to, total: Int?

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
        case prevPageURL = "prev_page_url"
        case to, total
    }
}

// MARK: - Datum
struct CountryModel: Codable,Identifiable {
    var id: Int?
    var name, iso3, numericCode, iso2: String?
    var phonecode: JSONNull?
    var capital, currency, currencyName, currencySymbol: String?
    var tld, native, region: String?
    var regionID: JSONNull?
    var subregion: String?
    var subregionID: JSONNull?
    var nationality, timezones, translations, latitude: String?
    var longitude, emoji, emojiU: String?
    var flag, wikiDataID: JSONNull?
    var createdAt, updatedAt: String?
    var statesCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, iso3
        case numericCode = "numeric_code"
        case iso2, phonecode, capital, currency
        case currencyName = "currency_name"
        case currencySymbol = "currency_symbol"
        case tld, native, region
        case regionID = "region_id"
        case subregion
        case subregionID = "subregion_id"
        case nationality, timezones, translations, latitude, longitude, emoji, emojiU, flag
        case wikiDataID = "wikiDataId"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case statesCount = "states_count"
    }
}

