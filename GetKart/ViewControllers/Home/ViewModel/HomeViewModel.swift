//
//  HomeViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import Foundation

class HomeViewModel{
    
    var page = 1
    init(){
        
    }
    
    
    func getProductListApi(){
        
        URLhandler.sharedinstance.makeCall(url: "https://adminweb.getkart.com/api/get-item?page=1&city=New%20Delhi",param: nil, methodType:.get) { responseObject, error in
            
        }
        
    }
    
}

