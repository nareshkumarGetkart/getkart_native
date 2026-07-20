//
//  NotificationDI.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

//
//  NotificationDI.swift
//

import Foundation

enum NotificationDI {

    @MainActor static func makeViewModel() -> NotificationViewModel {

        let remote = NotificationRemoteDataSourceImpl()

        let repository = NotificationRepositoryImpl(
            remote: remote
        )

        let useCase = GetNotificationUseCaseImpl(
            repository: repository
        )

        return NotificationViewModel(
            getNotificationUseCase: useCase
        )
    }

}

/*
 let vc = UIHostingController(
     rootView: NotificationView(
         viewModel: NotificationDI.makeViewModel()
     )
 )

 navigationController?.pushViewController(vc, animated: true)
 */
