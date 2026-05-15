//
//  BoardHomeView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/04/26.
//

import SwiftUI
import Kingfisher
import UIKit

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

// MARK: - Segment model
// A "segment" is either a full-width banner item, or a chunk of normal
// (non-banner) items that get rendered as two staggered Pinterest columns.
// This is what lets us keep the original two-LazyVStack stagger while
// still supporting banners that break the columns at any position.

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



// ─────────────────────────────────────────────────────────────────────────────
// MARK: - PinterestMasonryFeed
//
// Segments items at every banner (boardType==4) boundary.
// Each non-banner segment is laid out by TwoColumnMasonryLayout — a custom
// Layout that places items one-by-one into the shorter column, so:
//
//   • Each item keeps its own natural height  → true Pinterest stagger ✓
//   • Container height == taller column only  → banner sits flush, zero gap ✓
//
// Pagination fires via onLastItemAppear on the last non-banner item.
// ─────────────────────────────────────────────────────────────────────────────

struct PinterestMasonryFeed: View {

    let items:            [ItemModel]
    var spacing:          CGFloat = 6
    let itemView:         (ItemModel) -> AnyView
    let onLastItemAppear: () -> Void

    @State private var safariURL: URL?

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
                                safariURL = url
                            })

                        } else {

                            BoardBannerCard(product: item, onClickedView: {url in
                                safariURL = url
                            })
                        }
                    }
                    .frame(maxWidth: .infinity)

                case .columns(let chunkItems):

                    TwoColumnMasonryLayout(spacing: spacing) {

                        ForEach(chunkItems, id: \.id) { item in
                            itemView(item)
                        }
                    }
                }
            }

            // Pagination trigger
            Color.clear
                .frame(height: 1)
                .onAppear {
                    onLastItemAppear()
                }
        }.fullScreenCover(item: $safariURL) { url in SafariView(url: url) }
    }
}



// ─────────────────────────────────────────────────────────────────────────────
// MARK: - TwoColumnMasonryLayout   (custom Layout)
//
// Places N children into two columns, always adding to the shorter one.
// Reports container size as (fullWidth, maxColHeight) — NOT max(leftH, rightH)
// padded to an HStack-equalised height.
//
// This is the key difference from HStack+LazyVStack:
//   HStack reports its size as max(leftH, rightH) AND reserves that full height
//   for both columns → empty space on the shorter side → gap above next banner.
//
//   This Layout reports exactly the height of whichever column is taller after
//   all children are placed → zero leftover space → banner sits flush. ✓
// ─────────────────────────────────────────────────────────────────────────────

struct TwoColumnMasonryLayout: Layout {

    var spacing: CGFloat = 6

    struct CacheData {
        var frames: [CGRect] = []
        var size: CGSize = .zero
    }

    func makeCache(subviews: Subviews) -> CacheData {
        CacheData()
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {

        let totalW = proposal.width ?? UIScreen.main.bounds.width
        let colW = (totalW - spacing) / 2

        var frames: [CGRect] = Array(repeating: .zero, count: subviews.count)

        var colHeights: [CGFloat] = [0, 0]
        var lastIndexInColumn: [Int?] = [nil, nil]

        // First pass
        for index in subviews.indices {

            let sub = subviews[index]

            let col = colHeights[0] <= colHeights[1] ? 0 : 1

            let size = sub.sizeThatFits(
                ProposedViewSize(width: colW, height: nil)
            )

            let x = col == 0 ? 0 : colW + spacing
            let y = colHeights[col]

            frames[index] = CGRect(
                x: x,
                y: y,
                width: colW,
                height: size.height
            )

            colHeights[col] += size.height + spacing

            lastIndexInColumn[col] = index
        }

        // Final column heights
        let leftHeight = max(colHeights[0] - spacing, 0)
        let rightHeight = max(colHeights[1] - spacing, 0)

        let maxHeight = max(leftHeight, rightHeight)

        // Stretch last item of shorter column
        if leftHeight < rightHeight {

            if let index = lastIndexInColumn[0] {

                let diff = rightHeight - leftHeight

                frames[index].size.height += diff
            }

        } else if rightHeight < leftHeight {

            if let index = lastIndexInColumn[1] {

                let diff = leftHeight - rightHeight

                frames[index].size.height += diff
            }
        }

        cache.frames = frames
        cache.size = CGSize(width: totalW, height: maxHeight)

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
// ─────────────────────────────────────────────────────────────────────────────
// MARK: - BoardBannerCard
// Full-width banner (boardType == 4).
// ─────────────────────────────────────────────────────────────────────────────

struct BoardBannerCard: View {

    let product: ItemModel
    let onClickedView:(_ url:URL)->Void

    var body: some View {
        KFImage(URL(string: product.banner?.image ?? ""))
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


import AVKit

struct BoardVideoBannerCard: View {

    let product: ItemModel
    let onClickedView:(_ url:URL)->Void

    @State private var player: AVPlayer? = nil

    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            VideoPlayer(player: player)
                .frame(height: 220)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                )
                .onAppear {

                    guard player == nil else { return }

                    if let url = URL(string: product.banner?.image ?? "") {

                        let avPlayer = AVPlayer(url: url)

                        avPlayer.isMuted = true
                        avPlayer.play()

                        // loop video
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: avPlayer.currentItem,
                            queue: .main
                        ) { _ in
                            avPlayer.seek(to: .zero)
                            avPlayer.play()
                        }

                        self.player = avPlayer
                    }
                }
                .onDisappear {

                    player?.pause()
                    player = nil
                }

            VStack {

                Spacer()

                HStack {

                    Spacer()

                    Image(systemName: "speaker.slash.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding(12)
                }
            }
        }
        .background(Color(.systemBackground))
        .shadow(
            color: .black.opacity(0.08),
            radius: 4,
            y: 2
        )
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

struct ImageRatioKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}



struct ProductCardStaggeredNew: View {

    @State private var showSafari = false
    let product: ItemModel
    let sendLikeUnlikeObject: (Bool, Int) -> Void
    let onTapBoostButton: () -> Void
    var isToShowBoostButton = true
    var defaultImgWidth: CGFloat = 0.0
    var defaultImgHeight: CGFloat = 0.0
   
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {

            ZStack(alignment: .bottomTrailing) {

                KFImage(URL(string: product.image ?? ""))
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: 400, height: 500))
                    )
                    .cacheOriginalImage(false)
                    .resizable()
                    .scaledToFill()   // ← KEY: natural aspect ratio, no fixed height
                    .clipped()
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.10), radius: 7, x: 0, y: 2)

                VStack {
                    if (product.isFeature ?? false) {
                        HStack {
                            Text("Sponsored")
                                .font(.inter(.medium, size: 11))
                                .lineLimit(1)
                                .foregroundColor(Color(.gray))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(UIColor.systemBackground))
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(Color(.systemGreen).opacity(0.4), lineWidth: 0.1)
                                }
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
                                        .font(.inter(.medium, size: 11))
                                        .foregroundColor(.black)
                                    Image("upRight").renderingMode(.template)
                                        .foregroundColor(Color(UIColor.label))
                                }
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal, 8)
                            .background(randomColor(for: product.id ?? 0))
                            .cornerRadius(5)
                            .padding(5)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                if (product.user?.id ?? 0) != Local.shared.getUserId() {
                    Button {
                        manageLike(boardId: product.id ?? 0)
                    } label: {
                        HStack(spacing: 1) {
                            if product.isLiked == true {
                                Image("like_fill").resizable().aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            } else {
                                Image("like")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.primary)
                                    .frame(width: 24, height: 24)
                            }
                            if (product.totalLikes ?? 0) > 0 {
                                Text("\(product.totalLikes ?? 0)")
                                    .foregroundColor(Color(.label))
                                    .font(Font.inter(.regular, size: 12))
                            }
                        }
                    }
                }

                HStack(spacing: 3) {
                    Image("messageIcon").renderingMode(.template).foregroundColor(Color(.label))
                    if (product.commentsCount ?? 0) > 0 {
                        Text("\((product.commentsCount ?? 0).formatViews())")
                            .font(.inter(.medium, size: 12)).foregroundColor(Color(.label))
                    }
                }

                HStack(spacing: 3) {
                    Image("eye").renderingMode(.template).foregroundColor(Color(.label))
                    if (product.impressions ?? 0) > 0 {
                        Text("\((product.impressions ?? 0).formatViews())")
                            .font(.inter(.medium, size: 12)).foregroundColor(Color(.label))
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
                    .font(.inter(.regular, size: 12)).lineLimit(2)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)

            PriceView(
                price: product.price ?? 0.0,
                specialPrice: product.specialPrice ?? 0.0,
                currencySymbol: Local.shared.currencySymbol
            )
            .padding([.bottom], 10)
            .padding(.horizontal, 8)
            .padding(.top, 2)

            if (product.user?.id ?? 0) == Local.shared.getUserId() && isToShowBoostButton {
                if product.isFeature == false {
                    Button {
                        onTapBoostButton()
                    } label: {
                        Text("Boost \(Local.shared.currencySymbol)\(Int(product.package?.finalPrice ?? 0))")
                            .font(.inter(.semiBold, size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.65, blue: 0.15),
                                        Color(red: 0.95, green: 0.45, blue: 0.05)
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
        if AppDelegate.sharedInstance.isUserLoggedInRequest() {
            let newState = !(product.isLiked ?? false)
            sendLikeUnlikeObject(newState, boardId)
        }
    }

    func outboundClickApi(strURl: String, boardId: Int) {
        let params = ["board_id": boardId]
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
    
    func randomColor(for id: Int) -> Color {

        let colors: [Color] = [
            .white,
            Color(hex: "#B6EEF5"),
            Color(hex: "#FFBC55")
        ]

        return colors[id % colors.count]
    }
}

struct IdeaCardStaggeredNew: View {

    let product: ItemModel
    var defaultImgWidth: CGFloat = 0.0
    var defaultImgHeight: CGFloat = 0.0

    var body: some View {
        KFImage(URL(string: product.image ?? ""))
            .setProcessor(
                DownsamplingImageProcessor(size: CGSize(width: 400, height: 500))
            )
            .scaleFactor(UIScreen.main.scale)
            .cacheOriginalImage(false)
            .resizable()
            .scaledToFill()   // ← KEY: natural aspect ratio
            .clipped()
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.10), radius: 7, x: 0, y: 2)
            .overlay(
                Group {
                    if (product.isFeature ?? false) {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Sponsored")
                                    .foregroundColor(.white)
                                    .font(.inter(.bold, size: 14))
                                    .padding([.bottom, .trailing], 8)
                                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
                            }
                        }
                    }
                }
            )
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(Rectangle())
    }
}


struct CardItemViewNew: View {
    let item: ItemModel
    let onLike: (Bool, Int) -> Void
    let onTap: () -> Void
    let onTapBoostButton: () -> Void
    var isToShowBoostButton = true
    var imageRatio: CGFloat = 1.2  // ← ADD THIS

    var body: some View {
        if item.boardType == 1 {
            PromotionalAdsCardStaggered(product: item, onTapBottomtButton: onTapBoostButton)
        } else if item.boardType == 3 {
            IdeaCardStaggeredNew(product: item)  // ← pass ratio
                .onTapGesture(perform: onTap)
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
struct HorizontalBannerCard: View {

    let product: ItemModel
    let onTapButton: () -> Void

    var body: some View {
        KFImage(URL(string: product.banner?.image ?? ""))
            .scaleFactor(UIScreen.main.scale)
            .cacheOriginalImage(false)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 220)
            .clipped()
            .shadow(color: Color.black.opacity(0.10), radius: 7, x: 0, y: 2)
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture {
                onTapButton()
                outboundClickApi()
            }
    }

    private func outboundClickApi() {
        let params = ["board_id": product.id ?? 0]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.board_outbond_click,
            param: params,
            methodType: .post
        ) { responseObject, error in
            guard error == nil,
                  let result = responseObject as? NSDictionary,
                  (result["code"] as? Int) == 200
            else { return }
        }
    }
}



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

