//
//  CampaignBannerModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 29/10/25.
//

import Foundation

// MARK: - Welcome
struct CampaignBannerParse: Codable {
    let error: Bool?
    let message: String?
    let data: CampaignBanneClass?
    let code: Int?
}

// MARK: - DataClass
struct CampaignBanneClass: Codable {
    let currentPage: Int?
    let data: [UserBannerModel]?
    let firstPageURL: String?
    let from, lastPage: Int?
    let lastPageURL: String?
    let links: [Link]?
    let nextPageURL, path: String?
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

// MARK: - Datum
struct UserBannerModel: Codable {
    
    let id, userID: Int?
    let userPurchasedPackageID: Int?
    let campaignID: Int?
    let imagePath: String?
    let fileType: String?
    let country, state, city: String?
    let area, pincode: String?
    let latitude, longitude: String?
    let radius: Int?
    let type: String?
    let url: String?
    let status: String?
    let isActive: Int?
    let rejectionReason: String?
    let startDate: String?
    let endDate: String?
    let createdAt, updatedAt: String?
    let deletedAt: String?
    let user: User?
    let analyticsSummary: AnalyticsSummary?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case userPurchasedPackageID = "user_purchased_package_id"
        case campaignID = "campaign_id"
        case imagePath = "image_path"
        case fileType = "file_type"
        case country, state, city, area, pincode, latitude, longitude, radius, type, url, status
        case isActive = "is_active"
        case rejectionReason = "rejection_reason"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case user
        case analyticsSummary = "analytics_summary"

    }
}

// MARK: - AnalyticsSummary
struct AnalyticsSummary: Codable {
    let campaignBannerID: Int?
    let totalImpressions, totalClicks, totalUniqueViews: String?
 

    enum CodingKeys: String, CodingKey {
        case campaignBannerID = "campaign_banner_id"
        case totalImpressions = "total_impressions"
        case totalClicks = "total_clicks"
        case totalUniqueViews = "total_unique_views"

    }
}


