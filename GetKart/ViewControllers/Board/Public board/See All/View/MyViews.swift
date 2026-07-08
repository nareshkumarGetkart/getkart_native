//
//  MyViews.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 23/04/26.
//

import SwiftUI

struct MyViews: View {
    let navigationController: UINavigationController?
    let seeallType:SeeAllType?

    @StateObject private var vm:MyViewViewModel
    @State private var safariURL: URL?
    @State private var itemHeights: [Int: CGFloat] = [:] //  Measured heights for staggered layout
    @State private var videoFrames: [Int: CGRect] = [:]
    @State private var visibilityWorkItem: DispatchWorkItem?
    
    init(navigationController: UINavigationController?, seeallType: SeeAllType) {
        self.navigationController = navigationController
        self.seeallType = seeallType
        _vm = StateObject(wrappedValue: MyViewViewModel(seeallType: seeallType))
    }
    
    var body: some View {
        HStack{
            
            Button {
                navigationController?.popViewController(animated: true)
            } label: {
                Image("arrow_left")
                    .renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
            }
            .frame(width: 40, height: 40)
           
            if seeallType == .popular{
                Text("Popular on Getkart")
                    .font(Font.inter(.semiBold, size: 16))
                    .foregroundColor(Color(UIColor.label))
            }else if seeallType == .ideasforyou{
                Text("Ideas for you")
                    .font(Font.inter(.semiBold, size: 16))
                    .foregroundColor(Color(UIColor.label))
            }else if seeallType == .featured{
                Text("Featured")
                    .font(Font.inter(.semiBold, size: 16))
                    .foregroundColor(Color(UIColor.label))
            }else{
                Text("My Views")
                    .font(Font.inter(.semiBold, size: 16))
                    .foregroundColor(Color(UIColor.label))
            }
         
            
            Spacer()
        }
        
        VStack{
            
            if vm.items.isEmpty && !vm.isLoading {
                HStack{
                    Spacer()
                    VStack(spacing: 20){
                        Spacer()
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding(.top).padding(.horizontal)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    
                    let columns = splitColumns()
                    
                    HStack(alignment: .top, spacing: 6) {
                        
                        // LEFT COLUMN
                        LazyVStack(spacing: 6) {
                            
                            ForEach(columns.left, id: \.id) { item in
                                
                                if item.boardType == 2 {
                                    
                                    SmartVideoPlayerView(
                                        item: item,
                                        onTapBottomButton: {
                                            //Tapped video
                                            if let url = URL(string:(item.outbondUrl ?? "").getValidUrl()) {
                                                safariURL = url
                                                FeedVideoManager.shared.muteAll()
                                            }
                                        }
                                    ).background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onAppear {
                                                    videoFrames[item.id ?? 0] = geo.frame(in: .global)
                                                    scheduleVisibilityUpdate()
                                                    
                                                }.onDisappear{
                                                    videoFrames.removeValue(forKey: item.id ?? 0)
                                                    FeedVideoManager.shared.pause(id: item.id ?? 0)
                                                }
                                                .onChange(of: geo.frame(in: .global)) { frame in
                                                    videoFrames[item.id ?? 0] = frame
                                                    scheduleVisibilityUpdate()
                                                    
                                                }
                                        }
                                    )
                                    .measureHeight(id: item.id ?? 0)
                                    .onAppear {
                                       
                                        prefetchNextVideos(from: item)
                                        
                                    }
                                } else {
                                    CardItemView(
                                        item: item,
                                        onLike: { isLiked, boardId in
                                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                                        },
                                        onTap: { pushToDetailScreen(item: item) },
                                        onTapBoostButton:{
                                           
                                            if item.boardType == 1{
                                                //Clicking on bottom prmotional
                                                if let url = URL(string:(item.outbondUrl ?? "").getValidUrl()) {
                                                    safariURL = url
                                                    
                                                }
                                            }else{
                                                //paymentGatewayOpen(product: item)
                                            }
                                            
                                        },
                                        isToShowBoostButton:false
                                    )
                                    .measureHeight(id: item.id ?? 0)
                                    .onAppear {
                                        // handlePrefetch(itemIndex: globalIndex(of: item))
                                        
                                        if let index = globalIndex(of: item){
                                            vm.loadNextPageIfNeeded(currentIndex: index)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // RIGHT COLUMN
                        LazyVStack(spacing: 6) {
                            
                            ForEach(columns.right, id: \.id) { item in
                                
                                
                                if item.boardType == 2 {
                                    
                                    SmartVideoPlayerView(
                                        item: item,
                                        onTapBottomButton: {
                                            //Tapped video
                                            if let url = URL(string:(item.outbondUrl ?? "").getValidUrl()) {
                                                safariURL = url
                                                FeedVideoManager.shared.muteAll()
                                            }
                                        }
                                    ).background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onAppear {
                                                    videoFrames[item.id ?? 0] = geo.frame(in: .global)
                                                    scheduleVisibilityUpdate()
                                                    
                                                }.onDisappear{
                                                    videoFrames.removeValue(forKey: item.id ?? 0)
                                                    FeedVideoManager.shared.pause(id: item.id ?? 0)
                                                }
                                                .onChange(of: geo.frame(in: .global)) { frame in
                                                    videoFrames[item.id ?? 0] = frame
                                                    scheduleVisibilityUpdate()
                                                    
                                                }
                                        }
                                    )
                                    .measureHeight(id: item.id ?? 0)
                                    .onAppear {
                                     
                                        prefetchNextVideos(from: item)
                                        
                                    }
                                } else {
                                    CardItemView(
                                        item: item,
                                        onLike: { isLiked, boardId in
                                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                                        },
                                        onTap: { pushToDetailScreen(item: item) },
                                        onTapBoostButton:{
                                            
                                            if item.boardType == 1{
                                                //Tapped on prmotional button
                                                if let url = URL(string:(item.outbondUrl ?? "").getValidUrl()) {
                                                    
                                                    safariURL = url
                                                }
                                            }else{
                                                // paymentGatewayOpen(product: item)
                                            }
                                        },
                                        isToShowBoostButton:false
                                    )
                                    .measureHeight(id: item.id ?? 0)
                                    .onAppear {
                                        
                                        if let index = globalIndex(of: item){
                                            vm.loadNextPageIfNeeded(currentIndex: index)
                                        }
                                        //handlePrefetch(itemIndex: globalIndex(of: item))
                                    }
                                }
                            }
                        }
                    }
                    .padding([.horizontal,.top], 5)
                    
                                    
                    //
                    
                    GeometryReader { geo in
                    Color.clear
                    .preference(
                    key: ScrollBottomKey.self,
                    value: geo.frame(in: .global).maxY
                    )
                    }
                    .frame(height: 0)
                    
                    if vm.isLoading {
                    ProgressView().padding()
                    }
                }
                .onPreferenceChange(ScrollBottomKey.self) { bottomY in
                    vm.handleScrollBottom(bottomY: bottomY)
                }
                
                //  Detect REAL user scroll
                    .simultaneousGesture(
                            DragGesture()
                                .onEnded { _ in
                                    scheduleVisibilityUpdate()
                                }
                        )
            }
        }.background(Color(.systemGray6))
            .onAppear {
                if vm.items.count == 0{
                    vm.loadInitial()
                }
            }
            .refreshable {
                if !vm.isLoading{
                    vm.loadInitial()
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name(NotificationKeys.refreshLikeDislikeBoard.rawValue)
                )
            ) { notification in
                
                guard let dict = notification.object as? [String: Any] else { return }
                
                let isLike  = dict["isLike"] as? Bool ?? false
                let count  = dict["count"] as? Int ?? 0
                let boardId = dict["boardId"] as? Int ?? 0
                
                vm.update(likeCount: count, isLike: isLike, boardId: boardId)
            }
            
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name(NotificationKeys.refreshCommentCountBoard.rawValue)
                )
            ) { notification in
                
                guard let dict = notification.object as? [String: Any] else { return }
                
                let count  = dict["count"] as? Int ?? 0
                let boardId = dict["boardId"] as? Int ?? 0
                if let commentObj = dict["lastComment"] as? CommentModel {
                    vm.updateCommentCount(commentCount: count, commentObj: commentObj, boardId: boardId)
                }else{
                    vm.updateCommentCount(commentCount: count, commentObj: nil, boardId: boardId)
                }
            }
            
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name(NotificationKeys.boardBoostedRefresh.rawValue)
                )
            ) { notification in
                guard let dict = notification.object as? [String: Any] else { return }
                let boardId = dict["boardId"] as? Int ?? 0
                
                vm.updateBoost(isBoosted: true, boardId: boardId)
            }
            .fullScreenCover(item: $safariURL) { url in SafariView(url: url) }
        
    }
    
    func pushToDetailScreen(item:ItemModel){
        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: item))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    // MARK: - Split into 2 staggered columns
    private func splitColumns() -> (left: [ItemModel], right: [ItemModel]) {
        
        var left: [ItemModel] = []
        var right: [ItemModel] = []
        
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0
        
        for item in vm.items {
            let h = itemHeights[item.id ?? 0] ?? 200
            
            if leftHeight <= rightHeight {
                left.append(item)
                leftHeight += h
            } else {
                right.append(item)
                rightHeight += h
            }
        }
        return (left, right)
    }
    
    
    private func globalIndex(of item: ItemModel) -> Int? {
        vm.items.firstIndex { $0.id == item.id }
    }
   
    private func prefetchNextVideos(from currentItem: ItemModel) {

        guard let index = vm.items.firstIndex(where: { $0.id == currentItem.id }) else { return }

        let start = index + 1
        let end = min(index + 2, vm.items.count - 1)

        guard start <= end else { return }

        var urls: [URL] = []

        for i in start...end {

            let item = vm.items[i]

            if item.boardType == 2,
               let link = item.videoLink,
               let url = URL(string: link) {

                urls.append(url)
            }
        }

        VideoPreloadManagerDefault.shared.set(waiting: urls)
    }
    
    
    private func scheduleVisibilityUpdate() {
        
        visibilityWorkItem?.cancel()
        
        let work = DispatchWorkItem {
            calculateVisibleVideos()
        }
        
        visibilityWorkItem = work
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
    }
 
    private func calculateVisibleVideos() {
        
//        guard isActive else {
//            FeedVideoManager.shared.pauseAll()
//            return
//        }

        let screenHeight = UIScreen.main.bounds.height
        var visibleSet: Set<Int> = []

        for (id, frame) in videoFrames {

            if frame.maxY <= 0 || frame.minY >= screenHeight {
                continue
            }

            let visibleHeight =
                min(frame.maxY, screenHeight)
                - max(frame.minY, 0)

            let percent = visibleHeight / frame.height

            if percent >= 0.6 {
                visibleSet.insert(id)
            }
        }

        FeedVideoManager.shared.updatePlayback(visibleIDs: visibleSet)
        
    }
    
}

#Preview {
    MyViews(navigationController: nil, seeallType: .myviews)
}

