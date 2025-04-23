//
//  SellerModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/03/25.
//


// MARK: - Seller
struct SellerParse: Codable {
    let error: Bool?
    let message: String?
    let data: SellerClass?
    let code: Int?
}

// MARK: - DataClass
struct SellerClass: Codable {
    let seller: SellerModel?
    let ratings: Ratings?
}

// MARK: - Ratings
struct Ratings: Codable {
    let currentPage: Int?
    let data: [JSONAny]?
    let firstPageURL: String?
    let from: String?
    let lastPage: Int?
    let lastPageURL: String?
    let links: [Link]?
    let nextPageURL: String?
    let path: String?
    let perPage: Int?
    let prevPageURL, to: String?
    let total: Int?

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


// MARK: - SellerClass
struct SellerModel: Codable,Identifiable {
    let id: Int?
    let name, email, mobile: String?
    let mobileVisibility: Int?
    let emailVerifiedAt, profile: String?
    let type, fcmID: String?
    let notification: Int?
    let firebaseID, address, createdAt, updatedAt: String?
    let deletedAt: String?
    let countryCode: String?
    let showPersonalDetails, isVerified: Int?
    var isFollowing: Bool?
    let averageRating: String?
    let followersCount, followingCount, items: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, email, mobile, mobileVisibility
        case emailVerifiedAt = "email_verified_at"
        case profile, type
        case fcmID = "fcm_id"
        case notification
        case firebaseID = "firebase_id"
        case address
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case countryCode = "country_code"
        case showPersonalDetails = "show_personal_details"
        case isVerified = "is_verified"
        case isFollowing
        case averageRating = "average_rating"
        case followersCount, followingCount, items
    }
}


