//
//  FavoriteBoardViewModel.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/12/25.
//


import Foundation
import SwiftUI


final class FavoriteBoardViewModel: ObservableObject {

    // MARK: - Published (UI State)
    @Published var items: [ItemModel] = []
    @Published var isLoading: Bool = false
    @Published var hasMoreData: Bool = true

    // MARK: - Pagination
    private var page: Int = 1
    private let preloadOffset = 4   // 🔥 KEY
    private var didUserScroll = false   // 🔥 KEY
    private var lastTriggeredCount = 0
    
    private let preloadDistance: CGFloat = 200
    private var lastTriggerPage = 0

    func handleScrollBottom(bottomY: CGFloat) {
        let screenHeight = UIScreen.main.bounds.height

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
        guard didUserScroll else { return }
        guard !isLoading, hasMoreData else { return }

        let threshold = max(items.count - preloadOffset, 0)
        guard currentIndex >= threshold else { return }

        guard lastTriggeredCount != items.count else { return }
        lastTriggeredCount = items.count

        fetchBoards()
    }


    // MARK: - Category Change
    func categoryChanged(_ id: Int) {
        isLoading = false
        hasMoreData = true
        didUserScroll = false   // 🔥 reset
        loadInitial()
    }

    // MARK: - Like Update
    func updateLike(boardId: Int, isLiked: Bool) {
        if let index = items.firstIndex(where: { $0.id == boardId }) {
            items[index].isLiked = isLiked
            manageLikeDislikeApi(boardId: boardId, index: index)
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

        isLoading = true

        let url =
        Constant.shared.get_favourite_board + "?page=\(page)"

        ApiHandler.sharedInstance.makeGetGenericData(
            isToShowLoader: showLoader,
            url: url,
            loaderPos: .mid
        ) { (obj: ItemParse) in

            DispatchQueue.main.async {
                if obj.code == 200,
                   let data = obj.data?.data,
                   !data.isEmpty {

                    self.items.append(contentsOf: data)
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
                           
                             
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshLikeDislikeBoard.rawValue), object:  ["isLike":self.items[index].isLiked ?? false,"count":favouriteCount,"boardId":boardId], userInfo: nil)


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
