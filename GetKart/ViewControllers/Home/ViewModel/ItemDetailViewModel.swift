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
  //  @Published var sellerObj:SellerModel?
    @Published var relatedDataItemArray = [ItemModel]()
    @Published var itemObj:ItemModel?
    
    @Published var bannerAdsArray = [SliderModel]()

    

    var updateSelectedIndex: (()->())?
    
    var isMyProduct = false
    
    init(){
        getSliderListApi()
    }
    
    
    func getItemDetail(id:Int,slug:String,nav:UINavigationController?){
        
        var strUrl = Constant.shared.get_item + "?id=\(id)"
        if slug.count > 0{
            strUrl = Constant.shared.get_item + "?slug=\(slug)"
        }
        if isMyProduct == false{
            
            ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { [self] (obj:SingleItemParse) in
                
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
                        
                        self.updateSelectedIndex?()
                        
                      //  self.getSeller(sellerId: item.userID ?? 0)
                        self.getProductListApi(categoryId: item.categoryID ?? 0, excludeId: item.id ?? 0)
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
    
    
    
    
    
//    func getSeller(sellerId:Int){
//        
//        let strUrl = Constant.shared.get_seller + "?id=\(sellerId)"
//        
//        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:SellerParse) in
//            
//            if obj.data != nil {
//                self.sellerObj = obj.data?.seller
//            }
//        }
//    }
//    
    
    func getProductListApi(categoryId:Int,excludeId:Int){
        
        let strUrl = "\(Constant.shared.get_item)?category_id=\(categoryId)&exclude_id=\(excludeId)"
        
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
    
    
    func makeItemFeaturd(nav:UINavigationController?){
        
        AlertView.sharedManager.presentAlertWith(title: "", msg: "Are you sure to create this item as Boost ad?", buttonTitles: ["Cancel","OK"], onController: (nav?.topViewController)!, tintColor: .black) { title, index in
            if index == 1{
                self.makeItemFeaturedApi(nav: nav)
            }else{
            }
        }
    }
    
    
   private func makeItemFeaturedApi(nav:UINavigationController?){
        
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
                            destvc.isAdvertisement = true
                           nav?.pushViewController(destvc, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
    
  /*  func getLimitsApi(nav:UINavigationController?){
        
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
*/
    
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
    
    func getSliderListApi(){
     
        let params = ["referrer_url":"AD_DETAIL","country":Local.shared.getUserCountry(),"state":Local.shared.getUserState(),"city":Local.shared.getUserCity(),"area":Local.shared.getUserLocality(),"latitude":Local.shared.getUserLatitude(),"longitude":Local.shared.getUserLongitude()]
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.get_slider, param: params,httpMethod: .post, completion:  {[weak self] (obj:SliderModelParse) in
      /*  ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_slider) {[weak self] (obj:SliderModelParse) in
            */
            if obj.code == 200 {
                self?.bannerAdsArray = obj.data ?? []
            }
        })
    }

    

    
    
    
     func navigateToScreen(index:Int, sliderObj:SliderModel?,navigationController:UINavigationController?){
        
        if ((sliderObj?.is_active ?? 0) != 0) && (sliderObj?.campaign_id ?? 0) > 0{
            campaignClickEventApi(campaign_banner_id: sliderObj?.campaign_id ?? 0)
        }
        if sliderObj?.appRedirection == true && sliderObj?.redirectionType == "AdsListing"{
            
            if isUserLoggedInRequest() {
                if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPlanVC") as? CategoryPlanVC{
                    destvc.hidesBottomBarWhenPushed = true
                   navigationController?.pushViewController(destvc, animated: true)
                }
            }
            
        }else if sliderObj?.appRedirection == true && sliderObj?.redirectionType == "CampaignBanner"{
            
            if isUserLoggedInRequest() {
               
                let destvc = UIHostingController(rootView: BannerPromotionsView(navigationController: navigationController))
                destvc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(destvc, animated: true)
                
            }
            
        }else if sliderObj?.appRedirection == true && sliderObj?.redirectionType == "BoostAdsListing"{
            
            if isUserLoggedInRequest() {
                if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPlanVC") as? CategoryPlanVC{
                    destvc.hidesBottomBarWhenPushed = true
                  navigationController?.pushViewController(destvc, animated: true)
                }
            }
        }else if (sliderObj?.thirdPartyLink?.count ?? 0) > 0{
            
            guard let url = URL(string: sliderObj?.thirdPartyLink ?? "") else {
                print("Invalid URL")
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
              //  if sliderObj?.
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL")
            }
        }else if sliderObj?.modelType?.contains("Category") == true {
            
            
            if (sliderObj?.model?.subcategoriesCount ?? 0) > 0{
                
                getCategoriesListApi(sliderObj: sliderObj, navigationController: navigationController)
                
            }else{
                let vc = UIHostingController(rootView: SearchWithSortView(categroryId: sliderObj?.modelID ?? 0, navigationController:navigationController, categoryName:  sliderObj?.model?.name ?? "", categoryIds: "\(sliderObj?.modelID ?? 0)", categoryImg: sliderObj?.model?.image ?? ""))
                vc.hidesBottomBarWhenPushed = true
              navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            
            var detailView =  ItemDetailView(navController:  navigationController, itemId:sliderObj?.model?.id ?? 0, itemObj: nil, slug: sliderObj?.model?.slug ?? "")
            detailView.returnValue = { [weak self] value in
                if let obj = value{
                    
                }
            }
            let hostingController = UIHostingController(rootView:detailView)
            hostingController.hidesBottomBarWhenPushed = true
           navigationController?.pushViewController(hostingController, animated: true)
        }
    }
    
    
    
    func getCategoriesListApi(sliderObj:SliderModel?,navigationController:UINavigationController?){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_categories) { (obj:CategoryParse) in
            
            var subCatArray = [Subcategory]()
            
            if obj.data != nil {
                
                for obj in obj.data?.data ?? []{
                    
                    if obj.id == sliderObj?.modelID {
                        subCatArray = obj.subcategories ?? []
                        break
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    let catIds = ["\(sliderObj?.model?.parentCategoryID ?? 0)","\(sliderObj?.modelID ?? 0)"].joined(separator: ",")
                    
                    let swiftUIView = SubCategoriesView(subcategories: subCatArray, navigationController:  navigationController, strTitle: sliderObj?.model?.name ?? "",category_id:"\(sliderObj?.modelID ?? 0)", category_ids:catIds, popType: .categoriesSeeAll) // Create SwiftUI view
                    let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                    hostingController.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(hostingController, animated: true)
                })
                
            }
        }
    }
    
    
    func isUserLoggedInRequest() -> Bool {
        
        
        if Local.shared.getUserId() > 0 {
            return true
            
            
        }else{
            
            AppDelegate.sharedInstance.showLoginScreen()

//            let logiView = UIHostingController(rootView: LoginRequiredView(loginCallback: {
//                //Login
//                AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
//                
//            }))
//            logiView.modalPresentationStyle = .overFullScreen // Full-screen modal
//            logiView.modalTransitionStyle = .crossDissolve   // Fade-in effect
//            logiView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
//            navigationController?.topViewController?.present(logiView, animated: true, completion: nil)
            
            return false
        }
    }
    

    
    func campaignClickEventApi(campaign_banner_id:Int){
        

        let params = ["campaign_banner_id":campaign_banner_id,"country":Local.shared.getUserCountry(),"city": Local.shared.getUserCity(),"state":Local.shared.getUserState(),"area":Local.shared.getUserLocality(),"event_type":"click","latitude":Local.shared.getUserLatitude(),"longitude":Local.shared.getUserLongitude(),"referrer_url":""] as [String : Any]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.campaign_event, param: params,methodType:.post,showLoader: false) { responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
               // let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    
               
                }else{
                    

                }
            }
        }
    }
}


