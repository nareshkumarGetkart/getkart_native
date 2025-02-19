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
    
    func removeUserData() {
        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE = true
        SocketIOManager.sharedInstance.socket?.disconnect()
        SocketIOManager.sharedInstance.socket = nil
        SocketIOManager.sharedInstance.manager = nil
        UserDefaults.standard.removeObject(forKey:LocalKeys.userId.rawValue)
        UserDefaults.standard.removeObject(forKey: LocalKeys.token.rawValue)
        UserDefaults.standard.synchronize()
       
        AppDelegate.sharedInstance.sharedProfileID = ""
        AppDelegate.sharedInstance.notificationType = ""
        AppDelegate.sharedInstance.userId = ""
        AppDelegate.sharedInstance.roomId = ""
    }
    
}

enum LocalKeys:String,CaseIterable{
    
    case userId = "userId"
    case token = "token"
    case fcmtoken = "fcmtoken"
}



