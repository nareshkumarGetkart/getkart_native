//
//  CategoryViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 04/03/25.
//

import Foundation


class CategoryViewModel{
    
    var listArray:[CategoryModel]?
    weak var delegate:RefreshScreen?
    var page = 1
    var isDataLoading = true
   
    init(){
        getCategoriesListApi()
       
    }
       
    
    func getCategoriesListApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_categories) {[weak self] (obj:CategoryParse) in
            
            if obj.data != nil {
                self?.listArray = obj.data?.data
                self?.delegate?.refreshScreen()
            }
        }
    }
}





