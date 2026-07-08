//
//  BoardSearchView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/05/26.
//

import SwiftUI
import Alamofire
import Kingfisher

extension Notification.Name {
    static let resumeBannerVideo = Notification.Name("resumeBannerVideo")
}

struct BoardSearchView: View {
   
    @StateObject private var viewModel = HomeSerchViewModal()
   
    let tabBarController: UITabBarController?
   
    private var navigationController: UINavigationController? {
        return tabBarController?.viewControllers?[1].navigationController
    }
    @State private var safariURL: URL?
    @State private var currentBanner = 0
    @State private var timer: Timer?
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing:8){
                Button {
                    pushSearchBoard()

                } label: {
                    HStack {

                        HStack(spacing: 8) {

                            Image(systemName: "magnifyingglass").foregroundColor(.orange)
                            Text("Search").foregroundColor(
                                    Color(.placeholderText)).font(.inter(.regular, size: 15))
                            Spacer()
                        }
                        .padding(.vertical, 13)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .cornerRadius(10.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10.0)
                                .strokeBorder(Color(UIColor.separator), lineWidth: 0.5))
                    }
                    .frame(height: 44)
                }.padding(.horizontal, 12)
                Divider()
            }

            // List of Recent Items
            ScrollView {
                
                if !viewModel.banners.isEmpty{
                    
                    bannerSection.padding(.top,5)
                       
                }
                
                if !viewModel.featuredBoards.isEmpty{
                    //MARK: My view
                    VStack(alignment: .leading, spacing: 5) {
                        
                        HStack {
                            Text("Explore featured boards")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                
                                pushToMyViewsScreen(type: .featured)
                            }) {
                                Text("See All")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding([.top,.horizontal], 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                
                                ForEach(viewModel.featuredBoards, id: \.id) { item in
                                    if (item.boardType == 1){
                                        //Promotional Ads image
                                        PromotionalAdsSearch(product: item,defaultImgHeight: 225) {
                                            if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
                                                safariURL = url
                                            }
                                            
                                        }.frame(width:175,height: 260)
                                           
                                    }else if item.boardType == 3{
                                        //Idea View
                                        IdeaCardSearch(product: item,
                                                          defaultImgWidth: 175,
                                                          defaultImgHeight: 215).frame(width:175,height: 260)
                                            .onTapGesture{
                                                pushToDetailScreen(item: item)

                                        }
                                    }else{
                                        //Normal board
                                        BoardCardView(product: item,
                                                      defaultImgWidth: 175,
                                                      defaultImgHeight: 195).frame(width:175,height: 260)
                                        .onTapGesture {
                                            pushToDetailScreen(item: item)
                                        }
                                    }
                                }
                            }.padding(.vertical,8)
                            .padding(.horizontal, 10)
                            //.padding(.bottom, 4)
                        }
                    }//.padding(.bottom, 30)
                }

                if !viewModel.ideas.isEmpty{
                    //MARK: My view
                    VStack(alignment: .leading, spacing: 5) {
                        
                        HStack {
                            Text("Ideas for you")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                
                                pushToMyViewsScreen(type: .ideasforyou)
                            }) {
                                Text("See All")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                
                                ForEach(viewModel.ideas, id: \.id) { item in

                                    if item.boardType == 3{
                                        //Idea View
                                        IdeaCardSearch(product: item,
                                                          defaultImgWidth: 175,
                                                          defaultImgHeight: 215).frame(width:175,height: 260)
                                            .onTapGesture{
                                                pushToDetailScreen(item: item)

                                        }
                                    }else{
                                        //Normal board
                                        BoardCardView(product: item,
                                                      defaultImgWidth: 175,
                                                      defaultImgHeight: 195).frame(width:175,height: 260)
                                        .onTapGesture {
                                            pushToDetailScreen(item: item)
                                        }
                                    }
                                }
                            }.padding(.vertical,8)
                            .padding(.horizontal, 10)
                            //.padding(.bottom, 4)
                        }
                    }//.padding(.bottom, 30)
                }
                
                if !viewModel.popular.isEmpty{
                    //MARK: Popular on getkart view
                    VStack(alignment: .leading, spacing: 5) {
                        
                        HStack {
                            Text("Popular on Getkart")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                
                                pushToMyViewsScreen(type: .popular)
                            }) {
                                Text("See All")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                
                                ForEach(viewModel.popular, id: \.id) { item in

                                   
                                    if (item.boardType == 1){
                                        //Promotional Ads image
                                        PromotionalAdsSearch(product: item,defaultImgHeight: 225) {
                                            if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
                                                safariURL = url
                                            }
                                            
                                        }.frame(width:175,height: 260)
                                           
                                    }else if (item.boardType == 3){
                                        //Idea View
                                        IdeaCardSearch(product: item,
                                                          defaultImgWidth: 175,
                                                          defaultImgHeight: 215).frame(width:175,height: 260)
                                            .onTapGesture{
                                                pushToDetailScreen(item: item)

                                        }
                                    }else{
                                        //Normal board
                                        BoardCardView(product: item,
                                                      defaultImgWidth: 175,
                                                      defaultImgHeight: 195).frame(width:175,height: 260)
                                        .onTapGesture {
                                            pushToDetailScreen(item: item)
                                        }
                                    }
                                }
                            }.padding(.vertical,8)
                            .padding(.horizontal, 10)
                            //.padding(.bottom, 4)
                        }
                    }.padding(.bottom, 5)
                }

                            
            }.scrollIndicators(.hidden, axes: .vertical)
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .refreshable {
            if !viewModel.isLoading{
                currentBanner = 0
                timer?.invalidate()
                viewModel.fetchBanners()
                viewModel.fetchFeaturedBoard()
                viewModel.fetchIdeas()
                viewModel.fetchPopuplarItems()
            }
        }.fullScreenCover(item: $safariURL,
                          onDismiss: {
            print("Safari dismissed")
                   NotificationCenter.default.post(name: .resumeBannerVideo, object: nil)
        }) { url in SafariView(url: url) }
            
            .onChange(of: viewModel.banners.count) { count in
                guard count > 0 else { return }
                startImageTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    
  
    
    func pushToMyViewsScreen(type:SeeAllType){

        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            let hostingVC = UIHostingController(rootView: MyViews(navigationController:navigationController, seeallType: type))
            navigationController?.pushViewController(hostingVC, animated: true)
        }
    }
   
   
    func pushToDetailScreen(item:ItemModel){

        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:navigationController, itemObj: item))
        navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    
    func pushSearchBoard() {
      
       let vc = UIHostingController(
           rootView: SearchBoardResultView(
               navigationController: navigationController,
               isByDefaultOpenSearch: true
           )
       )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: false)
   }
    
    func pushSearchBoardWithSearchText(srchTxt:String) {
      
       let vc = UIHostingController(
           rootView: SearchBoardResultView(
               navigationController: navigationController,
               searchText:srchTxt, isByDefaultOpenSearch: false
           )
       )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: false)
   }
    
    private func startImageTimer() {

        timer?.invalidate()

        guard !viewModel.banners.isEmpty else { return }
        let banner = viewModel.banners[currentBanner]

        let isVideo = (banner.image ?? "").lowercased().contains(".mp4")

        guard !isVideo else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in

            moveToNextBanner()
        }
    }
    

    private func moveToNextBanner() {

        timer?.invalidate()

        print("Current:", currentBanner, "Count:", viewModel.banners.count)

        withAnimation {
            currentBanner = (currentBanner + 1) % viewModel.banners.count
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {

            NotificationCenter.default.post(
                name: .resumeBannerVideo,
                object: nil
            )
        }

        print("Next:", currentBanner)
    }
    
}


extension BoardSearchView {

    var bannerSection: some View {

        VStack(spacing: 10) {

            TabView(selection: $currentBanner) {

                ForEach(0..<viewModel.banners.count, id: \.self) { index in

                    BannerMediaView(
                        urlString: viewModel.banners[index].image ?? "",
                        shouldPlay: currentBanner == index,
                        action: {

                            if let url = URL(string: (viewModel.banners[index].url ?? "").getValidUrl()) {
                                safariURL = url
                            }

                            updateApi(index: index)
                        },
                        onVideoFinished: {
                            print("Video finished")
                            moveToNextBanner()
                        }
                    )
                    
                    .frame(maxWidth:.infinity,minHeight:200, maxHeight: 200)
                    .tag(index)
                }
            }
            .frame(height: 200)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .cornerRadius(10)
            HStack(spacing: 6) {
                
                ForEach(0..<viewModel.banners.count, id: \.self) { index in
                    
                    Circle()
                        .fill(
                            currentBanner == index
                            ? Color.orange
                            : Color.gray.opacity(0.3)
                        )
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(.horizontal)
        
        .onAppear {

            startImageTimer()
        }
        .onChange(of: currentBanner) { _ in

            startImageTimer()
        }
    }
    
    func updateApi(index:Int){
        if (viewModel.banners[index].is_campaign ?? false){
            viewModel.campaignClickEventApi(campaignBannerId: viewModel.banners[index].campaign_id ?? 0)
        }else{
            //For apps own banner
            viewModel.captureSliderClickApi(campaignBannerId: viewModel.banners[index].campaign_id ?? 0)
        }
    }
}

#Preview {
    BoardSearchView(tabBarController: nil)
}






