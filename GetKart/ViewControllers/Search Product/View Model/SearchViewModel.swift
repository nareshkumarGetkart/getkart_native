//
//  SearchViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/04/25.
//

import Foundation


class SearchViewModel:ObservableObject{
    
    
    @Published var items = [ItemModel]()
    var page = 1
    @Published var isDataLoading = false
    var city = ""
    var country = ""
    var state = ""
    var categroryId = 0
    var dictCustomFields:Dictionary<String,Any> = [:]
    var selectedSortBy: String  = "Default"
    var latitude = ""
    var longitude = ""

    init(catId:Int){
        categroryId = catId
        city = Local.shared.getUserCity()
        state = Local.shared.getUserState()
        country = Local.shared.getUserCountry()
       // latitude = Local.shared.getUserLatitude()
       // longitude = Local.shared.getUserLongitude()

        getSearchItemApi(srchTxt:"")

    }
    
    
    func getSearchItemApi(srchTxt:String){
        var latitude = 0.0
       var longitude = 0.0
        
        var strUrl = Constant.shared.get_item + "?category_id=\(categroryId)&page=\(page)"

              
        if srchTxt.count > 0{
            strUrl.append("&search=\(srchTxt)")
        }
        
        if city.count > 0{
            strUrl.append("&city=\(city)")
        }
        
        if country.count > 0{
            strUrl.append("&country=\(country)")
        }
        
        
        if state.count > 0{
            strUrl.append("&state=\(state)")
        }
        
        
        
     /*
        if latitude.count > 0{
            strUrl.append("&latitude=\(latitude)")
        }
        
        
        if longitude.count > 0{
            strUrl.append("&longitude=\(longitude)")
        }
        */
        if  let  latit = dictCustomFields["latitude"]  as? Double{
            latitude =  latit
            strUrl.append("&latitude=\(latitude)")
        }
        
        if  let  longit = dictCustomFields["longitude"]  as? Double{
            longitude =  longit
            strUrl.append("&longitude=\(longitude)")
        }
       
        if selectedSortBy.count > 0{
            
            if selectedSortBy == "Default"{
                
            }else{
                let str = selectedSortBy.lowercased()
                    .replacingOccurrences(of: " ", with: "-")
                strUrl.append("&sort_by=\(str)")
            }
        }

        
        if  let  max_price = dictCustomFields["max_price"]  as? String{
            strUrl.append("&max_price=\(max_price)")
        }
        
        if  let  min_price = dictCustomFields["min_price"]  as? String{
            strUrl.append("&min_price=\(min_price)")
        }
        
        isDataLoading = true
       // city: Akasahebpet, state: Andhra Pradesh, country: India
      
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:ItemParse) in

            if self.page == 1{
                self.items = obj.data?.data ?? []

            }else{
                self.items.append(contentsOf: (obj.data?.data)!)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.isDataLoading = false
                self.page = (self.page) + 1
            })
        }

    }
}
