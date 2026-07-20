//
//  NotificationRemoteDataSourceImpl.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

final class NotificationRemoteDataSourceImpl: NotificationRemoteDataSource {

    func getNotifications(
        page: Int,
        completion: @escaping(Result<NotificationParse, Error>) -> Void
    ) {

        let url = "\(Constant.shared.baseURL)/notifications?page=\(page)"

        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: page == 1,
            url: url
        ) { (response: NotificationParse) in

            completion(.success(response))
        }
    }
}
