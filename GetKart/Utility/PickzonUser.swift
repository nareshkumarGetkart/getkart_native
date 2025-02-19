//
//  PickzonUser.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 27/08/24.
//

import UIKit

final class PickzonUser: NSObject {
    
    static let shared = PickzonUser()
    
    var _id = ""
    var isComplete = 0
    var firstName = ""
    var lastName = ""
    var dob = ""
    var mobile = ""
    var countryCode = ""
     
    private override init() { }
    
    
    func parseUserData(respDict:Dictionary<String,Any>){
        
        self._id = respDict["_id"] as? String ?? ""
        self.isComplete = respDict["isComplete"] as? Int ?? 0
        self.firstName = respDict["firstName"] as? String ?? ""
        self.lastName = respDict["lastName"] as? String ?? ""
        self.dob = respDict["dob"] as? String ?? ""
        self.countryCode = respDict["countryCode"] as? String ?? ""
        self.mobile = respDict["mobile"] as? String ?? ""
    }
}
