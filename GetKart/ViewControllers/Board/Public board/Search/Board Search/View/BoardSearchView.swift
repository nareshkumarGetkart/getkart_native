//
//  BoardSearchView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/05/26.
//

import SwiftUI
import Alamofire
import Kingfisher


struct BoardSearchView: View {
   
    @StateObject private var viewModel = HomeSerchViewModal()
   
    let tabBarController: UITabBarController?
   
    private var navigationController: UINavigationController? {
        return tabBarController?.viewControllers?[1].navigationController
    }
    @State private var safariURL: URL?

    @State private var currentBanner = 0

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

                                    if item.boardType == 3{
                                        //Idea View
                                        IdeaCardSearch(product: item,
                                                          defaultImgWidth: 170,
                                                          defaultImgHeight: 190).frame(width:170,height: 260)
                                            .onTapGesture{
                                                pushToDetailScreen(item: item)

                                        }
                                    }else{
                                        //Normal board
                                        BoardCardView(product: item,
                                                      defaultImgWidth: 170,
                                                      defaultImgHeight: 190).frame(width:170,height: 260)
                                        .onTapGesture {
                                            pushToDetailScreen(item: item)
                                        }
                                    }
                                }
                            }.padding(.vertical,8)
                            .padding(.horizontal, 16)
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
                                                          defaultImgWidth: 170,
                                                          defaultImgHeight: 190).frame(width:170,height: 260)
                                            .onTapGesture{
                                                pushToDetailScreen(item: item)

                                        }
                                    }else{
                                        //Normal board
                                        BoardCardView(product: item,
                                                      defaultImgWidth: 170,
                                                      defaultImgHeight: 190).frame(width:170,height: 260)
                                        .onTapGesture {
                                            pushToDetailScreen(item: item)
                                        }
                                    }
                                }
                            }.padding(.vertical,8)
                            .padding(.horizontal, 16)
                            //.padding(.bottom, 4)
                        }
                    }//.padding(.bottom, 30)
                }
                
                if !viewModel.popular.isEmpty{
                    //MARK: My view
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

                                    if item.boardType == 3{
                                        //Idea View
                                        IdeaCardSearch(product: item,
                                                          defaultImgWidth: 170,
                                                          defaultImgHeight: 190).frame(width:170,height: 260)
                                            .onTapGesture{
                                                pushToDetailScreen(item: item)

                                        }
                                    }else{
                                        //Normal board
                                        BoardCardView(product: item,
                                                      defaultImgWidth: 170,
                                                      defaultImgHeight: 190).frame(width:170,height: 260)
                                        .onTapGesture {
                                            pushToDetailScreen(item: item)
                                        }
                                    }
                                }
                            }.padding(.vertical,8)
                            .padding(.horizontal, 16)
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
                viewModel.fetchBanners()
                viewModel.fetchFeaturedBoard()
                viewModel.fetchIdeas()
            }
        }.fullScreenCover(item: $safariURL) { url in SafariView(url: url) }
    }
    
    
  
    
    func pushToMyViewsScreen(type:SeeAllType){

        let hostingVC = UIHostingController(rootView: MyViews(navigationController:navigationController, seeallType: type))
        navigationController?.pushViewController(hostingVC, animated: true)
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
    
}



extension BoardSearchView {

    var bannerSection: some View {

        VStack(spacing: 10) {

            TabView(selection: $currentBanner) {

                ForEach(0..<viewModel.banners.count, id: \.self) { index in

                    BannerMediaView(urlString: viewModel.banners[index].image ?? "", shouldPlay: currentBanner == index,
                                    action: {
                       
                        
                        
                        if let url = URL(string: (viewModel.banners[index].url ?? "").getValidUrl()) {
                            safariURL = url
                        }
                        self.updateApi(index: index)
                        
                    })
                    
                    .frame(maxWidth:.infinity,minHeight:190, maxHeight: 190)
                    .tag(index)
                }
            }
            .frame(height: 190)
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


/*

import SwiftUI
import AVKit

struct BannerMediaView: View {

    let urlString: String

    @State private var player: AVPlayer?
    let action: (() -> Void)?

    var isVideo: Bool {
        let lower = urlString.lowercased()
        return lower.contains(".mp4") ||
               lower.contains(".mov") ||
               lower.contains(".m4v") ||
               lower.contains(".avi")
    }

    var body: some View {

        ZStack {

            if isVideo {

                if let player {
                    VideoPlayer(player: player)
                       
                        .onAppear {
                            player.play()
                            player.isMuted = false
                        }
                        .onDisappear {
                            player.pause()
                        }
                } else {
                    Image("getkartplaceholder")
                        .resizable()
                        .scaledToFill()
                }

            } else {

                AsyncImage(url: URL(string: urlString)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image("getkartplaceholder")
                        .resizable()
                        .scaledToFill()
                }
            }
        }.contentShape(Rectangle())
            .onTapGesture {
                action?()
            }
        .onAppear {
            if isVideo,
               player == nil,
               let url = URL(string: urlString) {
                player = AVPlayer(url: url)
            }
        }
        
    }
}
*/

import SwiftUI
import AVFoundation

struct BannerMediaView: View {

    let urlString: String
    let shouldPlay: Bool
    let action: (() -> Void)?
    @State private var isMuted = false
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var isVideo: Bool {

        let lower = urlString.lowercased()

        return lower.contains(".mp4")
        || lower.contains(".mov")
        || lower.contains(".m4v")
        || lower.contains(".avi")
    }

    var body: some View {

        ZStack {

            if isVideo {

                if let player {

                    VideoBannerPlayer(player: player)

                } else {

                    Image("getkartplaceholder")
                        .resizable()
                        .scaledToFill()
                }

            } else {

                AsyncImage(
                    url: URL(string: urlString)
                ) { image in

                    image
                        .resizable()
                        .scaledToFill()

                } placeholder: {

                    Image("getkartplaceholder")
                        .resizable()
                        .scaledToFill()
                }
            }
        }.overlay(alignment: .topTrailing) {
            if isVideo{
                Button {
                    
                    isMuted.toggle()
                    player?.isMuted = isMuted
                    
                } label: {
                    
                    Image(systemName:
                            isMuted
                          ? "speaker.slash.fill"
                          : "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(.black.opacity(0.6))
                    .clipShape(Circle())
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
            }
        }
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {

            player?.pause()
            action?()
        }
        .onAppear {

            createPlayerIfNeeded()

            if shouldPlay {
                player?.play()
            }
        }
        .onDisappear {

            player?.pause()
        }
        .onChange(of: shouldPlay) { play in

            if play {

                player?.play()

            } else {

                player?.pause()
            }
        }
    }

    private func createPlayerIfNeeded() {

        guard isVideo else { return }

        guard player == nil else { return }

        guard let url = URL(string: urlString) else { return }

        let item = AVPlayerItem(url: url)

        let queuePlayer = AVQueuePlayer()

        queuePlayer.isMuted = false

        let looper = AVPlayerLooper(
            player: queuePlayer,
            templateItem: item
        )

        self.player = queuePlayer
        self.looper = looper
    }
}
import SwiftUI
import AVFoundation

struct VideoBannerPlayer: UIViewRepresentable {

    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {

        let view = UIView()

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds

        view.layer.addSublayer(playerLayer)

        context.coordinator.playerLayer = playerLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}
