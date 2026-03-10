

import Foundation
import SwiftUI
import Combine
import Alamofire


class BoardSearchViewModel: ObservableObject {
  
    @Published var searchText: String = ""
    @Published var items: [Search] = [Search]()
    @Published var isDataLoading = true
    private var cancellables = Set<AnyCancellable>()
    private var debounceTimer: AnyCancellable?
    var page = 1
    var istoSearch = true
    var isEmptySearched = true
    
    
    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                if istoSearch{
                    self.page = 1
                    self.isDataLoading = true
                    self.getSearchSuggestionApi()
                }
            }
            .store(in: &cancellables)
    }

    
    
    func getSearchSuggestionApi(){
        self.items.removeAll()
        var strUrl = Constant.shared.board_suggestion_search
        if searchText.count > 0{
            strUrl.append("?search=\(searchText)")
        }
        
       AF.cancelAllRequests()
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) { (obj:SearchSuggestion) in
         
            if obj.code == 200 {
                self.isEmptySearched = (self.searchText.count == 0)
                self.items = obj.data ?? []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isDataLoading = false
                })
            }else{
                self.isDataLoading = false
            }
        }

    }

    
    func removeRecentSearchApi(suggestionId:Int){
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.clear_board_search + "?search_id=\(suggestionId)", param: nil,methodType: .get) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                _ = result["message"] as? String ?? ""
                
                if status == 200{
                    
                }else{
                }
            }
        }
    }
    
}
