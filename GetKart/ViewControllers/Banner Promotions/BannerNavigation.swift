//
//  BannerNavigation.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/10/25.
//

import Foundation
import SwiftUI


struct BannerNavigation{
        
    
    static func navigateToScreen(index:Int, sliderObj:SliderModel?,navigationController:UINavigationController?,viewType:String){
        
        if ((sliderObj?.is_active ?? 0) != 0) && (sliderObj?.id ?? 0) > 0 && (sliderObj?.is_campaign ?? false){
            campaignClickEventApi(campaign_banner_id: sliderObj?.id ?? 0, viewType: viewType)
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
          
            if (sliderObj?.model?.id ?? 0) == 0 && (sliderObj?.model?.slug ?? "").count == 0{return}

            var detailView =  ItemDetailView(navController:  navigationController, itemId:sliderObj?.model?.id ?? 0, itemObj: nil, slug: sliderObj?.model?.slug ?? "")
            detailView.returnValue = {  value in
                if let obj = value{
                    
                }
            }
            let hostingController = UIHostingController(rootView:detailView)
            hostingController.hidesBottomBarWhenPushed = true
           navigationController?.pushViewController(hostingController, animated: true)
        }
    }
    
    
    
    static private func getCategoriesListApi(sliderObj:SliderModel?,navigationController:UINavigationController?){
        
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
    
    
    static private func isUserLoggedInRequest() -> Bool {
        
        
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
    

    
    static private func campaignClickEventApi(campaign_banner_id:Int,viewType:String){
        

        let params = ["campaign_banner_id":campaign_banner_id,"country":Local.shared.getUserCountry(),"city": Local.shared.getUserCity(),"state":Local.shared.getUserState(),"area":Local.shared.getUserLocality(),"event_type":"click","latitude":Local.shared.getUserLatitude(),"longitude":Local.shared.getUserLongitude(),"referrer_url":viewType] as [String : Any]
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
