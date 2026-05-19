//
//  FollowerViewModal.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 13/05/26.
//

import Foundation


class FollowerViewModal:ObservableObject{
    
    @Published  var usersArray = [UserModel]()
    @Published  private var page = 1
    @Published  private var isDataLoading = false
    let userId:Int?
    var isFollower:Bool = false

   
    init(userId:Int,isFollower:Bool){
        self.userId = userId
        self.isFollower = isFollower
        self.getUserList()
    }
    
    //MARK: Api Methods
    func getUserList() {
        var strUrl = Constant.shared.get_following + "?user_id=\(userId ?? 0)&page=\(page)"
        
        if isFollower {
            strUrl = Constant.shared.get_followers + "?user_id=\(userId ?? 0)&page=\(page)"
        }

        self.isDataLoading = true
        
        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: true,
            url: strUrl
        ) { (obj: UserDataParse) in
            if (obj.code ?? 0) == 200 {
                self.usersArray.append(contentsOf: obj.data?.data ?? [])
                self.page += 1
                
            }
            self.isDataLoading = false
        }
    }
    
    // MARK: - Follow  APIs (your existing)
    func followUnfollowUserApi(userObj:UserModel) {
        
        let flag = ((userObj.isFollowing ?? false) == true) ? 0 : 1
        let params = ["follower_id":(userObj.id ?? 0),"flag":flag]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.follow_unfollow, param: params, showLoader: true) { [self] responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                // let message = result["message"] as? String ?? ""
                
                if code == 200{
                    
                    if result["data"] is Dictionary<String,Any>{
                        
                        if let index = self.usersArray.firstIndex(where: { $0.id == userObj.id }) {
                            
                            var obj = self.usersArray[index]
                            obj.isFollowing = (flag == 1) ? true : false
                            
                            self.usersArray[index] = obj
                        }
                    }
                }
            }
        }
    }
    
}
