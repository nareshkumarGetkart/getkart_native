//
//  NotificationEntity.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

import Foundation

struct NotificationEntity: Identifiable {

    let id: Int

    let title: String

    let message: String

    let image: String?

    let createdAt: Date?

    let itemId: Int?

    let sendTo: String?

    let userId: String?
}



import Foundation

extension NotificationModel {

    func toEntity()->NotificationEntity{

        NotificationEntity(

            id: id ?? 0,

            title: title ?? "",

            message: message ?? "",

            image: image,

            createdAt: createdAt?.toDateNew(),

            itemId: itemID,

            sendTo: sendTo,

            userId: userID

        )

    }

}

import Foundation

extension String{

    func toDateNew()->Date?{

        let formatter = ISO8601DateFormatter()

        return formatter.date(from: self)

    }

}
