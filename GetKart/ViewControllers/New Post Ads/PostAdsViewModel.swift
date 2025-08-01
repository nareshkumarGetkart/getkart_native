//
//  PostAdsVIewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/07/25.
//

import Foundation


class PostAdsViewModel:ObservableObject{
    
    @Published var dataArray:[CustomField]?
    
    init(){
    }
    
    
    func getCustomFieldsListApi(category_ids:String){
        let url = Constant.shared.getCustomfields + "?category_ids=\(category_ids)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) {[weak self] (obj:CustomFieldsParse) in
            
            if obj.data != nil {
                self?.dataArray = obj.data
            }
        }
    }
}
