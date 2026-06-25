//
//  BoardSeacrhViewModal.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 23/06/26.
//

import Foundation



@MainActor
final class HomeSerchViewModal: ObservableObject {

    @Published var banners: [SliderModel] = []
    @Published var featuredBoards: [ItemModel] = []
    @Published var ideas: [ItemModel] = []
    @Published var popular: [ItemModel] = []

    @Published var isLoading = false

    init(){
        fetchBanners()
        fetchFeaturedBoard()
        fetchIdeas()
        fetchPopuplarItems()
    }
   
    
    func fetchBanners() {
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_search_banners) {[weak self] (obj:SliderModelParse) in
            
            if obj.code == 200{
                if let arr = obj.data{
                    self?.banners = arr
                }
            }
            
        }
    }
    
    func fetchPopuplarItems() {
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_popular_items) {[weak self] (obj:ItemParse) in
            
            if obj.code == 200{
                if let arr = obj.data?.data{
                    self?.popular = arr
                }
            }
            
        }
    }
    
        
    
    func fetchFeaturedBoard() {
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_featured_board) {[weak self] (obj:ItemParse) in
            
            if obj.code == 200{
                if let arr = obj.data?.data{
                    self?.featuredBoards = arr
                }
            }
            
        }
        
    }
    
    func fetchIdeas() {
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_ideas_foru) {[weak self] (obj:ItemParse) in
            
            if obj.code == 200{
                if let arr = obj.data?.data{
                    self?.ideas = arr
                }
            }
            
        }
        
    }
    
     func campaignClickEventApi(campaignBannerId: Int) {
        let params: [String: Any] = [
            "campaign_banner_id": campaignBannerId,
            "event_type": "click",
            "referrer_url": "HOME"
        ]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.campaign_event,
            param: params,
            methodType: .post,
            showLoader: false
        ) { _, _ in }
    }
    
     func captureSliderClickApi(campaignBannerId: Int) {
        let params: [String: Any] = ["id": campaignBannerId]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.capture_slider_click,
            param: params,
            methodType: .post,
            showLoader: false
        ) { _, _ in }
    }
}
