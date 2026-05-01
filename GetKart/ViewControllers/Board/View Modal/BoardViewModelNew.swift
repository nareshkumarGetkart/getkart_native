//
//  BoardViewModelNew.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/01/26.
//

import Foundation
import SwiftUI

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

    // Expose read-only pagination info
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
                    self.hasLoadedOnce = true   //  important

                } //  Unlock only after processing

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
    
    
    func updateCommentCount(commentCount:Int,commentObj:CommentModel?,boardId:Int){
        
        if let index = items.firstIndex(where: { $0.id == boardId }) {
            items[index].commentsCount = commentCount
            items[index].lastComment = commentObj
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
