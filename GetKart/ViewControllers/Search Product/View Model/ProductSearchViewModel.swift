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


class ProductSearchViewModel: ObservableObject {
  
    @Published var searchText: String = ""
    @Published var items: [Search] = [Search]()
    @Published var isDataLoading = true
    private var cancellables = Set<AnyCancellable>()
    private var debounceTimer: AnyCancellable?
    var page = 1

    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.page = 1
                self.isDataLoading = true
                self.getSearchSuggestionApi()
            }
            .store(in: &cancellables)
    }

    
    
    func getSearchSuggestionApi(){
        
        var strUrl = Constant.shared.search_suggestions
        if searchText.count > 0{
            strUrl.append("?search=\(searchText)")
        }
        
        AF.cancelAllRequests()

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) { (obj:SearchSuggestion) in
         
            if obj.code == 200 {
                self.items = obj.data ?? []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isDataLoading = false
                })
            }else{
                self.isDataLoading = false
            }
        }

    }

}
