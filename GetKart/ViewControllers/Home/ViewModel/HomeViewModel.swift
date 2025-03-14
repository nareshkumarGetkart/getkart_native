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
    var isDataLoading = true
   
    init(){
        getCategoriesListApi()
        getSliderListApi()
        getFeaturedListApi()
    }
    
    
    func getProductListApi(){
        isDataLoading = true
        let strUrl = "\(Constant.shared.get_item)?page=\(page)&city=New%20Delhi"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:ItemParse) in

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
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_featured_section) {[weak self] (obj:FeaturedParse) in
            
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
    
 
    
    
}




