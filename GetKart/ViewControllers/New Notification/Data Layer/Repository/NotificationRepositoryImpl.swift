//
//  NotificationRepositoryImpl.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

import Foundation

final class NotificationRepositoryImpl:
NotificationRepository{

    private let remote:
    NotificationRemoteDataSource

    init(remote: NotificationRemoteDataSource){

        self.remote = remote

    }

    func getNotifications(

        page:Int,

        completion:@escaping(Result<NotificationClass,Error>)->Void

    ){

        remote.getNotifications(page: page){ result in

            switch result{

            case .success(let response):

                completion(

                    .success(

                        response.data ??

                        NotificationClass(

                            lastPageURL: nil,
                            prevPageURL: nil,
                            from: 0,
                            total: 0,
                            path: nil,
                            firstPageURL: nil,
                            lastPage: 1,
                            nextPageURL: nil,
                            data: [],
                            currentPage: 1,
                            links: [],
                            perPage: 0,
                            to: 0

                        )

                    )

                )

            case .failure(let error):

                completion(.failure(error))

            }

        }

    }

   

}
