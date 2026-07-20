//
//  GetNotificationUseCase.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

import Foundation

protocol GetNotificationUseCase{

    func execute(

        page:Int,

        completion:@escaping(Result<NotificationClass,Error>)->Void

    )

}
