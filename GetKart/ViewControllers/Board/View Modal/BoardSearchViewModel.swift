

import Foundation
import SwiftUI
import Combine
import Alamofire


class BoardSearchViewModel: ObservableObject {
  
    @Published var searchText: String = ""
    @Published var items: [Search] = [Search]()
    @Published var popularSearches: [String] = [String]()
    @Published var myViewItems: [ItemModel] = [ItemModel]()

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
        
      // AF.cancelAllRequests()
        
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
    

    func cancelSearchRequest() {
        AF.cancelAllRequests()
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
    
    func getPopularSearches(){
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.get_popular_searches, param: nil,methodType: .get) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                _ = result["message"] as? String ?? ""
                
                if status == 200{
                    if let data = result["data"] as? Array<String>{
                        self.popularSearches = data
                    }
                    
                }else{
                }
            }
        }
    }
    
    
    
    
    // MARK: - Page loader
     func getMyviewBoardList() {
        

        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.get_limited_views_items,
            param: nil,
            methodType: .get
        ) { [weak self] responseObject, error in
         
           
           // DispatchQueue.main.async { [self] in
                
                guard
                    let dict = responseObject as? NSDictionary,
                    let dataDict = dict["data"] as? NSDictionary,
                    let dataArray = dataDict["data"] as? [[String: Any]]
                else {
                    return
                }

                let newItems = dataArray.compactMap {
                    try? JSONDecoder().decode(
                        ItemModel.self,
                        from: JSONSerialization.data(withJSONObject: $0)
                    )
                }

                if newItems.count > 0{
                    self?.myViewItems = newItems
                }
             
            //}
        }
    }

    
    func updateLike(boardId: Int, isLiked: Bool) {
        if let index = myViewItems.firstIndex(where: { $0.id == boardId }) {
            myViewItems[index].isLiked = isLiked
            self.manageLikeDislikeApi(boardId: boardId, isLiked: isLiked)
        }
    }
  
    // MARK: - Like / Unlike (unchanged)
    func manageLikeDislikeApi(boardId: Int, isLiked: Bool) {
        guard let index = myViewItems.firstIndex(where: { $0.id == boardId }) else { return }

        let params = ["board_id": boardId]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.manage_board_favourite,
            param: params,
            methodType: .post
        ) { responseObject, error in
            guard error == nil else { return }

            let result = responseObject as? NSDictionary
            let status = result?["code"] as? Int ?? 0

            if status == 200,
               let data = result?["data"] as? [String: Any],
               let count = data["favourite_count"] as? Int {
                DispatchQueue.main.async {
                    self.myViewItems[index].totalLikes = count
                }
            }
        }
    }
}
