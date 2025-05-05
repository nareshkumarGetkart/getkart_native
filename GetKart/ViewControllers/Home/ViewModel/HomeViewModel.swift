//
//  HomeViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import Foundation

protocol RefreshScreen:AnyObject{
    func refreshScreen()
    func refreshFeaturedsList()
    func refreshBannerList()
    func refreshCategoriesList()
    func newItemRecieve(newItemArray:[Any]?)


}

extension RefreshScreen{
    func refreshFeaturedsList(){}
    func refreshBannerList(){}
    func refreshCategoriesList(){}
    func newItemRecieve(newItemArray:[Any]?){}

}

class HomeViewModel:ObservableObject{
    
    var sliderArray:[SliderModel]?
    var categoryObj:CategoryModelClass?
    var itemObj:ItemModelClass?
    var featuredObj:[FeaturedClass]?
    weak var delegate:RefreshScreen?
    var page = 1
    var isDataLoading = false
   
    init(){
        getCategoriesListApi()
        getSliderListApi()
        getFeaturedListApi()
    }
    
    
    func getProductListApi(){
        
        let city = Local.shared.getUserCity()
        let country = Local.shared.getUserCountry()
        let state = Local.shared.getUserState()

        if isDataLoading == true{
            return
        }
        isDataLoading = true
        var strUrl = "\(Constant.shared.get_item)?page=\(page)"
        
        if city.count > 0{
            strUrl.append("&city=\(city)")
        }
        
        if state.count > 0{
            strUrl.append("&state=\(state)")
        }
        
        if country.count > 0{
            strUrl.append("&country=\(country)")
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) {[weak self] (obj:ItemParse) in

            if obj.code == 200 {
                
                if self?.page == 1{
                    self?.itemObj = obj.data
                    self?.delegate?.refreshScreen()
                    
                }else{
                    self?.delegate?.newItemRecieve(newItemArray: obj.data?.data)
                    //  self?.itemObj?.data?.append(contentsOf: (obj.data?.data)!)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self?.isDataLoading = false
                    self?.page = (self?.page ?? 0) + 1
                })
            }
        }
    }
    
    
    func getFeaturedListApi(){
        
        let city = Local.shared.getUserCity()
        let country = Local.shared.getUserCountry()
        let state = Local.shared.getUserState()

        var strUrl = "\(Constant.shared.get_featured_section)"

        if city.count > 0{
            if !strUrl.contains("?"){
                strUrl.append("?city=\(city)")
            }else{
                strUrl.append("&city=\(city)")

            }
        }
        
        if state.count > 0{
            if !strUrl.contains("?"){
                strUrl.append("?state=\(state)")
            }else{
                strUrl.append("&state=\(state)")

            }
        }
        
        if country.count > 0{
            if !strUrl.contains("?"){
                strUrl.append("?country=\(country)")

            }else{
                strUrl.append("&country=\(country)")
            }
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:FeaturedParse) in
            
            if obj.code == 200 {
                
                self?.featuredObj = obj.data
                self?.delegate?.refreshFeaturedsList()
            }
        }
    }
    
    
    
    func getSliderListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_slider) {[weak self] (obj:SliderModelParse) in
            
            if obj.code == 200 {
                self?.sliderArray = obj.data
                self?.delegate?.refreshBannerList()
            }
        }
    }
    
    
    func getCategoriesListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_categories) {[weak self] (obj:CategoryParse) in
            
            if obj.code == 200 {
                self?.categoryObj = obj.data
                self?.delegate?.refreshCategoriesList()
            }
        }
    }
    
 /*
  //  func addToFavourite(index:Int){
        
//        let params = ["item_id":"\(listArray[index].id ?? 0)"]
//        
//        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
//            
//            if error == nil {
//                self.listArray[index].isLiked?.toggle()
//            }
//        }
 //   }
    
    */
    
    
}




