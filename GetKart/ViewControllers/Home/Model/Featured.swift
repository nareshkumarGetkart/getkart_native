//
//  Featured.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 03/03/25.
//

import Foundation

// MARK: - FeaturedParse

struct FeaturedParse: Codable {
    let error: Bool
    let message: String
    let data: [FeaturedClass]
    let code: Int
}

// MARK: - FeaturedClass
struct FeaturedClass: Codable {
    let id: Int?
    let title, slug: String?
    let sequence: Int?
    let  value: String?
    let filter, style: String?
    let minPrice, maxPrice: Int?
    let createdAt, updatedAt: String?
    let description: String?
    let totalData: Int?
    let sectionData: [ItemModel]?

    enum CodingKeys: String, CodingKey {
        case id, title, slug, sequence, filter, style
        case minPrice = "min_price"
        case maxPrice = "max_price"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case description
        case value
        case totalData = "total_data"
        case sectionData = "section_data"
    }
}

// MARK: - SectionDatum
//struct ItemModel: Codable {
//    let id: Int
//    let name, slug, description: String
//    let price: Int?
//    let image: String?
//    let watermarkImage: String?
//    let latitude, longitude: Double
//    let address, contact: String
//    let showOnlyToPremium: Int
//    let status: Status
//    let rejectedReason: String
//    let videoLink: String?
//    let clicks: Int
//    let city, state: String
//    let country: Country
//    let areaID: Int?
//    let userID: Int
//    let soldTo: String?
//    let categoryID: Int
//    let allCategoryIDS, expiryDate, createdAt, updatedAt: String
//    let deletedAt: String?
//    let favouritesCount: Int
//    let user: User
//    let category: Category
//    let galleryImages: [GalleryImage]
//    let featuredItems, favourites: [JSONAny]
//    let isFeature: Bool
//    let totalLikes: Int
//    let isLiked: Bool
//    let customFields: [CustomField]
//    let isAlreadyOffered, isAlreadyReported: Bool
//    let isPurchased: Int
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, slug, description, price, image
//        case watermarkImage = "watermark_image"
//        case latitude, longitude, address, contact
//        case showOnlyToPremium = "show_only_to_premium"
//        case status
//        case rejectedReason = "rejected_reason"
//        case videoLink = "video_link"
//        case clicks, city, state, country
//        case areaID = "area_id"
//        case userID = "user_id"
//        case soldTo = "sold_to"
//        case categoryID = "category_id"
//        case allCategoryIDS = "all_category_ids"
//        case expiryDate = "expiry_date"
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case deletedAt = "deleted_at"
//        case favouritesCount = "favourites_count"
//        case user, category
//        case galleryImages = "gallery_images"
//        case featuredItems = "featured_items"
//        case favourites
//        case isFeature = "is_feature"
//        case totalLikes = "total_likes"
//        case isLiked = "is_liked"
//        case customFields = "custom_fields"
//        case isAlreadyOffered = "is_already_offered"
//        case isAlreadyReported = "is_already_reported"
//        case isPurchased = "is_purchased"
//    }
//}

