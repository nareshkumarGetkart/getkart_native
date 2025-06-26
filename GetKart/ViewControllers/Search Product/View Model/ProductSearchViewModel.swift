//
//  ProductSearchViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/06/25.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

enum ProductListSource {
    case initial
    case search(UUID)
    case filter
    case pagination
}

class ProductSearchViewModel: ObservableObject {
  
    @Published var searchText: String = ""
//    @Published var items: [ItemModel] = [ItemModel]()
    
    @Published var items: [Search] = [Search]()

    @Published var isDataLoading = true
    var dictCustomFields:Dictionary<String,Any> = [:]
    private var cancellables = Set<AnyCancellable>()
    private var debounceTimer: AnyCancellable?
    var page = 1
    var dataArray:Array<CustomField> = Array()
    private var currentSource: ProductListSource?
    @Published var shouldScrollToTop = false

    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
           // .removeDuplicates()// adjust time as needed
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.page = 1
                self.isDataLoading = true
              //  self.items = []
              //  let token = UUID()
//                self.getProductListApi(source:.search(token), searchTxt: newValue)
                
                self.getSearchSuggestionApi()
            }
            .store(in: &cancellables)
    }

    
    
    func getSearchSuggestionApi(){
        
        var strUrl = Constant.shared.search_suggestions
        if searchText.count > 0{
            strUrl.append("?search=\(searchText)")
        }
        
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) { (obj:SearchSuggestion) in
         
            if obj.code == 200 {
                self.items = obj.data ?? []
                self.shouldScrollToTop = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isDataLoading = false
                })
            }else{
                self.isDataLoading = false
            }
        }

    }

    
    /*
    func getProductListApi(source: ProductListSource,searchTxt: String) {
     
        Alamofire.Session.default.cancelAllRequests()

        currentSource = source
        isDataLoading = true
        var strUrl = ""
        
        if dictCustomFields.keys.count == 0 {
            strUrl = "\(Constant.shared.get_item)?page=\(page)&sort_by=popular_items"
            
        }else {
            strUrl = "\(Constant.shared.get_item)?page=\(page)"
            
            for (ind,key) in dictCustomFields.keys.enumerated(){
                
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
        
        
        let cityDict = dictCustomFields["city"] as? String ?? ""
        let stateDict = dictCustomFields["state"] as? String ?? ""
        let country = dictCustomFields["country"] as? String ?? ""
        
        if cityDict.count == 0 && stateDict.count == 0  && country.count  == 0{
            
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
        
        if searchTxt.count > 0{
            strUrl.append("&search=\(searchTxt)")
            strUrl = strUrl.replacingOccurrences(of: "&sort_by=popular_items", with: "")

        }
        
     
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) { (obj:ItemParse) in
                        
            // If this is a search with UUID, make sure it still matches
            if case let .search(uuid) = source,
               case let .search(currentUuid) = self.currentSource,
               uuid != currentUuid {
                return // Skip outdated response
            }
            
            if obj.code == 200 {
                if self.page == 1{
                    self.items = obj.data?.data ?? []
                    self.shouldScrollToTop = true
                }else{
                    self.items.append(contentsOf: (obj.data?.data)!)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isDataLoading = false
                    self.page = (self.page) + 1
                })
            }else{
                self.isDataLoading = false
            }
        }
    }*/
}
