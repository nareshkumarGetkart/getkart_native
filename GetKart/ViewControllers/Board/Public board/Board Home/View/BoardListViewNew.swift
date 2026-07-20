//
//  BoardListViewNew.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/07/26.
//

import SwiftUI
import AVKit
import FittedSheets
import Kingfisher

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



//#Preview {
//    BoardListViewNew()
//}
