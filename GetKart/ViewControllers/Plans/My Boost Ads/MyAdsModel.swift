//
//  MyAdsModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/04/25.
//

import Foundation


// MARK: - MyAds
struct MyAdsParse: Codable {
    let error: Bool?
    let message: String?
    let data: MyAdsClass?
    let code: Int?
}

// MARK: - DataClass
struct MyAdsClass: Codable {
   
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

/*
// MARK: - Datum
struct Datum: Codable {
    let id: Int?
    let name, slug, description: String?
    let price: Int?
    let image: String?
    let watermarkImage: JSONNull?
    let latitude, longitude: Double?
    let address, contact: String?
    let showOnlyToPremium: Int?
    let status: String?
    let rejectedReason, videoLink: JSONNull?
    let clicks: Int?
    let city, state, country: String?
    let areaID: JSONNull?
    let userID: Int?
    let soldTo: JSONNull?
    let categoryID: Int?
    let allCategoryIDS: String?
    let expiryDate: JSONNull?
    let createdAt, updatedAt: String?
    let deletedAt: JSONNull?
    let user: User?
    let category: Category?
    let galleryImages, featuredItems, favourites: [JSONAny]?
    let area: JSONNull?
    let itemOffers, userReports: [JSONAny]?
    let isFeature: Bool?
    let totalLikes: Int?
    let isLiked: Bool?
    let customFields: [CustomField]?
    let isAlreadyOffered, isAlreadyReported: Bool?
    let isPurchased: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, price, image
        case watermarkImage = "watermark_image"
        case latitude, longitude, address, contact
        case showOnlyToPremium = "show_only_to_premium"
        case status
        case rejectedReason = "rejected_reason"
        case videoLink = "video_link"
        case clicks, city, state, country
        case areaID = "area_id"
        case userID = "user_id"
        case soldTo = "sold_to"
        case categoryID = "category_id"
        case allCategoryIDS = "all_category_ids"
        case expiryDate = "expiry_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case user, category
        case galleryImages = "gallery_images"
        case featuredItems = "featured_items"
        case favourites, area
        case itemOffers = "item_offers"
        case userReports = "user_reports"
        case isFeature = "is_feature"
        case totalLikes = "total_likes"
        case isLiked = "is_liked"
        case customFields = "custom_fields"
        case isAlreadyOffered = "is_already_offered"
        case isAlreadyReported = "is_already_reported"
        case isPurchased = "is_purchased"
    }
}*/

