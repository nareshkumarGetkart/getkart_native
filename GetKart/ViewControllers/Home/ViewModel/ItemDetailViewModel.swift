//
//  ItemDetailViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/03/25.
//

import Foundation
import SwiftUI


class ItemDetailViewModel:ObservableObject{
    
    @Published var sellerObj:SellerModel?
    @Published var relatedDataItemArray = [ItemModel]()
    @Published var itemObj:ItemModel?
    var isMyProduct = false
   
    init(){

    }

    
    func getItemDetail(id:Int){
        
        let strUrl = Constant.shared.get_item + "?id=\(id)"
        
        if isMyProduct == false{
            
            ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:SingleItemParse) in
                
                if obj.code == 200 {
                    
                    if let item  =  obj.data?.first{
                        self.itemObj = item
                        self.getSeller(sellerId: item.userID ?? 0)
                        self.getProductListApi(categoryId: item.categoryID ?? 0)
                        self.setItemTotalApi()
                    }
                }
            }
        }else{
            
        }
    }
    
    
    
        
    
    func getSeller(sellerId:Int){
        
        let strUrl = Constant.shared.get_seller + "?id=\(sellerId)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:SellerParse) in
            
            if obj.data != nil {
                self.sellerObj = obj.data?.seller
            }
        }
    }
    
    
    func getProductListApi(categoryId:Int){
        
        let strUrl = "\(Constant.shared.get_item)?category_id=\(categoryId)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:ItemParse) in

            self?.relatedDataItemArray = obj.data?.data ?? []
        
        }
    }
    
    
    func setItemTotalApi(){
     //   let strUrl = "\(Constant.shared.set_item_total_click)?item_id=\(itemId)"
        let params = ["item_id":"\(itemObj?.id ?? 0)"]

        URLhandler.sharedinstance.makeCall(url: Constant.shared.set_item_total_click, param: params,methodType:.post, showLoader: false) { responseObject, error in
            
        }
    }
    
    
    func addToFavourite(){
        
        let params = ["item_id":"\(itemObj?.id ?? 0)"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
            
            if error == nil {
                
                self.itemObj?.isLiked?.toggle()
            }
        }
    }
}
