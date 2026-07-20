//
//  NotificationRemoteDataSource.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

import Foundation

protocol NotificationRemoteDataSource {

    func getNotifications(

        page:Int,

        completion:@escaping(Result<NotificationParse,Error>)->Void

    )


}
