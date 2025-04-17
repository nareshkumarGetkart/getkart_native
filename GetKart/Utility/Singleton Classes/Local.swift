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
    
 
    var compression = 50
    var currencySymbol:String = "₹"

    
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
    
    func saveUserLocation(city:String, state:String, country:String, timezone:String ) {
        
        UserDefaults.standard.setValue(city, forKey: LocalKeys.city.rawValue)
        UserDefaults.standard.setValue(state, forKey: LocalKeys.state.rawValue)
        UserDefaults.standard.setValue(country, forKey: LocalKeys.country.rawValue)
        UserDefaults.standard.setValue(timezone, forKey: LocalKeys.timezone.rawValue)
        UserDefaults.standard.synchronize()
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
    func getUserTimeZone() -> String{
        
        return UserDefaults.standard.value(forKey: LocalKeys.timezone.rawValue) as? String ?? ""
    }
    
    func removeUserData() {
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE = true
        SocketIOManager.sharedInstance.socket?.disconnect()
        SocketIOManager.sharedInstance.socket = nil
        SocketIOManager.sharedInstance.manager = nil
        UserDefaults.standard.removeObject(forKey:LocalKeys.userId.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.token.rawValue)
        
        UserDefaults.standard.removeObject(forKey: LocalKeys.city.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.state.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.country.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.timezone.rawValue)
        
        UserDefaults.standard.synchronize()
        AppDelegate.sharedInstance.sharedProfileID = ""
        AppDelegate.sharedInstance.notificationType = ""
        AppDelegate.sharedInstance.userId = 0
        AppDelegate.sharedInstance.roomId = 0
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
}



