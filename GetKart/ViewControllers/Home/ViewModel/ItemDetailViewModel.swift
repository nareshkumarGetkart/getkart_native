//
//  ItemDetailViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/03/25.
//

import Foundation
import SwiftUI


class ItemDetailViewModel:ObservableObject{
    
    @Published var galleryImgArray = [GalleryImage]()
    @Published var sellerObj:SellerModel?
    @Published var relatedDataItemArray = [ItemModel]()
    @Published var itemObj:ItemModel?
    var isMyProduct = false
    
    init(){
        
    }
    
    
    func getItemDetail(id:Int,slug:String){
        
        var strUrl = Constant.shared.get_item + "?id=\(id)"
        if slug.count > 0{
            strUrl = Constant.shared.get_item + "?slug=\(slug)"
        }
        if isMyProduct == false{
            
            ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:SingleItemParse) in
                
                if obj.code == 200 {
                    
                    if let item  =  obj.data?.first{
                        self.itemObj = item
                        self.galleryImgArray = item.galleryImages ?? []
                        if let img = self.itemObj?.image {
                            let new = GalleryImage(id:10, image: img, itemID: self.itemObj?.id)
                            self.galleryImgArray.insert(new, at: 0)
                        }
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
    
    
    func deleteItemApi(nav:UINavigationController?){
        
        let params = ["id":"\(itemObj?.id ?? 0)"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.delete_item, param: params) { responseObject, error in
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    nav?.popToRootViewController(animated: true)
                    AlertView.sharedManager.showToast(message: message)

                }
            }
        }
    }
    
    
    func makeItemFeaturedApi(nav:UINavigationController?){
        
        
        let params = ["item_id":"\(itemObj?.id ?? 0)"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.make_item_featured, param: params) { responseObject, error in
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    nav?.popToRootViewController(animated: true)
                    AlertView.sharedManager.showToast(message: message)

                }
            }
        }
    }
    
    
    
    func getLimitsApi(nav:UINavigationController?){
        
        let strUrl = Constant.shared.getLimits + "?package_type=advertisement"
        URLhandler.sharedinstance.makeCall(url:strUrl , param:nil,methodType: .get) { responseObject, error in
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure to create this item as Boost ad?", buttonTitles: ["Cancel","OK"], onController: (nav?.topViewController)!, tintColor: .black) { title, index in
                        if index == 1{
                            self.makeItemFeaturedApi(nav: nav)
                        }else{
                            AlertView.sharedManager.showToast(message: message)
                        }
                    }
                }
            }
        }
    }
    

    
}


