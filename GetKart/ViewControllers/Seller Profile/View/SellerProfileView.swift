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
            objVM.getSellerProfile(sellerId: userId, nav: navController)

            if objVM.getItems(for: selectedTab).isEmpty {
                objVM.loadNextPage(tab: selectedTab)
            }
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
                )
                
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
            
            
            if navController?.topViewController is ChatVC {
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

            Spacer(minLength: 80)

            Image("no_data_found_illustrator")
                .frame(width: 150, height: 150)

            Text("No Data Found")
                .foregroundColor(.orange)
                .font(Font.manrope(.medium, size: 20.0))

            Spacer(minLength: 150)
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

/*
enum ProfileTab {
    case boards
    case ideas
    case promoImage
    case promoVideo
}


struct SellerProfileView: View {

    var navController: UINavigationController?
    var userId: Int = 33925

    @StateObject private var objVM: ProfileViewModel

    @State var showShareSheet = false
    @State var showOptionSheet = false

    @State private var selectedTab: ProfileTab = .boards

    // Pagination + Masonry Heights
    @State private var userDidScroll = false
    @State private var paginationConsumed = false
    @State private var itemHeights: [Int: CGFloat] = [:]

    @State private var lastItemCount: Int = 0
    @State private var scrollTick: Int = 0
    @State private var lastScrollTick: Int = 0

    private let prefetchOffset = 4

    @State private var paymentGateway: PaymentGatewayCentralized?

    // Video Visibility
    @State private var videoFrames: [Int: CGRect] = [:]

    // Safari
    @State private var openSafari: Bool = false
    @State private var outboundUrlClicked: String = ""

    //MARK: Initialization
    init(navController: UINavigationController? = nil, userId: Int, isProductSelected: Bool = true) {
        self.navController = navController
        self.userId = userId
        _objVM = StateObject(wrappedValue: ProfileViewModel(userId: userId))
        _selectedTab = State(initialValue: isProductSelected ? .boards : .boards)
    }

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Fixed Top Bar
            topNavBarView()

            Divider()

            // MARK: - SINGLE SCROLL VIEW (Whole Screen Scrollable)
            
            ScrollView(.vertical, showsIndicators: false) {

                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {

                    // MARK: - Profile Header Section (Scrollable)
                    profileHeaderView()

                    // MARK: - Message + Follow Buttons
                    //if Local.shared.getUserId() > 0 && Local.shared.getUserId() != (objVM.sellerObj?.id ?? 0) {
                        messageFollowButtonsView()
                   // }

                    // MARK: - Sticky Tabs
                    Section(header: tabHeaderView()) {

                        // MARK: - Content
                        if ((objVM.boardArray.count == 0 && selectedTab == .boards) ||
                            (objVM.ideaArray.count == 0 && selectedTab == .ideas) || (objVM.imageAdsArray.count == 0 && selectedTab == .promoImage) || (objVM.videoAdsArray.count == 0 && selectedTab == .promoVideo))
                            && objVM.isDataLoading == false {

                            emptyView()

                        } else {

                                boardGridView()

                        }

                        if objVM.isDataLoading {
                            ProgressView().padding(.vertical, 20)
                        }
                    }
                }
            }
            .background(Color(.systemGray6))
            .simultaneousGesture(
                DragGesture()
                    .onEnded { _ in
                        userDidScroll = true
                        paginationConsumed = false
                    }
            )
            .onPreferenceChange(ItemHeightKey.self) { value in
                itemHeights.merge(value) { $1 }
            }
            .onChange(of: scrollTick) { _ in
                calculateVisibleVideos()
            }
        }
        .navigationBarHidden(true)

        .onAppear {
            loadInitialData()
        }
        .onChange(of: selectedTab) { value in
            loadTabData(value: value)
        }
        .fullScreenCover(isPresented: $openSafari) {
            if let url = URL(string: outboundUrlClicked.getValidUrl()) {
                SafariView(url: url)
            }
        }
        .onDisappear {
            FeedVideoManager.shared.muteAll()
            FeedVideoManager.shared.pauseAll()
        }
    }
}



// MARK: - UI COMPONENTS
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

            if Local.shared.getUserId() > 0 && Local.shared.getUserId() != (objVM.sellerObj?.id ?? 0) {

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

    private func profileHeaderView() -> some View {
        
        VStack(spacing: 0) {
            
            
            HStack(alignment: .top, spacing: 12) {
                
                ContactImageSwiftUIView(
                    name: objVM.sellerObj?.name ?? "",
                    imageUrl: objVM.sellerObj?.profile ?? "",
                    fallbackImageName: "user-circle",
                    imgWidth: 70,
                    imgHeight: 70
                )
                
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
                        .font(.inter(.regular, size: 13))
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Text("\(objVM.sellerObj?.followingCount ?? 0)")
                        .font(.inter(.semiBold, size: 15))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Followers")
                        .font(.inter(.regular, size: 13))
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Text(formatCount(objVM.sellerObj?.followersCount ?? 0))
                        .font(.inter(.semiBold, size: 15))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
            }.padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 10)
        }.background(Color(.systemBackground))
        
    }
    

    private func messageFollowButtonsView() -> some View {

        HStack(spacing: 12) {

            Button(action: {
                // TODO: Open chat screen
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
                let follow = (objVM.sellerObj?.isFollowing ?? false) ? false : true
                objVM.followUnfollowUserApi(isFollow: follow)
                objVM.sellerObj?.followersCount =
                (objVM.sellerObj?.followersCount ?? 0) + (follow ? 1 : -1)

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
    }

    private func tabHeaderView() -> some View {

        VStack(spacing: 0) {

            HStack(spacing: 0) {
                
                tabButton(title: "Boards", isSelected: selectedTab == .boards)
                    .onTapGesture {
                        withAnimation {
                            selectedTab = .boards
                        }
                    }
                
                tabButton(title: "Ideas", isSelected: selectedTab == .ideas)
                    .onTapGesture {
                        withAnimation {
                            selectedTab = .ideas
                        }
                    }
                
                tabButton(title: "Promo Image", isSelected: selectedTab == .promoImage)
                    .onTapGesture { selectedTab = .promoImage }
                
                tabButton(title: "Promo Video", isSelected: selectedTab == .promoVideo)
                    .onTapGesture { selectedTab = .promoVideo }
            }
            .padding(.top, 4)
            .background(Color(.systemBackground))

            Divider()
        }
        .background(Color(.systemBackground))
    }

    private func tabButton(title: String, isSelected: Bool) -> some View {

        VStack(spacing: 6) {

            Text(title)
                .font(.inter(.semiBold, size: 16))
                .foregroundColor(isSelected ? .primary : .gray)
                .frame(maxWidth: .infinity)

            Rectangle()
                .fill(isSelected ? Color.primary : Color.clear)
                .frame(height: 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func emptyView() -> some View {

        VStack(spacing: 20) {

            Spacer(minLength: 80)

            Image("no_data_found_illustrator")
                .frame(width: 150, height: 150)

            Text("No Data Found")
                .foregroundColor(.orange)
                .font(Font.manrope(.medium, size: 20.0))

            Spacer(minLength: 150)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }
}


// MARK: - BOARD GRID (Masonry)
extension SellerProfileView {

    private func boardGridView() -> some View {

        let columns = splitColumns()

        return HStack(alignment: .top, spacing: 6) {

            LazyVStack(spacing: 6) {
                ForEach(columns.left.indices, id: \.self) { index in
                    let item = columns.left[index]
                    boardCell(item: item)
                }
            }

            LazyVStack(spacing: 6) {
                ForEach(columns.right.indices, id: \.self) { index in
                    let item = columns.right[index]
                    boardCell(item: item)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }

    @ViewBuilder
    private func boardCell(item: ItemModel) -> some View {

        if item.boardType == 2 {

            SmartVideoPlayerView(item: item, onTapBottomButton: {

                if (item.outbondUrl ?? "").count > 0 {
                    outboundUrlClicked = item.outbondUrl ?? ""
                    openSafari = true
                }
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
                handlePrefetch(itemIndex: globalIndex(of: item))
                prefetchNextVideos(from: item)
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
                handlePrefetch(itemIndex: globalIndex(of: item))
            }
        }
    }
}

// MARK: - API LOADING
extension SellerProfileView {

    private func loadInitialData() {

        if selectedTab == .ideas {

            if objVM.ideaArray.count == 0 {
                objVM.getSellerProfile(sellerId: userId, nav: navController)
                objVM.getItemListApi(sellerId: userId)
            }

        } else {

            if objVM.boardArray.count == 0 {
                objVM.getSellerProfile(sellerId: userId, nav: navController)
                objVM.getBoardListApi()
            }
        }
    }

    private func loadTabData(value: ProfileTab) {

        if value == .boards && objVM.boardArray.isEmpty && !objVM.isDataLoading {
            objVM.getBoardListApi()
        }

        if value == .ideas && objVM.ideaArray.isEmpty && !objVM.isDataLoading {
            objVM.getItemListApi(sellerId: userId)
        }
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

    private func updateItemInList(_ value: ItemModel) {
        if let index = $objVM.ideaArray.firstIndex(where: { $0.id == value.id }) {
            objVM.ideaArray[index] = value
        }
    }

    func reportUserPush() {
        let hostingController = UIHostingController(rootView: ReportUserView(roportUserId: userId))
        self.navController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: - BOARD PAGINATION LOGIC
extension SellerProfileView {

    private func handlePrefetch(itemIndex: Int?) {

        guard let index = itemIndex else { return }

        let triggerIndex = max(objVM.boardArray.count - prefetchOffset, 0)

        guard index >= triggerIndex else { return }
        guard scrollTick > lastScrollTick else { return }
        guard objVM.boardArray.count > lastItemCount else { return }
        guard !objVM.isDataLoading else { return }
        guard !objVM.canLoadMoreBoardPage else { return }

        paginationConsumed = true
        userDidScroll = false

        lastItemCount = objVM.boardArray.count
        lastScrollTick = scrollTick

        objVM.getBoardListApi()
    }

    private func prefetchNextVideos(from currentItem: ItemModel) {

        guard let index = objVM.boardArray.firstIndex(where: { $0.id == currentItem.id }) else { return }

        let start = index + 1
        let end = min(index + 2, objVM.boardArray.count - 1)

        guard start <= end else { return }

        var urls: [URL] = []

        for i in start...end {

            let item = objVM.boardArray[i]

            if item.boardType == 2,
               let link = item.videoLink,
               let url = URL(string: link) {

                urls.append(url)
            }
        }

        VideoPreloadManagerDefault.shared.set(waiting: urls)
    }

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

// MARK: - PAYMENT
extension SellerProfileView {

    func paymentGatewayOpen(product: ItemModel) {

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

// MARK: - MASONRY SPLIT
extension SellerProfileView {

    private func splitColumns() -> (left: [ItemModel], right: [ItemModel]) {

        var left: [ItemModel] = []
        var right: [ItemModel] = []

        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0

        if selectedTab == .boards{
            for item in objVM.boardArray {

                let h = itemHeights[item.id ?? 0] ?? 200

                if leftHeight <= rightHeight {
                    left.append(item)
                    leftHeight += h
                } else {
                    right.append(item)
                    rightHeight += h
                }
            }

        }else if selectedTab == .ideas{
            for item in objVM.ideaArray {

                let h = itemHeights[item.id ?? 0] ?? 200

                if leftHeight <= rightHeight {
                    left.append(item)
                    leftHeight += h
                } else {
                    right.append(item)
                    rightHeight += h
                }
            }

        }else if selectedTab == .promoImage{
           
            for item in objVM.imageAdsArray {

                let h = itemHeights[item.id ?? 0] ?? 200

                if leftHeight <= rightHeight {
                    left.append(item)
                    leftHeight += h
                } else {
                    right.append(item)
                    rightHeight += h
                }
            }

        }else if selectedTab == .promoVideo{
            
            for item in objVM.videoAdsArray {

                let h = itemHeights[item.id ?? 0] ?? 200

                if leftHeight <= rightHeight {
                    left.append(item)
                    leftHeight += h
                } else {
                    right.append(item)
                    rightHeight += h
                }
            }

        }
       
        return (left, right)
    }

    private func globalIndex(of item: ItemModel) -> Int? {
        if selectedTab == .boards{
           return objVM.boardArray.firstIndex { $0.id == item.id }
            
        }else if selectedTab == .ideas{
            return objVM.ideaArray.firstIndex { $0.id == item.id }
            
        }else if selectedTab == .promoImage{
            return objVM.imageAdsArray.firstIndex { $0.id == item.id }
            
        }else if selectedTab == .promoVideo{
            return objVM.videoAdsArray.firstIndex { $0.id == item.id }
        }
        return nil
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

#Preview {
    SellerProfileView(navController: nil, userId: 33925)
}
*/

extension String {
    
    func getValidUrl() -> String {
        var urlString = self
        
        if !urlString.lowercased().hasPrefix("http://") &&
            !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        return urlString
    }
}





/*
 /*
  
  enum ProfileTab {
      case products
      case boards
  }
 struct SellerProfileView: View {
     
     var navController:UINavigationController?
     var userId:Int = 33925
     @StateObject private var objVM:ProfileViewModel
     @State var showShareSheet = false
     @State var showOptionSheet = false
     @State private var selectedTab: ProfileTab = .products
     @State private var userDidScroll = false  //  User intent + safety locks
     @State private var paginationConsumed = false
     @State private var itemHeights: [Int: CGFloat] = [:] //  Measured heights for staggered layout
     //  ADD THESE
     @State private var lastItemCount: Int = 0
     @State private var scrollTick: Int = 0
     @State private var lastScrollTick: Int = 0
     private let prefetchOffset = 4   //  call API before 4 items
     @State private var paymentGateway: PaymentGatewayCentralized?
     @State private var videoFrames: [Int: CGRect] = [:]
     @State private var openSafari: Bool = false
     @State private var outboundUrlClicked: String = ""
     
     //MARK: Initialization
     init(navController: UINavigationController? = nil, userId: Int,isProductSelected:Bool=true) {
         self.navController = navController
         self.userId = userId
         _objVM = StateObject(wrappedValue: ProfileViewModel(userId: userId))
         _selectedTab = State(initialValue: isProductSelected ? .products : .boards)
     }
     
     var body: some View {
         VStack(spacing:0) {
             // Header Section
             HStack {
                 Button(action: {
                     // Handle back action
                     navController?.popViewController(animated: true)
                 }) {
                     Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                     
                 }
                 
                 Text("Profile")
                     .font(.inter(.medium, size: 18))
                     .foregroundColor(Color(.label))
                 
                 Spacer()
                 
                 HStack(spacing: 15) {
                     Button(action: {
                         // Handle share action
                         showShareSheet = true
                     }) {
                         Image("Share-outline")
                             .renderingMode(.template)
                             .font(.title3)
                             .foregroundColor(Color(UIColor.label))
                     } .actionSheet(isPresented: $showShareSheet) {
                         
                         ActionSheet(title: Text(""), message: nil, buttons: [
                             
                             .default(Text("Copy Link"), action: {
                                 
                                 UIPasteboard.general.string = ShareMedia.profileUrl + "\(userId)"
                                 AlertView.sharedManager.showToast(message: "Copied successfully.")
                                 
                             }),
                             
                                 .default(Text("Share"), action: {
                                     ShareMedia.shareMediafrom(type: .profile, mediaId: "\(userId)", controller: (navController?.topViewController!)!)
                                 }),
                             
                                 .cancel()
                         ])
                     }
                     if Local.shared.getUserId() > 0  && Local.shared.getUserId() != (objVM.sellerObj?.id ?? 0) {
                         Button(action: {
                             // Handle more options
                             showOptionSheet = true
                         }) {
                             Image("more").renderingMode(.template)
                                 .font(.title3)
                                 .foregroundColor(Color(UIColor.label))
                         }
                         .actionSheet(isPresented: $showOptionSheet) {
                             
                             
                             ActionSheet(title: Text(""), message: nil, buttons: [
                                 
                                 
                                 .default(Text((((objVM.sellerObj?.isBlock ?? 0) == 1) ? "Unblock" : "Block")), action: {
                                     
                                     if (objVM.sellerObj?.isBlock ?? 0) == 1{
                                         self.objVM.unblockUser()
                                     }else{
                                         self.objVM.blockUser()
                                     }
                                 }),
                                 
                                     .default(Text(("Report user")), action: {
                                         reportUserPush()
                                         
                                         
                                     }),
                                 
                                     .cancel()
                             ])
                         }
                     }
                 }
             }.frame(height: 44).padding(.horizontal, 10)
             Divider().padding(.bottom)
             
             HStack {
                 
                 ContactImageSwiftUIView(name: objVM.sellerObj?.name ?? "", imageUrl: objVM.sellerObj?.profile ?? "", fallbackImageName: "user-circle", imgWidth: 80, imgHeight: 80)
                 
                 HStack{
                     Text(objVM.sellerObj?.name ?? "")
                         .font(.inter(.medium, size: 15))
                     if(objVM.sellerObj?.isVerified ?? 0) == 1{
                         Image("verifiedIcon")
                             .resizable()
                             .scaledToFit()
                             .frame(width:20, height: 20).onTapGesture {
                                 AppDelegate.sharedInstance.presentVerifiedInfoView()
                             }
                         
                     }
                     Spacer()
                 }
                 Spacer()
                 
                 if Local.shared.getUserId() > 0 && Local.shared.getUserId() != (objVM.sellerObj?.id ?? 0) {
                     Button(action: {
                         // Handle follow action
                         let follow = (objVM.sellerObj?.isFollowing ?? false) ? false : true
                         objVM.followUnfollowUserApi(isFollow: follow)
                         objVM.sellerObj?.followersCount =    (objVM.sellerObj?.followersCount ?? 0)  + ((follow) ? 1 : -1)
                         
                     }) {
                         
                         let strText = (objVM.sellerObj?.isFollowing ?? false) ? "Unfollow" : "Follow"
                         Text(strText)
                             .padding(.horizontal, 20)
                             .padding(.vertical, 8)
                             .background(Color.orange)
                             .foregroundColor(Color(.white))
                             .cornerRadius(20)
                             .font(Font.inter(.semiBold, size: 15.0))
                     }
                 }
             }
             .padding(.horizontal, 10)
             
             // Stats Section
             HStack {

                 statView(value: "\(objVM.sellerObj?.items ?? 0)", label: "Products", isSelected: selectedTab == .products)
                     .onTapGesture {
                         withAnimation {
                             selectedTab = .products
                         }
                     }
               
                 Divider().frame(width: 1,height: 30)

                 statView(value: "\(objVM.sellerObj?.boards ?? 0)", label: "Board & Idea", isSelected: selectedTab == .boards)
                     .onTapGesture {
                         withAnimation {
                             selectedTab = .boards
                         }
                     }
                 
                 Divider().frame(width: 1,height: 30)

                 statView(value: "\(objVM.sellerObj?.followersCount ?? 0)", label: "Followers")
                     .onTapGesture {
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

                 Divider().frame(width: 1,height: 30)

                 statView(value: "\(objVM.sellerObj?.followingCount ?? 0)", label: "Following")
                     .onTapGesture {
                         if (objVM.sellerObj?.followingCount ?? 0) > 0 {
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
             }.padding(.vertical, 8)
             
             if ((objVM.itemArray.count == 0 && selectedTab == .products) || (objVM.boardArray.count == 0 && selectedTab == .boards))  && objVM.isDataLoading == false{
                 
                 HStack{
                     Spacer()
                     
                     VStack(spacing: 30){
                         Spacer()
                         Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                         Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding()
                         Spacer()
                     }
                     Spacer()
                 } .background(Color(.systemGray6))
             }else{
                 
                 if selectedTab == .products {
                     
                     // Products Section
                     ScrollView {
                         
                         LazyVGrid(columns: [GridItem(.flexible()),
                                             GridItem(.flexible())],
                                   spacing: 10) {
                             
                             ForEach($objVM.itemArray) { $item in
                                 
                                 ProductCard(objItem: $item,
                                             onItemLikeDislike: { likedObj in
                                     updateItemInList(likedObj)
                                 })
                                 .onAppear {
                                     
                                     if let lastItem = objVM.itemArray.last,
                                        lastItem.id == item.id,
                                        !objVM.isDataLoading {
                                         
                                         objVM.getItemListApi(sellerId: userId)
                                     }
                                 }
                                 .onTapGesture {
                                     
                                     var detailView = ItemDetailView(
                                         navController: self.navController,
                                         itemId: item.id ?? 0,
                                         itemObj: item,
                                         isMyProduct: true,
                                         slug: item.slug
                                     )
                                     
                                     detailView.returnValue = { value in
                                         if let obj = value {
                                             self.updateItemInList(obj)
                                         }
                                     }
                                     
                                     let hostingController =
                                     UIHostingController(rootView: detailView)
                                     
                                     self.navController?.pushViewController(hostingController,
                                                                            animated: true)
                                 }
                             }
                             
                         }
                                   .padding(.horizontal,8)
                                   .padding(.top,5)
                         
                         if objVM.isDataLoading {
                             ProgressView().padding()
                         }
                     }
                     .background(Color(.systemGray6))
                                         
                 } else {

                             //  BOARD GRID
                             
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
                                      
                                             
                                             let columns = splitColumns()
                                             
                                             HStack(alignment: .top, spacing: 6) {
                                                 
                                                 // LEFT COLUMN
                                                 LazyVStack(spacing: 6) {
                                                     ForEach(columns.left.indices, id: \.self) { index in
                                                         let item = columns.left[index]
                                                         
                                                         if item.boardType == 2 {
                                                             SmartVideoPlayerView(item: item,
                                                                                  onTapBottomButton: {
                                                                                  //Tapped vide
                                                                 if (item.outbondUrl ?? "").count > 0{

                                                                     outboundUrlClicked =  item.outbondUrl ?? ""
                                                                     openSafari = true
                                                                 }
                                                                 
                                                                                  })
                                                                 .background(
                                                                     GeometryReader { geo in
                                                                         Color.clear
                                                                             .onAppear {
                                                                                 videoFrames[item.id ?? 0] = geo.frame(in: .global)
                                                                                // scheduleVisibilityUpdate()

                                                                             }.onDisappear{
                                                                                 videoFrames.removeValue(forKey: item.id ?? 0)
                                                                                 FeedVideoManager.shared.pause(id: item.id ?? 0)
                                                                             }
                                                                             .onChange(of: geo.frame(in: .global)) { frame in
                                                                                 videoFrames[item.id ?? 0] = frame
                                                                                 //scheduleVisibilityUpdate()

                                                                             }
                                                                     }
                                                                 )
                                                                 .measureHeight(id: item.id ?? 0)
                                                                 .onAppear {
                                                                     handlePrefetch(itemIndex: globalIndex(of: item))
                                                                     prefetchNextVideos(from: item)

                                                                 }
                                                         } else {
                                                             CardItemView(
                                                                 item: item,
                                                                 onLike: { isLiked, boardId in
                                                                
                                                                     objVM.updateLike(boardId: boardId, isLiked: isLiked)
                                                                 },
                                                                 onTap: { pushToDetail(item: item) },
                                                                 onTapBoostButton:{
                                                                     if item.boardType == 1{
                                                                         //Ckicking on bottom
                                                                         if (item.outbondUrl ?? "").count > 0{
                                                                             outboundUrlClicked =  item.outbondUrl ?? ""
                                                                             openSafari = true
                                                                         }
                                                                     }else{
                                                                         paymentGatewayOpen(product: item)
                                                                     }
                                                                     
                                                                 },
                                                                 isToShowBoostButton:false
                                                                 
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
                                                     ForEach(columns.right.indices, id: \.self) { index in
                                                         let item = columns.right[index]
                                                         
                                                         if item.boardType == 2 {
                                                             SmartVideoPlayerView(item: item,
                                                                                  onTapBottomButton: {
                                                                                  //Tapped vide
                                                                 if (item.outbondUrl ?? "").count > 0{

                                                                     outboundUrlClicked =  item.outbondUrl ?? ""
                                                                     openSafari = true
                                                                 }
                                                                                  })
                                                                 .background(
                                                                     GeometryReader { geo in
                                                                         Color.clear
                                                                             .onAppear {
                                                                                 videoFrames[item.id ?? 0] = geo.frame(in: .global)
                                                                                // scheduleVisibilityUpdate()

                                                                             }.onDisappear{
                                                                                 videoFrames.removeValue(forKey: item.id ?? 0)
                                                                                 FeedVideoManager.shared.pause(id: item.id ?? 0)
                                                                             }
                                                                             .onChange(of: geo.frame(in: .global)) { frame in
                                                                                 videoFrames[item.id ?? 0] = frame
                                                                                // scheduleVisibilityUpdate()

                                                                             }
                                                                     }
                                                                 )
                                                                 .measureHeight(id: item.id ?? 0)
                                                                 .onAppear {
                                                                     handlePrefetch(itemIndex: globalIndex(of: item))
                                                                     prefetchNextVideos(from: item)

                                                                 }
                                                         } else {
                                                             CardItemView(
                                                                 item: item,
                                                                 onLike: { isLiked, boardId in
                                                                     objVM.updateLike(boardId: boardId, isLiked: isLiked)
                                                                 },
                                                                 onTap: { pushToDetail(item: item) },
                                                                 onTapBoostButton:{
                                                                     if item.boardType == 1{
                                                                         //Ckicking on bottom
                                                                         if (item.outbondUrl ?? "").count > 0{
                                                                             outboundUrlClicked =  item.outbondUrl ?? ""
                                                                             openSafari = true
                                                                         }
                                                                     }else{
                                                                         paymentGatewayOpen(product: item)
                                                                     }
                                                                 },
                                                                 isToShowBoostButton:false
                                                             )
                                                             .measureHeight(id: item.id ?? 0)
                                                             .onAppear {
                                                                 handlePrefetch(itemIndex: globalIndex(of: item))
                                                             }
                                                         }
                                                     }
                                                 }
                                             }
                                             .padding([.horizontal], 5)
                                
                                     Spacer()
                                     
                                     if objVM.isDataLoading {
                                         ProgressView().padding()
                                     }
                                     
                                 }.background(Color(.systemGray6))
                                 .scrollIndicators(.hidden, axes: .vertical)
                                 
                                 .onDisappear {
                                     FeedVideoManager.shared.muteAll()
                                     FeedVideoManager.shared.pauseAll()
                                 }
                                 .onChange(of: scrollTick) { _ in
                                     calculateVisibleVideos()
                                 }

                                 //  Capture measured heights
                                 .onPreferenceChange(ItemHeightKey.self) { value in
                                     itemHeights.merge(value) { $1 }
                                 }
                                 //  Detect REAL user scroll
                                 .simultaneousGesture(
                                     DragGesture()
                                         .onEnded { _ in
                                             userDidScroll = true
                                             paginationConsumed = false
                                         }
                                 )

                                 .onChange(of: objVM.boardArray.count) { _ in
                                     paginationConsumed = false
                                 }
                             }

                         }
                   
             }
             
         }.navigationBarHidden(true)
         
             .onAppear{
                 if selectedTab == .products{
                     if objVM.itemArray.count == 0{
                         objVM.getSellerProfile(sellerId: userId,nav: navController)
                         objVM.getItemListApi(sellerId: userId)
                     }
                 }else  if selectedTab == .boards{
                     if objVM.boardArray.count == 0{
                         objVM.getSellerProfile(sellerId: userId,nav: navController)
                         objVM.getBoardListApi()
                     }
                 }
             }
             .onChange(of: selectedTab) { value in
                 if value == .boards && objVM.boardArray.isEmpty  && !self.objVM.isDataLoading{
                     objVM.getBoardListApi()
                 }else if value == .products && objVM.itemArray.isEmpty && !self.objVM.isDataLoading{
                     objVM.getItemListApi(sellerId: userId)
                 }
             }
             .fullScreenCover(isPresented: $openSafari) {
               
                 if let url = URL(string:outboundUrlClicked.getValidUrl())  {
                     
                     SafariView(url:url)
                 }
             }
     }
    
     
     func getUrlValid(strURl:String) ->String{
         var urlString = strURl
         if !urlString.lowercased().hasPrefix("http://") &&
             !urlString.lowercased().hasPrefix("https://") {
             urlString = "https://" + urlString
         }
         return urlString
     }

     private func updateItemInList(_ value: ItemModel) {
         if let index = $objVM.itemArray.firstIndex(where: { $0.id == value.id }) {
             objVM.itemArray[index] = value
             
         }
     }
     
     // Function to create stats view
     private func statView(value: String, label: String,isSelected:Bool=false) -> some View {
         VStack {
             Text(value)
                 .font(.inter(.bold, size: 24))
                 .foregroundColor(isSelected ? .orange : .primary)

             Text(label)
                 .font(.inter(.regular, size: 14))
                 .foregroundColor(isSelected ? .orange : .gray)

         }
         .frame(maxWidth: .infinity)
     }
     
     
     func reportUserPush(){
         
         let hostingController = UIHostingController(rootView:ReportUserView(roportUserId:userId))
         self.navController?.pushViewController(hostingController, animated: true)
     }
     
     
       
       private func handlePrefetch(itemIndex: Int?) {

           guard let index = itemIndex else { return }

           let triggerIndex = max(objVM.boardArray.count - prefetchOffset, 0)

           // 1️⃣ Near bottom
           guard index >= triggerIndex else { return }

           // 2️⃣ Real scroll happened (works on all devices)
           guard scrollTick > lastScrollTick else { return }

           // 3️⃣ Prevent re-trigger for same data set
           guard objVM.boardArray.count > lastItemCount else { return }

           // 4️⃣ Safety guards
           guard !objVM.isDataLoading else { return }
           guard !objVM.canLoadMoreBoardPage else { return }

           paginationConsumed = true
           userDidScroll = false

           lastItemCount = objVM.boardArray.count
           lastScrollTick = scrollTick

           objVM.getBoardListApi()
       }

     
     private func prefetchNextVideos(from currentItem: ItemModel) {

         guard let index = objVM.boardArray.firstIndex(where: { $0.id == currentItem.id }) else { return }

         let start = index + 1
         let end = min(index + 2, objVM.boardArray.count - 1)

         guard start <= end else { return }

         var urls: [URL] = []

         for i in start...end {

             let item = objVM.boardArray[i]

             if item.boardType == 2,
                let link = item.videoLink,
                let url = URL(string: link) {

                 urls.append(url)
             }
         }

         VideoPreloadManagerDefault.shared.set(waiting: urls)
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
   
     private func handleSoundTransfer(visibleIDs: [Int]) {
 /*
         let manager = FeedVideoManager.shared
         
         guard let currentSound = manager.soundVideoID else {
             return
         }

         // If current sound owner still visible → do nothing
         if visibleIDs.contains(currentSound) {
             return
         }

         // 🔥 Transfer sound to next visible (if exists)
         manager.soundVideoID = visibleIDs.first */
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
                         navigationController: navController
                     )
                 )
                 vc.modalPresentationStyle = .overFullScreen
                 vc.modalTransitionStyle = .crossDissolve
                 vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                 navController?.present(vc, animated: true)
                 
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue), object:  ["boardId":product.id ?? 0], userInfo: nil)

             }
             
       
                self.paymentGateway = nil
         }

         paymentGateway?.initializeDefaults()
     }

   

       // MARK: - Split into 2 staggered columns
       private func splitColumns() -> (left: [ItemModel], right: [ItemModel]) {

           var left: [ItemModel] = []
           var right: [ItemModel] = []

           var leftHeight: CGFloat = 0
           var rightHeight: CGFloat = 0

           for item in objVM.boardArray {
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
           objVM.boardArray.firstIndex { $0.id == item.id }
       }
    
     // MARK: - Navigation
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
  
  
  */


 */
