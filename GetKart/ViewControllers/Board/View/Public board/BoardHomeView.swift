//
//  BoardHomeView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/04/26.
//

import SwiftUI
import Kingfisher
import AVKit

/*
struct BoardHomeView: View {
    
    @State private var selectedCategoryId: Int = 0
    @State private var selectedName: String = ""
    let tabBarController: UITabBarController?
    @StateObject private var categoryVM = CategoryViewModel(type: 2,isToShowLoader: false)
    @StateObject private var boardStore = BoardStore()
    @State private var loadedCategoryIds: Set<Int> = []
    @State private var openSafari: Bool = false
    @State private var outboundUrlClicked: String = ""

    var body: some View {
        VStack(spacing: 0) {
            headerView.background(Color(.systemBackground))
                .onAppear{
                updateEvents()
            }
            
            CategoryTabsNew(
                selected: $selectedName,
                selectedCategoryId: $selectedCategoryId,
                categoryVM: categoryVM
            ).background(Color(.systemBackground))
            
            if selectedCategoryId > 0{
              
                ZStack {
                    
                    let boardNav = tabBarController?.viewControllers?[0] as? UINavigationController
                    ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                        if loadedCategoryIds.contains(cat.id ?? 0) {
                            
                            BoardListViewNew(
                                tabBarController:tabBarController,
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
            }else{
                Spacer()
            }
            
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
    
    
    func updateEvents(){
        FaceBookAppEvents.facebookEvents(type: .board, categoryName: selectedName)

    }
}



// MARK: - BoardListViewNew

struct BoardListViewNew: View {
    let tabBarController: UITabBarController?
    @ObservedObject var vm: BoardViewModelNew
    let navigationController: UINavigationController?
    let isActive: Bool

    @State private var paymentGateway: PaymentGatewayCentralized?
    @State private var videoFrames: [Int: CGRect] = [:]
    @State private var visibilityWorkItem: DispatchWorkItem?
    @State private var safariURL: URL?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // Invisible scroll-to-top anchor
                Color.clear.frame(height: 0).id("TOP")

                if vm.items.isEmpty && !vm.isLoading && vm.hasLoadedOnce {
                    emptyView.padding(.top, 100)
                } else {
                    PinterestMasonryFeed(
                        items:    vm.items,
                        spacing:  6,
                        itemView: { item in AnyView(itemCellView(item: item)) },
                        onLastItemAppear: {
                            // Pagination: fired when the last visible item appears
                            guard !vm.isLoading, !vm.isLastPage else { return }
                            vm.tryLoadNextPage()
                        }
                    )
                    .padding(.horizontal, 5)
                }

                if vm.isLoading {
                    ProgressView().padding(.vertical, 12)
                }
            }
            .padding(.bottom, tabBarController?.tabBar.frame.height ?? 83)
            .ignoresSafeArea(edges: .bottom)
            .onDisappear { FeedVideoManager.shared.pauseAll() }
            .refreshable {
                await vm.refresh()
                FeedVideoManager.shared.reset()
                videoFrames.removeAll()
            }
            .task {
                if vm.items.isEmpty { vm.loadIfNeeded() }
            }
            .onChange(of: isActive) { active in
                if !active { FeedVideoManager.shared.pauseAll() }
            }
            // ── Notifications ─────────────────────────────────────────────
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.refreshLikeDislikeBoard.rawValue)
            )) { n in
                guard let d = n.object as? [String: Any] else { return }
                vm.update(likeCount: d["count"] as? Int ?? 0,
                          isLike:    d["isLike"] as? Bool ?? false,
                          boardId:   d["boardId"] as? Int ?? 0)
            }
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.refreshCommentCountBoard.rawValue)
            )) { n in
                guard let d = n.object as? [String: Any] else { return }
                vm.updateCommentCount(commentCount: d["count"] as? Int ?? 0,
                                      commentObj:   d["lastComment"] as? CommentModel,
                                      boardId:      d["boardId"] as? Int ?? 0)
            }
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.scrollBoardToTop)
            )) { _ in
                withAnimation(.easeInOut) { proxy.scrollTo("TOP", anchor: .top) }
            }
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.boardBoostedRefresh.rawValue)
            )) { n in
                guard let d = n.object as? [String: Any] else { return }
                vm.updateBoost(isBoosted: true, boardId: d["boardId"] as? Int ?? 0)
            }
            .onReceive(NotificationCenter.default.publisher(
                for: NSNotification.Name(NotificationKeys.refreshMyBoardsScreen.rawValue)
            )) { _ in
                Task {
                    await vm.refresh()
                    FeedVideoManager.shared.reset()
                    videoFrames.removeAll()
                }
            }
            .fullScreenCover(item: $safariURL) { url in SafariView(url: url) }
        }
    }

    // MARK: - Item cell
    @ViewBuilder
    private func itemCellView(item: ItemModel) -> some View {
        if item.boardType == 2 {
            SmartVideoPlayerView(
                item: item,
                onTapBottomButton: {
                    if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
                        safariURL = url
                        FeedVideoManager.shared.muteAll()
                    }
                }
            )
            .background(GeometryReader { geo in
                Color.clear
                    .onAppear {
                        videoFrames[item.id ?? 0] = geo.frame(in: .global)
                        scheduleVisibilityUpdate()
                    }
                    .onChange(of: geo.frame(in: .global)) { frame in
                        videoFrames[item.id ?? 0] = frame
                        scheduleVisibilityUpdate()
                    }
            })
            .onAppear { prefetchNextVideos(from: item) }
            .onDisappear {
                videoFrames.removeValue(forKey: item.id ?? 0)
                FeedVideoManager.shared.pause(id: item.id ?? 0)
            }
        } else {
            CardItemView(
                item: item,
                onLike: { isLiked, boardId in vm.updateLike(boardId: boardId, isLiked: isLiked) },
                onTap:  { pushToDetail(item: item) },
                onTapBoostButton: {
                    if item.boardType == 1 {
                        if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
                            safariURL = url
                        }
                    } else {
                        paymentGatewayOpen(product: item)
                    }
                },
                isToShowBoostButton: true
            )
        }
    }

    // MARK: - Helpers
    private func prefetchNextVideos(from currentItem: ItemModel) {
        guard let index = vm.items.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let start = index + 1
        let end   = min(index + 2, vm.items.count - 1)
        guard start <= end else { return }
        let urls: [URL] = (start...end).compactMap { i in
            let it = vm.items[i]
            guard it.boardType == 2, let link = it.videoLink else { return nil }
            return URL(string: link)
        }
        VideoPreloadManagerDefault.shared.set(waiting: urls)
    }

    private func scheduleVisibilityUpdate() {
        visibilityWorkItem?.cancel()
        let work = DispatchWorkItem { calculateVisibleVideos() }
        visibilityWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
    }

    private func calculateVisibleVideos() {
        guard isActive else { FeedVideoManager.shared.pauseAll(); return }
        let screenH = UIScreen.main.bounds.height
        var visible: Set<Int> = []
        for (id, frame) in videoFrames {
            guard frame.maxY > 0, frame.minY < screenH else { continue }
            let visH = min(frame.maxY, screenH) - max(frame.minY, 0)
            if (visH / frame.height) >= 0.6 { visible.insert(id) }
        }
        FeedVideoManager.shared.updatePlayback(visibleIDs: visible)
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image("no_data_found_illustrator")
            Text("No Data Found").foregroundColor(.orange)
        }
    }

    private func pushToDetail(item: ItemModel) {
        let vc = UIHostingController(
            rootView: BoardDetailView(navigationController: navigationController, itemObj: item)
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func paymentGatewayOpen(product: ItemModel) {
        paymentGateway = PaymentGatewayCentralized()
        paymentGateway?.selectedPlanId  = product.package?.id           ?? 0
        paymentGateway?.categoryId      = product.categoryID            ?? 0
        paymentGateway?.itemId          = product.id                    ?? 0
        paymentGateway?.paymentFor      = .boostBoard
        paymentGateway?.selIOSProductID = product.package?.iosProductID ?? ""
        paymentGateway?.callbackPaymentSuccess = { [self] isSuccess in
            if isSuccess {
                let vc = UIHostingController(
                    rootView: PlanBoughtSuccessView(navigationController: navigationController)
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle   = .crossDissolve
                vc.view.backgroundColor   = UIColor.black.withAlphaComponent(0.5)
                navigationController?.present(vc, animated: true)
                NotificationCenter.default.post(
                    name:   NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue),
                    object: ["boardId": product.id ?? 0]
                )
            }
            self.paymentGateway = nil
        }
        paymentGateway?.initializeDefaults()
    }
}

*/

import SwiftUI

struct BoardHomeView: View {

    @State private var selectedCategoryId: Int = 0
    @State private var selectedName: String = ""
    let tabBarController: UITabBarController?
    @StateObject private var categoryVM = CategoryViewModel(type: 2, isToShowLoader: false)
    @StateObject private var boardStore = BoardStore()
    // Only keep selected tab + 1 neighbour each side alive (max 3 total)
    @State private var loadedCategoryIds: [Int] = []
    private let maxLoadedTabs = 3
   
    @State private var isUpdatedEvents: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .background(Color(.systemBackground))
                .onAppear {
                    if isUpdatedEvents{
                        updateEvents()
                        isUpdatedEvents = true
                    }
                }

            CategoryTabsNew(
                selected: $selectedName,
                selectedCategoryId: $selectedCategoryId,
                categoryVM: categoryVM
            )
            .background(Color(.systemBackground))

            if selectedCategoryId > 0 {
                tabContentView
            } else {
                Spacer()
            }
        }
        .onChange(of: selectedCategoryId) { newId in
            FeedVideoManager.shared.pauseAll()
            FeedVideoManager.shared.muteAll()
            markTabLoaded(newId)
            prefetchNeighbours(of: newId)
        }
        .onAppear { markTabLoaded(selectedCategoryId) }
        .background(Color(.systemGray6))
        .onDisappear { FeedVideoManager.shared.muteAll() }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.refreshInterestChangeBoardScreen.rawValue)
            )
        ) { _ in handleInterestRefresh() }
    }

    // MARK: - Tab Content
    // This is the critical change: instead of ZStack with all tabs at opacity 0/1,
    // we only insert the active tab (+ loaded neighbours) into the view tree.
    // Views not in the tree = zero memory for their scroll state, image cache refs, etc.

    @ViewBuilder
    private var tabContentView: some View {
        let boardNav = tabBarController?.viewControllers?[0] as? UINavigationController

        ZStack {
            ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                let catId = cat.id ?? 0
                // HARD conditional — not opacity. Off-screen tabs don't exist.
                if loadedCategoryIds.contains(catId) {
                    BoardListViewNew(
                        tabBarController: tabBarController,
                        vm: boardStore.vm(for: catId),
                        navigationController: boardNav,
                        isActive: selectedCategoryId == catId
                    )
                    // Use offset instead of opacity so scroll position is preserved
                    // for the immediate neighbours, but they're off-screen
                    .offset(x: selectedCategoryId == catId ? 0 : UIScreen.main.bounds.width)
                    .allowsHitTesting(selectedCategoryId == catId)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 15)
                .onEnded { value in
                    let h = value.translation.width
                    let v = value.translation.height
                    guard abs(h) > abs(v) else { return }
                    if h < -70 { swipeCategory(left: true) }
                    else if h > 70 { swipeCategory(left: false) }
                }
        )
    }

    // MARK: - LRU Tab Management

    private func markTabLoaded(_ id: Int) {
        guard id > 0 else { return }

        if let idx = loadedCategoryIds.firstIndex(of: id) {
            loadedCategoryIds.remove(at: idx)
            loadedCategoryIds.insert(id, at: 0)
            return
        }

        // Evict when over cap
        while loadedCategoryIds.count >= maxLoadedTabs {
            let evictId = loadedCategoryIds.removeLast()
            boardStore.evict(id: evictId)
            // Also clear Kingfisher memory for images associated with this tab
            ImageCache.default.clearMemoryCache()
        }

        loadedCategoryIds.insert(id, at: 0)
    }

    /// Pre-load left and right neighbours so swipe feels instant
    private func prefetchNeighbours(of id: Int) {
        guard let list = categoryVM.listArray,
              let idx  = list.firstIndex(where: { $0.id == id }) else { return }

        if idx > 0 {
            let leftId = list[idx - 1].id ?? 0
            if !loadedCategoryIds.contains(leftId) {
                markTabLoaded(leftId)
            }
        }
        if idx < list.count - 1 {
            let rightId = list[idx + 1].id ?? 0
            if !loadedCategoryIds.contains(rightId) {
                markTabLoaded(rightId)
            }
        }
    }

    // MARK: - Notification / Swipe Handlers

    private func handleInterestRefresh() {
        selectedCategoryId = 55555
        selectedName = "All"
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: NotificationKeys.refreshMyBoardsScreen.rawValue),
            object: nil
        )
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
            selectedName       = newCat.name ?? ""
        }
    }

    func updateEvents() {
        FaceBookAppEvents.facebookEvents(type: .board, categoryName: selectedName)
        SocketIOManager.sharedInstance.checkSocketStatus()
        
       /* NotificationCenter.default.addObserver(forName: NSNotification.Name(SocketEvents.socketConnected.rawValue), object: nil, queue: .main) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                SocketIOManager.sharedInstance.emitEvent(SocketEvents.chatUnreadCount.rawValue, [:])
            })
        }*/
    }
}

struct BoardListViewNew: View {
    
    let tabBarController: UITabBarController?
    @ObservedObject var vm: BoardViewModelNew
    let navigationController: UINavigationController?
    let isActive: Bool
    @State private var paymentGateway: PaymentGatewayCentralized?
    @StateObject private var frameStore = FrameStore()
    @State private var safariURL: URL?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Color.clear.frame(height: 0).id("TOP")

                if vm.isLoading && vm.items.isEmpty && !vm.hasLoadedOnce{
                    PinterestSkeletonGrid()
                    // .padding(.top, 5)
                    
                }else if vm.items.isEmpty && !vm.isLoading && vm.hasLoadedOnce {
                    emptyView.padding(.top, 100)
                    
                } else {
//                    PinterestMasonryFeed(
//                        items: vm.items,
//                        spacing: 6,
//                        itemView: { item in (itemCellView(item: item) },
//                        onLastItemAppear: {
//                            guard !vm.isLoading, !vm.isLastPage else { return }
//                            vm.tryLoadNextPage()
//                        }, onOpenURL: {url in
//                            safariURL = url
//                        }
//                    )
                    
                    
                    PinterestMasonryFeed(
                        items: vm.items,
                        spacing: 6,
                        itemView: { item in itemCellView(item: item) },  // no AnyView wrapper
                        onLastItemAppear: {
                            guard !vm.isLoading, !vm.isLastPage else { return }
                            vm.tryLoadNextPage()
                        },
                        onOpenURL: { url in safariURL = url }
                    )
                    
                    .padding(.horizontal, 5)
                    .transaction { t in
                        t.animation = nil
                    }
                }

                if vm.isLoading {
                    ProgressView().padding(.vertical, 12)
                }
            }
            .padding(.bottom, tabBarController?.tabBar.frame.height ?? 83)
            .ignoresSafeArea(edges: .bottom)
            .onDisappear {
                FeedVideoManager.shared.pauseAll()
                frameStore.removeAll()
            }
            
            
            .refreshable {
                await vm.refresh()
                FeedVideoManager.shared.reset()
                frameStore.removeAll()
            }
            .task {
                if vm.items.isEmpty { vm.loadIfNeeded() }
            }
            .onChange(of: isActive) { active in
                if !active { FeedVideoManager.shared.pauseAll() }
            }
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.refreshLikeDislikeBoard.rawValue)
            )) { n in
                guard let d = n.object as? [String: Any] else { return }
                vm.update(likeCount: d["count"] as? Int ?? 0,
                          isLike:    d["isLike"] as? Bool ?? false,
                          boardId:   d["boardId"] as? Int ?? 0)
            }
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.refreshCommentCountBoard.rawValue)
            )) { n in
                guard let d = n.object as? [String: Any] else { return }
                vm.updateCommentCount(commentCount: d["count"] as? Int ?? 0,
                                      commentObj:   d["lastComment"] as? CommentModel,
                                      boardId:      d["boardId"] as? Int ?? 0)
            }
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.scrollBoardToTop)
            )) { _ in
                withAnimation(.easeInOut) { proxy.scrollTo("TOP", anchor: .top) }
            }
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.boardBoostedRefresh.rawValue)
            )) { n in
                guard let d = n.object as? [String: Any] else { return }
                vm.updateBoost(isBoosted: true, boardId: d["boardId"] as? Int ?? 0)
            }
            .onReceive(NotificationCenter.default.publisher(
                for: NSNotification.Name(NotificationKeys.refreshMyBoardsScreen.rawValue)
            )) { _ in
                Task {
                    await vm.refresh()
                    FeedVideoManager.shared.reset()
                    frameStore.removeAll()
                }
            }
            
            .onReceive( NotificationCenter.default.publisher(
                                for: UIApplication.didReceiveMemoryWarningNotification
                            )
                        ) { _ in
                            ImageCache.default.clearMemoryCache()
                            KingfisherManager.shared.downloader.cancelAll()
                            FeedVideoManager.shared.pauseAndSuspendAll()
                            frameStore.removeAll()
                            VideoPreloadManagerDefault.shared.cancelAll()
                        }
            
            .fullScreenCover(item: $safariURL) { url in SafariView(url: url) }
        }
    }

    // MARK: - Item Cell

    @ViewBuilder
    private func itemCellView(item: ItemModel) -> some View {
        if item.boardType == 2 {
            SmartVideoPlayerView(
                item: item,
                onTapBottomButton: {
                    if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
                        safariURL = url
                        FeedVideoManager.shared.muteAll()
                    }
                }
            )
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            frameStore.set(id: item.id ?? 0, frame: geo.frame(in: .global))
                            frameStore.scheduleVisibilityUpdate(isActive: isActive)
                        }
                        .onChange(of: geo.frame(in: .global)) { frame in
                            frameStore.set(id: item.id ?? 0, frame: frame)
                            frameStore.scheduleVisibilityUpdate(isActive: isActive)
                        }
                }
            )
            .onAppear { prefetchNextVideos(from: item) }
            .onDisappear {
                frameStore.remove(id: item.id ?? 0)
                FeedVideoManager.shared.pause(id: item.id ?? 0)
            }
        } else {
            CardItemViewNew(
                item: item,
                onLike: { isLiked, boardId in vm.updateLike(boardId: boardId, isLiked: isLiked) },
                onTap:  { pushToDetail(item: item) },
                onTapBoostButton: {
                    if item.boardType == 1 {
                        if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
                            safariURL = url
                        }
                    } else {
                        paymentGatewayOpen(product: item)
                    }
                },
                isToShowBoostButton: true
            )
        }
    }

    // MARK: - Helpers

    private func prefetchNextVideos(from currentItem: ItemModel) {
        guard let index = vm.items.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let start = index + 1
        let end   = min(index + 2, vm.items.count - 1)
        guard start <= end else { return }
        let urls: [URL] = (start...end).compactMap { i in
            let it = vm.items[i]
            guard it.boardType == 2, let link = it.videoLink else { return nil }
            return URL(string: link)
        }
        VideoPreloadManagerDefault.shared.set(waiting: urls)
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image("no_data_found_illustrator")
            Text("No Data Found").foregroundColor(.orange)
        }
    }

    private func pushToDetail(item: ItemModel) {
        let vc = UIHostingController(
            rootView: BoardDetailView(navigationController: navigationController, itemObj: item)
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func paymentGatewayOpen(product: ItemModel) {
        paymentGateway = PaymentGatewayCentralized()
        paymentGateway?.selectedPlanId  = product.package?.id           ?? 0
        paymentGateway?.categoryId      = product.categoryID            ?? 0
        paymentGateway?.itemId          = product.id                    ?? 0
        paymentGateway?.paymentFor      = .boostBoard
        paymentGateway?.selIOSProductID = product.package?.iosProductID ?? ""
        paymentGateway?.callbackPaymentSuccess = { [self] isSuccess in
            if isSuccess {
                let vc = UIHostingController(
                    rootView: PlanBoughtSuccessView(navigationController: navigationController)
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle   = .crossDissolve
                vc.view.backgroundColor   = UIColor.black.withAlphaComponent(0.5)
                navigationController?.present(vc, animated: true)
                NotificationCenter.default.post(
                    name:   NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue),
                    object: ["boardId": product.id ?? 0]
                )
            }
            self.paymentGateway = nil
        }
        paymentGateway?.initializeDefaults()
    }    
}

final class FrameStore: ObservableObject {

    private var frames: [Int: CGRect] = [:]
    private var visibilityWorkItem: DispatchWorkItem?

    func set(id: Int, frame: CGRect) {
        frames[id] = frame
    }

    func remove(id: Int) {
        frames.removeValue(forKey: id)
    }

    func removeAll() {
        frames.removeAll()
    }

    func scheduleVisibilityUpdate(isActive: Bool) {
        visibilityWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.calculateVisibleVideos(isActive: isActive)
        }
        visibilityWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
    }

    private func calculateVisibleVideos(isActive: Bool) {
        guard isActive else { FeedVideoManager.shared.pauseAll(); return }

        let screenH = UIScreen.main.bounds.height
        var visible: Set<Int> = []

        for (id, frame) in frames {
            guard frame.maxY > 0, frame.minY < screenH else { continue }
            let visH = min(frame.maxY, screenH) - max(frame.minY, 0)
            if frame.height > 0, (visH / frame.height) >= 0.6 {
                visible.insert(id)
            }
        }

        FeedVideoManager.shared.updatePlayback(visibleIDs: visible)
    }
}


enum FeedSegment: Identifiable {
    case banner(ItemModel)
    case staggeredChunk([ItemModel])   // always non-banner items only

    var id: String {
        switch self {
        case .banner(let item):
            return "banner-\(item.id ?? 0)"
        case .staggeredChunk(let items):
            // stable id from first+last item in chunk
            return "chunk-\(items.first?.id ?? 0)-\(items.last?.id ?? 0)"
        }
    }
}

struct PinterestMasonryFeed<ItemContent: View>: View {

    let items:            [ItemModel]
    var spacing:          CGFloat = 6
    let itemView:         (ItemModel) -> ItemContent
    let onLastItemAppear: () -> Void
    let onOpenURL:        (URL) -> Void

    @State private var lastTriggeredItemId: Int?
    private let paginationThreshold = 8
    private let chunkSize = 10

    // MARK: - Segment Model

    private enum Segment: Identifiable {
        case chunk([ItemModel])           // ✅ raw chunk, TwoColumnMasonryLayout handles placement
        case banner(ItemModel)
        case paginationTrigger(itemId: Int)

        var id: String {
            switch self {
            case .chunk(let items):
                return "chunk-\(items.first?.id ?? 0)-\(items.last?.id ?? 0)"
            case .banner(let i):
                return "ban-\(i.id ?? 0)"
            case .paginationTrigger(let id):
                return "page-trigger-\(id)"
            }
        }
    }

    // MARK: - Segment Builder

    private var segments: [Segment] {
        var result: [Segment]   = []
        var buffer: [ItemModel] = []

        let triggerItemId: Int? = {
            guard items.count >= paginationThreshold else { return nil }
            return items[items.count - paginationThreshold].id
        }()

        func flush() {
            guard !buffer.isEmpty else { return }
            var i = 0
            while i < buffer.count {
                let chunk = Array(buffer[i..<min(i + chunkSize, buffer.count)])
                result.append(.chunk(chunk))

                // ✅ Insert pagination trigger after chunk that contains trigger item
                let chunkIds = chunk.compactMap { $0.id }
                if let tid = triggerItemId, chunkIds.contains(tid) {
                    result.append(.paginationTrigger(itemId: tid))
                }

                i += chunkSize
            }
            buffer.removeAll()
        }

        for item in items {
            if item.boardType == 4 || item.boardType == 5 {
                flush()
                result.append(.banner(item))
            } else {
                buffer.append(item)
            }
        }
        flush()
        return result
    }

    // MARK: - Body

    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(segments) { segment in
                switch segment {

                case .banner(let item):
                    bannerView(item: item)
                        .frame(maxWidth: .infinity)

                case .chunk(let chunkItems):
                    // ✅ TwoColumnMasonryLayout: true stagger, column heights tracked,
                    //    only max 10 items per chunk so no memory pressure
                    TwoColumnMasonryLayout(
                        spacing: spacing,
                        shouldEqualizeBottom: isBannerNext(after: chunkItems)
                    ) {
                        ForEach(chunkItems, id: \.id) { item in
                            itemView(item)
                        }
                    }

                case .paginationTrigger(let triggerItemId):
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            guard lastTriggeredItemId != triggerItemId else { return }
                            lastTriggeredItemId = triggerItemId
                            onLastItemAppear()
                        }
                }
            }
            
            Color.clear.frame(height: 1)
                            .id("bottom-\(items.count)")  // ✅ id changes with each page load
                            .onAppear {
                                guard !items.isEmpty else { return }
                                guard lastTriggeredItemId != -items.count else { return }
                                lastTriggeredItemId = -items.count  // negative so no clash with item ids
                                onLastItemAppear()
                            }
        }
        .onChange(of: items.count) { _ in
            lastTriggeredItemId = nil
        }
    }

    // MARK: - Helpers

    // ✅ Equalize bottom only when next segment is a banner — removes gap
    private func isBannerNext(after chunkItems: [ItemModel]) -> Bool {
        guard let lastId = chunkItems.last?.id else { return false }
        guard let lastIndex = items.firstIndex(where: { $0.id == lastId }) else { return false }
        let nextIndex = lastIndex + 1
        guard nextIndex < items.count else { return false }
        return items[nextIndex].boardType == 4 || items[nextIndex].boardType == 5
    }

    // MARK: - Banner View

    @ViewBuilder
    private func bannerView(item: ItemModel) -> some View {
        if item.boardType == 5 {
            BoardVideoBannerCard(product: item) { url in onOpenURL(url) }
        } else {
            BoardBannerCard(product: item) { url in onOpenURL(url) }
        }
    }
}
/*
struct PinterestMasonryFeed<ItemContent: View>: View {

    let items:            [ItemModel]
    var spacing:          CGFloat = 6
    let itemView:         (ItemModel) -> ItemContent
    let onLastItemAppear: () -> Void
    let onOpenURL:        (URL) -> Void

    @State private var lastTriggeredItemId: Int?
    private let paginationThreshold = 8
    private let chunkSize = 10

    // MARK: - Segment Model

    private enum Segment: Identifiable {
        case columns(left: [ItemModel], right: [ItemModel])
        case banner(ItemModel)
        case paginationTrigger(itemId: Int)  // ✅ dedicated segment type

        var id: String {
            switch self {
            case .columns(let l, let r):
                return "col-\(l.first?.id ?? 0)-\(r.first?.id ?? 0)"
            case .banner(let i):
                return "ban-\(i.id ?? 0)"
            case .paginationTrigger(let id):
                return "page-trigger-\(id)"
            }
        }
    }

    // MARK: - Segment Builder
    // ✅ Pagination trigger is injected as its own segment so LazyVStack
    //    only renders it when it actually scrolls into view

    private var segments: [Segment] {
        var result:  [Segment]   = []
        var buffer:  [ItemModel] = []
        var allNonBannerItems:   [ItemModel] = items.filter {
            $0.boardType != 4 && $0.boardType != 5
        }

        // Find the trigger item id (paginationThreshold from end of ALL items)
        let triggerItemId: Int? = {
            guard items.count >= paginationThreshold else { return nil }
            return items[items.count - paginationThreshold].id
        }()

        func flush(isLast: Bool = false) {
            guard !buffer.isEmpty else { return }
            var i = 0
            while i < buffer.count {
                let chunk = Array(buffer[i..<min(i + chunkSize, buffer.count)])
                var left:  [ItemModel] = []
                var right: [ItemModel] = []
                for (idx, item) in chunk.enumerated() {
                    if idx % 2 == 0 { left.append(item) } else { right.append(item) }
                }
                result.append(.columns(left: left, right: right))

                // ✅ After the chunk that contains the trigger item,
                //    insert the pagination trigger as its own lazy row
                let chunkIds = chunk.compactMap { $0.id }
                if let tid = triggerItemId, chunkIds.contains(tid) {
                    result.append(.paginationTrigger(itemId: tid))
                }

                i += chunkSize
            }
            buffer.removeAll()
        }

        for item in items {
            if item.boardType == 4 || item.boardType == 5 {
                flush()
                result.append(.banner(item))
            } else {
                buffer.append(item)
            }
        }
        flush(isLast: true)
        return result
    }

    private var columnWidth: CGFloat {
        (UIScreen.main.bounds.width - 10 - spacing) / 2
    }

    // MARK: - Body

    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(segments) { segment in
                switch segment {

                case .banner(let item):
                    bannerView(item: item)
                        .frame(maxWidth: .infinity)

                case .columns(let left, let right):
                    HStack(alignment: .top, spacing: spacing) {
                        VStack(spacing: spacing) {
                            ForEach(left, id: \.id) { item in
                                itemView(item)
                                    .frame(width: columnWidth)
                            }
                        }
                        .frame(width: columnWidth, alignment: .top)

                        VStack(spacing: spacing) {
                            ForEach(right, id: \.id) { item in
                                itemView(item)
                                    .frame(width: columnWidth)
                            }
                        }
                        .frame(width: columnWidth, alignment: .top)

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                // ✅ This row only enters the view tree when LazyVStack
                //    scrolls to it — guaranteed to fire onAppear at the right time
                case .paginationTrigger(let triggerItemId):
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            guard lastTriggeredItemId != triggerItemId else { return }
                            lastTriggeredItemId = triggerItemId
                            print("✅ Pagination triggered at item: \(triggerItemId)")
                            onLastItemAppear()
                        }
                }
            }
        }
        .onChange(of: items.count) { _ in
            lastTriggeredItemId = nil
        }
    }

    // MARK: - Banner View

    @ViewBuilder
    private func bannerView(item: ItemModel) -> some View {
        if item.boardType == 5 {
            BoardVideoBannerCard(product: item) { url in onOpenURL(url) }
        } else {
            BoardBannerCard(product: item) { url in onOpenURL(url) }
        }
    }
}
*/
/*struct PinterestMasonryFeed<ItemContent: View>: View {
    let items:            [ItemModel]
    var spacing:          CGFloat = 6
    let itemView:         (ItemModel) -> ItemContent
    let onLastItemAppear: () -> Void
    let onOpenURL:        (URL) -> Void

    @State private var lastTriggeredItemId: Int?
    private let paginationThreshold = 5

    private enum Segment: Identifiable {
        case columns(left: [ItemModel], right: [ItemModel])
        case banner(ItemModel)

        var id: String {
            switch self {
            case .columns(let l, _): return "col-\(l.first?.id ?? 0)"
            case .banner(let i):     return "ban-\(i.id ?? 0)"
            }
        }
    }

    private var segments: [Segment] {
        var result: [Segment] = []
        var buffer: [ItemModel] = []

        func flushBuffer() {
            guard !buffer.isEmpty else { return }
            var left: [ItemModel] = []
            var right: [ItemModel] = []
            for (i, item) in buffer.enumerated() {
                if i % 2 == 0 { left.append(item) } else { right.append(item) }
            }
            result.append(.columns(left: left, right: right))
            buffer.removeAll()
        }

        for item in items {
            if item.boardType == 4 || item.boardType == 5 {
                flushBuffer()
                result.append(.banner(item))
            } else {
                buffer.append(item)
            }
        }
        flushBuffer()
        return result
    }

    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(segments) { segment in
                switch segment {
                case .banner(let item):
                    bannerView(item: item)
                        .frame(maxWidth: .infinity)

                case .columns(let left, let right):
                    let nextSegmentIsBanner: Bool = {
                        guard let currentIndex = segments.firstIndex(where: {
                            if case .columns(let l, _) = $0 { return l.first?.id == left.first?.id }
                            return false
                        }) else { return false }
                        let nextIndex = currentIndex + 1
                        guard nextIndex < segments.count else { return false }
                        if case .banner = segments[nextIndex] { return true }
                        return false
                    }()

                    HStack(alignment: .top, spacing: spacing) {
                        LazyVStack(spacing: spacing) {
                            ForEach(left, id: \.id) { item in
                                itemView(item)
                            }
                            // ✅ Push left column down if right is taller and next is banner
                            if nextSegmentIsBanner && right.count > left.count {
                                Color.clear.frame(height: 1)
                            }
                        }
                        LazyVStack(spacing: spacing) {
                            ForEach(right, id: \.id) { item in
                                itemView(item)
                            }
                        }
                    }
                }
            }
            Color.clear
                 .frame(height: 1)
                 .onAppear {
                     onLastItemAppear()
                 }
//            if items.count >= paginationThreshold {
//                let triggerItem = items[items.count - paginationThreshold]
//                Color.clear
//                    .frame(height: 1)
//                    .id("trigger-\(triggerItem.id ?? 0)")
//                    .onAppear {
//                        guard lastTriggeredItemId != triggerItem.id else { return }
//                        lastTriggeredItemId = triggerItem.id
//                        onLastItemAppear()
//                    }
//            }
        }
//        .onChange(of: items.count) { _ in
//            lastTriggeredItemId = nil
//        }
    }

    @ViewBuilder
    private func bannerView(item: ItemModel) -> some View {
        if item.boardType == 5 {
            BoardVideoBannerCard(product: item) { url in onOpenURL(url) }
        } else {
            BoardBannerCard(product: item) { url in onOpenURL(url) }
        }
    }

    private func triggerPaginationIfNeeded(item: ItemModel) {
        guard items.count >= paginationThreshold else { return }
        let triggerItem = items[items.count - paginationThreshold]
        guard item.id == triggerItem.id,
              lastTriggeredItemId != triggerItem.id else { return }
        lastTriggeredItemId = triggerItem.id
        onLastItemAppear()
    }
}
*/
/*
struct PinterestMasonryFeed: View {

    let items:            [ItemModel]
    var spacing:          CGFloat = 6
    let itemView:         (ItemModel) -> AnyView
    let onLastItemAppear: () -> Void
    let onOpenURL: (URL) -> Void

   // @State private var safariURL: URL?
    @State private var lastTriggeredItemId: Int?
    private let paginationThreshold = 5
    // ── Segment model ────────────────────────────────────────────────────────
    private enum Segment: Identifiable {
        case columns([ItemModel])
        case banner(ItemModel)

        var id: String {
            switch self {
            case .columns(let a): return "col-\(a.first?.id ?? 0)-\(a.last?.id ?? 0)"
            case .banner(let i):  return "ban-\(i.id ?? 0)"
            }
        }
    }

    private var segments: [Segment] {
        var result: [Segment]   = []
        var buffer: [ItemModel] = []
        for item in items {
           // if item.boardType == 4 {
            if item.boardType == 4 || item.boardType == 5 {
                if !buffer.isEmpty { result.append(.columns(buffer)); buffer.removeAll() }
                result.append(.banner(item))
            } else {
                buffer.append(item)
            }
        }
        if !buffer.isEmpty { result.append(.columns(buffer)) }
        return result
    }

    // Last non-banner item id — used to fire pagination
    private var lastNonBannerId: Int? {
        items.last(where: { $0.boardType != 4 })?.id
    }

    var body: some View {

        LazyVStack(spacing: spacing) {

            ForEach(segments) { segment in
                switch segment {

                    
                case .banner(let item):

                    Group {
                        if item.boardType == 5 {

                            BoardVideoBannerCard(product: item, onClickedView: {url in
                                onOpenURL(url)
                               // safariURL = url
                            })

                        } else {

                            BoardBannerCard(product: item, onClickedView: {url in
                                //safariURL = url
                                onOpenURL(url)

                            })
                        }
                    }
                    .frame(maxWidth: .infinity)

               /* case .columns(let chunkItems):

                    TwoColumnMasonryLayout(spacing: spacing) {

                        ForEach(chunkItems, id: \.id) { item in
                            itemView(item)
                        }
                        
                    }*/
                    
                case .columns(let chunkItems):

                    let lastChunkItemId = chunkItems.last?.id

                    let lastChunkGlobalIndex = items.firstIndex {
                        $0.id == lastChunkItemId
                    } ?? -1

                    let nextItemIsBanner: Bool = {

                        let nextIndex = lastChunkGlobalIndex + 1

                        guard nextIndex < items.count else {
                            return false
                        }

                        let nextItem = items[nextIndex]

                        return nextItem.boardType == 4 || nextItem.boardType == 5

                    }()

                    TwoColumnMasonryLayout(
                        spacing: spacing,
                        shouldEqualizeBottom: nextItemIsBanner
                    ) {

                        ForEach(chunkItems, id: \.id) { item in
                            itemView(item)
                        }
                    }
                    
                    
                }
            }

            // Pagination trigger
           /* Color.clear
                .frame(height: 1)
                .onAppear {
                    onLastItemAppear()
                }*/
            
            
            if items.count >= paginationThreshold {
                
                let triggerItem = items[items.count - paginationThreshold]
                
                Color.clear
                    .frame(height: 1)
                    .id(triggerItem.id ?? 0)
                    .onAppear {
                        
                        guard lastTriggeredItemId != triggerItem.id else {
                            return
                        }
                        
                        lastTriggeredItemId = triggerItem.id
                        
                        onLastItemAppear()
                    }
            }
        }
        .onChange(of: items.count) { _ in
            lastTriggeredItemId = nil
        }
    }
}
*/

struct TwoColumnMasonryLayout: Layout {
 
    var spacing:              CGFloat = 6
    var shouldEqualizeBottom: Bool    = true
 
    // ── FIX: computed once, not per-frame ─────────────────────────────────────
    private static let screenWidth = UIScreen.main.bounds.width
 
    struct CacheData {
        var frames: [CGRect] = []
        var size:   CGSize   = .zero
    }
 
    func makeCache(subviews: Subviews) -> CacheData { CacheData() }
 
    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout CacheData) -> CGSize {
 
        let totalW = proposal.width ?? Self.screenWidth
        let colW   = (totalW - spacing) / 2
 
        var frames              = Array(repeating: CGRect.zero, count: subviews.count)
        var colHeights: [CGFloat] = [0, 0]
        var lastInCol:  [Int?]    = [nil, nil]
 
        for index in subviews.indices {
            let col  = colHeights[0] <= colHeights[1] ? 0 : 1
            let size = subviews[index].sizeThatFits(ProposedViewSize(width: colW, height: nil))
            let x    = col == 0 ? 0 : colW + spacing
            let y    = colHeights[col]
            frames[index]    = CGRect(x: x, y: y, width: colW, height: size.height)
            colHeights[col] += size.height + spacing
            lastInCol[col]   = index
        }
 
        let leftH  = max(colHeights[0] - spacing, 0)
        let rightH = max(colHeights[1] - spacing, 0)
        let maxH   = max(leftH, rightH)
 
        if shouldEqualizeBottom {
            if leftH < rightH, let idx = lastInCol[0] {
                frames[idx].size.height += rightH - leftH
            } else if rightH < leftH, let idx = lastInCol[1] {
                frames[idx].size.height += leftH - rightH
            }
        }
 
        cache.frames = frames
        cache.size   = CGSize(width: totalW, height: maxH)
        return cache.size
    }
 
    func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: Subviews,
                       cache: inout CacheData) {
        for index in subviews.indices {
            let frame = cache.frames[index]
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }
}


struct BoardBannerCard: View {
    
    let product: ItemModel
    let onClickedView:(_ url:URL)->Void
    
    var body: some View {
        KFImage(URL(string: product.banner?.image ?? "")).onSuccess { result in
            
        }
        .scaleFactor(UIScreen.main.scale)
        .cacheOriginalImage(false)
        .resizable()
        .scaledToFill()
        .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 220)
        .clipped()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            recordOutboundClick()
        }
    }
    
    private func recordOutboundClick() {
        
        if  let url = product.banner?.thirdPartyLink{
            
            if let URL = URL(string: url.getValidUrl()){
                onClickedView(URL)
            }
        }else if  let url = product.banner?.url{
            if let URL = URL(string: url.getValidUrl()){
                onClickedView(URL)
            }
        }
        
        if (product.banner?.isCampaign ?? false){
            self.campaignClickEventApi(campaign_banner_id: product.banner?.campaignID ?? 0)
        }else{
            //For apps own banner
            self.captureSliderClickApi(campaign_banner_id: product.banner?.campaignID ?? 0)
        }
    }
    
    
    
    private func campaignClickEventApi(campaign_banner_id:Int){
        
        let params = ["campaign_banner_id":campaign_banner_id,"event_type":"click","referrer_url":"HOME"] as [String : Any]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.campaign_event, param: params,methodType:.post,showLoader: false) { responseObject, error in
        }
    }
    
    
    private func captureSliderClickApi(campaign_banner_id:Int){
        let params = ["id":campaign_banner_id] as [String : Any]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.capture_slider_click, param: params,methodType:.post,showLoader: false) { responseObject, error in
        }
    }
}



struct BoardVideoBannerCard: View {
    
    let product: ItemModel
    let onClickedView: (_ url: URL) -> Void
    
    @State private var player: AVPlayer?
    @State private var loopToken: NSObjectProtocol?
    
    var body: some View {
        VStack(spacing: 0) {
            videoLayer
            learnMoreBar
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
    }
    
    // MARK: - Sub-views
    
    private var videoLayer: some View {
        VideoPlayer(player: player)
            .frame(height: 200)
            .onAppear(perform: startPlayback)
            .onDisappear(perform: stopPlayback)
    }
    
    private var learnMoreBar: some View {
        HStack {
            Text("Learn more")
                .foregroundColor(.primary)
                .font(.system(size: 14, weight: .medium))
            Spacer()
            Image(systemName: "arrow.up.right")
                .renderingMode(.template)
                .foregroundColor(.primary)
                .font(.system(size: 12))
        }
        .padding(.horizontal, 10)
        .frame(height: 35)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
        .contentShape(Rectangle())
        .onTapGesture(perform: recordOutboundClick)
    }
    
    // MARK: - Playback Lifecycle
    
    private func startPlayback() {
        // Guard: don't recreate if already running (e.g. SwiftUI double-appear)
        guard player == nil,
              let url = URL(string: product.banner?.image ?? "") else { return }
        
        let avPlayer = AVPlayer(url: url)
        avPlayer.isMuted = true
        avPlayer.actionAtItemEnd = .none   // prevents auto-pause at end
        
        loopToken = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem,
            queue: .main
        ) { [weak avPlayer] _ in
            avPlayer?.seek(to: .zero, completionHandler: { _ in
                avPlayer?.play()
            })
        }
        
        avPlayer.play()
        self.player = avPlayer
    }
    
    private func stopPlayback() {
        // ── FIX 3: remove observer before nil-ing player ─────────────────────
        if let token = loopToken {
            NotificationCenter.default.removeObserver(token)
            loopToken = nil
        }
        
        player?.pause()
        // ── FIX 4: release AVAsset buffers immediately ────────────────────────
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    // MARK: - Analytics / Navigation
    
    private func recordOutboundClick() {
        let banner = product.banner
        
        if let raw = banner?.thirdPartyLink ?? banner?.url,
           let url = URL(string: raw.getValidUrl()) {
            onClickedView(url)
        }
        
        if banner?.isCampaign == true {
            campaignClickEventApi(campaignBannerId: banner?.campaignID ?? 0)
        } else {
            captureSliderClickApi(campaignBannerId: banner?.campaignID ?? 0)
        }
    }
    
    private func campaignClickEventApi(campaignBannerId: Int) {
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
    
    private func captureSliderClickApi(campaignBannerId: Int) {
        let params: [String: Any] = ["id": campaignBannerId]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.capture_slider_click,
            param: params,
            methodType: .post,
            showLoader: false
        ) { _, _ in }
    }
}

extension BoardHomeView {
    
    var headerView: some View {
        HStack {
            
            Image("Logo").resizable().aspectRatio(contentMode: .fit).frame(width: 115,height: 50)
            Spacer()
            // searchBar
            
            interestButton
        }
        .padding(.horizontal, 6)
        
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
              let boardNav = tabBar.viewControllers?[0] as? UINavigationController else { return }
        
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
                  let boardNav = tabBar.viewControllers?[0] as? UINavigationController else { return }
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
    BoardHomeView(tabBarController: nil)
}

private let columnWidth: CGFloat = UIScreen.main.bounds.width / 2 - 10
 
struct ProductCardStaggeredNew: View {

    @State private var showSafari = false
    let product:               ItemModel
    let sendLikeUnlikeObject:  (Bool, Int) -> Void
    let onTapBoostButton:      () -> Void
    var isToShowBoostButton    = true

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {

            // ✅ image stretches to fill remaining space after bottom content
            ZStack(alignment: .bottomTrailing) {
                KFImage(URL(string: product.image ?? ""))
                    .setProcessor(DownsamplingImageProcessor(
                        size: CGSize(width: columnWidth, height: 350)))
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage(false)
                    .memoryCacheExpiration(.seconds(120))
                    .loadDiskFileSynchronously()
                    .diskCacheExpiration(.days(3))
                    .fade(duration: 0.15)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .cornerRadius(10)

                VStack {
                    if product.isFeature == true {
                        HStack {
                            Text("Sponsored")
                                .font(.inter(.medium, size: 11))
                                .lineLimit(1)
                                .foregroundColor(Color(.gray))
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Color(UIColor.systemBackground))
                                .clipShape(Capsule())
                                .overlay { Capsule().stroke(Color(.systemGreen).opacity(0.4), lineWidth: 0.1) }
                                .padding(8)
                            Spacer()
                        }
                    }
                    Spacer()
                    if (product.user?.id ?? 0) != Local.shared.getUserId() {
                        HStack {
                            Spacer()
                            Button {
                                showSafari = true
                                outboundClickApi(strURl: product.outbondUrl ?? "", boardId: product.id ?? 0)
                            } label: {
                                HStack(spacing: 2) {
                                    Text(product.ctaLabel ?? "Buy Now")
                                        .font(.inter(.medium, size: 11)).foregroundColor(.black)
                                    Image("upRight").renderingMode(.template).foregroundColor(.black)
                                }
                            }
                            .padding(.vertical, 3).padding(.horizontal, 8)
                            .background(randomColor(for: product.id ?? 0))
                            .cornerRadius(5).padding(5)
                        }
                    }
                }
            }
            .frame(width: columnWidth)
            .layoutPriority(1)   // ✅ image ZStack gets extra space first

            // ── bottom content — fixed height, never stretches ──────────────

            HStack(spacing: 12) {
                if (product.user?.id ?? 0) != Local.shared.getUserId() {
                    Button { manageLike(boardId: product.id ?? 0) } label: {
                        HStack(spacing: 1) {
                            if product.isLiked == true {
                                Image("like_fill").resizable().aspectRatio(contentMode: .fit).frame(width: 24, height: 24)
                            } else {
                                Image("like").renderingMode(.template).resizable()
                                    .aspectRatio(contentMode: .fit).foregroundColor(.primary).frame(width: 24, height: 24)
                            }
                            if (product.totalLikes ?? 0) > 0 {
                                Text("\(product.totalLikes ?? 0)").foregroundColor(Color(.label)).font(.inter(.regular, size: 12))
                            }
                        }
                    }
                }
                HStack(spacing: 3) {
                    Image("messageIcon").renderingMode(.template).foregroundColor(Color(.label))
                    if (product.commentsCount ?? 0) > 0 {
                        Text("\((product.commentsCount ?? 0).formatViews())").font(.inter(.medium, size: 12)).foregroundColor(Color(.label))
                    }
                }
                HStack(spacing: 3) {
                    Image("eye").renderingMode(.template).foregroundColor(Color(.label))
                    if (product.impressions ?? 0) > 0 {
                        Text("\((product.impressions ?? 0).formatViews())").font(.inter(.medium, size: 12)).foregroundColor(Color(.label))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 0) {
                Text(product.name ?? "")
                    .foregroundColor(Color(.label))
                    .font(.inter(.semiBold, size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                Text(product.description ?? "")
                    .font(.inter(.regular, size: 12))
                    .lineLimit(2)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)

            PriceView(
                price: product.price ?? 0,
                specialPrice: product.specialPrice ?? 0,
                currencySymbol: Local.shared.currencySymbol
            )
            .padding([.bottom], 10).padding(.horizontal, 8).padding(.top, 2)

            if (product.user?.id ?? 0) == Local.shared.getUserId(),
               isToShowBoostButton,
               product.isFeature == false {
                Button { onTapBoostButton() } label: {
                    Text("Boost \(Local.shared.currencySymbol)\(Int(product.package?.finalPrice ?? 0))")
                        .font(.inter(.semiBold, size: 14)).foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color(red: 1.0, green: 0.65, blue: 0.15),
                                                        Color(red: 0.95, green: 0.45, blue: 0.05)]),
                            startPoint: .top, endPoint: .bottom))
                        .cornerRadius(5)
                }
                .padding(.horizontal, 10).padding(.bottom, 10)
            }
        }
        .frame(width: columnWidth)          // ✅ fixed width
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle())
        .fullScreenCover(isPresented: $showSafari) {
            if let url = URL(string: (product.outbondUrl ?? "").getValidUrl()) {
                SafariView(url: url)
            }
        }
    }

    private func manageLike(boardId: Int) {
        guard AppDelegate.sharedInstance.isUserLoggedInRequest() else { return }
        sendLikeUnlikeObject(!(product.isLiked ?? false), boardId)
    }

    func outboundClickApi(strURl: String, boardId: Int) {
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.board_outbond_click,
            param: ["board_id": boardId],
            methodType: .post
        ) { _, _ in }
    }

    func randomColor(for id: Int) -> Color {
        [Color.white, Color(hex: "#B6EEF5"), Color(hex: "#FFBC55")][id % 3]
    }
}
 
 
struct IdeaCardStaggeredNew: View {

    let product: ItemModel

    var body: some View {
        KFImage(URL(string: product.image ?? ""))
            .setProcessor(DownsamplingImageProcessor(
                size: CGSize(width: columnWidth, height: 410)))
            .scaleFactor(UIScreen.main.scale)
            .cacheOriginalImage(false)
            .memoryCacheExpiration(.seconds(120))
            .fade(duration: 0.15)
            .resizable()
            .scaledToFill()
            .frame(width: columnWidth)
            .frame(maxHeight:.infinity)
            .clipped()
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.10), radius: 7, x: 0, y: 2)
            .overlay(
                Group {
                    if product.isFeature == true {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Sponsored").foregroundColor(.white)
                                    .font(.inter(.bold, size: 14))
                                    .padding([.bottom, .trailing], 8)
                                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
                            }
                        }
                    }
                }
            )
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(Rectangle())
    }
}
 
struct CardItemViewNew: View {
    let item:             ItemModel
    let onLike:           (Bool, Int) -> Void
    let onTap:            () -> Void
    let onTapBoostButton: () -> Void
    var isToShowBoostButton = true
    var imageRatio: CGFloat = 1.2
 
    var body: some View {
        if item.boardType == 1 {
            PromotionalAdsCardStaggeredNew(product: item, onTapBottomtButton: onTapBoostButton)
        } else if item.boardType == 3 {
            IdeaCardStaggeredNew(product: item).onTapGesture(perform: onTap)
        } else {
            ProductCardStaggeredNew(
                product: item,
                sendLikeUnlikeObject: onLike,
                onTapBoostButton: onTapBoostButton,
                isToShowBoostButton: isToShowBoostButton
            )
            .onTapGesture(perform: onTap)
        }
    }
}
 
 
struct PromotionalAdsCardStaggeredNew: View {

    let product: ItemModel
    let onTapBottomtButton: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            ZStack(alignment: .topTrailing) {
                KFImage(URL(string: product.image ?? ""))
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(
                            width: (UIScreen.main.bounds.width / 2 - 10),
                            height: 380
                        ))
                    )
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage(false)
                    .memoryCacheExpiration(.seconds(120))
                    .fade(duration: 0.15)
                    .resizable()
                    .scaledToFill()              //  was .scaledToFit() — fills assigned height
                    .clipped()                   //  crops overflow
                    .shadow(color: Color.black.opacity(0.10), radius: 7, x: 0, y: 2)
            }
            .frame(maxWidth: columnWidth)  //  fixed width, min height
            .frame(maxHeight:.infinity)
            .layoutPriority(1)                           //  takes all extra height first

            // CTA bar — fixed height, never stretches
            HStack {
                Text(product.ctaLabel ?? "Learn more")
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .renderingMode(.template)
                    .foregroundColor(.primary)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 10)
            .frame(height: 35)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
            .onTapGesture {
                onTapBottomtButton()
                outboundClickApi()
            }
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle())
    }

    func outboundClickApi() {
        let params = ["board_id": product.id ?? 0]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.board_outbond_click,
            param: params,
            methodType: .post
        ) { responseObject, error in
            if error == nil {
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                if status == 200 { }
            }
        }
    }
}
struct HorizontalBannerCard: View {
    let product:     ItemModel
    let onTapButton: () -> Void
 
    var body: some View {
        KFImage(URL(string: product.banner?.image ?? "")).onSuccess { result in
           
        }
            .scaleFactor(UIScreen.main.scale)
            .cacheOriginalImage(false)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 220)
            .clipped()
            .shadow(color: .black.opacity(0.10), radius: 7, x: 0, y: 2)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture {
                onTapButton()
                outboundClickApi()
            }
    }
 
    private func outboundClickApi() {
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.board_outbond_click,
            param: ["board_id": product.id ?? 0],
            methodType: .post
        ) { responseObject, error in
            guard error == nil,
                  let result = responseObject as? NSDictionary,
                  (result["code"] as? Int) == 200 else { return }
        }
    }
}
 
 
struct ImageRatioKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}



//////// *************************OLD CODE ************************************************///

//struct BoardListViewNew: View {
//    let tabBarController: UITabBarController?
//    @ObservedObject var vm: BoardViewModelNew
//    let navigationController: UINavigationController?
//    @State private var userDidScroll = false  //  User intent + safety locks
//    @State private var paginationConsumed = false
//    @State private var itemHeights: [Int: CGFloat] = [:] //  Measured heights for staggered layout
//    @State private var lastItemCount: Int = 0
//    @State private var scrollTick: Int = 0
//    @State private var lastScrollTick: Int = 0
//    private let prefetchOffset = 4   //  call API before 4 items
//    @State private var paymentGateway: PaymentGatewayCentralized?
//    @State private var videoFrames: [Int: CGRect] = [:]
//    @State private var visibilityWorkItem: DispatchWorkItem?
//    let isActive: Bool   //  ADD THIS
//    @State private var safariURL: URL?
//
//    private func leftColumnHeight(_ columns: (left: [ItemModel], right: [ItemModel])) -> CGFloat {
//        columns.left.reduce(0) { $0 + (itemHeights[$1.id ?? 0] ?? 200) + 6 }
//    }
//
//    private func rightColumnHeight(_ columns: (left: [ItemModel], right: [ItemModel])) -> CGFloat {
//        columns.right.reduce(0) { $0 + (itemHeights[$1.id ?? 0] ?? 200) + 6 }
//    }
//    // MARK: - Banner detection
//    // Change boardType == 4 to whatever value your API uses for full-width banners.
//    private func isBanner(_ item: ItemModel) -> Bool {
//        item.boardType == 4
//    }
//
//    // MARK: - Build segments
//    // Splits vm.items into an ordered list of segments:
//    //   • Every banner item becomes its own .banner segment (full width).
//    //   • Consecutive non-banner items are grouped into a .staggeredChunk
//    //     that gets rendered with the original two-LazyVStack Pinterest layout.
//    private func buildSegments() -> [FeedSegment] {
//        var segments: [FeedSegment] = []
//        var currentChunk: [ItemModel] = []
//
//        for item in vm.items {
//            if isBanner(item) {
//                // Flush any accumulated non-banner items first
//                if !currentChunk.isEmpty {
//                    segments.append(.staggeredChunk(currentChunk))
//                    currentChunk = []
//                }
//                segments.append(.banner(item))
//            } else {
//                currentChunk.append(item)
//            }
//        }
//        // Flush remaining non-banner items
//        if !currentChunk.isEmpty {
//            segments.append(.staggeredChunk(currentChunk))
//        }
//
//        return segments
//    }
//
//    // MARK: - Split a chunk into two staggered columns (original logic, unchanged)
//    private func splitColumns(items: [ItemModel]) -> (left: [ItemModel], right: [ItemModel]) {
//
//        var left: [ItemModel] = []
//        var right: [ItemModel] = []
//
//        var leftHeight: CGFloat = 0
//        var rightHeight: CGFloat = 0
//
//        for item in items {
//            let h = itemHeights[item.id ?? 0] ?? 200
//
//            if leftHeight <= rightHeight {
//                left.append(item)
//                leftHeight += h
//            } else {
//                right.append(item)
//                rightHeight += h
//            }
//        }
//
//        return (left, right)
//    }
//
//    var body: some View {
//
//        ScrollViewReader { proxy in
//            ScrollView {
//                Color.clear
//                    .frame(height: 0)
//                    .id("TOP")
//                    .overlay(
//                        GeometryReader { geo in
//                            Color.clear
//                                .onChange(of: geo.frame(in: .global).minY) { _ in
//                                    scrollTick += 1
//                                }
//                        }
//                    )
//
//                if vm.items.isEmpty && !vm.isLoading && vm.hasLoadedOnce {
//                    emptyView.padding(.top, 100)
//
//                } else {
//
//                    // MARK: - Outer LazyVStack: one entry per segment
//                    // Each segment is either a full-width banner or a staggered chunk.
//                    LazyVStack(spacing: 6) {
//                        ForEach(buildSegments()) { segment in
//                            switch segment {
//
//                            // ── Full-width banner ──────────────────────────────
//                            case .banner(let item):
//                                HorizontalBannerCard(product: item) {
//                                       // tap action
//                                   }
//                                   .padding(.horizontal, 5)
//                                   .padding(.top, -6) // ← ADD THIS to pull banner up, closing gap
//
//                            // ── Staggered Pinterest chunk ──────────────────────
//                            // This is EXACTLY your original two-LazyVStack layout,
//                            // just scoped to the non-banner items in this chunk.
//                            case .staggeredChunk(let chunkItems):
//                                let columns = splitColumns(items: chunkItems)
//
//                                HStack(alignment: .top, spacing: 6) {
//
//                                    // LEFT COLUMN
//                                    LazyVStack(spacing: 6) {
//                                        ForEach(columns.left, id: \.id) { item in
//                                            if item.boardType == 2 {
//                                                SmartVideoPlayerView(
//                                                    item: item,
//                                                    onTapBottomButton: {
//                                                        if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
//                                                            safariURL = url
//                                                            FeedVideoManager.shared.muteAll()
//                                                        }
//                                                    }
//                                                ).background(
//                                                    GeometryReader { geo in
//                                                        Color.clear
//                                                            .onAppear {
//                                                                videoFrames[item.id ?? 0] = geo.frame(in: .global)
//                                                                scheduleVisibilityUpdate()
//                                                            }
//                                                            .onChange(of: geo.frame(in: .global)) { frame in
//                                                                videoFrames[item.id ?? 0] = frame
//                                                                scheduleVisibilityUpdate()
//                                                            }
//                                                    }
//                                                )
//                                                .measureHeight(id: item.id ?? 0)
//                                                .onAppear {
//                                                    handlePrefetch(itemIndex: globalIndex(of: item))
//                                                    prefetchNextVideos(from: item)
//                                                }
//                                                .onDisappear {
//                                                    videoFrames.removeValue(forKey: item.id ?? 0)
//                                                    FeedVideoManager.shared.pause(id: item.id ?? 0)
//                                                }
//                                            } else {
//                                                CardItemView(
//                                                    item: item,
//                                                    onLike: { isLiked, boardId in
//                                                        vm.updateLike(boardId: boardId, isLiked: isLiked)
//                                                    },
//                                                    onTap: { pushToDetail(item: item) },
//                                                    onTapBoostButton: {
//                                                        if item.boardType == 1 {
//                                                            if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
//                                                                safariURL = url
//                                                            }
//                                                        } else {
//                                                            paymentGatewayOpen(product: item)
//                                                        }
//                                                    },
//                                                    isToShowBoostButton: true
//                                                )
//                                                .measureHeight(id: item.id ?? 0)
//                                                .onAppear {
//                                                    handlePrefetch(itemIndex: globalIndex(of: item))
//                                                }
//                                            }
//                                        }
//                                    }
//
//                                    // RIGHT COLUMN
//                                    LazyVStack(spacing: 6) {
//                                        ForEach(columns.right, id: \.id) { item in
//                                            if item.boardType == 2 {
//                                                SmartVideoPlayerView(
//                                                    item: item,
//                                                    onTapBottomButton: {
//                                                        if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
//                                                            safariURL = url
//                                                            FeedVideoManager.shared.muteAll()
//                                                        }
//                                                    }
//                                                )
//                                                .background(
//                                                    GeometryReader { geo in
//                                                        Color.clear
//                                                            .onAppear {
//                                                                videoFrames[item.id ?? 0] = geo.frame(in: .global)
//                                                                scheduleVisibilityUpdate()
//                                                            }
//                                                            .onChange(of: geo.frame(in: .global)) { frame in
//                                                                videoFrames[item.id ?? 0] = frame
//                                                                scheduleVisibilityUpdate()
//                                                            }
//                                                    }
//                                                )
//                                                .measureHeight(id: item.id ?? 0)
//                                                .onAppear {
//                                                    handlePrefetch(itemIndex: globalIndex(of: item))
//                                                    prefetchNextVideos(from: item)
//                                                }
//                                                .onDisappear {
//                                                    videoFrames.removeValue(forKey: item.id ?? 0)
//                                                    FeedVideoManager.shared.pause(id: item.id ?? 0)
//                                                }
//                                            } else {
//                                                CardItemView(
//                                                    item: item,
//                                                    onLike: { isLiked, boardId in
//                                                        vm.updateLike(boardId: boardId, isLiked: isLiked)
//                                                    },
//                                                    onTap: { pushToDetail(item: item) },
//                                                    onTapBoostButton: {
//                                                        if item.boardType == 1 {
//                                                            if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
//                                                                safariURL = url
//                                                            }
//                                                        } else {
//                                                            paymentGatewayOpen(product: item)
//                                                        }
//                                                    },
//                                                    isToShowBoostButton: true
//                                                )
//                                                .measureHeight(id: item.id ?? 0)
//                                                .onAppear {
//                                                    handlePrefetch(itemIndex: globalIndex(of: item))
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                                .padding(.horizontal, 5)
//                            }
//                        }
//                    }
//                }
//
//                if vm.isLoading {
//                    ProgressView().padding(.vertical, 12)
//                }
//            }
//            //.ignoresSafeArea(.container, edges: [.bottom, .top])
//
//            .padding(.bottom, tabBarController?.tabBar.frame.height ?? 83)
//            .ignoresSafeArea(edges: .bottom)
//
//            .onDisappear {
//                FeedVideoManager.shared.pauseAll()
//            }
//            //  Detect REAL user scroll
//            .simultaneousGesture(
//                DragGesture()
//                    .onEnded { _ in
//                        userDidScroll = true
//                        paginationConsumed = false
//                        scheduleVisibilityUpdate()
//                    }
//            )
//            .onChange(of: vm.items.count) { _ in
//                paginationConsumed = false
//            }
//            .refreshable {
//                await vm.refresh()
//                userDidScroll = false
//                paginationConsumed = false
//                itemHeights.removeAll()
//
//                // ADD
//                lastItemCount = 0
//                lastScrollTick = scrollTick
//
//                FeedVideoManager.shared.reset()
//                videoFrames.removeAll()
//            }
//            .task {
//                if vm.items.isEmpty {
//                    vm.loadIfNeeded()
//                }
//            }
//            .onReceive(
//                NotificationCenter.default.publisher(
//                    for: Notification.Name(NotificationKeys.refreshLikeDislikeBoard.rawValue)
//                )
//            ) { notification in
//                guard let dict = notification.object as? [String: Any] else { return }
//                let isLike  = dict["isLike"] as? Bool ?? false
//                let count   = dict["count"] as? Int ?? 0
//                let boardId = dict["boardId"] as? Int ?? 0
//                vm.update(likeCount: count, isLike: isLike, boardId: boardId)
//            }
//            .onReceive(
//                NotificationCenter.default.publisher(
//                    for: Notification.Name(NotificationKeys.refreshCommentCountBoard.rawValue)
//                )
//            ) { notification in
//                guard let dict = notification.object as? [String: Any] else { return }
//                let count   = dict["count"] as? Int ?? 0
//                let boardId = dict["boardId"] as? Int ?? 0
//                if let commentObj = dict["lastComment"] as? CommentModel {
//                    vm.updateCommentCount(commentCount: count, commentObj: commentObj, boardId: boardId)
//                } else {
//                    vm.updateCommentCount(commentCount: count, commentObj: nil, boardId: boardId)
//                }
//            }
//            .onReceive(
//                NotificationCenter.default.publisher(
//                    for: Notification.Name(NotificationKeys.scrollBoardToTop)
//                )
//            ) { _ in
//                withAnimation(.easeInOut) {
//                    proxy.scrollTo("TOP", anchor: .top)
//                }
//            }
//            .onReceive(
//                NotificationCenter.default.publisher(
//                    for: Notification.Name(NotificationKeys.boardBoostedRefresh.rawValue)
//                )
//            ) { notification in
//                guard let dict = notification.object as? [String: Any] else { return }
//                let boardId = dict["boardId"] as? Int ?? 0
//                vm.updateBoost(isBoosted: true, boardId: boardId)
//            }
//            .onChange(of: isActive) { active in
//                if !active {
//                    FeedVideoManager.shared.pauseAll()
//                }
//            }
//            //  Capture measured heights
//            .onPreferenceChange(ItemHeightKey.self) { value in
//                itemHeights.merge(value) { $1 }
//            }
//            .onReceive(
//                NotificationCenter.default.publisher(
//                    for: NSNotification.Name(NotificationKeys.refreshMyBoardsScreen.rawValue)
//                )
//            ) { _ in
//                Task {
//                    await vm.refresh()
//                    userDidScroll = false
//                    paginationConsumed = false
//                    itemHeights.removeAll()
//
//                    // ADD
//                    lastItemCount = 0
//                    lastScrollTick = scrollTick
//
//                    FeedVideoManager.shared.reset()
//                    videoFrames.removeAll()
//                }
//            }
//            .fullScreenCover(item: $safariURL) { url in
//                SafariView(url: url)
//            }
//        }
//    }
//
//    // MARK: - Banner item view (NEW — full-width, any boardType you flag as banner)
//    @ViewBuilder
//    private func bannerItemView(item: ItemModel) -> some View {
//        CardItemView(
//            item: item,
//            onLike: { isLiked, boardId in
//                vm.updateLike(boardId: boardId, isLiked: isLiked)
//            },
//            onTap: { pushToDetail(item: item) },
//            onTapBoostButton: {
//                if let url = URL(string: (item.outbondUrl ?? "").getValidUrl()) {
//                    safariURL = url
//                }
//            },
//            isToShowBoostButton: false
//        )
//        .frame(maxWidth: .infinity)
//        .measureHeight(id: item.id ?? 0)
//        .onAppear {
//            handlePrefetch(itemIndex: globalIndex(of: item))
//        }
//    }
//
//    // MARK: - Prefetch Next Videos
//    private func prefetchNextVideos(from currentItem: ItemModel) {
//
//        guard let index = vm.items.firstIndex(where: { $0.id == currentItem.id }) else { return }
//
//        let start = index + 1
//        let end = min(index + 2, vm.items.count - 1)
//
//        guard start <= end else { return }
//
//        var urls: [URL] = []
//
//        for i in start...end {
//            let item = vm.items[i]
//            if item.boardType == 2,
//               let link = item.videoLink,
//               let url = URL(string: link) {
//                urls.append(url)
//            }
//        }
//
//        VideoPreloadManagerDefault.shared.set(waiting: urls)
//    }
//
//    private func scheduleVisibilityUpdate() {
//        visibilityWorkItem?.cancel()
//        let work = DispatchWorkItem {
//            calculateVisibleVideos()
//        }
//        visibilityWorkItem = work
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
//    }
//
//    private func calculateVisibleVideos() {
//        guard isActive else {
//            FeedVideoManager.shared.pauseAll()
//            return
//        }
//
//        let screenHeight = UIScreen.main.bounds.height
//        var visibleSet: Set<Int> = []
//
//        for (id, frame) in videoFrames {
//            if frame.maxY <= 0 || frame.minY >= screenHeight { continue }
//
//            let visibleHeight =
//                min(frame.maxY, screenHeight)
//                - max(frame.minY, 0)
//
//            let percent = visibleHeight / frame.height
//
//            if percent >= 0.6 {
//                visibleSet.insert(id)
//            }
//        }
//
//        FeedVideoManager.shared.updatePlayback(visibleIDs: visibleSet)
//    }
//
//    func paymentGatewayOpen(product: ItemModel) {
//
//        paymentGateway = PaymentGatewayCentralized()
//        paymentGateway?.selectedPlanId = product.package?.id ?? 0
//        paymentGateway?.categoryId = product.categoryID ?? 0
//        paymentGateway?.itemId = product.id ?? 0
//        paymentGateway?.paymentFor = .boostBoard
//        paymentGateway?.selIOSProductID = product.package?.iosProductID ?? ""
//
//        paymentGateway?.callbackPaymentSuccess = { (isSuccess) in
//            if isSuccess {
//                let vc = UIHostingController(
//                    rootView: PlanBoughtSuccessView(
//                        navigationController: navigationController
//                    )
//                )
//                vc.modalPresentationStyle = .overFullScreen
//                vc.modalTransitionStyle = .crossDissolve
//                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//                navigationController?.present(vc, animated: true)
//
//                NotificationCenter.default.post(
//                    name: NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue),
//                    object: ["boardId": product.id ?? 0],
//                    userInfo: nil
//                )
//            }
//            self.paymentGateway = nil
//        }
//
//        paymentGateway?.initializeDefaults()
//    }
//
//    // MARK: - Prefetch Logic (FINAL & SAFE)
//    private func handlePrefetch(itemIndex: Int?) {
//
//        guard let index = itemIndex else { return }
//
//        let triggerIndex = max(vm.items.count - prefetchOffset, 0)
//
//        // 1️⃣ Near bottom
//        guard index >= triggerIndex else { return }
//
//        // 2️⃣ Real scroll happened (works on all devices)
//        guard scrollTick > lastScrollTick else { return }
//
//        // 3️⃣ Prevent re-trigger for same data set
//        guard vm.items.count > lastItemCount else { return }
//
//        // 4️⃣ Safety guards
//        guard !vm.isLoading else { return }
//        guard !vm.isLastPage else { return }
//
//        paginationConsumed = true
//        userDidScroll = false
//
//        lastItemCount = vm.items.count
//        lastScrollTick = scrollTick
//
//        vm.tryLoadNextPage()
//    }
//
//    private func globalIndex(of item: ItemModel) -> Int? {
//        vm.items.firstIndex { $0.id == item.id }
//    }
//
//    // MARK: - Empty View
//    private var emptyView: some View {
//        VStack(spacing: 20) {
//            Image("no_data_found_illustrator")
//            Text("No Data Found")
//                .foregroundColor(.orange)
//        }
//    }
//
//    // MARK: - Navigation
//    private func pushToDetail(item: ItemModel) {
//        let vc = UIHostingController(
//            rootView: BoardDetailView(
//                navigationController: navigationController,
//                itemObj: item
//            )
//        )
//        vc.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}

