//
//  MessageModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 18/03/25.
//

import Foundation


// MARK: - Empty
struct MessageParse: Codable {
    let code: Int?
    let message: String?
    let data: MessageClass?
    let error: Bool?
}

// MARK: - DataClass
struct MessageClass: Codable {
    let lastPageURL: String?
    let prevPageURL: String?
    let from, total: Int?
    let path, firstPageURL: String?
    let lastPage: Int?
    let nextPageURL: String?
    let data: [MessageModel]?
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
struct MessageModel: Codable {
    var readAt: String?
    let id: Int?
    let createdAt, file: String?
    let itemOfferID: Int?
    let message: String?
    let messageType: String?
    let updatedAt: String?
    let senderID: Int?
    let audio: String?
    let receiverID: Int?
    var isCautionExpanded = 0
   // let userType: String?
    let warning:String?
    
    enum CodingKeys: String, CodingKey {
        case readAt = "read_at"
        case id,warning
        case createdAt = "created_at"
        case file
        case itemOfferID = "item_offer_id"
        case message
        case messageType = "message_type"
        case updatedAt = "updated_at"
        case senderID = "sender_id"
        case audio
        case receiverID = "receiver_id"
       // case userType
    }
    init(readAt: String? = nil, id: Int?, createdAt: String?, file: String?, itemOfferID: Int?, message: String?, messageType: String?, updatedAt: String?, senderID: Int?, audio: String?, receiverID: Int?,warning:String?="") {
        self.readAt = readAt
        self.id = id
        self.createdAt = createdAt
        self.file = file
        self.itemOfferID = itemOfferID
        self.message = message
        self.messageType = messageType
        self.updatedAt = updatedAt
        self.senderID = senderID
        self.audio = audio
        self.receiverID = receiverID
        self.warning = warning
    }
}



// MARK: - Empty
struct SendMessageParse: Codable {
    let error: Bool?
    let message: String?
    let data: MessageModel?
    let code: Int?
}

