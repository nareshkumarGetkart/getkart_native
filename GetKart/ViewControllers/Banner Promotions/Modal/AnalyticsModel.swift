//
//  AnalyticsModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/10/25.
//

import Foundation



// MARK: - Welcome
struct AnalyticsParse: Codable {
    let error: Bool
    let message: String
    let data: AnalyticsModel?
    let code: Int
}

// MARK: - DataClass
struct AnalyticsModel: Codable {
    let id: Int
    let title: String?
    let radius: Int?
    let image: String?
    let status: String?
    let impressions, clicks, uniqueViews: Int?
    let ctr: String?
    let conversions, timeOnScreen, timeToClick: String?
    let location, createdAt, startDate, screenAppearance: String?
    let url: String?
    let rejectionReason: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, radius, image, status, impressions, clicks,url
        case uniqueViews = "unique_views"
        case ctr, conversions
        case timeOnScreen = "time_on_screen"
        case timeToClick = "time_to_click"
        case location
        case createdAt = "created_at"
        case startDate = "start_date"
        case screenAppearance = "screen_appearance"
        case rejectionReason = "rejection_reason"
    }
}


