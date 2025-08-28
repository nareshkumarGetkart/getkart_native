
import Foundation

// MARK: - CityParse
struct CityParse: Codable {
    var error: Bool?
    var message: String?
    var data: CityClass?
    var code: Int?
}

// MARK: - DataClass
struct CityClass: Codable {
    var currentPage: Int?
    var data: [CityModal]?
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
struct CityModal: Codable, Identifiable {
    var id: Int?
    var name: String?
    var stateID: Int?
    var stateCode: String?
    var countryID: Int?
    var countryCode: String?
    var latitude, longitude: String?
    var flag, wikiDataID, createdAt, updatedAt: String?
    var areasCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name
        case stateID = "state_id"
        case stateCode = "state_code"
        case countryID = "country_id"
        case countryCode = "country_code"
        case latitude, longitude, flag
        case wikiDataID = "wikiDataId"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case areasCount = "areas_count"
    }
}




