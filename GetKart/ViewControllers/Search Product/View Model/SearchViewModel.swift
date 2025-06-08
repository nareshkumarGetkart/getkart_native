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
    var categroryId = ""
    var dictCustomFields:Dictionary<String,Any> = [:]
    var selectedSortBy: String  = "Default"
    var latitude = ""
    var longitude = ""
    var categoryIds = ""


    init(catId:Int,categoryIds:String){
        self.categoryIds = categoryIds
        self.categroryId = "\(catId)"
        self.city = Local.shared.getUserCity()
        self.state = Local.shared.getUserState()
        self.country = Local.shared.getUserCountry()
        latitude = Local.shared.getUserLatitude()
        longitude = Local.shared.getUserLongitude()
        
        dictCustomFields["country"] = country
        dictCustomFields["state"] = state
        dictCustomFields["city"] = city
        
        dictCustomFields["latitude"] = latitude
        dictCustomFields["longitude"] = longitude
        
        dictCustomFields["category_id"] = self.categroryId
        getSearchItemApi(srchTxt:"")
        
        
    }
    
    
    func getSearchItemApi(srchTxt:String){
       // var latitude = 0.0
        // var longitude = 0.0
        
        var strUrl = Constant.shared.get_item + "?category_id=\(categroryId)&page=\(page)"

        print("\n===\(dictCustomFields)\n")
     
      
        /*
        if city.count > 0{
            strUrl.append("&city=\(city)")
        }
        
        if country.count > 0{
            strUrl.append("&country=\(country)")
        }
        
        
        if state.count > 0{
            strUrl.append("&state=\(state)")
        }
        
        */
        
       /*
        if latitude.count > 0{
            strUrl.append("&latitude=\(latitude)")
        }
        
        if longitude.count > 0{
            strUrl.append("&longitude=\(longitude)")
        }
        */
        
        
        
        if dictCustomFields.keys.count == 0 {
            strUrl = Constant.shared.get_item + "?category_id=\(categroryId)&page=\(page)"
            
            if  !self.latitude.isEmpty{

                strUrl.append("&latitude=\(latitude)")
            }
            
            if  !self.longitude.isEmpty{
                strUrl.append("&longitude=\(longitude)")
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
        }else {
            strUrl = "\(Constant.shared.get_item)?page=\(page)"
            
            for (ind,key) in dictCustomFields.keys.enumerated(){
                // for ind in 0..<keys.count {
                //let key = keys[ind] as? String ?? ""
//                if ind == 0 {
//                    strUrl = strUrl + "?\(dictCustomFields[key] ?? "")"
//                }else {
                  //  strUrl = strUrl + "&\(dictCustomFields[key] ?? "")"
               // }
                if let value = dictCustomFields[key]{
                   
                    if ["city","state","latitude","longitude","country","min_price","max_price","category_id","posted_since"].contains(key){
                   
                        if let value = dictCustomFields[key] {
                            if "\(value)".trim().count > 0{
                                
                                strUrl += "&\(key)=\(value)"
                            }
                        }

                    }else{
                        if let value = dictCustomFields[key] {
                            
                            strUrl += "&custom_fields[\(key)]=\(value)"
                        }

                    }
                }
            }
        }
                
        /*
        if  let  latit = dictCustomFields["latitude"]  as? Double{
            latitude =  latit
            strUrl.append("&latitude=\(latitude)")
        }
        
        if  let  longit = dictCustomFields["longitude"]  as? Double{
            longitude =  longit
            strUrl.append("&longitude=\(longitude)")
        }
       */
        
        
        
        let cityDict = dictCustomFields["city"] as? String ?? ""
        let stateDict = dictCustomFields["state"] as? String ?? ""
        let country = dictCustomFields["country"] as? String ?? ""
        
        if cityDict.count == 0 && stateDict.count == 0 && country.count == 0{
            
            let city = Local.shared.getUserCity()
            let country = Local.shared.getUserCountry()
            let state = Local.shared.getUserState()
            let lat = Local.shared.getUserLatitude()
            let long = Local.shared.getUserLongitude()

                if !strUrl.localizedStandardContains("country") {
                    strUrl.append("&country=\(country)")
                }
                
             if (!strUrl.localizedStandardContains("state")) && state.count > 0{
                    
                    strUrl.append("&state=\(state)")
                }
                if (!strUrl.localizedStandardContains("city")) && city.count > 0{
                    
                    strUrl.append("&city=\(city)")
                }
                if (!strUrl.localizedStandardContains("latitude")) && (city.count > 0 || state.count > 0){
                    
                    strUrl.append("&latitude=\(lat)")
                }
                
                if (!strUrl.localizedStandardContains("longitude")) && (city.count > 0 || state.count > 0){
                    
                    strUrl.append("&longitude=\(long)")
                }
        }
        
        
        if selectedSortBy.count > 0{
            
            if selectedSortBy == "Default"{
                
            }else{
                let str = selectedSortBy.lowercased()
                    .replacingOccurrences(of: " ", with: "-")
                strUrl.append("&sort_by=\(str)")
            }
        }
        
        
        if srchTxt.count > 0{
            strUrl.append("&search=\(srchTxt)")
        }

        /*
        if  let  max_price = dictCustomFields["max_price"]  as? String{
            strUrl.append("&max_price=\(max_price)")
        }
        
        if  let  min_price = dictCustomFields["min_price"]  as? String{
            strUrl.append("&min_price=\(min_price)")
        }
        */
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
