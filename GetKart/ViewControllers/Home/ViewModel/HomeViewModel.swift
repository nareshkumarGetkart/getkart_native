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
    
    var sliderArray = [SliderModel]()
    var categoryObj:CategoryModelClass?
    weak var delegate:RefreshScreen?
    
    var page = 1
    
    init(){
        getCategoriesListApi()
    }
    
    
    func getProductListApi(){
        let strUrl = "\(Constant.shared.get_item)?page=\(page)&city=New%20Delhi"
        URLhandler.sharedinstance.makeCall(url: strUrl,param: nil, methodType:.get) { responseObject, error in
            
        }
        
    }
    
    
    func getSliderListApi(){
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.get_slider ,param: nil, methodType:.get) { responseObject, error in
            
            
        }
        
    }
    
    
    func getCategoriesListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: Constant.shared.get_categories) { (obj:CategoryParse) in
            
            if obj.data != nil {
                self.categoryObj = obj.data
                self.delegate?.refreshScreen()
            }
        }
        
        
    }
    
    

    
    
    
    
}




