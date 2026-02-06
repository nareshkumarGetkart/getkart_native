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
    init(type:Int = 1,isToShowLoader:Bool = true){
        catType = type
        getCategoriesListApi(showLoader: isToShowLoader)
    }
    
    func getCategoriesListApi(showLoader:Bool = true){
        
        if  self.ismoreDataAvailable == false{
            return
        }
        
        let strUrl = Constant.shared.get_categories + "?page=\(page)&type=\(catType)"
        isDataLoading = true
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: showLoader, url:strUrl ) {[weak self] (obj:CategoryParse) in
            
            if obj.data != nil {
                
                self?.ismoreDataAvailable = (obj.data?.data ?? []).count > 4 ? true : false
                if self?.page == 1{
                    self?.listArray = obj.data?.data
                    
//                    if self?.catType == 2{
//                        self?.setCategories( self?.listArray ?? [])
//                    }
                    
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
    
    
    func setCategories(_ apiList: [CategoryModel]) {
           var list = apiList

           if list.first?.id != 55555 {
               list.insert(
                   CategoryModel(
                       id: 55555,
                       sequence: nil,
                       name: "All",
                       image: "",
                       parentCategoryID: nil,
                       description: nil,
                       status: nil,
                       createdAt: nil,
                       updatedAt: nil,
                       slug: nil,
                       subcategoriesCount: nil,
                       allItemsCount: nil,
                       translatedName: nil,
                       translations: nil,
                       subcategories: []
                   ),
                   at: 0
               )
           }

           listArray = list
       }
}





