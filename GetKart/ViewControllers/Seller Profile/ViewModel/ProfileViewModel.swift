//
//  ProfileViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/03/25.
//

import Foundation


class ProfileViewModel:ObservableObject{
    
    @Published var sellerObj:Seller?
    @Published var itemArray = [ItemModel]()
    var isDataLoading = true
    var page = 1
    
    init(){
        
    }
    
    func getItemListApi(sellerId:Int){
        isDataLoading = true
        
        let strUrl = "\(Constant.shared.get_item)?user_id=\(sellerId)?page=\(page)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:ItemParse) in
            self?.isDataLoading = false
            if (obj.code ?? 0) == 200 {
                self?.itemArray = obj.data?.data ?? []
            }
        }
    }
    
    
    func getSellerProfile(sellerId:Int){
        
        let strURl = Constant.shared.get_seller + "?id=\(sellerId)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strURl) { [weak self] (obj:Profile)  in
            if obj.code == 200 {
                self?.sellerObj = obj.data?.seller
            }
        }
    }
    func followUnfollowUserApi(isFollow:Bool){
        
        let flag = (isFollow == true) ? 1 : 0
        let params = ["follower_id":(sellerObj?.id ?? 0),"flag":flag]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.follow_unfollow, param: params, showLoader: true) { [self] responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                // let message = result["message"] as? String ?? ""
                
                if code == 200{
                    
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        sellerObj?.isFollowing = (flag == 1) ? true : false
                    }
                }
            }
        }
    }
    
    
    func unblockUser(){
        
        let params = ["blocked_user_id":sellerObj?.id ?? 0]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.unblock_user, param: params) { responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                self.sellerObj?.isBlock = 0
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
            }
        }
    }
    
    func blockUser(){
        
        let params = ["blocked_user_id":sellerObj?.id ?? 0]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.block_user, param: params) { responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                self.sellerObj?.isBlock = 1
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
            }
        }
    }
}
