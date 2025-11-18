//
//  Local.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 23/08/24.
//

import Foundation
import UIKit
import Kingfisher

final class Local {
    
    static let shared = Local()
    
    private  init(){ }
    
    var isToRefreshVerifiedStatusApi = true
    var compression = 50
    var currencySymbol:String = "₹"
    var companyEmail:String = "support@getkart.com"
    var companyTelelphone1:String = "8800957957"
    var bannerScrollInterval = 3
    var placeApiKey:String = ""


    var isLogout = false

    
    func saveUserId(userId:Int){
        UserDefaults.standard.setValue(userId, forKey: LocalKeys.userId.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func getUserId() -> Int{
        
        return UserDefaults.standard.value(forKey: LocalKeys.userId.rawValue) as? Int ?? 0
    }
    
    
    func saveHashToken(token:String){
        
        UserDefaults.standard.setValue(token, forKey: LocalKeys.token.rawValue)
        UserDefaults.standard.synchronize()
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
    
    func saveUserLocation(city:String, state:String, country:String, latitude:String, longitude:String, timezone:String,locality:String = "") {
        
        UserDefaults.standard.setValue(city, forKey: LocalKeys.city.rawValue)
        UserDefaults.standard.setValue(state, forKey: LocalKeys.state.rawValue)
        UserDefaults.standard.setValue(country, forKey: LocalKeys.country.rawValue)
        UserDefaults.standard.setValue(latitude, forKey: LocalKeys.latitude.rawValue)
        UserDefaults.standard.setValue(longitude, forKey: LocalKeys.longitude.rawValue)
        UserDefaults.standard.setValue(timezone, forKey: LocalKeys.timezone.rawValue)
        UserDefaults.standard.setValue(locality, forKey: LocalKeys.locality.rawValue)

        UserDefaults.standard.synchronize()
    }
    
    func getUserLocality() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.locality.rawValue) as? String ?? ""
    }
    
    func getUserCity() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.city.rawValue) as? String ?? ""
    }
    func getUserState() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.state.rawValue) as? String ?? ""
    }
    func getUserCountry() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.country.rawValue) as? String ?? ""
    }
    
    func getUserLatitude() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.latitude.rawValue) as? String ?? "0"
    }
    
    func getUserLongitude() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.longitude.rawValue) as? String ?? "0"
    }
    
    func getUserTimeZone() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.timezone.rawValue) as? String ?? ""
    }
    
    func removeUserData() {
 
 
       /*
        UserDefaults.standard.removeObject(forKey: LocalKeys.city.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.state.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.country.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.timezone.rawValue)
        */
       
        //Socket
        SocketIOManager.sharedInstance.socket?.disconnect()
        SocketIOManager.sharedInstance.socket = nil
        SocketIOManager.sharedInstance.manager = nil
        
        //Local
        UserDefaults.standard.removeObject(forKey:LocalKeys.userId.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.token.rawValue)
        UserDefaults.standard.removeObject(forKey:"reportList")

        UserDefaults.standard.synchronize()
      
        //Notification
        AppDelegate.sharedInstance.sharedProfileID = ""
        AppDelegate.sharedInstance.notificationType = ""
        AppDelegate.sharedInstance.userId = 0
        AppDelegate.sharedInstance.roomId = 0
   
        Local.shared.isToRefreshVerifiedStatusApi = true
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
        //Cache clear
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
   
        //Realm Database
        RealmManager.shared.deleteUserInfoObjects()
        RealmManager.shared.clearDB()

    }
    
    
    
}

enum LocalKeys:String,CaseIterable{
    
    case userId = "userId"
    case token = "token"
    case fcmtoken = "fcmtoken"
    case city =  "city"
    case state = "state"
    case country = "country"
    case timezone = "timezone"
    case latitude = "latitude"
    case longitude = "longitude"
    case appTheme = "AppTheme"
    case locality =  "locality"

}



