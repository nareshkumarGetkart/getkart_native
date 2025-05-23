//
//  RealmManager.swift
//  GetKart
//
//  Created by gurmukh singh on 2/24/25.
//

import Foundation
import RealmSwift
/*
class RealmManager: ObservableObject {
    
    static let shared = RealmManager()
    
    private(set) var localRealm: Realm?
    
    private init() {
        openRealm()
    }
    func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion > 1 {
                    // Do something, usually updating the schema's variables here
                }
            })

            Realm.Configuration.defaultConfiguration = config

            localRealm = try Realm()
        } catch {
            print("Error opening Realm", error)
        }
    }
    
    func saveUserInfo(userInfo:UserInfo) {
        self.deleteUserInfoObjects()
        let userInfo =  DBUserInfo(userInfo: userInfo)
        do {
            try localRealm?.write {
                localRealm?.add(userInfo)
            }
        } catch {
            print("An error occurred while saving the category: \(error)")
        }
    }
    
    
    
    func updateUserData(dict:Dictionary<String, Any>){
        
        let realm = try! Realm()
        
        // Find the object you want to update
        if let user = realm.object(ofType: DBUserInfo.self, forPrimaryKey: dict["id"] as? Int ?? 0) {
            try! realm.write {
                user.name = dict["name"] as? String ?? ""
                user.email = dict["email"] as? String ?? ""
                user.profile = dict["profile"] as? String ?? ""
                user.address = dict["address"] as? String ?? ""
                user.mobile = dict["mobile"] as? String ?? ""
                user.country_code = dict["country_code"] as? String ?? ""
                user.mobileVisibility = dict["mobileVisibility"] as? Int ?? 0
                user.notification = dict["notification"] as? Int ?? 0
            }
        }
        
    }
    
    
    func fetchLoggedInUserInfo()->UserInfo {
        
        if let allUsers = localRealm?.objects(DBUserInfo.self){
            
            if allUsers.count > 0 {
                let userInfo = UserInfo(dbUserInfo: allUsers[0])
                return userInfo
            }
        }

        return UserInfo()
    }
    
    
    func deleteUserInfoObjects() {
        do {
            if let allUsers = localRealm?.objects(DBUserInfo.self){

                    //Delete must be perform in a write transaction
                try! localRealm?.write {
                    localRealm?.delete(allUsers)
                     }
                }

            } catch let error {
                print("error - \(error.localizedDescription)")
            }
    }
    
    public  func clearDB() {
        
        try? localRealm?.write {
            
            localRealm?.deleteAll()
        }
    }
    
}


*/

class RealmManager: ObservableObject {

    static let shared = RealmManager()

    private init() {
        configureRealm()
    }

    private func configureRealm() {
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // Handle migration if needed
            }
        })
        Realm.Configuration.defaultConfiguration = config
    }

    private var realm: Realm {
        return try! Realm()
    }

    func fetchLoggedInUserInfo() -> UserInfo {
        if let dbUser = realm.objects(DBUserInfo.self).first {
            return UserInfo(dbUserInfo: dbUser)
        }
        return UserInfo()
    }

    func saveUserInfo(userInfo: UserInfo) {
        deleteUserInfoObjects()
        Local.shared.saveUserId(userId: userInfo.id ?? 0)
        let dbUser = DBUserInfo(userInfo: userInfo)
        
        try? realm.write {
            realm.add(dbUser)
        }
    }

    func deleteUserInfoObjects() {
        Local.shared
        try? realm.write {
            let allUsers = realm.objects(DBUserInfo.self)
            realm.delete(allUsers)
        }
    }

    func updateUserData(dict: [String: Any]) {
        if let user = realm.object(ofType: DBUserInfo.self, forPrimaryKey: dict["id"] as? Int ?? 0) {
            try? realm.write {
                user.name = dict["name"] as? String ?? ""
                user.email = dict["email"] as? String ?? ""
                user.profile = dict["profile"] as? String ?? ""
                user.address = dict["address"] as? String ?? ""
                user.mobile = dict["mobile"] as? String ?? ""
                user.country_code = dict["country_code"] as? String ?? ""
                user.mobileVisibility = dict["mobileVisibility"] as? Int ?? 0
                user.notification = dict["notification"] as? Int ?? 0
            }
        }
    }

    func clearDB() {
        try? realm.write {
            realm.deleteAll()
        }
    }
}
