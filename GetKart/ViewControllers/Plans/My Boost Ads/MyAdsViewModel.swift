//
//  MyAdsViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/04/25.
//

import Foundation
import UIKit


class MyAdsViewModel:ObservableObject{
    
    @Published var listArray = [ItemModel]()
    
    init(){
        getBoostAdsList()
    }
    
    func getBoostAdsList(){
        let strUrl  = "\(Constant.shared.my_items)?status=featured"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:MyAdsParse) in
            
            
            if (obj.code ?? 0) == 200 {
                self.listArray.append(contentsOf: obj.data?.data ?? [])
                
            }
            
        }
       
    }
    

    
}
