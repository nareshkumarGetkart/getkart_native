
//   let stateParse = try? JSONDecoder().decode(StateParse.self, from: jsonData)

import Foundation

// MARK: - StateParse
struct StateParse: Codable {
    var error: Bool?
    var message: String?
    var data: StateModalClass?
    var code: Int?
}

// MARK: - DataClass
struct StateModalClass: Codable {
    var currentPage: Int?
    var data: [StateModal]?
    var firstPageURL: String?
    var from, lastPage: Int?
    var lastPageURL: String?
    var links: [Link]?
    var nextPageURL, path: String?
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
struct StateModal: Codable, Identifiable {
    var id: Int?
    var name: String?
    var countryID: Int?
    var stateCode: String?
    var fipsCode, iso2: String?
    var type, latitude, longitude: String?
    var flag, wikiDataID: String?
    var createdAt, updatedAt: String?
    var citiesCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name
        case countryID = "country_id"
        case stateCode = "state_code"
        case fipsCode = "fips_code"
        case iso2, type, latitude, longitude, flag
        case wikiDataID = "wikiDataId"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case citiesCount = "cities_count"
    }
}





// MARK: - Encode/decode helpers

