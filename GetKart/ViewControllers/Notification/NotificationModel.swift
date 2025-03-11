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
    let itemID: JSONNull?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case title, message, image
        case sendTo
        case userID
        case itemID
    }
}

