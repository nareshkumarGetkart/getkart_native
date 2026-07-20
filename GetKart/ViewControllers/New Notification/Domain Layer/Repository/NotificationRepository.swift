//
//  NotificationRepository.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

import Foundation

import Foundation

protocol NotificationRepository {

    func getNotifications(
        page: Int,
        completion: @escaping(Result<NotificationClass,Error>)->Void
    )

    

}
