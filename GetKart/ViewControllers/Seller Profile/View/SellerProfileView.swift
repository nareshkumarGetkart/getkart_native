//
//  SellerProfileView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/03/25.
//

import SwiftUI


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
    init(navController: UINavigationController? = nil, userId: Int) {
           self.navController = navController
           self.userId = userId
           _objVM = StateObject(wrappedValue: ProfileViewModel(userId: userId))
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
                                                                            }.onDisappear{
                                                                                print("dissapearing video \(item.id ?? 0)")
                                                                                videoFrames.removeValue(forKey: item.id ?? 0)
                                                                                FeedVideoManager.shared.pause(id: item.id ?? 0)
                                                                            }
                                                                            .onChange(of: geo.frame(in: .global)) { frame in
                                                                                videoFrames[item.id ?? 0] = frame
                                                                            }
                                                                    }
                                                                )
                                                                .measureHeight(id: item.id ?? 0)
                                                                .onAppear {
                                                                    handlePrefetch(itemIndex: globalIndex(of: item))
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
                                                                            }.onDisappear{
                                                                                print("dissapearing video \(item.id ?? 0)")
                                                                                videoFrames.removeValue(forKey: item.id ?? 0)
                                                                                FeedVideoManager.shared.pause(id: item.id ?? 0)
                                                                            }
                                                                            .onChange(of: geo.frame(in: .global)) { frame in
                                                                                videoFrames[item.id ?? 0] = frame
                                                                            }
                                                                    }
                                                                )
                                                                .measureHeight(id: item.id ?? 0)
                                                                .onAppear {
                                                                    handlePrefetch(itemIndex: globalIndex(of: item))
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
//                                .onAppear {
//                                    
//                                    if objVM.boardArray.count == 0{
//                                        objVM.getBoardListApi()
//                                    }
//                                }
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


#Preview {
    SellerProfileView(navController: nil,userId: 33925)
}




/*struct SellerProfileView: View {
    
    var navController:UINavigationController?
    var userId:Int = 0
//    @ObservedObject private var objVM = ProfileViewModel()
    @StateObject private var objVM = ProfileViewModel()

    @State var showShareSheet = false
    @State var showOptionSheet = false
    
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
                
                Text("Seller Profile")
                    .font(.manrope(.bold, size: 18))
                    .foregroundColor(Color(.label))
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {
                        // Handle share action
                        showShareSheet = true
                    }) {
                        Image("share").renderingMode(.template)
                            .font(.title2)
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
                            Image(systemName: "ellipsis")
                                .font(.title2)
                                .foregroundColor(Color(UIColor.label))
                        } .actionSheet(isPresented: $showOptionSheet) {
                            
                            
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
            
            HStack {
                
                
                ContactImageSwiftUIView(name: objVM.sellerObj?.name ?? "", imageUrl: objVM.sellerObj?.profile ?? "", fallbackImageName: "user-circle", imgWidth: 80, imgHeight: 80)
                
                HStack{
                    Text(objVM.sellerObj?.name ?? "")
                        .font(.manrope(.medium, size: 15))
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
                        Text(strText).font(.manrope(.medium, size: 15))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .foregroundColor(Color(.white))
                            .cornerRadius(20)
                            .font(Font.manrope(.semiBold, size: 15.0))
                    }
                }
            }
            .padding(.horizontal, 10)
            
            // Stats Section
            HStack {
                
                statView(value: "\(objVM.sellerObj?.items ?? 0)", label: "Products")
                
                Divider().frame(width: 1,height: 30).background(.gray)
                
                statView(value: "\(objVM.sellerObj?.followersCount ?? 0)", label: "Followers")
                    .onTapGesture {
                        
                        if (objVM.sellerObj?.followersCount ?? 0) > 0{
                            if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                                let hostVC = UIHostingController(rootView: FollowerListView(navController: navController,isFollower: true,userId: userId))
                                self.navController?.pushViewController(hostVC, animated: true)
                            }
                        }
                    }
                
                Divider().frame(width: 1,height: 30).background(.gray)
                
                statView(value: "\(objVM.sellerObj?.followingCount ?? 0)", label: "Following")
                    .onTapGesture {
                        
                        if (objVM.sellerObj?.followingCount ?? 0) > 0{
                            if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                                
                                let hostVC = UIHostingController(rootView: FollowerListView(navController: navController,isFollower: false,userId: userId))
                                self.navController?.pushViewController(hostVC, animated: true)
                            }
                        }
                    }
                
            }.padding(.vertical, 8)
            
            
            if objVM.itemArray.count == 0  && objVM.isDataLoading == false{
                
                HStack{
                    Spacer()
                    
                    VStack(spacing: 30){
                        Spacer()
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding()
                        Spacer()
                    }
                    Spacer()
                }
            }else{
                // Products Section
                ScrollView {

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        
                        ForEach($objVM.itemArray) { $item in
                            
                            ProductCard(objItem: $item, onItemLikeDislike: {likedObj in
                                updateItemInList(likedObj)
                                
                            })
                            .onAppear {
                                
                                if let lastItem = objVM.itemArray.last, lastItem.id == item.id, !objVM.isDataLoading {
                                    objVM.getItemListApi(sellerId: userId)
                                }
                            }
                            .onTapGesture {
                                var detailView =  ItemDetailView(navController:   self.navController, itemId: item.id ?? 0, itemObj: item,isMyProduct:true, slug: item.slug)
                                
                                detailView.returnValue = { value in
                                    if let obj = value{
                                        self.updateItemInList(obj)
                                    }
                                }
                                let hostingController = UIHostingController(rootView:detailView)
                                
                                self.navController?.pushViewController(hostingController, animated: true)
                            }
                        }
                    }.padding(.horizontal,8).padding(.top,5)
                    
                    if objVM.isDataLoading {
                        ProgressView()
                            .padding()
                    }
                    
                }.background(Color(.systemGray6))
            }
            
        }.navigationBarHidden(true)
        
            .onAppear{
                if objVM.itemArray.count == 0{
                    objVM.getSellerProfile(sellerId: userId,nav: navController)
                    objVM.getItemListApi(sellerId: userId)
                }
            }
    }
   
    private func updateItemInList(_ value: ItemModel) {
        if let index = $objVM.itemArray.firstIndex(where: { $0.id == value.id }) {
            objVM.itemArray[index] = value
            
        }
    }
    
    // Function to create stats view
    private func statView(value: String, label: String) -> some View {
        VStack {
            Text(value)
                .font(.manrope(.bold, size: 16))

            Text(label)
                .font(.manrope(.regular, size: 15))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    
    func reportUserPush(){
        
        let hostingController = UIHostingController(rootView:ReportUserView(roportUserId:userId))
        self.navController?.pushViewController(hostingController, animated: true)
    }
}*/




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
