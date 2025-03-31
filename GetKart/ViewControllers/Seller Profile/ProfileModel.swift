//
//  ProfileModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/03/25.
//

import Foundation


// MARK: - Profile
struct Profile: Codable {
    let error: Bool?
    let message: String?
    let data: PersonClass?
    let code: Int?
}

// MARK: - DataClass
struct PersonClass: Codable {
    let seller: Seller?
    let ratings: Ratings?
}

// MARK: - Ratings


// MARK: - Seller
struct Seller: Codable {
    let id: Int?
    let name, email, mobile: String?
    let mobileVisibility: Int?
    let emailVerifiedAt, profile: String?
    let type, fcmID: String?
    let notification: Int?
    let firebaseID: String?
    let address: String?
    let createdAt, updatedAt: String?
    let deletedAt: String?
    let countryCode: String?
    let showPersonalDetails, isVerified: Int?
    let isFollowing: Bool?
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

