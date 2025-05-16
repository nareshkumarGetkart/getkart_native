//
//  UserInfo.swift
//  GetKart
//
//  Created by gurmukh singh on 2/25/25.
//

struct UserInfo {
    var address:String?
    var country_code:String?
    var created_at:String?
    var deleted_at:String?
    var email:String?
    
    var email_verified_at:String?
    var fcm_id:String?
    var firebase_id:String?
    var id:Int?
    var is_verified:Int?
    var mobile:String?
    
    var mobileVisibility:Int?
    var name:String?
    var notification:Int?
    var profile:String?
    var roles:[Roles]? = []
    
    var show_personal_details:Int?
    var type:String?
    var updated_at:String?
    var token:String?
    init(){ }
    init(dict:Dictionary<String, Any>, token:String){
        
        self.address = dict["address"] as? String ?? ""
        self.country_code = dict["country_code"] as? String ?? ""
        self.created_at = dict["created_at"] as? String ?? ""
        self.deleted_at = dict["deleted_at"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.email_verified_at = dict["email_verified_at"] as? String ?? ""
        self.fcm_id = dict["fcm_id"] as? String ?? ""
        
        firebase_id = dict["firebase_id"] as? String ?? ""
        id = dict["id"] as? Int ?? 0
        is_verified = dict["is_verified"] as? Int ?? 0
        mobile = dict["mobile"] as? String ?? ""
        mobileVisibility = dict["mobileVisibility"] as? Int ?? 0
        name = dict["name"] as? String ?? ""
        notification = dict["notification"] as? Int ?? 0
        profile = dict["profile"] as? String ?? ""
        let arrayRoles = dict["roles"] as? Array<Dictionary<String,Any>> ?? []
        for dictRole in arrayRoles {
            roles?.append(Roles(dict: dictRole))
        }
        
        show_personal_details = dict["show_personal_details"] as? Int ?? 0
        type = dict["type"] as? String ?? ""
        updated_at = dict["updated_at"] as? String ?? ""
        
        self.token = token
    }
    init(dbUserInfo:DBUserInfo) {
        self.address = dbUserInfo.address ?? ""
        self.country_code = dbUserInfo.country_code ?? ""
        self.created_at = dbUserInfo.created_at ?? ""
        self.deleted_at = dbUserInfo.deleted_at ?? ""
        self.email = dbUserInfo.email ?? ""
        self.email_verified_at = dbUserInfo.email_verified_at ?? ""
        self.fcm_id = dbUserInfo.fcm_id ?? ""
        
        firebase_id = dbUserInfo.firebase_id ?? ""
        id = dbUserInfo.id ?? 0
        is_verified = dbUserInfo.is_verified ?? 0
        mobile = dbUserInfo.mobile ?? ""
        mobileVisibility = dbUserInfo.mobileVisibility ?? 0
        name = dbUserInfo.name ?? ""
        notification = dbUserInfo.notification ?? 0
        profile = dbUserInfo.profile ?? ""
        
        for role in dbUserInfo.roles {
            self.roles?.append(Roles(role: role))
                               
        }
        
        
        show_personal_details = dbUserInfo.show_personal_details ?? 0
        type = dbUserInfo.type ?? ""
        updated_at = dbUserInfo.updated_at ?? ""
        
        self.token = dbUserInfo.token
    }
}

struct Roles {
    var created_at:String?
    var custom_role :Int?
    var guard_name: String?
    var id:Int?
    var name: String?
    var pivot:Pivot?
    var updated_at: String?
    init(){ }
    init(dict:Dictionary<String, Any>){
        created_at = dict["created_at"] as? String ?? ""
        custom_role = dict["custom_role"] as? Int ?? 0
        guard_name = dict["guard_name"] as? String ?? ""
        id = dict["id"] as? Int ?? 0
        name = dict["name"] as? String ?? ""
        pivot = Pivot(dict: dict["pivot"] as? Dictionary ?? [:])
        updated_at = dict["updated_at"] as? String ?? ""
    }
    init(role:DBUserRoles) {
        created_at = role.created_at ?? ""
        custom_role = role.custom_role ?? 0
        guard_name = role.guard_name ?? ""
        id = role.id ?? 0
        name = role.name ?? ""
        
        pivot = Pivot(pivot: (role.pivot ?? DBPivot()))
        
        updated_at = role.updated_at
    }
}

struct Pivot {
    var model_id:Int?
    var model_type:String?
    var role_id:Int?
    init(){ }
    init(dict:Dictionary<String, Any>){
        model_id = dict["model_id"] as? Int ?? 0
        model_type = dict["model_type"] as? String ?? ""
        role_id = dict["role_id"] as? Int ?? 0
    }
    init (pivot:DBPivot) {
        model_id = pivot.model_id ?? 0
        model_type = pivot.model_type ?? ""
        role_id = pivot.role_id ?? 0
    }
}
