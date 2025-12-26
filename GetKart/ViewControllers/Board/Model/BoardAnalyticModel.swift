//
//  BoardAnalyticModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/12/25.
//

import Foundation


// MARK: - BoardAnalytics
struct BoardAnalyticsParse: Codable {
    let error: Bool?
    let message: String
    let data: BoardAnalyticModel?
    let code: Int?
}

// MARK: - DataClass
struct BoardAnalyticModel: Codable {
    var board: BoardDetail?
    let analytics: Analytics?
}

// MARK: - Analytics
struct Analytics: Codable {
    let impressions, clicks, outboundClicks: Int? //, ctrPercentage
    let favorites: Int?

    enum CodingKeys: String, CodingKey {
        case impressions, clicks
        case outboundClicks = "outbound_clicks"
       // case ctrPercentage = "ctr_percentage"
        case favorites
    }
}

// MARK: - Board
struct BoardDetail: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let description: String?
    let outbondURL: String?
    let createdAt: String?
    let categoryID, favouritesCount: Int?
    let category: Category?
    let rejectionReason: String?
    let status: String?
    var isActive:Int?

    enum CodingKeys: String, CodingKey {
        case id, name, image, description
        case outbondURL = "outbond_url"
        case createdAt = "created_at"
        case categoryID = "category_id"
        case favouritesCount = "favourites_count"
        case category
        case rejectionReason = "rejected_reason"
        case status
        case isActive = "is_active"

    }
}

