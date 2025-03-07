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
    
    init(){

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
}
