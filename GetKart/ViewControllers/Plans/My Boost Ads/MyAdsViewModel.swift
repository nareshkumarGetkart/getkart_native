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
    var page = 1
    @Published var isDataLoading = false
    
    init(){
        getBoostAdsList()
    }
    
    func getBoostAdsList(){
        
        self.isDataLoading = true
        let strUrl  = "\(Constant.shared.my_items)?status=featured&page=\(page)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:MyAdsParse) in
            
            
            if (obj.code ?? 0) == 200 {
                if self?.page == 1{
                    self?.listArray.removeAll()
                }
                self?.listArray.append(contentsOf: obj.data?.data ?? [])
                                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    
                    self?.isDataLoading = false
                    self?.page += 1
                })
                
            }else{
                self?.isDataLoading = false
            }
            
        }
       
    }
    

    
}
