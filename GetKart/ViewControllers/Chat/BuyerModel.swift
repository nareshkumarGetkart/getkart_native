//
//  BuyerModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 18/03/25.
//

import Foundation

// MARK: - Buyer
struct BuyerChatParse: Codable {
    
    let code: Int?
    let message: String?
    let data: BuyerChatClass?
    let error: Bool?
}

// MARK: - DataClass
struct BuyerChatClass: Codable {
    let lastPageURL: String?
    let prevPageURL: String?
    let from, total: Int?
    let path, firstPageURL: String?
    let lastPage: Int?
    let nextPageURL: String?
    let data: [ChatList]?
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
struct ChatList: Codable {
    let id, buyerID: Int?
    let lastMessageTime: String?
    let buyer: BuyerClass?
    let amount: Int?
    let createdAt: String?
    let itemID: Int?
    let item: ItemChat?
    let updatedAt: String?
    let userBlocked: Bool?
    let sellerID: Int?
    let seller: BuyerClass?
    let chat: [Chat]?

    enum CodingKeys: String, CodingKey {
        case id
        case buyerID
        case lastMessageTime
        case buyer, amount
        case createdAt
        case itemID
        case item
        case updatedAt
        case userBlocked
        case sellerID
        case seller, chat
    }
}

// MARK: - BuyerClass
struct BuyerClass: Codable {
    let id: Int?
    let name: String?
    let profile: String?
}

// MARK: - Chat
struct Chat: Codable {
    let messageType: MessageType?
    let updatedAt: String?
    let itemOfferID: Int?

    enum CodingKeys: String, CodingKey {
        case messageType
        case updatedAt
        case itemOfferID
    }
}

enum MessageType: String, Codable {
    case text = "text"
}

// MARK: - Item
struct ItemChat: Codable {
    let status: String?
    let soldTo, review: String?
    let id, price: Int?
    let deletedAt: String?
    let image: String?
    let description, name: String?
    let isPurchased: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case soldTo
        case review, id, price
        case deletedAt
        case image, description, name
        case isPurchased
    }
}


