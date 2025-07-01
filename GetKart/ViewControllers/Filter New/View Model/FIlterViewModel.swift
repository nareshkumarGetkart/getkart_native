//
//  FIlterViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/06/25.
//

import Foundation


class FIlterViewModel:ObservableObject{
    
    @Published var fieldsArray:[CustomField] = []
    @Published var selectedIndex = -1
    var dictCustomFields:Dictionary<String,Any> = [:]

    init(){
        
    }
    
    
    func getCustomFieldsListApi(category_ids:String){
        
       let city = Local.shared.getUserCity()
       let country = Local.shared.getUserCountry()
       let  state = Local.shared.getUserState()
    
        var latitude = ""
        var longitude = ""

        if state.count > 0 || state.count > 0{
            latitude = Local.shared.getUserLatitude()
            longitude = Local.shared.getUserLongitude()
        }
        
        
        var strUrl = Constant.shared.getFilterCustomfields + "?category_ids=\(category_ids)"
        
        if city.count > 0{
            strUrl.append("&city=\(city)")
        }
        
        if state.count > 0{
            strUrl.append("&state=\(state)")
        }
        
        if country.count > 0{
            strUrl.append("&country=\(country)")
        }
        
        if latitude.count > 0 && (state.count > 0 || city.count > 0){
            strUrl.append("&latitude=\(latitude)")
        }
        
        if longitude.count > 0 && (state.count > 0 || city.count > 0){
            strUrl.append("&longitude=\(longitude)")
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {[weak self] (obj:CustomFieldsParse) in
            
            if obj.data != nil {
                self?.fieldsArray = obj.data ?? []
                    
//                if category_ids.count > 0{
//                    let objCategory = CustomField(id: 123323, name: "Category", type: .category, image: "", customFieldRequired: nil, values: nil, minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil)
//                    self?.fieldsArray.insert(objCategory, at: 0)
//                }
//                
                let objSortBY = CustomField(id: 345676, name: "Sort By", type: .sortby, image: "", customFieldRequired: nil, values: [
                   // "Default",
                    "New to Old",
                    "Old to New",
                    "Price High to Low",
                    "Price Low to High"
                ], minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil,ranges: [])
                self?.fieldsArray.append(objSortBY)
                
                self?.selectedIndex = 0

            }
        }
    }
    
}
