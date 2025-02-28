//
//  HomeViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import Foundation

class HomeViewModel{
    
    var sliderArray = [SliderModel]()
    
    var page = 1
    init(){
        
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
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.get_categories ,param: nil, methodType:.get) { responseObject, error in
            
        }
        
    }
    
    

    
    
    
    
}




