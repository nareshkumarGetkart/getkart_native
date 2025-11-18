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
    let isActive:Int?
    let paymentTransactions: PaymentTransactions?

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
        case isActive = "is_active"
        case paymentTransactions = "payment_transactions"

    }
}

// MARK: - PaymentTransactions
struct PaymentTransactions: Codable {
    let id, userID: Int?
    let city: String?
    let state: String?
    let amount: Int?
    let paymentGateway, orderID, paymentStatus, createdAt: String?
    let updatedAt: String?
    let bannerID, packageID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case city, state, amount
        case paymentGateway = "payment_gateway"
        case orderID = "order_id"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case bannerID = "banner_id"
        case packageID = "package_id"
    }
}



