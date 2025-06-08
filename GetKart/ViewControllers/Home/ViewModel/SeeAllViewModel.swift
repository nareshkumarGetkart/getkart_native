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
    var city = ""
    var state = ""
    var country = ""
    var latitude = ""
    var longitude = ""

    init(itemId:Int){
        self.itemId = itemId
       // getItemListApi()
    }
    
    func getItemListApi(){
        isDataLoading = true
        
        var strUrl = "\(Constant.shared.get_item)?featured_section_id=\(self.itemId)&page=\(page)"

        if city.count > 0{
            if !strUrl.contains("?"){
                strUrl.append("?city=\(city)")
            }else{
                strUrl.append("&city=\(city)")

            }
        }
        
        if state.count > 0{
            if !strUrl.contains("?"){
                strUrl.append("?state=\(state)")
            }else{
                strUrl.append("&state=\(state)")

            }
        }
        
        if country.count > 0{
            if !strUrl.contains("?"){
                strUrl.append("?country=\(country)")

            }else{
                strUrl.append("&country=\(country)")
            }
        }
        
        
        if latitude.count > 0 && (state.count > 0 || city.count > 0){
            if !strUrl.contains("?"){
                strUrl.append("?latitude=\(latitude)")

            }else{
                strUrl.append("&latitude=\(latitude)")
            }
                
        }
        
        if longitude.count > 0 && (state.count > 0 || city.count > 0){
            if !strUrl.contains("?"){
                strUrl.append("?longitude=\(longitude)")
            }else{
                strUrl.append("?longitude=\(longitude)")
            }
        }
        
        
       // let params = ["featured_section_id":self.itemId,"page":page,"_total_api_calls":1] as [String : Any]
        
        
        
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
