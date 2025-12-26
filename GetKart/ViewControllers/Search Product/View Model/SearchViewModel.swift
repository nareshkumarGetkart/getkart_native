//
//  SearchViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/04/25.
//

import Foundation


class SearchViewModel:ObservableObject{
    
    @Published var items = [ItemModel]()
    @Published var isDataLoading = true
    var dictCustomFields:Dictionary<String,Any> = [:]
    var city = ""
    var country = ""
    var state = ""
    var categroryId = ""
    var selectedSortBy: String  = "Default"
    var latitude = ""
    var longitude = ""
    var categoryIds = ""
    @Published var shouldScrollToTop = false
    var page = 1

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
        
        isDataLoading = true
        
    
        var strUrl = Constant.shared.get_item + "?category_id=\(categroryId)&page=\(page)"

        if dictCustomFields.keys.count == 0 {
            
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
            
            for (_,key) in dictCustomFields.keys.enumerated(){
 
                if let value = dictCustomFields[key]{
                   
                    let rawValue = "\(value)"
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let encodedValue = rawValue
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&="))) ?? rawValue

                    if key == "category_id" && strUrl.contains("category_id")
                    {
                        print("key == \(key)")
                    }else  if ["city","state","latitude","longitude","country","min_price","max_price","category_id","posted_since","sort_by"].contains(key){
                   
                        if let value = dictCustomFields[key] {
                            if "\(value)".trim().count > 0{
                                strUrl += "&\(key)=\(encodedValue)"
                            }
                        }
                    }else{
                        if let value = dictCustomFields[key],"\(value)".count > 0 {
                            
                            strUrl += "&custom_fields[\(key)]=\(encodedValue)"
                        }
                    }
                }
            }
        }
      
        
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
        
        
        if srchTxt.count > 0{
            strUrl.append("&search=\(srchTxt)")
        }
    
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) { (obj:ItemParse) in

            if obj.code == 200{
              
                    
                    if self.page == 1{
                        self.items = obj.data?.data ?? []
                        DispatchQueue.main.async {
                        self.shouldScrollToTop = true
                        }
                    }else{
                        self.items.append(contentsOf: (obj.data?.data)!)
                    }
              
         
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.isDataLoading = false
                self.page = (self.page) + 1
            })
            }else{
                self.isDataLoading = false
            }
        }

    }
    


}
