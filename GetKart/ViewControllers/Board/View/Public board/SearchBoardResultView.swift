//
//  SearchBoardResultView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.
//

import SwiftUI

struct SearchBoardResultView: View {
    let navigationController:UINavigationController?
    @State  var isByDefaultOpenSearch:Bool
    @State private var searchText = ""
    @State private var selected = "All"
    @StateObject private var vm = SearchBoardResultViewModel()
    @State private var paymentGateway: PaymentGatewayCentralized?
   
    @State private var videoFrames: [Int: CGRect] = [:]
    @State private var openSafari: Bool = false
    @State private var outboundUrlClicked: String = ""
    
   // @ObservedObject private var manager = FeedVideoManager.shared
    @State private var visibilityWorkItem: DispatchWorkItem?
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            
            VStack{
                // MARK: - Top Row (Time, Icons)
                HStack {
                    
                    Button {
                        navigationController?.popViewController(animated: true)
                        
                    } label: {
                        Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    }.frame(width: 40,height: 40)
                    
                    // MARK: - Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.orange)
                        
                        TextField("Search any item...", text: .constant(searchText))
                            .textFieldStyle(PlainTextFieldStyle()).disabled(true)
                        
                    }   .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color(UIColor.systemBackground)).cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .onTapGesture {
                            
                            let hostingVC = UIHostingController(rootView: SearchBoardView(searchText:searchText, navigationController: self.navigationController, searchedItem: { srchTxt in
                                
                                if searchText != srchTxt{
                                    searchText = srchTxt
                                    vm.searchText = searchText
                                    vm.loadInitial()
                                }
                            }))
                            self.navigationController?.pushViewController(hostingVC, animated: false)
                            
                        }
                    
                    Button {
                        print("Scan tapped")
                        navigationController?.popViewController(animated: true)
                        
                    } label: {
                        Text("Cancel")
                            .font(.title3)
                            .foregroundColor(Color(.label))
                    }
                }
                .padding(.horizontal)
                
                
                CategoryTabs(
                    selected: $selected,
                    selectedCategoryId: Binding(
                        get: { vm.selectedCategoryId },
                        set: { vm.categoryChanged($0) }
                    )
                )
                
            } .background(Color(.systemBackground))
            
            if vm.items.count == 0 && !vm.isLoading {
                HStack{
                    Spacer()
                    VStack(spacing: 20){
                        Spacer()
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding(.top).padding(.horizontal)
                        Text("We're sorry what you were looking for. Please try another way").font(Font.manrope(.regular, size: 16.0)).multilineTextAlignment(.center).padding(.horizontal)
                        Spacer()
                    }
                    Spacer()
                }
            }else{
                
                
                ScrollView {
                    
                    
                    
                    LazyVStack {
                        StaggeredGrid(columns: 2, spacing: 5) {
                        ForEach(Array(vm.items.enumerated()), id: \.offset) { index, item in
                               
                               // ForEach(vm.items, id: \.id) { item in

                                 if item.boardType == 2{
                                   
                                    SmartVideoPlayerView(
                                        item: item,
                                        onTapBottomButton: {
                                        //Tapped video
                                            if (item.outbondUrl ?? "").count > 0{
                                                outboundUrlClicked =  item.outbondUrl ?? ""
                                                openSafari = true
                                            }
                                        }
                                    ).background(
                                            GeometryReader { geo in
                                                Color.clear
                                                    .onAppear {
                                                        videoFrames[item.id ?? 0] = geo.frame(in: .global)
                                                        scheduleVisibilityUpdate()

                                                    }.onDisappear{
                                                        print("dissapearing video \(item.id ?? 0)")
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
                                            vm.loadNextPageIfNeeded(currentIndex: index)
                                        }
                                }else{
                                   
                                  /*  ProductCardStaggered1(
                                        product: item,
                                        sendLikeUnlikeObject: { isLiked, boardId in
                                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                                        }, onTapBoostButton: {
                                            paymentGatewayOpen(product: item)
                                        }
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        pushToDetailScreen(item: item)
                                    }
                                    .onAppear {
                                        vm.loadNextPageIfNeeded(currentIndex: index)
                                    }*/
                                    
                                    CardItemView(
                                        item: item,
                                        onLike: { isLiked, boardId in
                                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                                        },
                                        onTap: { pushToDetailScreen(item: item) },
                                        onTapBoostButton:{
                                            if item.boardType == 1{
                                                //Clicking on bottom prmotional
                                                if (item.outbondUrl ?? "").count > 0{

                                                    outboundUrlClicked =  item.outbondUrl ?? ""
                                                    openSafari = true
                                                }
                                            }else{
                                                paymentGatewayOpen(product: item)
                                            }
                                            
                                        },
                                        isToShowBoostButton:true
                                    )
                                    .measureHeight(id: item.id ?? 0)
                                    .onAppear {
                                        vm.loadNextPageIfNeeded(currentIndex: index)
                                    }
                                }
                            }
                        }
                        .padding(5)
                        
                        //  bottom detector (NO layout impact)
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
                }
                .onPreferenceChange(ScrollBottomKey.self) { bottomY in
                    vm.handleScrollBottom(bottomY: bottomY)
                }
                //  Detect REAL user scroll
                    .simultaneousGesture(
                            DragGesture()
                                .onEnded { _ in
                                    
//                                    userDidScroll = true
//                                    paginationConsumed = false
                                    
                                    scheduleVisibilityUpdate()
                                }
                        )
                    
            }
        }
        .background(Color(.systemGray6))
        .onDisappear{
            
             FeedVideoManager.shared.reset()
             videoFrames.removeAll()
            
        }
        .onAppear{
            if isByDefaultOpenSearch{
                let hostingVC = UIHostingController(rootView: SearchBoardView(navigationController: self.navigationController, isToCloseToSearchResultScreen:isByDefaultOpenSearch,searchedItem: { srchTxt in
                    if searchText != srchTxt{
                        searchText = srchTxt
                        vm.searchText = searchText
                        if !vm.isLoading{
                            vm.loadInitial()
                        }
                    }
                }))
                self.navigationController?.pushViewController(hostingVC, animated: true)
                isByDefaultOpenSearch = false
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
                for: Notification.Name(NotificationKeys.boardBoostedRefresh.rawValue)
            )
        ) { notification in
           guard let dict = notification.object as? [String: Any] else { return }
            let boardId = dict["boardId"] as? Int ?? 0
            
            vm.updateBoost(isBoosted: true, boardId: boardId)
        }

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

            if percent >= 0.3 {
                visibleSet.insert(id)
            }
        }

        FeedVideoManager.shared.updatePlayback(visibleIDs: visibleSet)
    }
    
    func paymentGatewayOpen(product:ItemModel) {

        paymentGateway = PaymentGatewayCentralized()
        paymentGateway?.selectedPlanId = product.package?.id ?? 0
        paymentGateway?.categoryId = product.categoryID ?? 0
        paymentGateway?.itemId = product.id ?? 0
        paymentGateway?.paymentFor = .boostBoard
        paymentGateway?.selIOSProductID = product.package?.iosProductID ?? ""

        paymentGateway?.callbackPaymentSuccess = { (isSuccess) in

            if isSuccess {
                let vc = UIHostingController(
                    rootView: PlanBoughtSuccessView(
                        navigationController: navigationController
                    )
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                navigationController?.present(vc, animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue), object:  ["boardId":product.id ?? 0], userInfo: nil)

            }
      
               self.paymentGateway = nil
        }

        paymentGateway?.initializeDefaults()
    }
    func pushToDetailScreen(item:ItemModel){
        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: item))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
}

#Preview {
    SearchBoardResultView(navigationController: nil, isByDefaultOpenSearch: false)
}
