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
    let name:String?
    let email:String?
    let profile:String?
    let mobile: String?
    let mobileVisibility:Int?
    let type, fcmID:String?
    let notification:Int?
    let firebaseID:String?
    let address:String?
    let createdAt, updatedAt:String?
    let countryCode: String?
    let showPersonalDetails, isVerified:Int?
    let isFollowing:Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, mobile, mobileVisibility
        case profile, type
        case fcmID = "fcm_id"
        case notification
        case firebaseID = "firebase_id"
        case address
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case countryCode = "country_code"
        case showPersonalDetails = "show_personal_details"
        case isVerified = "is_verified"
        case isFollowing
    }
    
    init(id: Int?, name: String?, email: String?, profile: String?, mobile: String?, mobileVisibility: Int?, type: String?, fcmID: String?, notification: Int?, firebaseID: String?, address: String?, createdAt: String?, updatedAt: String?, countryCode: String?, showPersonalDetails: Int?, isVerified: Int?, isFollowing: Bool?) {
        self.id = id
        self.name = name
        self.email = email
        self.profile = profile
        self.mobile = mobile
        self.mobileVisibility = mobileVisibility
        self.type = type
        self.fcmID = fcmID
        self.notification = notification
        self.firebaseID = firebaseID
        self.address = address
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.countryCode = countryCode
        self.showPersonalDetails = showPersonalDetails
        self.isVerified = isVerified
        self.isFollowing = isFollowing
    }
}




// MARK: - Blocked
struct UserDataParse: Codable {
    let error: Bool?
    let message: String?
    let data:UserParseClass?
    let code: Int?
}


struct UserParseClass:Codable{
 
    let data: [UserModel]?
}
