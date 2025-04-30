//
//  HomeViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import Foundation

protocol RefreshScreen:AnyObject{
    func refreshScreen()
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

            if self?.page == 1{
                self?.itemObj = obj.data

            }else{
                self?.itemObj?.data?.append(contentsOf: (obj.data?.data)!)
            }
            self?.delegate?.refreshScreen()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self?.isDataLoading = false
                self?.page = (self?.page ?? 0) + 1
            })
        }
    }
    
    
    func getFeaturedListApi(){
        
        let city = Local.shared.getUserCity()
        let country = Local.shared.getUserCountry()
        let state = Local.shared.getUserState()

        var strUrl = "\(Constant.shared.get_featured_section)"

        if city.count > 0{
            strUrl.append("&city=\(city)")
        }
        
        if state.count > 0{
            strUrl.append("&state=\(state)")
        }
        
        if country.count > 0{
            strUrl.append("&country=\(country)")
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:FeaturedParse) in
            
            self?.featuredObj = obj.data
            self?.delegate?.refreshScreen()
        }
    }
    
    
    
    func getSliderListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_slider) {[weak self] (obj:SliderModelParse) in
            
            if obj.data != nil {
                self?.sliderArray = obj.data
                self?.delegate?.refreshScreen()
            }
        }
    }
    
    
    func getCategoriesListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_categories) {[weak self] (obj:CategoryParse) in
            
            if obj.data != nil {
                self?.categoryObj = obj.data
                self?.delegate?.refreshScreen()
            }
        }
    }
    
 
    func addToFavourite(index:Int){
        
//        let params = ["item_id":"\(listArray[index].id ?? 0)"]
//        
//        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
//            
//            if error == nil {
//                self.listArray[index].isLiked?.toggle()
//            }
//        }
    }
    
    
}




