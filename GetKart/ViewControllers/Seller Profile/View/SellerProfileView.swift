//
//  SellerProfileView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/03/25.
//

import SwiftUI

enum ProfileTab: Int, CaseIterable {
    case boards
    case ideas
    case promoVideo
    case promoImage

    var title: String {
        switch self {
        case .boards: return "Boards"
        case .ideas: return "Ideas"
        case .promoVideo: return "Video Ads"
        case .promoImage: return "Image Ads"
        }
    }
}

struct SellerProfileView: View {

    var navController: UINavigationController?
    var userId: Int = 0

    @StateObject private var objVM: ProfileViewModel

    @State private var selectedTab: ProfileTab = .boards

    @State var showShareSheet = false
    @State var showOptionSheet = false
    @State private var isViewVisible = false
    // Masonry heights
    @State private var itemHeights: [Int: CGFloat] = [:]

    // Pagination trigger
    private let prefetchOffset = 4

    // Video tracking
    @State private var videoFrames: [Int: CGRect] = [:]
    @State private var scrollTick: Int = 0

    // Safari
    @State private var openSafari: Bool = false
    @State private var outboundUrlClicked: String = ""

    // Payment
    @State private var paymentGateway: PaymentGatewayCentralized?

    init(navController: UINavigationController? = nil,
         userId: Int,
         defaultTab: ProfileTab = .boards) {

        self.navController = navController
        self.userId = userId
        _objVM = StateObject(wrappedValue: ProfileViewModel(userId: userId))
        _selectedTab = State(initialValue: defaultTab)
    }

    var body: some View {

        VStack(spacing: 0) {

            topNavBarView()

            Divider()

            ScrollViewReader{ proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Color.clear.frame(height:0).id("TAB_TOP")
                        profileHeaderView()
                        
                        if Local.shared.getUserId() > 0 &&
                            Local.shared.getUserId() != (objVM.sellerObj?.id ?? 0) {
                            messageFollowButtonsView()
                        }
                        
                        Section(header: tabHeaderView(proxy: proxy)) {
                            
                          
                            
                            let items = objVM.getItems(for: selectedTab)
                            
                            if items.isEmpty && !objVM.isLoading(for: selectedTab) {
                                emptyView()
                            } else {
                                
//                                if selectedTab == .ideas {
//                                    ideasGridView(items: items)
//                                }
//                                else if selectedTab == .promoImage {
//                                    promoImageGridView(items: items)
//                                }
//                                else {
                                    masonryBoardView(items: items)
                               // }
                            }
                            
                            if objVM.isLoading(for: selectedTab) {
                                ProgressView().padding(.vertical, 20)
                            }
                        }
                    }
                }
                .background(Color(.systemGray6))
            }
            
        }
        .navigationBarHidden(true)
        .onAppear {
            isViewVisible = true
            objVM.getSellerProfile(sellerId: userId, nav: navController)

            if objVM.getItems(for: selectedTab).isEmpty {
                objVM.loadNextPage(tab: selectedTab)
            }
        }.onDisappear{
            isViewVisible = false
        }
        .onChange(of: selectedTab) { tab in
            if objVM.getItems(for: tab).isEmpty {
                objVM.loadNextPage(tab: tab)
            }
        }
        .fullScreenCover(isPresented: $openSafari) {
            if let url = URL(string: outboundUrlClicked.getValidUrl()) {
                SafariView(url: url)
            }
        }
        .onDisappear {
            FeedVideoManager.shared.pauseAll()
            FeedVideoManager.shared.muteAll()
        }
        .onPreferenceChange(ItemHeightKey.self) { value in
            itemHeights.merge(value) { $1 }
        }
    }
    
    
    func createRoom(){
        
        FaceBookAppEvents.facebookEvents(type: .createOffer, categoryName: objVM.sellerObj?.name ?? "")
        let params = ["user_id":userId] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.createRoom.rawValue, params)
    }
}

// MARK: - TOP BAR
extension SellerProfileView {

    private func topNavBarView() -> some View {

        HStack {

            Button(action: {
                navController?.popViewController(animated: true)
            }) {
                Image("arrow_left")
                    .renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
            }

            Text("Profile")
                .font(.inter(.medium, size: 18))
                .foregroundColor(Color(.label))

            Spacer()

            Button(action: {
                showShareSheet = true
            }) {
                Image("Share-outline")
                    .renderingMode(.template)
                    .font(.title3)
                    .foregroundColor(Color(UIColor.label))
            }
            .actionSheet(isPresented: $showShareSheet) {

                ActionSheet(title: Text(""), message: nil, buttons: [

                    .default(Text("Copy Link"), action: {
                        UIPasteboard.general.string = ShareMedia.profileUrl + "\(userId)"
                        AlertView.sharedManager.showToast(message: "Copied successfully.")
                    }),

                    .default(Text("Share"), action: {
                        ShareMedia.shareMediafrom(
                            type: .profile,
                            mediaId: "\(userId)",
                            controller: (navController?.topViewController!)!
                        )
                    }),

                    .cancel()
                ])
            }

            if Local.shared.getUserId() > 0 &&
                Local.shared.getUserId() != (objVM.sellerObj?.id ?? 0) {

                Button(action: {
                    showOptionSheet = true
                }) {
                    Image("more")
                        .renderingMode(.template)
                        .font(.title3)
                        .foregroundColor(Color(UIColor.label))
                }
                .actionSheet(isPresented: $showOptionSheet) {

                    ActionSheet(title: Text(""), message: nil, buttons: [

                        .default(Text(((objVM.sellerObj?.isBlock ?? 0) == 1) ? "Unblock" : "Block"), action: {

                            if (objVM.sellerObj?.isBlock ?? 0) == 1 {
                                self.objVM.unblockUser()
                            } else {
                                self.objVM.blockUser()
                            }
                        }),

                        .default(Text("Report user"), action: {
                            reportUserPush()
                        }),

                        .cancel()
                    ])
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - PROFILE HEADER
extension SellerProfileView {

    private func profileHeaderView() -> some View {
        
        VStack(spacing: 0) {
            
            
            HStack(alignment: .top, spacing: 12) {
                
                ContactImageSwiftUIView(
                    name: objVM.sellerObj?.name ?? "",
                    imageUrl: objVM.sellerObj?.profile ?? "",
                    fallbackImageName: "user-circle",
                    imgWidth: 70,
                    imgHeight: 70
                ).onTapGesture {
                    previewUserImage()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Spacer()
                    
                    HStack(spacing: 6) {
                        
                        Text(objVM.sellerObj?.name ?? "")
                            .font(.inter(.semiBold, size: 18))
                            .foregroundColor(.primary)
                        
                        if (objVM.sellerObj?.isVerified ?? 0) == 1 {
                            Image("verifiedIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .onTapGesture {
                                    AppDelegate.sharedInstance.presentVerifiedInfoView()
                                }
                        }
                    }
                    
                    Text(objVM.sellerObj?.address ?? "")
                        .font(.inter(.regular, size: 13))
                        .foregroundColor(.gray)
                }
                Spacer()
            }.padding(.horizontal, 12)
              .padding(.top, 12)
             .padding(.bottom, 10)
            
            
            HStack(spacing: 30) {
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Follow")
                        .font(.inter(.semiBold, size: 14))
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Text("\(objVM.sellerObj?.followingCount ?? 0)")
                        .font(.inter(.semiBold, size: 15))
                        .foregroundColor(.primary)
                }    .onTapGesture {
                    if (objVM.sellerObj?.followersCount ?? 0) > 0 {
                        if AppDelegate.sharedInstance.isUserLoggedInRequest() {
                            let hostVC = UIHostingController(
                                rootView: FollowerListView(
                                    navController: navController,
                                    isFollower: false,
                                    userId: userId
                                )
                            )
                            self.navController?.pushViewController(hostVC, animated: true)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Followers")
                        .font(.inter(.semiBold, size: 14))
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Text(formatCount(objVM.sellerObj?.followersCount ?? 0))
                        .font(.inter(.semiBold, size: 15))
                        .foregroundColor(.primary)
                }    .onTapGesture {
                    if (objVM.sellerObj?.followersCount ?? 0) > 0 {
                        if AppDelegate.sharedInstance.isUserLoggedInRequest() {
                            let hostVC = UIHostingController(
                                rootView: FollowerListView(
                                    navController: navController,
                                    isFollower: true,
                                    userId: userId
                                )
                            )
                            self.navController?.pushViewController(hostVC, animated: true)
                        }
                    }
                }
                
                Spacer()
                
            }.padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 10)
        }.background(Color(.systemBackground))
        
    }
    
    func previewUserImage(){
        if AppDelegate.sharedInstance.isUserLoggedInRequest() {
            if (objVM.sellerObj?.profile ?? "").count > 0{
                let zoomCtrl = VKImageZoom()
                zoomCtrl.image_url = URL(string: objVM.sellerObj?.profile ?? "")
                zoomCtrl.modalPresentationStyle = .fullScreen
               self.navController?.present(zoomCtrl, animated: true, completion: nil)
            }
        }
    }

    private func messageFollowButtonsView() -> some View {
        
        HStack(spacing: 12) {

            Button(action: {
                // TODO: Open chat screen
                if AppDelegate.sharedInstance.isUserLoggedInRequest() {
                    createRoom()
                }
            }) {
                Text("Message")
                    .font(.inter(.semiBold, size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(hex: "#BDEEFF"))
                    .cornerRadius(10)
            }

            Button(action: {
                if AppDelegate.sharedInstance.isUserLoggedInRequest() {
                    
                    let follow = (objVM.sellerObj?.isFollowing ?? false) ? false : true
                    objVM.followUnfollowUserApi(isFollow: follow)
                    objVM.sellerObj?.followersCount =
                    (objVM.sellerObj?.followersCount ?? 0) + (follow ? 1 : -1)
                }

            }) {

                let strText = (objVM.sellerObj?.isFollowing ?? false) ? "Unfollow" : "Follow"

                Text(strText)
                    .font(.inter(.semiBold, size: 15))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(hex: "#FFBC55"))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .background(Color(.systemBackground))
        
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(SocketEvents.createRoom.rawValue))) { notification in
            
            
//            if navController?.topViewController is ChatVC {
//                return
//            }
            
            if isViewVisible == false{
                return
            }
            guard let data = notification.userInfo else{
                return
            }
            
            if let dataDict = data["data"] as? Dictionary<String,Any>{
                
                let id = dataDict["id"] as? Int ?? 0
                let sender_id = dataDict["sender_id"] as? Int ?? 0
                let receiver_id = dataDict["receiver_id"] as? Int ?? 0
                
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = id
                destVC.userId = receiver_id
                self.navController?.pushViewController(destVC, animated: true)
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
            }
            else{
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = 0
                destVC.userId = userId
                self.navController?.pushViewController(destVC, animated: true)
            }
        }
    }
}

// MARK: - STICKY TABS
extension SellerProfileView {

    private func tabHeaderView(proxy: ScrollViewProxy) -> some View {

        VStack(spacing: 0) {

            HStack(spacing: 0) {

                ForEach(ProfileTab.allCases, id: \.self) { tab in

                    tabButton(title: tab.title, isSelected: selectedTab == tab)
                        .onTapGesture {

                            guard selectedTab != tab else { return }

                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedTab = tab
                            }

                            // Scroll to tab content start
                            DispatchQueue.main.async{
                           // DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo("TAB_TOP", anchor: .top)
                                }
                            }
                        }
                }
            }
            .padding(.top, 4)
            .background(Color.white)

            Divider()
        }
        .background(Color.white)
    }

    private func tabButton(title: String, isSelected: Bool) -> some View {

        VStack(spacing: 6) {

            Text(title)
                .font(.inter(.semiBold, size: 14))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(maxWidth: .infinity)

            Rectangle()
                .fill(isSelected ? Color.black : Color.clear)
                .frame(height: 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// MARK: - IDEAS GRID
extension SellerProfileView {

    private func ideasGridView(items: [ItemModel]) -> some View {

        LazyVGrid(columns: [GridItem(.flexible()),
                            GridItem(.flexible())],
                  spacing: 10) {

            ForEach(items, id: \.id) { item in

                ProductCard(objItem: .constant(item), onItemLikeDislike: { likedObj in
                    // Update logic if needed
                })
                .onAppear {
                    paginationTrigger(item: item, items: items)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }
}

// MARK: - PROMO IMAGE GRID
extension SellerProfileView {

    private func promoImageGridView(items: [ItemModel]) -> some View {

        LazyVGrid(columns: [GridItem(.flexible()),
                            GridItem(.flexible())],
                  spacing: 10) {

            ForEach(items, id: \.id) { item in

                CardItemView(
                    item: item,
                    onLike: { isLiked, boardId in
                        objVM.updateLike(boardId: boardId, isLiked: isLiked)
                    },
                    onTap: { pushToDetail(item: item) },
                    onTapBoostButton: {},
                    isToShowBoostButton: false
                )
                .onAppear {
                    paginationTrigger(item: item, items: items)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }
}

// MARK: - MASONRY VIEW (Boards + Promo Video)
extension SellerProfileView {

    private func masonryBoardView(items: [ItemModel]) -> some View {

        let columns = splitColumns(items: items)

        return HStack(alignment: .top, spacing: 6) {

            LazyVStack(spacing: 6) {
                ForEach(columns.left, id: \.id) { item in
                    masonryCell(item: item, items: items)
                }
            }

            LazyVStack(spacing: 6) {
                ForEach(columns.right, id: \.id) { item in
                    masonryCell(item: item, items: items)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }

    @ViewBuilder
    private func masonryCell(item: ItemModel, items: [ItemModel]) -> some View {

        if item.boardType == 2 {

            SmartVideoPlayerView(item: item, onTapBottomButton: {

                if (item.outbondUrl ?? "").count > 0 {
                    outboundUrlClicked = item.outbondUrl ?? ""
                    openSafari = true
                }
            },onTapExpandButton: {
                //Expand Button
                pushToReelsView(itemObj: item)

            },onTapProfile: {userId in
               // pushToProfile(id: userId)
                selectedTab = .boards
            })
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            videoFrames[item.id ?? 0] = geo.frame(in: .global)
                            scrollTick += 1
                        }
                        .onDisappear {
                            videoFrames.removeValue(forKey: item.id ?? 0)
                            FeedVideoManager.shared.pause(id: item.id ?? 0)
                        }
                        .onChange(of: geo.frame(in: .global)) { frame in
                            videoFrames[item.id ?? 0] = frame
                            scrollTick += 1
                        }
                }
            )
            .measureHeight(id: item.id ?? 0)
            .onAppear {
                paginationTrigger(item: item, items: items)
                calculateVisibleVideos()
            }

        } else {

            CardItemView(
                item: item,
                onLike: { isLiked, boardId in
                    objVM.updateLike(boardId: boardId, isLiked: isLiked)
                },
                onTap: { pushToDetail(item: item) },
                onTapBoostButton: {
                    if item.boardType == 1 {
                        if (item.outbondUrl ?? "").count > 0 {
                            outboundUrlClicked = item.outbondUrl ?? ""
                            openSafari = true
                        }
                    } else {
                        paymentGatewayOpen(product: item)
                    }
                },
                isToShowBoostButton: false
            )
            .measureHeight(id: item.id ?? 0)
            .onAppear {
                paginationTrigger(item: item, items: items)
            }
        }
    }
    
    func pushToReelsView(itemObj:ItemModel){
        let vc = UIHostingController(rootView: ReelsView(navigationController: self.navController,itemObj:itemObj))
        vc.hidesBottomBarWhenPushed = true
        self.navController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PAGINATION TRIGGER (COMMON)
extension SellerProfileView {

    private func paginationTrigger(item: ItemModel, items: [ItemModel]) {

        guard let id = item.id else { return }
        guard let lastId = items.last?.id else { return }

        // Trigger near last 4 items
        if id == lastId {
            if objVM.canLoadMore(for: selectedTab) && !objVM.isLoading(for: selectedTab) {
                objVM.loadNextPage(tab: selectedTab)
            }
        }
    }
}

// MARK: - EMPTY VIEW
extension SellerProfileView {

    private func emptyView() -> some View {

        VStack(spacing: 20) {

            Spacer()

            Image("no_data_found_illustrator")
                .frame(width: 150, height: 150)

            Text("No Data Found")
                .foregroundColor(.orange)
                .font(Font.manrope(.medium, size: 20.0))

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }
}

// MARK: - HELPERS
extension SellerProfileView {

    private func formatCount(_ value: Int) -> String {
        if value >= 1000000 {
            return String(format: "%.1fM", Double(value) / 1000000.0)
        } else if value >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000.0)
        }
        return "\(value)"
    }

    private func reportUserPush() {
        let hostingController = UIHostingController(rootView: ReportUserView(roportUserId: userId))
        self.navController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: - SPLIT COLUMNS (MASONRY)
extension SellerProfileView {

    private func splitColumns(items: [ItemModel]) -> (left: [ItemModel], right: [ItemModel]) {

        var left: [ItemModel] = []
        var right: [ItemModel] = []

        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0

        for item in items {

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
}

// MARK: - VIDEO VISIBILITY
extension SellerProfileView {

    private func calculateVisibleVideos() {

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

// MARK: - NAVIGATION
extension SellerProfileView {

    private func pushToDetail(item: ItemModel) {

        let vc = UIHostingController(
            rootView: BoardDetailView(
                navigationController: navController,
                itemObj: item
            )
        )
        vc.hidesBottomBarWhenPushed = true
        navController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PAYMENT
extension SellerProfileView {

    private func paymentGatewayOpen(product: ItemModel) {

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
                        navigationController: navController
                    )
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                navController?.present(vc, animated: true)

                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue),
                    object: ["boardId": product.id ?? 0],
                    userInfo: nil
                )
            }

            self.paymentGateway = nil
        }

        paymentGateway?.initializeDefaults()
    }
}

#Preview {
    SellerProfileView(navController: nil, userId: 33925, defaultTab: .boards)
}





