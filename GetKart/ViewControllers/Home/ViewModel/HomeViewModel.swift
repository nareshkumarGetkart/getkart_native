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

class HomeViewModel{
    
    var sliderArray:[SliderModel]?
    var categoryObj:CategoryModelClass?
    var itemObj:ItemModelClass?
    var featuredObj:[FeaturedClass]?
    
    
    weak var delegate:RefreshScreen?
    
    var page = 1
    
    init(){
        getCategoriesListApi()
        getSliderListApi()
        getFeaturedListApi()
    }
    
    
    func getProductListApi(){
        let strUrl = "\(Constant.shared.get_item)?page=\(page)&city=New%20Delhi"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:ItemParse) in

            self.itemObj = obj.data
            self.delegate?.refreshScreen()
        }
    }
    
    
    func getFeaturedListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_featured_section) { (obj:FeaturedParse) in
            
            self.featuredObj = obj.data
            self.delegate?.refreshScreen()
        }
    }
    
    
    
    func getSliderListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_slider) { (obj:SliderModelParse) in
            
            if obj.data != nil {
                self.sliderArray = obj.data
                self.delegate?.refreshScreen()
            }
        }
    }
    
    
    func getCategoriesListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_categories) { (obj:CategoryParse) in
            
            if obj.data != nil {
                self.categoryObj = obj.data
                self.delegate?.refreshScreen()
            }
        }
    }
}




