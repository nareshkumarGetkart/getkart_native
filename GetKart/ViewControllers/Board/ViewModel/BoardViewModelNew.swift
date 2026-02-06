//
//  BoardViewModelNew.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/01/26.
//

import Foundation


import Foundation
import SwiftUI

/*final class BoardViewModelNew: ObservableObject {

    // MARK: - Published States
    @Published private(set) var items: [ItemModel] = []
    @Published var isLoading: Bool = false
    @Published var isLastPage: Bool = false
    @Published var errorMessage: String?
      private var isRefreshing = false

     var isScrollArmed = true   // 🔥 KEY

    // MARK: - Pagination
    private(set) var currentPage: Int = 1
    private let pageSize: Int = 10
    private var requestedPages: Set<Int> = []   // 🔒 PAGE LOCK

    // MARK: - Category
    let categoryId: Int

    // MARK: - Scroll trigger protection
    private var isRequestInProgress = false

    // MARK: - Init
    init(categoryId: Int) {
        self.categoryId = categoryId
    }

    // MARK: - Initial Load
    func loadInitial() {
        guard !isLoading else { return }
        currentPage = 1
        isLastPage = false
        items.removeAll()
        
        fetchBoards(page: currentPage)
    }
   
    func refresh() async {
          isScrollArmed = false        // 🔒 DISARM
            guard !isRefreshing else { return }
            isRefreshing = true
            reset()

            await fetchBoardsAsync(page: 1)

            isRefreshing = false
        }

        private func reset() {
            currentPage = 1
            isLastPage = false
            requestedPages.removeAll()
            items.removeAll()
        }
    
    // 🔥 CALLED ON TAB APPEAR
    func loadIfNeeded() {
        guard items.isEmpty else {
            // ✅ already loaded → DO NOTHING
            return
        }
        fetchBoards(page: currentPage)
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard !isLoading, !isLastPage else { return }

        let thresholdIndex = max(items.count - 1, 0) // trigger 3 items before end
        guard currentIndex == thresholdIndex else { return }
        

        loadNextPage()
    }
    

    // MARK: - Pagination
    func loadNextPage() {
        guard !isLoading,
              !isLastPage,
              !isRequestInProgress,
              isScrollArmed
        else { return }

        isScrollArmed = false        // 🔒 DISARM
        isRequestInProgress = true
        isLoading = true

        let nextPage = currentPage + 1
        fetchBoards(page: nextPage)
    }

    
    /// 🔓 Call when user scrolls again
      func rearmPagination() {
          isScrollArmed = true
      }

    private func fetchBoardsAsync(page: Int) async {
           await withCheckedContinuation { continuation in
               fetchBoards(page: page)
               continuation.resume()
           }
       }
    // MARK: - API Call
    private func fetchBoards(page: Int) {

        let url =
        Constant.shared.get_public_board +
        "?page=\(page)&category_id=\(categoryId != 55555 ? "\(categoryId)" : "")"

        URLhandler.sharedinstance.makeCall(
            url: url,
            param: nil,
            methodType: .get
        ) { [weak self] responseObject, error in
            guard let self else { return }

            DispatchQueue.main.async {

                self.isRequestInProgress = false
                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard
                    let dict = responseObject as? NSDictionary,
                    let dataDict = dict["data"] as? NSDictionary,
                    let dataArray = dataDict["data"] as? [[String: Any]]
                else {
                    self.isLastPage = true
                    return
                }

                let newItems: [ItemModel] = dataArray.compactMap {
                    try? JSONDecoder().decode(
                        ItemModel.self,
                        from: JSONSerialization.data(withJSONObject: $0)
                    )
                }

                if page == 1 {
                    self.items = newItems
                } else {
                    self.items.append(contentsOf: newItems)
                }

                self.currentPage = page

                let current = dataDict["current_page"] as? Int ?? page
                let last = dataDict["last_page"] as? Int ?? page
                self.isLastPage = current >= last
            }
        }
    }

    // MARK: - Like / Unlike
    func updateLike(boardId: Int, isLiked: Bool) {
        guard let index = items.firstIndex(where: { $0.id == boardId }) else {
                    return
                }
        let params = ["board_id":boardId]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_board_favourite, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    if let  data = result["data"] as? Dictionary<String,Any>{
                     
                        if let favouriteCount = data["favourite_count"] as? Int{
                            
                            self.items[index].totalLikes = favouriteCount

                        }
                    }
                    
                }else{
                    
                }
            }
        }
    }
}
*/


/*
@MainActor
final class BoardViewModelNew: ObservableObject {

    @Published private(set) var items: [ItemModel] = []
    @Published var isLoading = false
    @Published var isLastPage = false

    private var currentPage = 0
    private var isRequestInProgress = false

    var categoryId: Int

    init(categoryId: Int) {
        self.categoryId = categoryId
    }

    func loadIfNeeded() {
        guard items.isEmpty else { return }
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoading, !isLastPage, !isRequestInProgress else { return }

        isRequestInProgress = true
        isLoading = true

        let nextPage = currentPage + 1
        fetchBoards(page: nextPage)
    }

    func refresh() async {
        currentPage = 0
        isLastPage = false
        items.removeAll()
        loadNextPage()
    }
    
    func update(likeCount:Int,isLike:Bool,boardId:Int){
        
        if let index = items.firstIndex(where: { $0.id == boardId }) {
            items[index].isLiked = isLike
            items[index].totalLikes = likeCount
        }
       
    }

    private func fetchBoards(page: Int) {

        let url =
        Constant.shared.get_public_board +
        "?page=\(page)&category_id=\(categoryId != 55555 ? "\(categoryId)" : "")"

        URLhandler.sharedinstance.makeCall(
            url: url,
            param: nil,
            methodType: .get
        ) { [weak self] responseObject, error in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                self.isRequestInProgress = false

                guard
                    let dict = responseObject as? NSDictionary,
                    let dataDict = dict["data"] as? NSDictionary,
                    let dataArray = dataDict["data"] as? [[String: Any]]
                else {
                    self.isLastPage = true
                    return
                }

                let newItems = dataArray.compactMap {
                    try? JSONDecoder().decode(
                        ItemModel.self,
                        from: JSONSerialization.data(withJSONObject: $0)
                    )
                }

                // 🔥 HARD STOP
                if newItems.isEmpty {
                    self.isLastPage = true
                    return
                }
                withAnimation(.none) {
                    
                    self.items.append(contentsOf: newItems)
                }
                self.currentPage = page

                let current = dataDict["current_page"] as? Int ?? page
                let last = dataDict["last_page"] as? Int ?? page
                self.isLastPage = current >= last
            }
        }
    }

    // MARK: - Like Update
    func updateLike(boardId: Int, isLiked: Bool) {
        if let index = items.firstIndex(where: { $0.id == boardId }) {
            items[index].isLiked = isLiked
            self.manageLikeDislikeApi(boardId: boardId, isLiked: isLiked)
        }
    }


    // MARK: - Like / Unlike (unchanged)
    func manageLikeDislikeApi(boardId: Int, isLiked: Bool) {
        guard let index = items.firstIndex(where: { $0.id == boardId }) else { return }

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
                    self.items[index].totalLikes = count
                }
            }
        }
    }
}
*/


@MainActor
final class BoardViewModelNew: ObservableObject {

    // MARK: - Published
    @Published private(set) var items: [ItemModel] = []
    @Published var isLoading = false
    @Published var isLastPage = false
    @Published var hasLoadedOnce = false

    // MARK: - Pagination
    private var currentPage = 0
    private var requestedPages: Set<Int> = []

    let categoryId: Int

    init(categoryId: Int) {
        self.categoryId = categoryId
    }

    // ✅ Expose read-only pagination info
    var page: Int { currentPage }
    var hasMorePages: Bool { !isLastPage }

    // MARK: - Initial load
    func loadIfNeeded() {
        guard items.isEmpty else { return }
        loadPage(1)
    }

    // MARK: - Trigger next page
    func tryLoadNextPage() {
        let nextPage = currentPage + 1
        guard !isLoading, !isLastPage, !requestedPages.contains(nextPage) else { return }

        requestedPages.insert(nextPage)
        loadPage(nextPage)
    }

    // MARK: - Page loader
    private func loadPage(_ page: Int) {
        guard !isLoading else { return }
        isLoading = true

        let url =
            Constant.shared.get_public_board +
            "?page=\(page)&category_id=\(categoryId != 55555 ? "\(categoryId)" : "")"

        URLhandler.sharedinstance.makeCall(
            url: url,
            param: nil,
            methodType: .get
        ) { [weak self] responseObject, error in
            guard let self else { return }

            DispatchQueue.main.async {
                defer {
                    
                    self.isLoading = false
                    self.hasLoadedOnce = true   // 👈 important

                } // 🔒 Unlock only after processing

                guard
                    let dict = responseObject as? NSDictionary,
                    let dataDict = dict["data"] as? NSDictionary,
                    let dataArray = dataDict["data"] as? [[String: Any]]
                else {
                    self.isLastPage = true
                    return
                }

                let newItems = dataArray.compactMap {
                    try? JSONDecoder().decode(
                        ItemModel.self,
                        from: JSONSerialization.data(withJSONObject: $0)
                    )
                }

                if newItems.isEmpty {
                    self.isLastPage = true
                    return
                }

                withAnimation(.none) {
                    
                    self.items.append(contentsOf: newItems)
                }
                self.currentPage = dataDict["current_page"] as? Int ?? page
                let last = dataDict["last_page"] as? Int ?? page
                self.isLastPage = self.currentPage >= last
            }
        }
    }

    // MARK: - Refresh
    func refresh() async {
        currentPage = 0
        isLastPage = false
        items.removeAll()
        requestedPages.removeAll()
        loadPage(1)
    }

    // MARK: - Like update
    func updateLike(boardId: Int, isLiked: Bool) {
        if let index = items.firstIndex(where: { $0.id == boardId }) {
            items[index].isLiked = isLiked
            self.manageLikeDislikeApi(boardId: boardId, isLiked: isLiked)
        }
    }
  
    
    func update(likeCount:Int,isLike:Bool,boardId:Int){
        
        if let index = items.firstIndex(where: { $0.id == boardId }) {
            items[index].isLiked = isLike
            items[index].totalLikes = likeCount
        }
       
    }
    
    
    func updateBoost(isBoosted:Bool,boardId:Int){
        
        if let index = items.firstIndex(where: { $0.id == boardId }) {
            items[index].isFeature = isBoosted
        }
       
    }

    // MARK: - Like / Unlike (unchanged)
    func manageLikeDislikeApi(boardId: Int, isLiked: Bool) {
        guard let index = items.firstIndex(where: { $0.id == boardId }) else { return }

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
                    self.items[index].totalLikes = count
                }
            }
        }
    }
}
