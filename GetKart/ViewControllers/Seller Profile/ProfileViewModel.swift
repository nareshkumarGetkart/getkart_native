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
}
