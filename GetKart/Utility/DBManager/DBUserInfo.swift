//
//  UserInfo.swift
//  GetKart
//
//  Created by gurmukh singh on 2/24/25.
//

import Foundation
import RealmSwift

class DBUserInfo: Object {
    @Persisted var address:String?
    @Persisted var country_code:String?
    @Persisted var created_at:String?
    @Persisted var deleted_at:String?
    @Persisted var email:String?
    
    @Persisted var email_verified_at:String?
    @Persisted var fcm_id:String?
    @Persisted var firebase_id:String?
    @Persisted var id:Int?
    @Persisted var is_verified:Int?
    @Persisted var mobile:String?
    
    @Persisted var mobileVisibility:Int?
    @Persisted var name:String?
    @Persisted var notification:Int?
    @Persisted var profile:String?
    
    @Persisted var roles  = RealmSwift.List<DBUserRoles>()
    
    @Persisted var updated_at: String?
    @Persisted var show_personal_details:Int?
    @Persisted var type:String?
    @Persisted var token:String?
    override init(){ }
    init(userInfo:UserInfo) {
        super.init()
        self.address = userInfo.address
        self.country_code = userInfo.country_code
        self.created_at = userInfo.created_at
        self.deleted_at = userInfo.deleted_at
        self.email = userInfo.email
        self.email_verified_at = userInfo.email_verified_at
        self.fcm_id = userInfo.fcm_id
        
        firebase_id = userInfo.firebase_id
        id = userInfo.id
        is_verified = userInfo.is_verified
        mobile = userInfo.mobile
        mobileVisibility = userInfo.mobileVisibility
        name = userInfo.name
        notification = userInfo.notification
        profile = userInfo.profile
        
        for rl in userInfo.roles ?? [] {
            roles.append(DBUserRoles(role: rl))
        }
       
        show_personal_details = userInfo.show_personal_details
        type = userInfo.type
        updated_at = userInfo.updated_at
        
        self.token = userInfo.token
    }
    
}


class DBUserRoles: Object {
    @Persisted var created_at:String?
    @Persisted var custom_role :Int?
    @Persisted var guard_name: String?
    @Persisted var id:Int?
    @Persisted var name: String?
    @Persisted var updated_at: String?
    @Persisted var pivot:DBPivot?
    override init(){ }
    init(role:Roles){
        super.init()
        created_at = role.created_at
        custom_role = role.custom_role
        guard_name = role.guard_name
        id = role.id
        name = role.name
        updated_at = role.updated_at
        pivot = DBPivot(pivot: role.pivot ?? Pivot())
    }
}

class DBPivot: Object {
    @Persisted var model_id:Int?
    @Persisted var model_type:String?
    @Persisted var role_id:Int?
    override init(){ }
    init(pivot:Pivot){
        super.init()
        model_id = pivot.model_id
        model_type = pivot.model_type
        role_id = pivot.role_id
    }
    
    
}
