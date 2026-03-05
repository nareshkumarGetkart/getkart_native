//
//  CommentModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 26/02/26.
//

import Foundation

//struct CommentModel: Identifiable {
//    let id = UUID()
//    let name: String
//    let profileImage: String
//    let comment: String
//    let time: String
//    var likes: Int
//    var isLiked: Bool
//}



// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let comment = try? JSONDecoder().decode(Comment.self, from: jsonData)

import Foundation

// MARK: - Comment
struct CommentParse: Codable {
    let error: Bool?
    let message: String?
    let data: CommentClass?
    let code: Int?
}

// MARK: - DataClass
struct CommentClass: Codable {
    let data: [CommentModel]?
    let path: String?
    let perPage: Int?
    let nextCursor, nextPageURL, prevCursor, prevPageURL: String?

    enum CodingKeys: String, CodingKey {
        case data, path
        case perPage = "per_page"
        case nextCursor = "next_cursor"
        case nextPageURL = "next_page_url"
        case prevCursor = "prev_cursor"
        case prevPageURL = "prev_page_url"
    }
}

// MARK: - Datum
struct CommentModel: Codable,Identifiable {
   
    let id, itemID, userID: Int?
    let parentID: Int?
    var comment: String?
    var likesCount, repliesCount: Int?
    let isDeleted: Bool?
    let createdAt, updatedAt: String?
    let isOwner: Bool?
    var isLiked: Bool?
    let user: User?
    var replyArray:[CommentModel]?

    enum CodingKeys: String, CodingKey {
        case id
        case itemID = "item_id"
        case userID = "user_id"
        case parentID = "parent_id"
        case comment
        case likesCount = "likes_count"
        case repliesCount = "replies_count"
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isOwner = "is_owner"
        case isLiked = "is_liked"
        case user
    }
}


// MARK: - Comment
struct CommentSingleParse: Codable {
    let error: Bool?
    let message: String?
    let data: CommentModel?
    let code: Int?
}

//// MARK: - User
//struct User: Codable {
//    let id: Int
//    let name, email, mobile: String
//    let mobileVisibility: Int
//    let emailVerifiedAt: JSONNull?
//    let profile: String
//    let type, fcmID: String
//    let notification: Int
//    let firebaseID: String
//    let address: JSONNull?
//    let createdAt, updatedAt: String
//    let deletedAt: JSONNull?
//    let countryCode: String
//    let showPersonalDetails, isVerified: Int
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, email, mobile, mobileVisibility
//        case emailVerifiedAt = "email_verified_at"
//        case profile, type
//        case fcmID = "fcm_id"
//        case notification
//        case firebaseID = "firebase_id"
//        case address
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case deletedAt = "deleted_at"
//        case countryCode = "country_code"
//        case showPersonalDetails = "show_personal_details"
//        case isVerified = "is_verified"
//    }
//}

// MARK: - Encode/decode helpers

