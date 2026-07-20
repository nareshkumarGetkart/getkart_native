//
//  GetNotificationUseCaseImpl.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

import Foundation

final class GetNotificationUseCaseImpl:
GetNotificationUseCase{

    private let repository:
    NotificationRepository

    init(repository: NotificationRepository){

        self.repository = repository

    }

    func execute(

        page:Int,

        completion:@escaping(Result<NotificationClass,Error>)->Void

    ){

        repository.getNotifications(

            page: page,

            completion: completion

        )

    }

}
