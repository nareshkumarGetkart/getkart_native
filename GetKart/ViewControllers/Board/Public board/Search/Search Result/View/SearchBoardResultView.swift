//
//  SearchBoardResultView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.
//

import SwiftUI

struct SearchBoardResultView: View {
    
    let navigationController: UINavigationController?

       @State var isByDefaultOpenSearch: Bool
       @State var searchText: String
       @State private var selected: String

       @StateObject private var vm = SearchBoardResultViewModel()

       @State private var paymentGateway: PaymentGatewayCentralized?
       @State private var videoFrames: [Int: CGRect] = [:]
       @State private var safariURL: URL?
       @State private var visibilityWorkItem: DispatchWorkItem?
       @State private var didLoad = false
        @State private var scrollToTopTrigger = false
        @State private var newFieldArray:[CustomField]?


    
       init(
           navigationController: UINavigationController?,
           searchText: String = "",
           isByDefaultOpenSearch: Bool = false
       ) {
           self.navigationController = navigationController
           _searchText = State(initialValue: searchText)
           _isByDefaultOpenSearch = State(initialValue: isByDefaultOpenSearch)
           _selected = State(initialValue: "All")
       }

    
    var body: some View {
        
        VStack(spacing: 0) {
            
            //VStack{
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
                        .background(Color(UIColor.systemGroupedBackground)).cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 0.1)
                        )
                       // .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .onTapGesture {
                            
                            let hostingVC = UIHostingController(rootView: SearchBoardView(searchText:searchText, navigationController: self.navigationController, searchedItem: { srchTxt in
                                
                                if searchText != srchTxt{
                                    searchText = srchTxt
                                    vm.searchText = searchText
                                    scrollToTopTrigger.toggle()
                                    vm.loadInitial()
                                }
                            }))
                            self.navigationController?.pushViewController(hostingVC, animated: false)
                        }
                    
                    Button {
                        print("filter tapped")
                       /* navigationController?.popViewController(animated: true)*/
                        self.pushToFilterScreen(selIndex: 0)
                        
                    } label: {
                        Image("filter").resizable().renderingMode(.template).aspectRatio(contentMode: .fit).frame(width: 25,height: 25)
                            .foregroundColor(Color(.label))
                       /* Text("Cancel")
                            .foregroundColor(Color(.label))*/
                    }.frame(width: 40,height: 40)
                }.padding(.bottom,8)
                .padding(.horizontal,5)
                .background(Color(.systemBackground))
                .onAppear {
                    guard !didLoad else { return }
                    didLoad = true
                    
                    if searchText.count > 0 {
                        vm.searchText = searchText
                        vm.loadInitial()
                    }
                }
                
               /* CategoryTabs(
                    selected: $selected,
                    selectedCategoryId: Binding(
                        get: { vm.selectedCategoryId },
                        set: { vm.categoryChanged($0) }
                    )
                )*/
                
          //  } .background(Color(.systemBackground))
                
            
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
            ScrollViewReader { proxy in

                ScrollView {
                    
                    Color.clear
                        .frame(height: 0.1)
                               .id("TOP")
                    
                    LazyVStack {
                        StaggeredGrid(columns: 2, spacing: 5) {
                            ForEach(Array(vm.items.enumerated()), id: \.offset) { index, item in
                                
                                // ForEach(vm.items, id: \.id) { item in
                                
                                if item.boardType == 2{
                                    
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
                                        vm.loadNextPageIfNeeded(currentIndex: index)
                                        prefetchNextVideos(from: item)
                                        
                                    }
                                }else{
                                    
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
                .onChange(of: vm.selectedCategoryId) { _ in
                        DispatchQueue.main.async {
                            proxy.scrollTo("TOP", anchor: .top)
                        }
                    }
                .onChange(of: scrollToTopTrigger) { _ in
                        DispatchQueue.main.async {
                            proxy.scrollTo("TOP", anchor: .top)
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
                        scrollToTopTrigger.toggle()
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
        
        .fullScreenCover(item: $safariURL) { url in
            SafariView(url: url)
        }

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
    
    
    
    func pushToFilterScreen(selIndex:Int){
        
        let filterView = FilterView(navigation:self.navigationController,categoryId: "0",categImg: "",categoryName: "",filterDict: vm.dictCustomFields,fieldArray: newFieldArray,onApplyFilter: { filterDict, filterFieldsArr in
            scrollToTopTrigger.toggle()
            newFieldArray = filterFieldsArr
            vm.dictCustomFields = filterDict
           // self.objVM.getSearchItemApi(srchTxt: srchTxt)
            vm.loadInitial()
            
            print(filterDict)
            print(filterFieldsArr)

            
        }, selectedIndex:selIndex)
        
        let hostingVC = UIHostingController(rootView: BottomSheetHost(content: filterView))

        
        if let sheet = hostingVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom(resolver: { context in
                    context.maximumDetentValue * 0.70
                })]
            } else {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        self.navigationController?.present(hostingVC, animated: true)
    }
}

//#Preview {
//    SearchBoardResultView(navigationController: nil, isByDefaultOpenSearch: false)
//}
