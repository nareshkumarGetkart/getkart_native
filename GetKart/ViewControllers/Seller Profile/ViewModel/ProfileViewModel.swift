//
//  ProfileViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/03/25.
//

import Foundation
import SwiftUICore


class ProfileViewModel:ObservableObject{
    
    @Published var sellerObj:Seller?
    @Published var itemArray = [ItemModel]()
    @Published var isDataLoading = false
    var page = 1
    var canLoadMorePages = true

    init(){
        
    }
    

    
    func loadMoreContentIfNeeded(currentItem item: ItemModel?) {
//        guard let item = item else {
//            getItemListApi(sellerId:sellerObj?.id ?? 0)
//            return
//        }
//        

        let thresholdIndex = itemArray.index(itemArray.endIndex, offsetBy: -1)
        if  item?.id == thresholdIndex {

//        if itemArray.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            getItemListApi(sellerId:sellerObj?.id ?? 0)
        }
    }
    
    
    
    func getItemListApi(sellerId:Int){
        
        guard !isDataLoading && canLoadMorePages else { return }

        isDataLoading = true
        
        let strUrl = "\(Constant.shared.get_item)?user_id=\(sellerId)&page=\(page)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) {[weak self] (obj:ItemParse) in
            if (obj.code ?? 0) == 200 {
                self?.itemArray.append(contentsOf: obj.data?.data ?? [])
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.page += 1
                    self?.isDataLoading = false
                    self?.canLoadMorePages = (obj.data?.data ?? []).count > 0
               }
            }else{
                self?.isDataLoading = false
                self?.canLoadMorePages = false
            }
        }
    }
    
    
    func getSellerProfile(sellerId:Int,nav:UINavigationController?){
        
        let strURl = Constant.shared.get_seller + "?id=\(sellerId)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strURl) { [weak self] (obj:Profile)  in
            if obj.code == 200 {
                self?.sellerObj = obj.data?.seller
            }else{
                AlertView.sharedManager.presentAlertWith(title: "", msg: (obj.message ?? "") as NSString, buttonTitles: ["OK"], onController: (nav?.topViewController)!) { title, index in
                    
                    nav?.popViewController(animated: true)
                    
                }
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


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
