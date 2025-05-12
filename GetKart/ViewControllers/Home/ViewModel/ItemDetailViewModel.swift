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
    
    
    func getItemDetail(id:Int,slug:String,nav:UINavigationController?){
        
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
                        
                        if (item.videoLink?.count ?? 0) > 0{
                            
                            let new = GalleryImage(id:10, image: item.videoLink, itemID: 400)
                            self.galleryImgArray.append(new)
                            
                        }
                        
                        self.getSeller(sellerId: item.userID ?? 0)
                        self.getProductListApi(categoryId: item.categoryID ?? 0)
                        self.setItemTotalApi()
                    }else{
                        
                        AlertView.sharedManager.presentAlertWith(title: "", msg: "Item not available", buttonTitles: ["OK"], onController: (nav?.topViewController)!) { title, index in
                            
                            nav?.popViewController(animated: true)
                            
                        }

                    }
                }else{
                    AlertView.sharedManager.presentAlertWith(title: "", msg: (obj.message ?? "") as NSString, buttonTitles: ["OK"], onController: (nav?.topViewController)!) { title, index in
                        
                        nav?.popViewController(animated: true)
                        
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
                
                self.itemObj?.isLiked = !(self.itemObj?.isLiked ?? false)
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
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)

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
                
                if status == 200 {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)

                    self.itemObj?.isFeature = true
                    nav?.popToRootViewController(animated: true)
                    AlertView.sharedManager.showToast(message: message)
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
            }
        }
    }
    
    
    
    func getLimitsApi(nav:UINavigationController?){
        
        let strUrl = Constant.shared.getLimits + "?package_type=advertisement"
        URLhandler.sharedinstance.makeCall(url:strUrl , param:nil,methodType: .get) { [self] responseObject, error in
            
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
                }else{
                    AlertView.sharedManager.showToast(message: message)
                    
                    if (self.itemObj?.city?.count ?? 0) > 0 && (self.itemObj?.categoryID ?? 0) > 0 {
                        
                        if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPackageVC") as? CategoryPackageVC{
                            destvc.hidesBottomBarWhenPushed = true
                            destvc.categoryId = self.itemObj?.categoryID ?? 0
                            destvc.categoryName = self.itemObj?.category?.name ?? ""
                            destvc.city = self.itemObj?.city ?? ""
                            destvc.country =  self.itemObj?.country ?? ""
                            destvc.state =  self.itemObj?.state ?? ""
                            destvc.latitude = "\(self.itemObj?.latitude ?? 0.0)"
                            destvc.longitude = "\(self.itemObj?.longitude ?? 0.0)"
                           nav?.pushViewController(destvc, animated: true)
                        }
                    }

                }
            }
        }
    }

    
    func updateItemStatus(nav:UINavigationController?){
        
        let params = ["status":"inactive","item_id":(itemObj?.id ?? 0)] as [String : Any]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.update_item_status, param: params,methodType: .post) {  responseObject, error in
            
            
            if(error != nil)
            {
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)

                    AlertView.sharedManager.showToast(message: message)
                    nav?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    
    func renewAdsApi(nav:UINavigationController?){
        
        let params = ["item_id":itemObj?.id ?? 0]
        URLhandler.sharedinstance.makeCall(url:Constant.shared.renew_item  , param:params,methodType: .post) { [self] responseObject, error in
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                let activePackage = result["activePackage"] as? Int ?? 0
                
                if status == 200{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)
                    AlertView.sharedManager.showToast(message: message)
                    nav?.popToRootViewController(animated: true)
                }else{
                    AlertView.sharedManager.showToast(message: message)
                    
                    if (self.itemObj?.city?.count ?? 0) > 0 && (self.itemObj?.categoryID ?? 0) > 0  && activePackage == 0{
                        
                        if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPackageVC") as? CategoryPackageVC{
                            destvc.hidesBottomBarWhenPushed = true
                            destvc.categoryId = self.itemObj?.categoryID ?? 0
                            destvc.categoryName = self.itemObj?.category?.name ?? ""
                            destvc.city = self.itemObj?.city ?? ""
                            destvc.country =  self.itemObj?.country ?? ""
                            destvc.state =  self.itemObj?.state ?? ""
                            destvc.latitude = "\(self.itemObj?.latitude ?? 0.0)"
                            destvc.longitude = "\(self.itemObj?.longitude ?? 0.0)"
                           nav?.pushViewController(destvc, animated: true)
                        }
                    }

                }
            }
        }
    }
        
    
    
    
    func postNowApi(nav:UINavigationController?){
        
        let params = ["id":itemObj?.id ?? 0]
        URLhandler.sharedinstance.makeCall(url:Constant.shared.post_draft_item , param: params, methodType:.post, showLoader: true) { [self] responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)

                    AlertView.sharedManager.showToast(message: message)
                    nav?.popViewController(animated: true)
                    
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                    
                    if (itemObj?.city?.count ?? 0) > 0 && (itemObj?.categoryID ?? 0) > 0 {
                        
                        if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPackageVC") as? CategoryPackageVC{
                            destvc.hidesBottomBarWhenPushed = true
                            destvc.categoryId = itemObj?.categoryID ?? 0
                            destvc.categoryName = itemObj?.category?.name ?? ""
                            destvc.city = itemObj?.city ?? ""
                            destvc.country =  self.itemObj?.country ?? ""
                            destvc.state =  self.itemObj?.state ?? ""
                            destvc.latitude = "\(self.itemObj?.latitude ?? 0.0)"
                            destvc.longitude = "\(self.itemObj?.longitude ?? 0.0)"
                            nav?.pushViewController(destvc, animated: true)
                        }
                    }
                }
            }
        }
        
    }
}


