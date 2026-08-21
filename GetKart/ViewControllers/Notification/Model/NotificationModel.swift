//
//  NotificationModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import Foundation


//struct NotificationModel: Identifiable {
//    let id = UUID()
//    let image: String
//    let title: String
//    let message: String
//}


// MARK: - Notification
struct NotificationParse: Codable {
    let code: Int?
    let message: String?
    let data: NotificationClass?
    let error: Bool?
}

// MARK: - DataClass
struct NotificationClass: Codable {
    let lastPageURL: String?
    let prevPageURL: JSONNull?
    let from, total: Int?
    let path, firstPageURL: String?
    let lastPage: Int?
    let nextPageURL: JSONNull?
    let data: [NotificationModel]?
    let currentPage: Int?
    let links: [Link]?
    let perPage, to: Int?

    enum CodingKeys: String, CodingKey {
        case lastPageURL
        case prevPageURL
        case from, total, path
        case firstPageURL
        case lastPage
        case nextPageURL
        case data
        case currentPage
        case links
        case perPage
        case to
    }
}

// MARK: - Datum
struct NotificationModel: Codable,Identifiable {
    let id: Int?
    let createdAt, title, message: String?
    let image: String?
    let sendTo, userID: String?
    let itemID: Int?
    let type: Int?
    /*const TYPE_CHAT_MESSAGE = 1;
                    
                    const TYPE_FOLLOWING_PRODUCT_APPROVED = 2; // Follow > user's product approved after review
                 
                    const TYPE_PRODUCT_EXPIRED = 3;
                 
                    const TYPE_BOARD_REJECTED = 4;
                 
                    const TYPE_BOARD_APPROVED = 5; // Promotional video board approval
                 
                    const TYPE_BANNER_REJECTED = 6;
                 
                    const TYPE_BANNER_APPROVED = 7;
                 
                    const TYPE_IDEA_REJECTED = 8;
                 
                    const TYPE_IDEA_APPROVED = 9; // Also sent to followers when idea under review gets approved
                 
                    const TYPE_PRODUCT_COMMENT = 10;
                 
                    const TYPE_PRODUCT_COMMENT_REPLY = 11;
                 
                    const TYPE_BOARD_BUSINESS_IMAGE_APPROVED = 12;
                 
                    const TYPE_BOARD_BUSINESS_IMAGE_REJECTED = 13;
                 
                    const TYPE_BOARD_BUSINESS_VIDEO_APPROVED= 14;
                 
                    const TYPE_BOARD_BUSINESS_VIDEO_REJECTED = 15;
                    */

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case title, message, image
        case sendTo = "send_to"
        case userID = "user_id"
        case itemID = "item_id"
        case type
    }
}

