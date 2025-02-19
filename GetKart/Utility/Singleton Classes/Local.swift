//
//  Local.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 23/08/24.
//

import Foundation
import UIKit


final class Local {
    
    static let shared = Local()
    var isLogout = false
    
    private  init(){ }
    
    var likedImageArray:Array<String>?
    var likeCount:Int?
    var imageRejectedCount:Int?
    var compression = 50
    var coordinates:Coordinates?
    var address:Address?
    
    func getTravelModePopupStatus() -> Int{
        
        return UserDefaults.standard.value(forKey: LocalKeys.travelModePopup.rawValue)  as? Int ?? 0
    }
    
    func travelModePopupStatus(status:Int){
        
        UserDefaults.standard.set(status, forKey: LocalKeys.travelModePopup.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func saveSignUpStatus(status:Int){
        
        UserDefaults.standard.set(status, forKey: LocalKeys.signupCompleted.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func getSignUpStatus() -> Int{
        
        return UserDefaults.standard.value(forKey: LocalKeys.signupCompleted.rawValue)  as? Int ?? 0
    }
    
    func saveUserId(userId:String){
        
        UserDefaults.standard.setValue(userId, forKey: LocalKeys.userId.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func getUserId() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.userId.rawValue) as? String ?? ""
    }
        
    func saveHashToken(token:String){
        
        UserDefaults.standard.setValue(token, forKey: LocalKeys.token.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func saveisFirstLike(isFirstLike:Int) {
        UserDefaults.standard.setValue(isFirstLike, forKey: LocalKeys.isFirstLike.rawValue)
        UserDefaults.standard.synchronize()
    }
    func getIsFirstLike() -> Int{
        
        return UserDefaults.standard.value(forKey: LocalKeys.isFirstLike.rawValue) as? Int ?? 0
    }
    
    
    func getHashToken() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.token.rawValue) as? String ?? ""
    }
    
    func saveFCMToken(token:String){
        
        UserDefaults.standard.setValue(token, forKey: LocalKeys.fcmtoken.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func getFCMToken() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.fcmtoken.rawValue) as? String ?? ""
    }
    
    func getAppVersion() -> String{
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        return "\(version)"
    }
    
    func getUUID()->String {
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
        }
        return ""
    }
    
    func removeUserData() {
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE = true
        SocketIOManager.sharedInstance.socket?.disconnect()
        SocketIOManager.sharedInstance.socket = nil
        SocketIOManager.sharedInstance.manager = nil
        Local.shared.likedImageArray?.removeAll()
        Local.shared.likeCount = 0
        Local.shared.imageRejectedCount = 0
        UserDefaults.standard.removeObject(forKey:LocalKeys.socialId.rawValue)
        UserDefaults.standard.removeObject(forKey:LocalKeys.userId.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.token.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.signupCompleted.rawValue)
        UserDefaults.standard.removeObject(forKey: "isFirstTime")
        UserDefaults.standard.removeObject(forKey: "NotificationDisplayTime")
        self.travelModePopupStatus(status: 0)
        UserDefaults.standard.synchronize()
       
        AppDelegate.sharedInstance.sharedProfileID = ""
        AppDelegate.sharedInstance.notificationType = ""
        AppDelegate.sharedInstance.userId = ""
        AppDelegate.sharedInstance.roomId = ""
        
        socialId = ""
        socialName = ""
        socialEmail = ""
    }
    
        
    func setDefaultValuesToFilterKeys(){
        
        UserDefaults.standard.setValue(0, forKey: FilterKeys.interest.rawValue)
        UserDefaults.standard.setValue(18, forKey: FilterKeys.fromAge.rawValue)
        UserDefaults.standard.setValue(80, forKey: FilterKeys.toAge.rawValue)
        UserDefaults.standard.setValue(160, forKey: FilterKeys.distance.rawValue)
        UserDefaults.standard.setValue(248, forKey: FilterKeys.height.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func getFilterInterst()->Int{
        return UserDefaults.standard.value(forKey: FilterKeys.interest.rawValue) as? Int ?? 0
    }
    
    func getFilterfromAge()->Int{
        return UserDefaults.standard.value(forKey: FilterKeys.fromAge.rawValue) as? Int ?? 0
    }
    func getFiltertoAge()->Int{
        return UserDefaults.standard.value(forKey: FilterKeys.toAge.rawValue) as? Int ?? 0
    }
    func getFilterdistance()->Int{
        return UserDefaults.standard.value(forKey: FilterKeys.distance.rawValue) as? Int ?? 0
    }
   
    func getFilterheight()->Int{
        return UserDefaults.standard.value(forKey: FilterKeys.height.rawValue) as? Int ?? 0
    }
}

enum LocalKeys:String,CaseIterable{
    
    case userId = "userId"
    case token = "token"
    case signupCompleted = "signupCompleted"
    case fcmtoken = "fcmtoken"
    case isFirstLike = "isFirstLike"
    case socialId = "socialId"
    case travelModePopup = "travelModePopup"

}

enum FilterKeys:String,CaseIterable{
    
    case interest = "interest"
    case fromAge = "fromAge"
    case toAge = "toAge"
    case distance = "distance"
    case height = "height"
}




