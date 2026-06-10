//
//  BoardHomeView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/04/26.
//

import SwiftUI
import Kingfisher
import AVKit
import FittedSheets

//MARK: - BoardHomeView

struct BoardHomeView: View {

    @State private var selectedCategoryId: Int = 55555
    @State private var selectedName: String = "All"
    let tabBarController: UITabBarController?
    @StateObject private var categoryVM = CategoryViewModelOptimized(type: 2, isToShowLoader: false)
    @StateObject private var boardStore = BoardStoreNew()
    @State private var loadedCategoryIds: [Int] = [55555]
    private let maxLoadedTabs = 3
    @State private var isUpdatedEvents: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .background(Color(.systemBackground))

            CategoryTabsOtimized(
                selected: $selectedName,
                selectedCategoryId: $selectedCategoryId,
                categoryVM: categoryVM
            )
            .background(Color(.systemBackground))

            //  FIX 4: selectedCategoryId is 55555 from the start, so
            // tabContentView renders immediately without waiting for the API.
            if selectedCategoryId > 0 {
                tabContentView
            } else {
                HStack { Spacer() }.frame(height: 30).padding()
                PinterestSkeletonGrid().padding(.top, 5)
            }
        }
        //  FIX 5: Kick off the "All" feed load as early as possible —
        // before the category API even returns.
//        .task {
//            markTabLoaded(55555)
//            prefetchNeighbours(of: 55555)
//        }
      .onChange(of: selectedCategoryId) { newId in
            FeedVideoManager.shared.pauseAll()
            FeedVideoManager.shared.muteAll()
            markTabLoaded(newId)
            prefetchNeighbours(of: newId)
        }
        .onAppear {
            if isUpdatedEvents {
                updateEvents()
                isUpdatedEvents = false
            }
        }
        .background(Color(.systemGray6))
        .onDisappear { FeedVideoManager.shared.muteAll() }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.refreshInterestChangeBoardScreen.rawValue)
            )
        ) { _ in handleInterestRefresh() }
    }

    // Rest of the view is unchanged...
    @ViewBuilder
    private var tabContentView: some View {
        let boardNav = tabBarController?.viewControllers?[0] as? UINavigationController

        ZStack {
            ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                let catId = cat.id ?? 0
                if loadedCategoryIds.contains(catId) {
                    BoardListViewNew(
                        tabBarController: tabBarController,
                        vm: boardStore.vm(for: catId),
                        navigationController: boardNav,
                        isActive: selectedCategoryId == catId
                    )
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

    private func markTabLoaded(_ id: Int) {
        guard id > 0 else { return }
        if let idx = loadedCategoryIds.firstIndex(of: id) {
            loadedCategoryIds.remove(at: idx)
            loadedCategoryIds.insert(id, at: 0)
            return
        }
        while loadedCategoryIds.count >= maxLoadedTabs {
            let evictId = loadedCategoryIds.removeLast()
            boardStore.evict(id: evictId)
            ImageCache.default.clearMemoryCache()
        }
        loadedCategoryIds.insert(id, at: 0)
    }

    private func prefetchNeighbours(of id: Int) {
        guard let list = categoryVM.listArray,
              let idx = list.firstIndex(where: { $0.id == id }) else { return }
        if idx > 0 {
            let leftId = list[idx - 1].id ?? 0
            if !loadedCategoryIds.contains(leftId) { markTabLoaded(leftId) }
        }
        if idx < list.count - 1 {
            let rightId = list[idx + 1].id ?? 0
            if !loadedCategoryIds.contains(rightId) { markTabLoaded(rightId) }
        }
    }

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
            selectedName = newCat.name ?? ""
        }
    }

    func updateEvents() {
        Task.detached(priority: .utility) {
            await FaceBookAppEvents.facebookEvents(type: .board, categoryName: selectedName)
        }
        Task.detached(priority: .background) {
            SocketIOManager.sharedInstance.checkSocketStatus()
        }
        
        if Local.shared.getUserId() > 0{
            getpopupApi()
        }
    }
}



extension BoardHomeView{
    
    //MARK: Api methods
    func getpopupApi(){

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: Constant.shared.alert_popup) { (obj:PopupParseModel) in
            
            if obj.code == 200,obj.error == false{
                
                /*
                 // =========== If any add in Draft message will get popped up to Buy Plans ===========
                 $type = 1;
                 // =========== If user has Free Approved Add then pop up message to Buy  Plan ===========
                 $type = 2;
                 
                 // =========== If user has Paid Ad from Listing Plan then Pop up message to Boost Plan ===========
                 $type = 3;
                 
                 // =========== If User has just registered and not posted any ad than Pop up message to Run Ad  ===========
                 $type = 4;
                 */
                
                if (obj.data.type ?? 0) == 0{
                    DispatchQueue.main.async {
                        if let destVc = StoryBoard.preLogin.instantiateViewController(withIdentifier: "PopupVC") as? PopupVC{
                            destVc.objPopup = obj.data
                            destVc.modalPresentationStyle = .overFullScreen
                            destVc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                            destVc.modalPresentationStyle = .overCurrentContext
                            destVc.modalTransitionStyle = .coverVertical
                            AppDelegate.sharedInstance.navigationController?.present(destVc, animated: false)
                        }
                    }
                /*  } else if (obj.data.type ?? 0) == 1 || (obj.data.type ?? 0) == 2 || (obj.data.type ?? 0) == 3  || (obj.data.type ?? 0) == 4 || (obj.data.type ?? 0) == 5 {
                     self?.presentHostingController(objPopup: obj.data)
                    */
                }else if (obj.data.type ?? 0) == 5{
                    self.presentHostingController(objPopup: obj.data)
                
                }else if (obj.data.type ?? 0) == 6{
                    //Boost board
                    self.showBoostYourBoardPopup(obj: obj.data)
                    
                }
            }
        }
    }
    
    
    func presentHostingController(objPopup:PopupModel){
        
        let controller = UIHostingController(
            rootView: BottomSheetPopupView(objPopup: objPopup,pushToScreenFromPopup: {  (obj,dismissOnly) in }))
        
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.intrinsic],
            options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: true))
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 15
        sheet.dismissOnPull = false
       // sheet.gripColor = Color.clear
        
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 15
        sheet.dismissOnOverlayTap = true
        sheet.dismissOnPull = false
        //sheet.gripColor = Color.clear
        
        if (objPopup.mandatoryClick ?? false){
            
            sheet.dismissOnOverlayTap = false
            sheet.dismissOnPull = false
            sheet.allowPullingPastMaxHeight = false
            sheet.allowPullingPastMinHeight = false
            sheet.shouldRecognizePanGestureWithUIControls = false
            sheet.sheetViewController?.shouldRecognizePanGestureWithUIControls = false
            sheet.sheetViewController?.allowGestureThroughOverlay = false
            sheet.sheetViewController?.dismissOnPull = false
            sheet.allowPullingPastMinHeight = false
        }
        let boardNav = tabBarController?.viewControllers?[0] as? UINavigationController

        let settingView =  BottomSheetPopupView(objPopup: objPopup,pushToScreenFromPopup: {  (obj,dismissOnly) in
            
            if sheet.options.useInlineMode == true {
                sheet.attemptDismiss(animated: true)
            } else {
                sheet.dismiss(animated: true, completion: nil)
            }
            
            
            if dismissOnly{
                
            }else{
               if (obj.type ?? 0) == 5  {
                    //5 banner promotion
                    let destVC = UIHostingController(rootView:  BannerPromotionsView(navigationController: boardNav))
                    destVC.hidesBottomBarWhenPushed = true
                   boardNav?.pushViewController(destVC, animated: true)
                    
                }else if (obj.type ?? 0) == 6  {
                    //Boost board
                    
                }
            }
        })
        
        
        controller.rootView = settingView
        
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {

            boardNav?.present(sheet, animated: true, completion: nil)
        }
        
    }
    
    
    func showBoostYourBoardPopup(obj:PopupModel) {
        let boardNav = tabBarController?.viewControllers?[0] as? UINavigationController

        let popupView = BoostYourBoardPopupView(
            onBoost: {
                print("Boost tapped")
                boardNav?.dismiss(animated: true)
                
                if (obj.itemID ?? 0) > 0{
                    let destVC = UIHostingController(rootView: BoardAnalyticsView(navigationController: boardNav, boardId: obj.itemID ?? 0,isFromBoostPopup: true))
                    destVC.hidesBottomBarWhenPushed = true
                    boardNav?.pushViewController(destVC, animated: true)
                }else{
                    let destVC = UIHostingController(rootView: MyBoardsView(navigationController: boardNav))
                    destVC.hidesBottomBarWhenPushed = true
                    boardNav?.pushViewController(destVC, animated: true)
                }
            },
            onLater: {
                print("Later tapped")
                boardNav?.dismiss(animated: true)
                
            },
            onClose: {
                boardNav?.dismiss(animated: true)
            },
            objPopup:obj
        )
        
        let hostingVC = UIHostingController(rootView: popupView)
        hostingVC.modalPresentationStyle = .overFullScreen
        hostingVC.view.backgroundColor = .clear
        boardNav?.present(hostingVC, animated: false)
    }
    
    
}

//MARK: - Extension BoardHomeView
extension BoardHomeView {
    
    var headerView: some View {
        HStack {
            Image("Logo").resizable().aspectRatio(contentMode: .fit)
                .frame(width: 140,height: 50)
            Spacer()
            interestButton
        }
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
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

//MARK: - Category Optimized
struct CategoryTabsOtimized: View {

    @Binding var selected: String
    @Binding var selectedCategoryId: Int
    @ObservedObject var categoryVM: CategoryViewModelOptimized
    @Environment(\.scrollToTopProxy) private var scrollToTopProxy
    @State private var categoryScrollProxy: ScrollViewProxy?

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
                    .padding(.top, 8)
                }
                .onAppear {
                    categoryScrollProxy = proxy
                    //  Scroll to the already-selected "All" tab on first appear
                    // (proxy is ready now; selectedCategoryId is already 55555)
                    scrollCategoryToCenter(selectedCategoryId, proxy: proxy)
                }
            }
            Divider()
        }
        //  When the full category list arrives from the API, just scroll to
        // the current selection — no list mutation, no ID reset needed.
        .onChange(of: categoryVM.listArray?.count) { _ in
            scrollCategoryToCenter(selectedCategoryId)
        }
        // Keeps the tab bar in sync when the parent changes the selection
        // (e.g. swipe gesture in BoardHomeView)
        .onChange(of: selectedCategoryId) { newId in
            scrollCategoryToCenter(newId)
        }
    }

    // MARK: - Actions

    private func selectCategory(_ cat: CategoryModel, proxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            selectedCategoryId = cat.id ?? 0
            selected = cat.name ?? ""
            proxy.scrollTo(cat.id, anchor: .center)
            scrollToTopProxy?.scrollTo("TOP", anchor: .top)
        }
    }

    // Overload used by onChange (proxy captured in state)
    private func scrollCategoryToCenter(_ id: Int) {
        guard let proxy = categoryScrollProxy else { return }
        scrollCategoryToCenter(id, proxy: proxy)
    }

    private func scrollCategoryToCenter(_ id: Int, proxy: ScrollViewProxy) {
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
                .foregroundColor(isSelected ? .primary : .secondary) //  visual clarity
            Rectangle()
                .fill(isSelected ? Color.orange : .clear)
                .frame(height: 3)
        }
        .contentShape(Rectangle())
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
                    
                }else if vm.items.isEmpty && !vm.isLoading && vm.hasLoadedOnce {
                    emptyView.padding(.top, 100)
                    
                } else {

                    PinterestMasonryFeed(
                        items: vm.items,
                        spacing: 8,
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
    case staggeredChunk([ItemModel]) // always non-banner items only

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

//MARK: PinterestMasonryFeed

struct PinterestMasonryFeed<ItemContent: View>: View {

    let items: [ItemModel]
    var spacing: CGFloat = 8

    let itemView: (ItemModel) -> ItemContent
    let onLastItemAppear: () -> Void
    let onOpenURL: (URL) -> Void

    @State private var lastTriggeredItemId: Int?

    private let paginationThreshold = 6
    private let chunkSize = 10

    // MARK: - Segment

    private enum Segment: Identifiable {
        case chunk([ItemModel])
        case banner(ItemModel)

        var id: String {
            switch self {
            case .chunk(let items):
                return "chunk-\(items.first?.id ?? 0)-\(items.last?.id ?? 0)"

            case .banner(let item):
                return "banner-\(item.id ?? 0)"
            }
        }
    }

    // MARK: - Build Segments

    private var segments: [Segment] {

        var result: [Segment] = []
        var buffer: [ItemModel] = []

        func flush() {
            guard !buffer.isEmpty else { return }

            var index = 0

            while index < buffer.count {

                let end = min(index + chunkSize, buffer.count)

                result.append(
                    .chunk(Array(buffer[index..<end]))
                )

                index += chunkSize
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
                        .onAppear {
                            checkPagination(item)
                        }

                case .chunk(let chunkItems):

                    
                   /* TwoColumnMasonryLayout(
                        spacing: spacing,
                        shouldEqualizeBottom: true
                    ) {

                        ForEach(chunkItems, id: \.id) { item in

                            itemView(item)
                                .onAppear {
                                    checkPagination(item)
                                }
                        }
                    }*/
                    
                    TwoColumnMasonryLayout(
                        items: chunkItems,
                        spacing: spacing,
                        shouldEqualizeBottom: true
                    ) {
                        ForEach(chunkItems, id: \.id) { item in
                            itemView(item)
                                .onAppear {
                                    checkPagination(item)
                                }
                        }
                    }
                }
            }

            // Backup pagination trigger
            Color.clear
                .frame(height: 1)
                .id("bottom-\(items.count)")
                .onAppear {

                    guard items.count >= paginationThreshold else {
                        return
                    }

                    onLastItemAppear()
                }
        }
        .onChange(of: items.count) { _ in
            lastTriggeredItemId = nil
        }
    }

    // MARK: - Pagination

    private func checkPagination(_ item: ItemModel) {

        guard let itemId = item.id else {
            return
        }

        guard let currentIndex = items.firstIndex(where: {
            $0.id == itemId
        }) else {
            return
        }

        let triggerIndex = max(
            items.count - paginationThreshold,
            0
        )

        guard currentIndex >= triggerIndex else {
            return
        }

        guard lastTriggeredItemId != itemId else {
            return
        }

        lastTriggeredItemId = itemId

        DispatchQueue.main.async {
            onLastItemAppear()
        }
    }

    // MARK: - Banner

    @ViewBuilder
    private func bannerView(item: ItemModel) -> some View {

        if item.boardType == 5 {

            BoardVideoBannerCard(product: item) { url in
                onOpenURL(url)
            }

        } else {

            BoardBannerCard(product: item) { url in
                onOpenURL(url)
            }
        }
    }
}

//MARK: - TwoColumnMasonryLayout
struct TwoColumnMasonryLayout: Layout {

    let items: [ItemModel]
    var spacing: CGFloat = 8
    var shouldEqualizeBottom: Bool = true

    private static let screenWidth = UIScreen.main.bounds.width

    struct CacheData {
        var frames: [CGRect] = []
        var size: CGSize = .zero
    }

    func makeCache(subviews: Subviews) -> CacheData {
        CacheData()
    }
/*
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {

        let totalWidth = proposal.width ?? Self.screenWidth
        let columnWidth = (totalWidth - spacing) / 2

        var frames = Array(
            repeating: CGRect.zero,
            count: subviews.count
        )

        var columnHeights: [CGFloat] = [0, 0]
        var lastInColumn: [Int?] = [nil, nil]

        for index in subviews.indices {

            let column = columnHeights[0] <= columnHeights[1] ? 0 : 1

            let size = subviews[index].sizeThatFits(
                ProposedViewSize(
                    width: columnWidth,
                    height: nil
                )
            )

            let x = column == 0
                ? 0
                : columnWidth + spacing

            let y = columnHeights[column]

            frames[index] = CGRect(
                x: x,
                y: y,
                width: columnWidth,
                height: size.height
            )

            columnHeights[column] += size.height + spacing
            lastInColumn[column] = index
        }

        let leftHeight = max(
            columnHeights[0] - spacing,
            0
        )

        let rightHeight = max(
            columnHeights[1] - spacing,
            0
        )

        let maxHeight = max(
            leftHeight,
            rightHeight
        )

       
        if shouldEqualizeBottom {

            let leftIndex = lastInColumn[0]
            let rightIndex = lastInColumn[1]

            let leftIsVideo: Bool = {
                guard let idx = leftIndex,
                      idx < items.count else {
                    return false
                }

                return items[idx].boardType == 2
            }()

            let rightIsVideo: Bool = {
                guard let idx = rightIndex,
                      idx < items.count else {
                    return false
                }

                return items[idx].boardType == 2
            }()

            if leftHeight < rightHeight {

                let diff = rightHeight - leftHeight

                if leftIsVideo {

                    // Keep video fixed.
                    // Don't stretch anything.
                }
                else if let idx = leftIndex {

                    frames[idx].size.height += diff
                }

            } else if rightHeight < leftHeight {

                let diff = leftHeight - rightHeight

                if rightIsVideo {

                    // Keep video fixed.
                    // Don't stretch anything.
                }
                else if let idx = rightIndex {

                    frames[idx].size.height += diff
                }
            }
        }

        cache.frames = frames
        cache.size = CGSize(
            width: totalWidth,
            height: maxHeight
        )

        return cache.size
    }
*/
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {

        let totalWidth = proposal.width ?? Self.screenWidth
        let columnWidth = (totalWidth - spacing) / 2

        var frames = Array(repeating: CGRect.zero, count: subviews.count)
        var columnHeights: [CGFloat] = [0, 0]
        var lastInColumn: [Int?] = [nil, nil]

        for index in subviews.indices {
            
            // ✅ Strict alternation: 0,1,0,1...
            let column = index % 2

            let size = subviews[index].sizeThatFits(
                ProposedViewSize(width: columnWidth, height: nil)
            )

            let x = column == 0 ? 0 : columnWidth + spacing
            let y = columnHeights[column]

            frames[index] = CGRect(x: x, y: y, width: columnWidth, height: size.height)

            columnHeights[column] += size.height + spacing
            lastInColumn[column] = index
        }

        let leftHeight  = max(columnHeights[0] - spacing, 0)
        let rightHeight = max(columnHeights[1] - spacing, 0)
        let maxHeight   = max(leftHeight, rightHeight)

        // ✅ Equalize bottom - but now it's always a small diff since columns are balanced
        if shouldEqualizeBottom {
//            let leftIsVideo: Bool = {
//                return false
//                guard let idx = lastInColumn[0], idx < items.count else { return false }
//                return items[idx].boardType == 2
//            }()
//
//            let rightIsVideo: Bool = {
//                return false
//
//                guard let idx = lastInColumn[1], idx < items.count else { return false }
//                return items[idx].boardType == 2
//            }()

            if leftHeight < rightHeight {
                let diff = rightHeight - leftHeight
                if let idx = lastInColumn[0] {
                    frames[idx].size.height += diff
                }
            } else if rightHeight < leftHeight {
                let diff = leftHeight - rightHeight
                if  let idx = lastInColumn[1] {
                    frames[idx].size.height += diff
                }
            }
        }

        cache.frames = frames
        cache.size = CGSize(width: totalWidth, height: maxHeight)
        return cache.size
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) {

        for index in subviews.indices {

            let frame = cache.frames[index]

            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + frame.minX,
                    y: bounds.minY + frame.minY
                ),
                proposal: ProposedViewSize(
                    width: frame.width,
                    height: frame.height
                )
            )
        }
    }
}
/*struct TwoColumnMasonryLayout: Layout {
 
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
*/
/*struct PinterestMasonryFeed<ItemContent: View>: View {

    let items:            [ItemModel]
    var spacing:          CGFloat = 6
    let itemView:         (ItemModel) -> ItemContent
    let onLastItemAppear: () -> Void
    let onOpenURL:        (URL) -> Void

    @State private var lastTriggeredItemId: Int?
    private let paginationThreshold = 8
    private let chunkSize = 10

//MARK: - Segment Model

    private enum Segment: Identifiable {
        case chunk([ItemModel])           //  raw chunk, TwoColumnMasonryLayout handles placement
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
                        shouldEqualizeBottom: true //isBannerNext(after: chunkItems)
                    ) {
                        ForEach(chunkItems, id: \.id) { item in
                            itemView(item)
                                .onAppear {
                                    
                                   //checkPagination(item)
                                }
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
            
        /*   Color.clear.frame(height: 1)
                           // .id("bottom-\(items.count)")  // ✅ id changes with each page load
                            .onAppear {
//                                guard !items.isEmpty else { return }
//                                guard lastTriggeredItemId != -items.count else { return }
//                                lastTriggeredItemId = -items.count  // negative so no clash with item ids
                               // onLastItemAppear()
                            }.layoutPriority(1)*/
        }
        .onChange(of: items.count) { _ in
            lastTriggeredItemId = nil
        }
    }

    // MARK: - Helpers
    private func checkPagination(_ item: ItemModel) {
        
        guard lastTriggeredItemId != item.id else { return }
        guard let currentIndex = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        let thresholdIndex = max(items.count - paginationThreshold, 0)

        
        if currentIndex >= thresholdIndex {
            onLastItemAppear()
        }
    }
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
}*/

private var goldenGradient: LinearGradient {
    LinearGradient(
        colors: [
            Color(red: 248/255, green: 233/255, blue: 143/255),
            Color(red: 231/255, green: 193/255, blue: 71/255),
            Color(red: 214/255, green: 169/255, blue: 27/255)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

//MARK: - BoardBannerCard
struct BoardBannerCard: View {
    
    let product: ItemModel
    let onClickedView:(_ url:URL)->Void
    
    private var isSponsored: Bool {
        product.banner?.isCampaign ?? false
    }
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                KFImage(URL(string: product.banner?.image ?? "")).onSuccess { result in
                    
                }
                .scaleFactor(UIScreen.main.scale)
                .cacheOriginalImage(false)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 190, maxHeight: 250)
                .clipped()
                
                if isSponsored {
                    sponsoredBadge
                        .padding(12)
                }
            }
            
            if isSponsored {
                learnMoreBar
            }
        }
        .background(Color(.systemBackground))
        .clipShape(
            RoundedRectangle(
                cornerRadius: isSponsored ? 12 : 8,
                style: .continuous
            )
        )
        .overlay {
                if isSponsored {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#F7E58D"),
                                        Color(hex: "#D4AF37")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 5
                            )
                    }
            
        }
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        //.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        //.shadow(color: .black.opacity(0.08), radius: 4, y: 2)
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
    private var sponsoredBadge: some View {
        HStack(spacing: 4) {

            Image(systemName: "star.fill")
                .font(.system(size: 8))
                .foregroundColor(.yellow)

            Text("Sponsored")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "#F7E58D"),
                            Color(hex: "#D4AF37")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
    private var learnMoreBar: some View {
      
        HStack {
            Text("Learn more")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "arrow.up.right")
                .foregroundColor(.black)
        }
        .padding(.horizontal, 14)
        .frame(height: 38)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#F7E58D"),
                    Color(hex: "#D4AF37")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .onTapGesture {
            recordOutboundClick()
        }
    }
}


//MARK: - Board Video Banner
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




private let columnWidth: CGFloat = UIScreen.main.bounds.width / 2 - 10
  

//MARK: - CardItemViewNew
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

//MARK: - IdeaCardStaggeredNew
struct IdeaCardStaggeredNew: View {
    
    let product: ItemModel
    private var kfImage: some View {
        let cellular = NetworkCondition.isCellular
        let scale: CGFloat = cellular ? 1.0 : UIScreen.main.scale
        let targetSize = CGSize(
            width:  columnWidth * scale,
            height: columnWidth * scale * 1.3
        )
        return KFImage(URL(string: product.image ?? ""))
            .setProcessor(DownsamplingImageProcessor(size: targetSize))
            .scaleFactor(cellular ? 1.0 : UIScreen.main.scale)
            .cacheOriginalImage(true)
            .memoryCacheExpiration(.seconds(300))
            .diskCacheExpiration(.days(7))
            .placeholder { Color(.systemGray5) }
            .fade(duration: 0.25)          // ← Kingfisher's own fade, not .transition(.fade)
            .resizable()                   // ← must come after all KFImage config modifiers
            .scaledToFill()
            .frame(width: columnWidth)
            .clipped()
    }
    
    var body: some View {
       /* KFImage(URL(string: product.image ?? ""))
            .setProcessor(DownsamplingImageProcessor(
                size: CGSize(width: columnWidth * UIScreen.main.scale,
                             height: columnWidth * UIScreen.main.scale * 1.3)))
            .scaleFactor(1)
            .cacheOriginalImage(false)
            .memoryCacheExpiration(.seconds(120))
            .diskCacheExpiration(.days(3))
            .resizable()
            .scaledToFill()
            .frame(width: columnWidth)
            .clipped()*/
        kfImage.cornerRadius(10)
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
 
//MARK: - ProductCardStaggeredNew
struct ProductCardStaggeredNew: View {

    @State private var showSafari = false
    let product:               ItemModel
    let sendLikeUnlikeObject:  (Bool, Int) -> Void
    let onTapBoostButton:      () -> Void
    var isToShowBoostButton    = true
    
    
    private var kfImage: some View {
        let cellular = NetworkCondition.isCellular
        let scale: CGFloat = cellular ? 1.0 : UIScreen.main.scale
        let targetSize = CGSize(
            width:  columnWidth * scale,
            height: columnWidth * scale * 1.3
        )
        return KFImage(URL(string: product.image ?? ""))
            .setProcessor(DownsamplingImageProcessor(size: targetSize))
            .scaleFactor(cellular ? 1.0 : UIScreen.main.scale)
            .cacheOriginalImage(true)
            .memoryCacheExpiration(.seconds(300))
            .diskCacheExpiration(.days(7))
            .placeholder { Color(.systemGray5) }
            .fade(duration: 0.25)          // ← Kingfisher's own fade, not .transition(.fade)
            .resizable()                   // ← must come after all KFImage config modifiers
            .scaledToFill()
            .frame(width: columnWidth)
            .clipped()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {

            ZStack(alignment: .bottomTrailing) {
              /*  KFImage(URL(string: product.image ?? ""))
                    .setProcessor(DownsamplingImageProcessor(
                        size: CGSize(width: columnWidth * UIScreen.main.scale,
                                     height: columnWidth * UIScreen.main.scale * 1.3)))
            
                    .scaleFactor(1)
                    .cacheOriginalImage(false)
                    .memoryCacheExpiration(.seconds(120))
                    .diskCacheExpiration(.days(3))
                    .resizable()
                    .scaledToFill()
                   .frame(width: columnWidth)
                    .clipped()*/
                kfImage
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
            .layoutPriority(1)
            
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

//MARK: - PromotionalAdsCardStaggeredNew

struct PromotionalAdsCardStaggeredNew: View {

    let product: ItemModel
    let onTapBottomtButton: () -> Void
    
    private var kfImage: some View {
        let cellular = NetworkCondition.isCellular
        let scale: CGFloat = cellular ? 1.0 : UIScreen.main.scale
        let targetSize = CGSize(
            width:  columnWidth * scale,
            height: columnWidth * scale * 1.3
        )
        return KFImage(URL(string: product.image ?? ""))
            .setProcessor(DownsamplingImageProcessor(size: targetSize))
            .scaleFactor(cellular ? 1.0 : UIScreen.main.scale)
            .cacheOriginalImage(true)
            .memoryCacheExpiration(.seconds(300))
            .diskCacheExpiration(.days(7))
            .placeholder { Color(.systemGray5) }
            .fade(duration: 0.25)          // ← Kingfisher's own fade, not .transition(.fade)
            .resizable()                   // ← must come after all KFImage config modifiers
            .scaledToFill()
            .frame(width: columnWidth)
            .clipped()
    }

    var body: some View {
        VStack(spacing: 0) {

            ZStack(alignment: .topTrailing) {
                kfImage
              /*  KFImage(URL(string: product.image ?? ""))
                    .setProcessor(DownsamplingImageProcessor(
                        size: CGSize(width: columnWidth * UIScreen.main.scale,
                                     height: columnWidth * UIScreen.main.scale * 1.3)))
                    .scaleFactor(1)
                    .cacheOriginalImage(false)
                    .memoryCacheExpiration(.seconds(200))
                    .diskCacheExpiration(.days(3))
                    .resizable()
                    .scaledToFill()
                    .frame(width: columnWidth)*/
               
            }
            .frame(maxWidth: columnWidth)
            .frame(maxHeight:.infinity)
            .layoutPriority(1)

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
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2) //  shadow added
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


/*struct BoardHomeView: View {

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
        

            CategoryTabsNew(
                selected: $selectedName,
                selectedCategoryId: $selectedCategoryId,
                categoryVM: categoryVM
            )
            .background(Color(.systemBackground))

            if selectedCategoryId > 0 {
                tabContentView
            } else {
                HStack{Spacer()}.frame(height:30).padding()
                PinterestSkeletonGrid() .padding(.top, 5)
            }
        }
        .onChange(of: selectedCategoryId) { newId in
            FeedVideoManager.shared.pauseAll()
            FeedVideoManager.shared.muteAll()
            markTabLoaded(newId)
            prefetchNeighbours(of: newId)
        }
        .onAppear {
          //  markTabLoaded(selectedCategoryId)
            if isUpdatedEvents{
                updateEvents()
                isUpdatedEvents = true
            }
        }
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
        Task.detached(priority: .utility) {
            await FaceBookAppEvents.facebookEvents(type: .board, categoryName: selectedName)
        }
        
        Task.detached(priority: .background) {
            SocketIOManager.sharedInstance.checkSocketStatus()
        }
    }
}*/
