//
//  BuyerModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 18/03/25.
//

import Foundation



struct ParseUpdatedChat:Codable{
    let code: Int?
    let message: String?
    let data: ChatList?
    let error: Bool?
    let type:String?
}

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
        case lastPageURL = "last_page_url"
        case prevPageURL = "prev_page_url"
        case from, total, path
        case firstPageURL = "first_page_url"
        case lastPage = "last_page"
        case nextPageURL = "next_page_url"
        case data
        case currentPage = "current_page"
        case links
        case perPage = "per_page"
        case to
    }
}


struct LastMessage:Codable{
    var readAt: String?
    let id: Int?
    let createdAt, file: String?
    let message: String?
    let messageType: String?
    let updatedAt: String?
    let audio: String?
    let roomId: Int?

    enum CodingKeys: String, CodingKey {
        case readAt = "read_at"
        case id
        case createdAt = "created_at"
        case file
        case message
        case messageType = "message_type"
        case updatedAt = "updated_at"
        case roomId = "room_id"
        case audio
    }
}


// MARK: - Datum
struct ChatList: Codable {
    
    let lastMessageTime: String?
    let createdAt: String?
    let updatedAt: String?
    let userBlocked: Bool?
    var lastMessage:LastMessage?
    var unreadCount:Int?
    var readAt:String?
    let user:ChatUser?
    let roomId:Int?
    
    enum CodingKeys: String, CodingKey {
       
        case lastMessageTime = "last_message_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastMessage = "last_message"
        case readAt = "read_at"
        case userBlocked = "user_blocked"
        case user
        case roomId = "room_id"
        case unreadCount = "unread_count"
    }
}

// MARK: - BuyerClass
struct BuyerClass: Codable {
    let id: Int?
    let name: String?
    let profile: String?
    let deletedAt:String?
    
    enum CodingKeys:String,CodingKey{
        case id
        case name
        case profile
        case deletedAt = "deleted_at"
    }
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

struct ChatUser: Codable,Identifiable {
    let id: Int?
    let name: String?
    let profile: String?
   
    enum CodingKeys: String, CodingKey {
        case id, name, profile
    }
}

enum MessageType: String, Codable {
    case text = "text"
}

// MARK: - Item
struct ItemChat: Codable {
    let status: String?
    let soldTo, review: String?
    let id: Int?
    let price:Double? //    let id, price: Int?

    let deletedAt: String?
    let image: String?
    let description, name: String?
    let isPurchased: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case soldTo
        case review, id, price
        case deletedAt = "deleted_at"
        case image, description, name
        case isPurchased
    }
}





// MARK: - Buyer
struct UserChatParse: Codable {
    
    let code: Int?
    let message: String?
    let data: UserChatClass?
    let error: Bool?
}

// MARK: - DataClass
struct UserChatClass: Codable {
    let lastPageURL: String?
    let prevPageURL: String?
    let from, total: Int?
    let path, firstPageURL: String?
    let lastPage: Int?
    let nextPageURL: String?
    let data: [ChatUser]?
    let currentPage: Int?
    let links: [Link]?
    let perPage, to: Int?

    enum CodingKeys: String, CodingKey {
        case lastPageURL = "last_page_url"
        case prevPageURL = "prev_page_url"
        case from, total, path
        case firstPageURL = "first_page_url"
        case lastPage = "last_page"
        case nextPageURL = "next_page_url"
        case data
        case currentPage = "current_page"
        case links
        case perPage = "per_page"
        case to
    }
}
