//
//  FvoriteViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 26/03/25.
//

import Foundation


class FavoriteViewModel :ObservableObject{
    
     var page = 1
    @Published var isDataLoading = true
    @Published var listArray = [ItemModel]()
    
    init(){

    }
    
    
    func getFavoriteHistory(){
        isDataLoading = true
        let strUrl = Constant.shared.get_favourite_item + "?page=\(page)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) { (obj:FavoriteParse) in
            if obj.code == 200 {
                if self.page == 1{
                    self.listArray.removeAll()
                }
                self.listArray.append(contentsOf: obj.data?.data ?? [])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.page = self.page + 1
                    self.isDataLoading = false
                })
            }else{
                self.isDataLoading = false
            }
        }
    }
    
    
    func addToFavourite(index:Int){
        
        let params = ["item_id":"\(listArray[index].id ?? 0)"]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
            
            if error == nil {
                self.listArray[index].isLiked?.toggle()
            }
        }
    }
}
