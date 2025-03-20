//
//  MyAdsModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/03/25.
//

import Foundation


// MARK: - Empty
//struct Empty: Codable {
//    let error: Bool?
//    let message: String?
//    let data: DataClass?
//    let code: Int?
//}
//
//// MARK: - DataClass
//struct DataClass: Codable {
//    let currentPage: Int?
//    let data: [Datum]?
//    let firstPageURL: String?
//    let from, lastPage: Int?
//    let lastPageURL: String?
//    let links: [Link]?
//    let nextPageURL: JSONNull?
//    let path: String?
//    let perPage: Int?
//    let prevPageURL: JSONNull?
//    let to, total: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case currentPage
//        case data
//        case firstPageURL
//        case from
//        case lastPage
//        case lastPageURL
//        case links
//        case nextPageURL
//        case path
//        case perPage
//        case prevPageURL
//        case to, total
//    }
//}
//
//// MARK: - Datum
//struct Datum: Codable {
//    let id: Int?
//    let name, slug, description: String?
//    let price: Int?
//    let image: String?
//    let watermarkImage: JSONNull?
//    let latitude, longitude: Double?
//    let address, contact: String?
//    let showOnlyToPremium: Int?
//    let status, rejectedReason: String?
//    let videoLink: JSONNull?
//    let clicks: Int?
//    let city, state, country: String?
//    let areaID: JSONNull?
//    let userID: Int?
//    let soldTo: JSONNull?
//    let categoryID: Int?
//    let allCategoryIDS, expiryDate, createdAt, updatedAt: String?
//    let deletedAt: JSONNull?
//    let user: User?
//    let category: Category?
//    let galleryImages: [GalleryImage]?
//    let featuredItems: [JSONAny]?
//    let favourites: [Favourite]?
//    let area: JSONNull?
//    let itemOffers, userReports: [JSONAny]?
//    let isFeature: Bool?
//    let totalLikes: Int?
//    let isLiked: Bool?
//    let customFields: [CustomField]?
//    let isAlreadyOffered, isAlreadyReported: Bool?
//    let isPurchased: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, slug, description, price, image
//        case watermarkImage
//        case latitude, longitude, address, contact
//        case showOnlyToPremium
//        case status
//        case rejectedReason
//        case videoLink
//        case clicks, city, state, country
//        case areaID
//        case userID
//        case soldTo
//        case categoryID
//        case allCategoryIDS
//        case expiryDate
//        case createdAt
//        case updatedAt
//        case deletedAt
//        case user, category
//        case galleryImages
//        case featuredItems
//        case favourites, area
//        case itemOffers
//        case userReports
//        case isFeature
//        case totalLikes
//        case isLiked
//        case customFields
//        case isAlreadyOffered
//        case isAlreadyReported
//        case isPurchased
//    }
//}



// MARK: - Favourite
//struct Favourite: Codable {
//    let id: Int?
//    let createdAt, updatedAt: String?
//    let userID, itemID: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case createdAt
//        case updatedAt
//        case userID
//        case itemID
//    }
//}

// MARK: - GalleryImage
//struct GalleryImage: Codable {
//    let id: Int?
//    let image: String?
//    let itemID: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id, image
//        case itemID
//    }
//}

//// MARK: - User
//struct User: Codable {
//    let id: Int?
//    let name, email, mobile: String?
//    let profile: String?
//    let createdAt: String?
//    let isVerified, showPersonalDetails: Int?
//    let countryCode: String?
//    let reviewsCount: Int?
//    let averageRating: JSONNull?
//    let sellerReview: [JSONAny]?
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, email, mobile, profile
//        case createdAt
//        case isVerified
//        case showPersonalDetails
//        case countryCode
//        case reviewsCount
//        case averageRating
//        case sellerReview
//    }
//}

