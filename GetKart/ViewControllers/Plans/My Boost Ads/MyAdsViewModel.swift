//
//  MyAdsViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/04/25.
//

import Foundation


class MyAdsViewModel:ObservableObject{
    
    @Published var listArray = [ItemModel]()
    
    init(){
        getBoostAdsList()
    }
    
    func getBoostAdsList(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.my_items) { (obj:MyAdsParse) in
            
            
            if (obj.code ?? 0) == 200 {
                self.listArray.append(contentsOf: obj.data?.data ?? [])
                
            }
            
        }
       
    }
    
}
