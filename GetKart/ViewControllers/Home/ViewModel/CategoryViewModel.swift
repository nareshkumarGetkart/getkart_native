//
//  CategoryViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 04/03/25.
//

import Foundation


class CategoryViewModel:ObservableObject{
    
   @Published var listArray:[CategoryModel]?
    weak var delegate:RefreshScreen?
    private var page = 1
    var isDataLoading = true
    private var ismoreDataAvailable = true
    private var catType:Int  //1 for previous 2 for board
    init(type:Int = 1){
        catType = type
        getCategoriesListApi()
    }
    
    func getCategoriesListApi(){
        
        if  self.ismoreDataAvailable == false{
            return
        }
        
        let strUrl = Constant.shared.get_categories + "?page=\(page)&type=\(catType)"
        isDataLoading = true
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url:strUrl ) {[weak self] (obj:CategoryParse) in
            
            if obj.data != nil {
                
                self?.ismoreDataAvailable = (obj.data?.data ?? []).count > 4 ? true : false
                if self?.page == 1{
                    self?.listArray = obj.data?.data
                    
                }else{
                    self?.listArray?.append(contentsOf: obj.data?.data ?? [])
                }
                self?.delegate?.refreshScreen()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self?.isDataLoading = false
                    self?.page += 1
                    
                })
            }
        }
    }
}





