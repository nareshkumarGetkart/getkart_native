//
//  BoardViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/12/25.
//

import Foundation
import SwiftUI

final class BoardViewModel: ObservableObject {

    // MARK: - Published (UI State)
    @Published var items: [ItemModel] = []
    @Published var selectedCategoryId: Int = 0
    @Published var isLoading: Bool = false
    @Published var hasMoreData: Bool = true

    // MARK: - Pagination
    private var page: Int = 1
    private let preloadOffset = 4   // 🔥 KEY
    private var didUserScroll = false   // 🔥 KEY
    private var lastTriggeredCount = 0
    private let preloadDistance: CGFloat =  200
    private var lastTriggerPage = 0

    func handleScrollBottom(bottomY: CGFloat) {
        let screenHeight = UIScreen.main.bounds.height

        print("screenHeight=\(screenHeight)\n")
        print("screenHeight + preloadDistance =\(screenHeight + preloadDistance)")

        guard bottomY < screenHeight + preloadDistance else { return }
        guard !isLoading, hasMoreData else { return }
        guard lastTriggerPage != page else { return }

        lastTriggerPage = page
        fetchBoards()
    }



    // MARK: - Initial Load
    func loadInitial() {
        page = 1
        lastTriggerPage = 0
        hasMoreData = true
        isLoading = false
        items.removeAll()
        fetchBoards(showLoader: false)
    }



    func loadNextPage() {
        guard !isLoading, hasMoreData else { return }
        fetchBoards()
    }

    // MARK: - Called when scroll happens
    func userDidScroll() {
        didUserScroll = true
    }

    // MARK: - Pagination Trigger
    // MARK: - NEXT PAGE CALL (🔥 THIS IS THE FIX)
 
    func loadNextPageIfNeeded(currentIndex: Int) {
        //guard didUserScroll else { return }
        guard !isLoading, hasMoreData else { return }

        let threshold = max(items.count - preloadOffset, 0)
      
        guard threshold >= 0 else { return }

        guard currentIndex >= threshold else { return }

        guard lastTriggeredCount != items.count else { return }
        lastTriggeredCount = items.count
        
        let objItem =  items[currentIndex]
        let lastItem = items.last
        if (objItem.id == lastItem?.id){
            fetchBoards()
        }

    }


    // MARK: - Category Change
  /*  func categoryChanged(_ id: Int) {
        
        if selectedCategoryId == id{
            return
        }
        isLoading = false
        hasMoreData = true
        didUserScroll = false   // 🔥 reset
        selectedCategoryId = id
        loadInitial()
    }
*/
    func categoryChanged(_ id: Int) {

        guard selectedCategoryId != id else { return }

        // 🔥 FULL RESET
        page = 1
        lastTriggerPage = 0
        lastTriggeredCount = 0
        hasMoreData = true
        isLoading = false
        didUserScroll = false

        items.removeAll()
        selectedCategoryId = id

        fetchBoards(showLoader: false)
    }

    // MARK: - Like Update
    func updateLike(boardId: Int, isLiked: Bool) {
        if let index = items.firstIndex(where: { $0.id == boardId }) {
            items[index].isLiked = isLiked
            self.manageLikeDislikeApi(boardId: boardId, index: index)
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
    
    // MARK: - API
    private func fetchBoards(showLoader: Bool = false) {
        guard !isLoading else { return }

        self.isLoading = true

        
        let url =
        Constant.shared.get_public_board +
        "?page=\(page)&category_id=\(selectedCategoryId > 0 ? "\(selectedCategoryId)" : "")"

        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: showLoader,
            url: url,
            loaderPos: .mid
        ) { (obj: ItemParse) in

            DispatchQueue.main.async {
                if obj.code == 200,
                   let data = obj.data?.data,
                   !data.isEmpty {

                    if self.page == 1{
                        self.items = data
                    }else{
//                        withTransaction(Transaction(animation: nil)) {
//                                self.items.append(contentsOf: data)
//                            }
                        self.items.append(contentsOf: data)
                    }
                    self.page += 1
                    self.hasMoreData = true
                } else {
                    self.hasMoreData = false
                }

                self.isLoading = false
            }
        }
    }
    
    func manageLikeDislikeApi(boardId:Int,index:Int){
        
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
    func outboundClickApi(strURl:String,boardId:Int){
        
        let params = ["board_id":boardId]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.board_outbond_click, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                _ = result["message"] as? String ?? ""
                
                if status == 200{

                }else{
                }
            }
        }
        
        
        if let url = URL(string: strURl)  {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL")
            }
        }
      
    }

}
