//
//  PublicBoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/01/26.
//

import SwiftUI
import Kingfisher
import UIKit

struct PublicBoardView: View {

    @State private var selectedCategoryId: Int = 0
    @State private var selectedName: String = ""
    let tabBarController: UITabBarController?
    @StateObject private var categoryVM = CategoryViewModel(type: 2,isToShowLoader: false)
    @StateObject private var boardStore = BoardStore()   //  STORE
    @State private var loadedCategoryIds: Set<Int> = []
    @State private var openSafari: Bool = false
    @State private var outboundUrlClicked: String = ""

    var body: some View {
        VStack(spacing: 0) {
            
            headerView.background(Color(.systemBackground))
            
            
            CategoryTabsNew(
                selected: $selectedName,
                selectedCategoryId: $selectedCategoryId,
                categoryVM: categoryVM
            ).background(Color(.systemBackground))
            
            if selectedCategoryId > 0{
              
                ZStack {
                    
                    let boardNav = tabBarController?.viewControllers?[1] as? UINavigationController
                    ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                        if loadedCategoryIds.contains(cat.id ?? 0) {
                            
                            BoardListView(
                                vm: boardStore.vm(for: cat.id ?? 0),
                                navigationController: boardNav,
                                isActive: selectedCategoryId == cat.id
                            )
                            .opacity(selectedCategoryId == cat.id ? 1 : 0)
                            .allowsHitTesting(selectedCategoryId == cat.id)
                        }
                    }
                }
                //  High priority horizontal swipe gesture
                .simultaneousGesture(
                    DragGesture(minimumDistance: 15)
                        .onEnded { value in
                            let horizontal = value.translation.width
                            let vertical = value.translation.height
                            
                            // Only trigger horizontal swipes
                            guard abs(horizontal) > abs(vertical) else { return }
                            
                            if horizontal < -70 {
                                swipeCategory(left: true)   // next tab
                            } else if horizontal > 70 {
                                swipeCategory(left: false)  // previous tab
                            }
                        }
                )
                
                
               /* let boardNav = tabBarController?.viewControllers?[1] as? UINavigationController
                TabView(selection: $selectedCategoryId) {
                 
                 ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                 BoardListView(
                 vm: boardStore.vm(for: cat.id ?? 0),
                 navigationController: boardNav, isActive: selectedCategoryId == cat.id
                 )
                 .tag(cat.id ?? 0)
                 }
                 }
                 .tabViewStyle(.page(indexDisplayMode: .never))
                 .transaction { tx in
                 tx.animation = nil   //  CRITICAL
                 }
                */
            }
            
            Spacer()
        }

        .onChange(of: selectedCategoryId) { newId in
           
                FeedVideoManager.shared.pauseAll()
                FeedVideoManager.shared.muteAll()
                markTabLoaded(newId)

        }
        .onAppear {
            markTabLoaded(selectedCategoryId)
        }
        .background(Color(.systemGray6))
        
        .onDisappear{
            FeedVideoManager.shared.muteAll()
        }
        
        //  NOTIFICATION OBSERVER HERE
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notification.Name(
                    NotificationKeys.refreshInterestChangeBoardScreen.rawValue
                )
            )
        ) { _ in
            handleInterestRefresh()
        }
    }
    
    private func markTabLoaded(_ id: Int) {
        if !loadedCategoryIds.contains(id) {
            loadedCategoryIds.insert(id)
        }
    }

  
    // MARK: - Notification Handler
        private func handleInterestRefresh() {
            // 1️⃣ Switch tab to ALL
            selectedCategoryId = 55555
            selectedName = "All"

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshMyBoardsScreen.rawValue), object: nil, userInfo: nil)
        }
    
    private func swipeCategory(left: Bool) {
        guard let list = categoryVM.listArray,
              let currentIndex = list.firstIndex(where: { $0.id == selectedCategoryId })
        else { return }

        let newIndex = left
            ? min(currentIndex + 1, list.count - 1)
            : max(currentIndex - 1, 0)

        let newCat = list[newIndex]

        withAnimation(.none) {
            selectedCategoryId = newCat.id ?? 0
            selectedName = newCat.name ?? ""
        }
    }
}


final class BoardStore: ObservableObject {
    
    @Published private(set) var boardVMs: [Int: BoardViewModelNew] = [:]
    @MainActor
    func vm(for categoryId: Int) -> BoardViewModelNew {
        if let vm = boardVMs[categoryId] {
            return vm
        }

        let vm = BoardViewModelNew(categoryId: categoryId)

        DispatchQueue.main.async {
            self.boardVMs[categoryId] = vm
        }

        return vm
    }

}

struct CategoryTabsNew: View {

    @Binding var selected: String
    @Binding var selectedCategoryId: Int
    @ObservedObject var categoryVM: CategoryViewModel
    @State private var didSetupDefault = false
    @Environment(\.scrollToTopProxy) private var scrollToTopProxy
    @State private var categoryScrollProxy: ScrollViewProxy?   // CORRECT PROXY
    
    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {

                    HStack(spacing: 20) {
                        ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                            categoryTab(cat)
                                .id(cat.id)
                                .onTapGesture {
                                    selectCategory(cat, proxy: proxy)
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top)
                }
                .onAppear {
                    categoryScrollProxy = proxy   //  SAVE HORIZONTAL PROXY
                }
            }

            Divider()
        }
        .onChange(of: categoryVM.listArray?.count) { _ in
            setupDefaultAll()
        }
        //  THIS FIXES SWIPE → MID SCROLL
        .onChange(of: selectedCategoryId) { newId in
                scrollCategoryToCenter(newId)
        }
    }

    // MARK: - Actions

    private func selectCategory(_ cat: CategoryModel, proxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            selectedCategoryId = cat.id ?? 0
            selected = cat.name ?? ""

            proxy.scrollTo(cat.id, anchor: .center)          // horizontal
            scrollToTopProxy?.scrollTo("TOP", anchor: .top)  // vertical
        }
    }

    private func scrollCategoryToCenter(_ id: Int) {
        guard let proxy = categoryScrollProxy else { return }

        withAnimation(.easeInOut) {
            proxy.scrollTo(id, anchor: .center)
        }
    }

    // MARK: - UI

    private func categoryTab(_ cat: CategoryModel) -> some View {
        let isSelected = selectedCategoryId == cat.id

        return VStack(spacing: 6) {
            Text(cat.name ?? "")
                .font(.system(size: 15, weight: .medium))

            Rectangle()
                .fill(isSelected ? Color.orange : .clear)
                .frame(height: 3)
        }
        .contentShape(Rectangle())
    }

    // MARK: - Default "All"

    private func setupDefaultAll() {
        guard !didSetupDefault,
              var list = categoryVM.listArray,
              !list.isEmpty else { return }

        didSetupDefault = true

        if list.first?.id != 55555 {
            list.insert(
                CategoryModel(
                    id: 55555,
                    sequence: nil,
                    name: "All",
                    image: "",
                    parentCategoryID: nil,
                    description: nil,
                    status: nil,
                    createdAt: nil,
                    updatedAt: nil,
                    slug: nil,
                    subcategoriesCount: nil,
                    allItemsCount: nil,
                    translatedName: nil,
                    translations: nil,
                    subcategories: []
                ),
                at: 0
            )
        }

        categoryVM.listArray = list
        selectedCategoryId = 55555
        selected = "All"
    }
}


struct BoardListView: View {

    @ObservedObject var vm: BoardViewModelNew
    let navigationController: UINavigationController?
    @State private var userDidScroll = false  //  User intent + safety locks
    @State private var paginationConsumed = false
    @State private var itemHeights: [Int: CGFloat] = [:] //  Measured heights for staggered layout
    @State private var lastItemCount: Int = 0
    @State private var scrollTick: Int = 0
    @State private var lastScrollTick: Int = 0
    private let prefetchOffset = 4   //  call API before 4 items
    @State private var paymentGateway: PaymentGatewayCentralized?
    @State private var videoFrames: [Int: CGRect] = [:]
    @State private var visibilityWorkItem: DispatchWorkItem?
    let isActive: Bool   //  ADD THIS
    @State private var safariURL: URL?

    var body: some View {

        ScrollViewReader { proxy in
            ScrollView {
                Color.clear
                    .frame(height: 0)
                    .id("TOP")

                    .overlay(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { _ in
                                    scrollTick += 1
                                }
                        }
                    )

                
                if vm.items.isEmpty && !vm.isLoading && vm.hasLoadedOnce{
                   emptyView.padding(.top, 100)

                } else {

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
                                                }
                                                .onChange(of: geo.frame(in: .global)) { frame in
                                                    videoFrames[item.id ?? 0] = frame
                                                    scheduleVisibilityUpdate()
                                                }
                                        }
                                    ) .measureHeight(id: item.id ?? 0)
                                        .onAppear {
                                            handlePrefetch(itemIndex: globalIndex(of: item))
                                            prefetchNextVideos(from: item)
                                        }.onDisappear{
                                            videoFrames.removeValue(forKey: item.id ?? 0)
                                            FeedVideoManager.shared.pause(id: item.id ?? 0)
                                        }
                                    
                                } else {
                                    CardItemView(
                                        item: item,
                                        onLike: { isLiked, boardId in
                                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                                        },
                                        onTap: { pushToDetail(item: item) },
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
                                        handlePrefetch(itemIndex: globalIndex(of: item))
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
                                        //Tapped vide
                                            if let url = URL(string:(item.outbondUrl ?? "").getValidUrl()) {
                                                safariURL = url
                                                FeedVideoManager.shared.muteAll()
                                            }
                                        }
                                    )
                                        .background(
                                            GeometryReader { geo in
                                                Color.clear
                                                    .onAppear {
                                                        videoFrames[item.id ?? 0] = geo.frame(in: .global)
                                                        scheduleVisibilityUpdate()
                                                     
                                                    }
                                                    .onChange(of: geo.frame(in: .global)) { frame in
                                                        videoFrames[item.id ?? 0] = frame
                                                        scheduleVisibilityUpdate()
                                                    }
                                            }
                                        )
                                        .measureHeight(id: item.id ?? 0)
                                        .onAppear {
                                            handlePrefetch(itemIndex: globalIndex(of: item))
                                            prefetchNextVideos(from: item)

                                        }.onDisappear{
                                            videoFrames.removeValue(forKey: item.id ?? 0)
                                            FeedVideoManager.shared.pause(id: item.id ?? 0)
                                        }
                                } else {
                                CardItemView(
                                    item: item,
                                    onLike: { isLiked, boardId in
                                        vm.updateLike(boardId: boardId, isLiked: isLiked)
                                    },
                                    onTap: { pushToDetail(item: item) },
                                    onTapBoostButton:{
                                        
                                        if item.boardType == 1{
                                            //Tapped on prmotional button
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
                                    handlePrefetch(itemIndex: globalIndex(of: item))
                                }
                            }
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }

                if vm.isLoading {
                    ProgressView().padding(.vertical, 12)
                }
            }.ignoresSafeArea(.container, edges: [.bottom,.top])

                .onDisappear {
                    FeedVideoManager.shared.pauseAll()

                }
              
            //  Detect REAL user scroll
                .simultaneousGesture(
                    DragGesture()
                        .onEnded { _ in
                            
                            userDidScroll = true
                            paginationConsumed = false
                            
                            scheduleVisibilityUpdate()
                        }
                )
                
            .onChange(of: vm.items.count) { _ in
                paginationConsumed = false
        
            }
            

            .refreshable {
                await vm.refresh()
                userDidScroll = false
                paginationConsumed = false
                itemHeights.removeAll()
                
                // ADD
                lastItemCount = 0
                lastScrollTick = scrollTick
                
                FeedVideoManager.shared.reset()
                videoFrames.removeAll()
            }

            .task {
                if vm.items.isEmpty {
                    vm.loadIfNeeded()
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
                    for: Notification.Name(NotificationKeys.scrollBoardToTop)
                )
            ) { _ in
                withAnimation(.easeInOut) {
                    proxy.scrollTo("TOP", anchor: .top)
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
            
            .onChange(of: isActive) { active in
                if !active {
                    FeedVideoManager.shared.pauseAll()

                }
            }
            
            //  Capture measured heights
            .onPreferenceChange(ItemHeightKey.self) { value in
                itemHeights.merge(value) { $1 }
            }
            
            .onReceive(
                NotificationCenter.default.publisher(
                    for: NSNotification.Name(NotificationKeys.refreshMyBoardsScreen.rawValue)
                )
            ) { _ in
                Task {
                    await vm.refresh()
                    userDidScroll = false
                    paginationConsumed = false
                    itemHeights.removeAll()
                    
                    // ADD
                      lastItemCount = 0
                      lastScrollTick = scrollTick
                    
                    FeedVideoManager.shared.reset()
                    videoFrames.removeAll()
                }
            }
            
            .fullScreenCover(item: $safariURL) { url in
                SafariView(url: url)
            }

        }
    }
    
    
 
    // MARK: - Prefetch Next Videos
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
        
        guard isActive else {
            FeedVideoManager.shared.pauseAll()
            return
        }

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

    // MARK: -  Prefetch Logic (FINAL & SAFE)
    private func handlePrefetch(itemIndex: Int?) {

        guard let index = itemIndex else { return }

        let triggerIndex = max(vm.items.count - prefetchOffset, 0)

        // 1️⃣ Near bottom
        guard index >= triggerIndex else { return }

        // 2️⃣ Real scroll happened (works on all devices)
        guard scrollTick > lastScrollTick else { return }

        // 3️⃣ Prevent re-trigger for same data set
        guard vm.items.count > lastItemCount else { return }

        // 4️⃣ Safety guards
        guard !vm.isLoading else { return }
        guard !vm.isLastPage else { return }

        paginationConsumed = true
        userDidScroll = false

        lastItemCount = vm.items.count
        lastScrollTick = scrollTick

        vm.tryLoadNextPage()
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

    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image("no_data_found_illustrator")
            Text("No Data Found")
                .foregroundColor(.orange)
        }
    }

    // MARK: - Navigation
    private func pushToDetail(item: ItemModel) {
        let vc = UIHostingController(
            rootView: BoardDetailView(
                navigationController: navigationController,
                itemObj: item
            )
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}


struct CardItemView: View {
    let item: ItemModel
    let onLike: (Bool, Int) -> Void
    let onTap: () -> Void
    let onTapBoostButton: () -> Void
    var isToShowBoostButton = true

    var body: some View {
        
        if item.boardType == 1{
            //Image ads view
            PromotionalAdsCardStaggered(product: item, onTapBottomtButton: onTapBoostButton)
        }else if item.boardType == 3{
            //Idea View
            IdeaCardStaggered(product: item).onTapGesture(perform: onTap)
        }else{
            ProductCardStaggered(product: item, sendLikeUnlikeObject: onLike, onTapBoostButton: onTapBoostButton,isToShowBoostButton:isToShowBoostButton)
                .onTapGesture(perform: onTap)
        }
    }
}

extension View {
    func measureHeight(id: Int) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: ItemHeightKey.self,
                    value: [id: geo.size.height]
                )
            }
        )
    }
}

struct ItemHeightKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}



extension PublicBoardView{
    
    var headerView: some View {
        HStack {
    
            searchBar
            
            interestButton
        }
        .padding(.horizontal, 10)
        
        .background(Color(.systemBackground))
    }
    
    var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.orange)
            Text("Search any item...")
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .onTapGesture {
            pushSearchBoard()
        }
    }
    
    func pushSearchBoard() {
       guard let tabBar = tabBarController,
             let boardNav = tabBar.viewControllers?[1] as? UINavigationController else { return }
       
       let vc = UIHostingController(
           rootView: SearchBoardResultView(
               navigationController: boardNav,
               isByDefaultOpenSearch: true
           )
       )
        vc.hidesBottomBarWhenPushed = true
       boardNav.pushViewController(vc, animated: false)
   }
    
    var interestButton: some View {
        Button {
            guard let tabBar = tabBarController,
                  let boardNav = tabBar.viewControllers?[1] as? UINavigationController else { return }
            let vc = UIHostingController(
                rootView: BoardInterestView(navigationController: boardNav)
            )
            vc.hidesBottomBarWhenPushed = true
            boardNav.pushViewController(vc, animated: true)
        } label: {
            Image("magic").renderingMode(.template).foregroundColor(Color(.label)).padding(8)
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("no_data_found_illustrator")
            Text("No Data Found")
                .foregroundColor(.orange)
            Spacer()
        }
    }
}


#Preview {
    PublicBoardView(tabBarController: nil)
}


struct ProductCardStaggered: View {

    @State private var showSafari = false
    let product: ItemModel
    let sendLikeUnlikeObject: (Bool, Int) -> Void
    @State private var imageRatio: CGFloat = 1
    let onTapBoostButton: () -> Void
    var isToShowBoostButton = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            
            ZStack(alignment:.bottomTrailing) {
                
                KFImage(URL(string: product.image ?? ""))
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
                    )
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage(false)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .cornerRadius(10)
                    .shadow(
                        color: Color.black.opacity(0.10),
                        radius: 7,
                        x: 0,
                        y: 2
                    )
                
                if (product.user?.id ?? 0) != Local.shared.getUserId(){
                    
                    Button {
                        showSafari = true
                        outboundClickApi(strURl: product.outbondUrl ?? "", boardId: product.id ?? 0)
                    } label: {
                        HStack(spacing:2){
                            
                            Text(product.ctaLabel ?? "Buy Now")
                                .font(.inter(.medium, size: 11))
                                .foregroundColor(.white)
                            Image("upRight")
                        }
                    }.padding(.vertical, 3)
                        .padding(.horizontal, 8)
                        .background(Color.orange)
                        .cornerRadius(5)
                        .padding(5)
                }
            }
            
            HStack(spacing:2) {
                if (product.user?.id ?? 0) == Local.shared.getUserId(){
                    Spacer()
                    
                }else{
                    Button {
                        manageLike(boardId: product.id ?? 0)
                    } label: {
                        Image(product.isLiked == true ? "like_fill" : "like")
                            .frame(width: 24, height: 24)
                        
                    }
                    if (product.totalLikes ?? 0) > 0{
                        Text("\(product.totalLikes ?? 0)").foregroundColor(Color(.gray))
                            .font(Font.inter(.regular, size: 12))
                    }
                    Spacer()
                }
                
                if (product.isFeature ?? false) {
                    Text("Sponsored")
                        .font(.inter(.medium, size: 11))
                        .foregroundColor(Color(.gray))
                }
            } .padding(.horizontal,4)
            
            
            VStack(alignment: .leading,spacing: 0){
                
                Text(product.name ?? "").foregroundColor(Color(.label))
                    .font(.inter(.semiBold, size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(product.description ?? "")
                    .font(.inter(.regular, size: 12)).lineLimit(2)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                
            }.padding(.horizontal,8)
            
            
            PriceView(
                price: product.price ?? 0.0,
                specialPrice: product.specialPrice ?? 0.0,
                currencySymbol: Local.shared.currencySymbol
            ).padding([.bottom],8).padding(.horizontal,8).padding(.top,2)
            
            
            if (product.user?.id ?? 0) == Local.shared.getUserId() && isToShowBoostButton{
                
                if product.isFeature == false {
                    Button {
                        // Boost action
                        onTapBoostButton()
                        
                    } label: {
                        Text("Boost \(Local.shared.currencySymbol)\(Int(product.package?.finalPrice ?? 0))")
                            .font(.inter(.semiBold, size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.65, blue: 0.15), // light orange
                                        Color(red: 0.95, green: 0.45, blue: 0.05) // dark orange
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(5)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }
                
                
            }
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .clipShape(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
        ).contentShape(Rectangle())
        
        
        .fullScreenCover(isPresented: $showSafari) {
                
            if let url = URL(string:(product.outbondUrl ?? "").getValidUrl())  {
                    
                SafariView(url:url)
            }
        }
    }

    
    private func manageLike(boardId: Int) {
        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            
            let newState = !(product.isLiked ?? false)
            sendLikeUnlikeObject(newState, boardId)
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
    }
}


struct IdeaCardStaggered: View {

    let product: ItemModel
    @State private var imageRatio: CGFloat = 1

    var body: some View {
            
            ZStack(alignment:.bottomTrailing) {

                    KFImage(URL(string: product.image ?? ""))
                      .setProcessor(
                            DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
                        )
                        .scaleFactor(UIScreen.main.scale)
                        .cacheOriginalImage(false)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .cornerRadius(10)
                            .shadow(
                                color: Color.black.opacity(0.10),
                                radius: 7,
                                x: 0,
                                y: 2
                            )
                
                if (product.isFeature ?? false){
                    Text("Sponsored")
                        .foregroundColor(.white)
                        .font(.inter(.bold, size: 14)).padding([.bottom,.trailing],8)
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
                }
            }
         
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .clipShape(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
        ).contentShape(Rectangle())
        
      }
}


struct PromotionalAdsCardStaggered: View {
    
    let product: ItemModel
    @State private var imageRatio: CGFloat = 1
    let onTapBottomtButton: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack(alignment:.topTrailing) {
                
                KFImage(URL(string: product.image ?? ""))
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
                    )
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage(false)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                //.cornerRadius(10)
                    .shadow(
                        color: Color.black.opacity(0.10),
                        radius: 7,
                        x: 0,
                        y: 2
                    )
            }
            
            // CTA (Attached like screenshot)
            
            HStack {
                Text(product.ctaLabel ?? "Learn more")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 10)
            .frame(height: 35)
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .onTapGesture {
                onTapBottomtButton()
                outboundClickApi()
            }
            
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .clipShape(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
        ).contentShape(Rectangle())
        
    }
    
   
    func outboundClickApi(){
        
        let params = ["board_id":product.id ?? 0]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.board_outbond_click, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                }else{
                }
            }
        }
    }
}

