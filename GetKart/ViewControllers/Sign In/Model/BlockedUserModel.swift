//
//  BlockedUserModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/03/25.
//

import Foundation


// MARK: - Blocked
struct UserParse: Codable {
    let error: Bool?
    let message: String?
    let data: [UserModel]?
    let code: Int?
}

// MARK: - Datum
struct UserModel: Codable,Identifiable {
    let id: Int?
    let name: String?
    let profile: String?
   
    init(id: Int?, name: String?, profile: String?) {
        self.id = id
        self.name = name
        self.profile = profile
    }
}
