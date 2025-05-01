//
//  SeeAllViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 04/03/25.
//

import Foundation

class SeeAllViewModel{
    
    var isDataLoading = true
    var page = 1
    var listArray:Array<ItemModel>?
    weak var delegate:RefreshScreen?
    var itemId = 0
    
    init(itemId:Int){
        self.itemId = itemId
        getItemListApi()
    }
    
    func getItemListApi(){
        isDataLoading = true
        
       // let params = ["featured_section_id":self.itemId,"page":page,"_total_api_calls":1] as [String : Any]
        
        
        let strUrl = "\(Constant.shared.get_item)?featured_section_id=\(self.itemId)&page=\(page)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:ItemParse) in
        
       // ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.get_item, param: params,httpMethod:.post) {[weak self] (obj:ItemParse) in

            if self?.page == 1{
                self?.listArray = Array<ItemModel>()
               // self?.listArray = obj.data?.data

            }else{
               // self?.listArray?.append(contentsOf: (obj.data?.data)!)
            }
            self?.delegate?.newItemRecieve(newItemArray: obj.data?.data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self?.isDataLoading = false
                self?.page = (self?.page ?? 0) + 1
            })
        }
    }
}
