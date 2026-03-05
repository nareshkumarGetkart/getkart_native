//
//  BoardDetailView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.
//

import SwiftUI
import Kingfisher

struct BoardDetailView: View{
    
    @State private var currentIndex: Int = 0
    var navigationController:UINavigationController?
    @State private var listArray:Array<ItemModel> = [ItemModel]()
    @State private var page = 1
    @State private var isDataLoading = true
    let itemObj:ItemModel
    @State  private var isLastPage = false
    
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
    @State private var visibilityWorkItem: DispatchWorkItem?
    @State private var openSafari: Bool = false
    @State private var outboundUrlClicked: String = ""

    var body: some View {
        
        // HEADER
        headerView.zIndex(1)
        
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
                        
                        ReelPostView(post: itemObj,
                                     sendLikeDislikeObject: { isLiked, boardId,likeCount  in
                            if let index = listArray.firstIndex(where: { $0.id == boardId }) {
                             // index is Int
                             print("Found at index:", index)
                             var obj = listArray[index]
                             obj.isLiked = isLiked
                             obj.totalLikes = likeCount
                             listArray[index] = obj
                             }
                        },onClickedUserProfile: { user in
                            self.pushToProfileScreen(user: user)
                        }).padding([.horizontal],5)
                        
                        let columns = splitColumns()
                        
                        HStack(alignment: .top, spacing: 6) {
                            
                            // LEFT COLUMN
                            LazyVStack(spacing: 6) {
//                                ForEach(columns.left.indices, id: \.self) { index in
//                                    let item = columns.left[index]
                                    ForEach(columns.left, id: \.id) { item in

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
                                           
                                                updateLike(boardId: boardId, isLiked: isLiked)
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
                                                
                                            }
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
//                                ForEach(columns.right.indices, id: \.self) { index in
//                                    let item = columns.right[index]
                                    ForEach(columns.right, id: \.id) { item in

                                        if item.boardType == 2 {
                                            SmartVideoPlayerView(
                                                item: item,
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
                                             updateLike(boardId: boardId, isLiked: isLiked)
                                            },
                                            onTap: { pushToDetail(item: item) },
                                            onTapBoostButton:{
                                                paymentGatewayOpen(product: item)
                                            }
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
            }.background(Color(.systemGray6))
            .scrollIndicators(.hidden, axes: .vertical)
            .onAppear {
                
                if listArray.count == 0{
                    getBoardListApi()
                    boardClickApi(post: itemObj)
                }
            }
            //  Detect REAL user scroll
                .simultaneousGesture(
                        DragGesture()
                            .onEnded { _ in
                          
                                scheduleVisibilityUpdate()
                            }
                    )
        
            .background(
                
                NavigationConfigurator { nav in
                    nav.interactivePopGestureRecognizer?.isEnabled = true
                    nav.interactivePopGestureRecognizer?.delegate = nil
                }
            ) //Added for swipe pop navigation
            
            .fullScreenCover(isPresented: $openSafari) {
                
                if let url = URL(string:outboundUrlClicked.getValidUrl())  {
                    
                    SafariView(url:url)
                }
            }
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
    private var headerView: some View {
        HStack {
            Button {
                navigationController?.popViewController(animated: true)
            } label: {
                Image("arrow_left")
                    .renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
            }
            .frame(width: 40, height: 40)

            Text(itemObj.category?.name ?? "")
                .font(Font.inter(.semiBold, size: 16))
                .foregroundColor(Color(UIColor.label))

            Spacer()

            if listArray.count > 0,
               (listArray[currentIndex].user?.id ?? 0) != Local.shared.getUserId() {

                Button {
                    openActionSheetToReportBoard(boardIndex: currentIndex)
                } label: {
                    Image("more")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }
                .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 5)
        .frame(height: 44)
        .background(Color(.systemBackground))
    }
  
    
    private func handlePrefetch(itemIndex: Int?) {

        guard let index = itemIndex else { return }

        let triggerIndex = max(listArray.count - prefetchOffset, 0)

        // 1️⃣ Near bottom
        guard index >= triggerIndex else { return }

        // 2️⃣ Real scroll happened (works on all devices)
        guard scrollTick > lastScrollTick else { return }

        // 3️⃣ Prevent re-trigger for same data set
        guard listArray.count > lastItemCount else { return }

        // 4️⃣ Safety guards
        guard !isDataLoading else { return }
        guard !isLastPage else { return }

        paginationConsumed = true
        userDidScroll = false

        lastItemCount = listArray.count
        lastScrollTick = scrollTick

        getBoardListApi()
    }


    // MARK: - Split into 2 staggered columns
    private func splitColumns() -> (left: [ItemModel], right: [ItemModel]) {

        var left: [ItemModel] = []
        var right: [ItemModel] = []

        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0

        for item in listArray {
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
        listArray.firstIndex { $0.id == item.id }
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
    
    
    private func pushToProfileScreen(user: User) {
        let vc = UIHostingController(
            rootView: SellerProfileView(navController: navigationController, userId: user.id ?? 0)
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Like update
    func updateLike(boardId: Int, isLiked: Bool) {
        if let index = listArray.firstIndex(where: { $0.id == boardId }) {
            listArray[index].isLiked = isLiked
            self.manageLikeDislikeApi(boardId: boardId, isLiked: isLiked)
        }
    }
    //MARK: Api methods
    func boardClickApi(post:ItemModel){
        
       
        let params = ["board_id":post.id ?? 0]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.board_click, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
               // let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                }else{ }
            }
        }
    }
    func getBoardListApi(){
        
        if self.page == 1{
            self.listArray.removeAll()
        }
        let strUrl = Constant.shared.get_related_boards + "?page=\(page)&category_id=\(itemObj.categoryID ?? 0)&exclude_id=\(itemObj.id ?? 0)"

 
        self.isDataLoading = true
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl,loaderPos: .mid) { (obj:ItemParse) in
            
            if obj.code == 200 {
             
                DispatchQueue.main.async {
                    let newItems = obj.data?.data ?? []
                    guard !newItems.isEmpty else {
                        self.isDataLoading = false
                        
                        return }

                    self.listArray.append(contentsOf: newItems)
                    self.page += 1
                    self.isDataLoading = false
                    
                    
                    let currentPage = obj.data?.currentPage as? Int ?? page
                    let last = obj.data?.lastPage as? Int ?? page
                    self.isLastPage = currentPage >= last
                }
                

            }else{
                self.isDataLoading = false
            }
        }
    }
    
    // MARK: - Like / Unlike (unchanged)
    func manageLikeDislikeApi(boardId: Int, isLiked: Bool) {
        guard let index = listArray.firstIndex(where: { $0.id == boardId }) else { return }

        let params = ["board_id": boardId]
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.manage_board_favourite,
            param: params,
            methodType: .post
        ) { responseObject, error in
            guard error == nil else { return }

            if let result = responseObject{
                let status = result["code"] as? Int ?? 0
                
                if status == 200,
                   let data = result["data"] as? [String: Any],
                   let count = data["favourite_count"] as? Int {
                    DispatchQueue.main.async {
                        self.listArray[index].totalLikes = count
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshLikeDislikeBoard.rawValue), object:  ["isLike":isLiked,"count":count,"boardId":boardId], userInfo: nil)
                    
                }
            }
        }
    }
    
    
    
    func openActionSheetToReportBoard(boardIndex:Int){
        
        if listArray[boardIndex].isAlreadyReported == true{
            AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Already reported.")
        }else{
            let sheet = UIAlertController(
                title: "",
                message: nil,
                preferredStyle: .actionSheet
            )
            
            let strText = "Report Board"
            sheet.addAction(UIAlertAction(title: strText, style: .default, handler: { action in
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    let reportAds =  ReportAdsView(itemId:(listArray[boardIndex].id ?? 0),isToReportBoard:true) {bool in
                        listArray[boardIndex].isAlreadyReported = bool
                    }
                    let destVC = UIHostingController(rootView:reportAds)
                    destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
                    destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
                    destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                    self.navigationController?.present(destVC, animated: true, completion: nil)
                }
            }))
            
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            UIApplication.shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?
                .rootViewController?
                .present(sheet, animated: true)
        }
    }
}

struct ReelPostView: View {
    @State var post: ItemModel
    var sendLikeDislikeObject: (_ isLiked:Bool, _ boardId:Int, _ likeCount:Int) -> Void
    @State private var showSeeMore = false
    @State private var isTextTruncated = false
    @State private var showSafari = false
    @State private var showComments = false
    @State private var showCommentSeeMore = false
    @State private var isCommentTextTruncated = false
    @State private var showShareSheet = false
    var onClickedUserProfile:(_ user:User) -> Void

    var body: some View {

        VStack(spacing: 0) {
            PostImagesCarousel(images: post.galleryImages ?? [])
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .shadow(
                            color: Color(.label).opacity(0.18),
                            radius: 7,
                            x: 0,
                            y: 5
                        )  )
              
            //  FLAT CONTENT (NO CARD)
            bottomCard
                .padding(.horizontal,8)
                .padding(.top, 10)
            
            if (post.lastComment?.comment?.count ?? 0) > 0 {
              
                HStack{
                 
                    Button {
                        
                    } label: {
                      
                        AsyncImage(url: URL(string: post.lastComment?.user?.profile ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30,height:30)
                                .clipped()
                        } placeholder: {
                            Image("getkartplaceholder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30,height:30)
                                .clipped()
                        }.onTapGesture {
                            if let obj = post.lastComment?.user{
                                onClickedUserProfile(obj)
                            }
                        }
                        
                    }.frame(width: 30,height:30)
                    .cornerRadius(15.0)
                    
                    VStack(alignment:.leading ,spacing: 0){
                        Text(post.lastComment?.user?.name ?? "").font(.inter(.medium, size: 13)).lineLimit(1)
                        HStack{
                           
                            // Spacer()
                            if (post.commentsCount ?? 0) > 1{
                                Text(post.lastComment?.comment ?? "").font(.inter(.regular, size: 11)).lineLimit(1)
                                Text("...").font(.inter(.medium, size: 13)).foregroundColor(Color(.gray))
                                Button {
                                    showComments = true
                                } label: {
                                    
                                    Text("See all comments")
                                        .font(.inter(.bold, size: 14))
                                        .foregroundColor(Color(.label))
                                }
                            }else{
                                Text(post.lastComment?.comment ?? "").font(.inter(.regular, size: 11))
                            }
                        }
                       
//                        ZStack(alignment: .bottomTrailing) {
//                            
//                            TruncatableText(
//                                text: post.lastComment?.comment ?? "",
//                                lineLimit: 1,
//                                font: .inter(.regular, size: 12)
//                            ) { truncated in
//                                isCommentTextTruncated = truncated
//                            }.padding(.trailing, isCommentTextTruncated ? 125 : 0) //  space for "See more"
//                            
//                            if isCommentTextTruncated{
//                                Button {
//                                    showComments = true
//                                } label: {
//                                    Text("See all comments")
//                                        .font(.inter(.bold, size: 14))
//                                        .foregroundColor(Color(.label))
//                                }
//                            }
//                        }
                       // Text(post.lastComment?.comment ?? "").lineLimit(1)
                    }
                    Spacer()
                }.padding()
            }
           
             if (post.user?.id ?? 0) != Local.shared.getUserId(){
              
                //  BUY NOW
                Button {
                    showSafari = true
                    outboundClickApi(strURl: post.outbondUrl ?? "")
                } label: {
                    Text("Buy Now")
                        .font(.inter(.semiBold, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 55)
                }
                .background(Color(hexString: "#FF9900"))
                .cornerRadius(10)
                .padding()
             }else{
                 HStack{
                     Spacer()
                 }.frame(height:8)
             }
            
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        )
           
        .sheet(isPresented: $showSeeMore) {
                DynamicHeightSheet(
                    content:SeeMorePopupView(title: post.name ?? "", description: post.description ?? "", onBuy: {
                        showSeeMore = false
                        showSafari = true
                        outboundClickApi(strURl: post.outbondUrl ?? "")
                    }, ctaLabel: post.ctaLabel ?? "Buy Now")
                )
           
        }

        .fullScreenCover(isPresented: $showSafari) {
              
                if let url = URL(string:getUrlValid(strURl: post.outbondUrl ?? ""))  {
                    
                    SafariView(url:url)
                }
        }
           
        .sheet(isPresented: $showComments) {
                CommentsView(itemObj: post) {
                    showComments = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
           
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
    
    private var imageHeight: CGFloat {
        UIScreen.main.bounds.height * 0.45
    }


    private var bottomCard: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack{
                
                if (post.user?.id ?? 0) != Local.shared.getUserId(){
              
                    HStack(spacing:3){
                        Button {
                            if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                                post.isLiked?.toggle()
                                manageLikeDislikeApi()
                            }
                        } label: {
                            let imgStr = (post.isLiked == true) ? "like_fill" : "like"
                            Image(imgStr).foregroundColor(Color(.label))
                        }
                        if (post.totalLikes ?? 0) > 0{
                            
                            Text("\(post.totalLikes ?? 0)").font(Font.inter(.regular, size: 14)).foregroundColor(Color(.label))
                        }
                    }
                }
                
                
                Button {
                    
                    showComments = true
                } label: {
                    HStack(spacing:3){
                        Image("messageIcon").renderingMode(.template).foregroundColor(Color(.label))
                        if (post.commentsCount ?? 0) > 0{
                            Text("\((post.commentsCount ?? 0))").font(.inter(.medium, size: 14)).foregroundColor(Color(.label))
                        }
                    }
                }
                
                Button {
                    showShareSheet = true
                } label: {
                    Image("Share-outline")//.renderingMode(.template).foregroundColor(Color(hex: "#818181"))
                }
                .actionSheet(isPresented: $showShareSheet) {
                    ActionSheet(
                        title: Text(""),
                        message: nil,
                        buttons: [
                            .default(Text("Copy Link"), action: {
                                UIPasteboard.general.string = ShareMedia.boardUrl + "\(post.id ?? 0)"
                                AlertView.sharedManager.showToast(message: "Copied successfully.")
                            }),
                            .default(Text("Share"), action: {
                                
                                ShareMedia.shareMediafrom(type: .board, mediaId: "\(post.id ?? 0)", controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                            }),
                            .cancel()
                        ]
                    )
                }
                
                Spacer()
                if (post.isFeature ?? false){
                    Text("Sponsored").font(.inter(.medium, size: 16)).foregroundColor(Color(.gray))
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(post.name ?? "")
                    .font(.inter(.medium, size: 18))
                    .foregroundColor(Color(.label))
                //Text(post.description ?? "") .font(.inter(.regular, size: 14))
                
                ZStack(alignment: .bottomTrailing) {
                    
                    TruncatableText(
                        text: post.description ?? "",
                        lineLimit: 2,
                        font: .inter(.regular, size: 14)
                    ) { truncated in
                        isTextTruncated = truncated
                    }.padding(.trailing, isTextTruncated ? 65 : 0) // 👈 space for "See more"
                    
                    if isTextTruncated {
                        Button {
                            showSeeMore = true
                        } label: {
                            Text("See more")
                                .font(.inter(.bold, size: 14))
                                .foregroundColor(Color(.label))
                        }
                    }
                }
                
                if (post.specialPrice ?? 0.0) > 0{
                    HStack{
                        Text("\(Local.shared.currencySymbol)\((post.specialPrice ?? 0.0).formatNumber())")
                            .font(.inter(.medium, size: 18))
                            .foregroundColor(Color(hex: "#008838"))
                        Text("\(Local.shared.currencySymbol)\((post.price ?? 0.0).formatNumber())")
                            .font(.inter(.medium, size: 15))
                            .foregroundColor(Color(.gray)).strikethrough(true, color: .secondary)
                        let per = (((post.price ?? 0.0) - (post.specialPrice ?? 0.0)) / (post.price ?? 0.0)) * 100.0
                        Text("\(per.formatNumber())% Off").font(.inter(.medium, size: 12))
                            .foregroundColor(Color(hex: "#008838"))
                        
                    }.padding(.top,5)
                        

                }else{
                   
                    Text("\(Local.shared.currencySymbol) \((post.price ?? 0.0).formatNumber())")
                        .font(.inter(.medium, size: 18))
                        .foregroundColor(Color(hex: "#008838")).padding(.top,5)
                }
            }
            
//            Button {
//                outboundClickApi(strURl: post.outbondUrl ?? "")
//            } label: {
//                
//                Text("Buy Now").font(.inter(.semiBold, size: 16.0)).foregroundColor(.white).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
//                  
//            }.background(Color(hexString: "#FF9900"))
//             .cornerRadius(8).padding([.bottom,.top])
        }

    }
    
    
    
    func outboundClickApi(strURl:String){
        
        let params = ["board_id":post.id ?? 0]
        
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
        
      /*   var urlString = strURl
         if !urlString.lowercased().hasPrefix("http://") &&
               !urlString.lowercased().hasPrefix("https://") {
                urlString = "https://" + urlString
            }
        if let url = URL(string: urlString)  {
            print(urlString)
            let vc = UIHostingController(rootView:  PreviewURL(fileURLString:urlString,isCopyUrl:true))
            AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)
            
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                print("Cannot open URL")
//            }
        }*/
      
    }
    

    
    
    func manageLikeDislikeApi(){
        
        let params = ["board_id":post.id ?? 0]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_board_favourite, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    if let  data = result["data"] as? Dictionary<String,Any>{
                     
                        if let favouriteCount = data["favourite_count"] as? Int{
                            
                            post.totalLikes = favouriteCount
                          
                            self.sendLikeDislikeObject(post.isLiked ?? false, post.id ?? 0, favouriteCount)
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshLikeDislikeBoard.rawValue), object:  ["isLike":post.isLiked ?? false,"count":favouriteCount,"boardId":self.post.id ?? 0], userInfo: nil)


                        }
                    }
                    
                }else{
                    
                }
            }
        }
    }
}

struct VerticalPager<Content: View>: UIViewControllerRepresentable {

    var pages: [Content]
    var onPageChange: ((Int) -> Void)?   // 👈 callback

    func makeUIViewController(context: Context) -> PagerVC {
        let vc = PagerVC()
        vc.onPageChange = onPageChange
        vc.setPages(pages)
        //vc.pages = pages.map { UIHostingController(rootView: $0) }
        return vc
    }

    func updateUIViewController(_ uiViewController: PagerVC, context: Context) {
        
        uiViewController.setPages(pages)
    }
}

class PagerVC: UIViewController, UIScrollViewDelegate {

    private(set) var pages: [UIViewController] = []
    let scrollView = UIScrollView()

    private var lastIndex = 0
    var onPageChange: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true   // 🔥 IMPORTANT
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPages()
    }

    // 🔥 APPEND-SAFE PAGE UPDATE
    func setPages(_ newPages: [some View]) {
        guard newPages.count >= pages.count else { return }

        let oldCount = pages.count
        let currentOffset = scrollView.contentOffset

        for index in oldCount..<newPages.count {
            let vc = UIHostingController(rootView: newPages[index])
            addChild(vc)
            vc.view.backgroundColor = .systemBackground
            scrollView.addSubview(vc.view)
            vc.didMove(toParent: self)
            pages.append(vc)
        }

        layoutPages()
        scrollView.contentOffset = currentOffset   // 🔒 preserve position
    }

    private func layoutPages() {
        scrollView.frame = view.bounds

        let pageHeight = view.bounds.height
        let pageWidth = view.bounds.width

        scrollView.contentSize = CGSize(
            width: pageWidth,
            height: pageHeight * CGFloat(pages.count)
        )

        for (i, vc) in pages.enumerated() {
            vc.view.frame = CGRect(
                x: 0,
                y: pageHeight * CGFloat(i),
                width: pageWidth,
                height: pageHeight
            )
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.y / view.bounds.height))
        if index != lastIndex {
            lastIndex = index
            onPageChange?(index)
        }
    }
}



struct PostImagesCarousel: View {
    
    let images: [GalleryImage]
    @State private var selectedIndex = 0
    
    var body: some View {
        
        TabView(selection: $selectedIndex) {
            
            ForEach(Array(images.enumerated()), id: \.element.id) { index, img in
                
                if let url = URL(string: img.image ?? "") {
                    
                    
                    KFImage(url)
                      .setProcessor(
                            DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
                        )
                        .scaleFactor(UIScreen.main.scale)
                        .cacheOriginalImage(false)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                    
//                    AsyncImage(url: url) { image in
//                        image.scaleFactor(UIScreen.main.scale)
//                            .resizable()
//                            .scaledToFit()
//                           .frame(height: 350)
//                            .clipped()
//                    } placeholder: {
//                        Image("getkartplaceholder")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 350)
//                            .clipped()
//                    }
                    .tag(index)
                }
            }
        }
        .frame(height: 350)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .clipShape(RoundedRectangle(cornerRadius: 10)) //  important
        //.padding(.horizontal, 5)
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.orange
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
        }
    }
}


struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            if let nav = vc.navigationController {
                configure(nav)
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}



import UIKit
import CoreImage
import SafariServices

extension UIImage {

    func averageColorNew() -> UIColor? {
        guard let ciImage = CIImage(image: self) else { return nil }

        let extent = ciImage.extent
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: ciImage,
                kCIInputExtentKey: CIVector(
                    x: extent.origin.x,
                    y: extent.origin.y,
                    z: extent.size.width,
                    w: extent.size.height
                )
            ]
        )

        guard let outputImage = filter?.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1
        )
    }
}



/*  var body: some View {

      VStack(spacing: 0) {

          // IMAGE
          GeometryReader { geo in
            //  ZStack(alignment:.top){
              ZStack(alignment: .top) {
                  // avgColor   // 🔥 background from image

               /*   AsyncImage(url: URL(string: post.image ?? "")) { img in
                      img
                          .resizable()
                      
                      
                          .scaledToFit()
                          //.frame(width: geo.size.width, height: geo.size.height)
                          .frame(maxWidth: .infinity)
                      // .clipped()
//                            .cornerRadius(10)
//                            .shadow(
//                                color: Color.black.opacity(0.10),
//                                radius: 7,
//                                x: 0,
//                                y: 2
//                            )
                          . padding(0)
                          .onAppear {
                             // extractAverageColor(from: img)
                          }
                  } placeholder: {
                      Color.black
                  }*/
                  
                  if let url = URL(string: post.image ?? "") {
                      
                      
                     // GeometryReader { geo in
                          KFImage(url)
                              .resizable()
                             // .scaledToFill()
                              //.frame(width: geo.size.width,height:imgHeight)
                              //.aspectRatio(3/4, contentMode: .fill)
                              .onSuccess { result in
                                              let size = result.image.size
                                              if size.height > 0 {
                                                  imageRatio = size.width / size.height
                                              }
                                          }
                                          .scaledToFill()
                                          .aspectRatio(imageRatio, contentMode: .fit)
                              .clipped()
//                                .cornerRadius(8)
//                                .shadow(
//                                    color: Color.black.opacity(0.10),
//                                    radius: 7,
//                                    x: 0,
//                                    y: 2
//                                )
  //                    }
  //                    .frame(height: imgHeight)
                  }

              }.background(Color(.systemBackground))
//                   .frame(width: geo.size.width, height: geo.size.height)
                  .frame(maxWidth: .infinity)
                  .frame(height: min(geo.size.height, UIScreen.main.bounds.height * 0.6))

              .cornerRadius(15)
                  .shadow(
                      color: Color.black.opacity(0.6),
                      radius: 15,
                      x: 0,
                      y: 6
                  )
          }
          //.cornerRadius(10)

          // BOTTOM CARD (ALWAYS VISIBLE)
          bottomCard.padding()
        //  Spacer()
          Button {
              outboundClickApi(strURl: post.outbondUrl ?? "")
          } label: {
              
              Text("Buy Now").font(.inter(.semiBold, size: 16.0)).foregroundColor(.white).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                
          }.background(Color(hexString: "#FF9900"))
              .cornerRadius(8).padding([.bottom,.top]).padding(.horizontal)
          
      }
          .background(Color(.systemBackground))
          //.cornerRadius(10)
          .clipped()
          //.padding(0)
  }
*/
  
//    private func extractAverageColor(from image: Image) {
//            let renderer = ImageRenderer(content: image)
//            renderer.scale = UIScreen.main.scale
//
//            if let uiImage = renderer.uiImage,
//               let color = uiImage.averageColor {
//                avgColor = Color(color)
//            }
//        }



/*
class PagerVC: UIViewController, UIScrollViewDelegate {

    var pages: [UIViewController] = []
    let scrollView = UIScrollView()

    private let pageSpacing: CGFloat = 0
    
    
      var onPageChange: ((Int) -> Void)?
      private var lastIndex = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.isOpaque = false
        scrollView.delegate = self
        scrollView.bounces = false

        view.addSubview(scrollView)
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let pageHeight = view.frame.height
        let pageWidth = view.frame.width

        scrollView.frame = view.bounds

        // ⭐ UPDATED contentSize with spacing
        scrollView.contentSize = CGSize(
            width: pageWidth,
            height: (pageHeight * CGFloat(pages.count)) +
                    (pageSpacing * CGFloat(pages.count - 1))
        )

        for (i, vc) in pages.enumerated() {
            if vc.view.superview == nil {
                addChild(vc)
                vc.view.backgroundColor = .systemGray5
                scrollView.addSubview(vc.view)
                vc.didMove(toParent: self)
            }

            // ⭐ UPDATED Y position with spacing
            vc.view.frame = CGRect(
                x: 0,
                y: (pageHeight + pageSpacing) * CGFloat(i),
                width: pageWidth,
                height: pageHeight
            )
        }
    }
    
    // ✅ THIS IS WHERE currentIndex COMES FROM
       func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
           let index = Int(round(scrollView.contentOffset.y / view.bounds.height))

           if index != lastIndex {
               lastIndex = index
               onPageChange?(index)
           }
       }
}
*/


/*  func boardClickApi(){
      
      let params = ["board_id":post.id ?? 0]
      
      URLhandler.sharedinstance.makeCall(url: Constant.shared.board_click, param: params,methodType: .post) { responseObject, error in
          
          if error == nil{
              
              let result = responseObject! as NSDictionary
              let status = result["code"] as? Int ?? 0
              let message = result["message"] as? String ?? ""
              
              if status == 200{
              }else{
              }
          }
      }
  }*/







struct TruncatableText: View {
    let text: String
    let lineLimit: Int
    let font: Font
    let onTruncationChange: (Bool) -> Void

    @State private var isTruncated = false

    var body: some View {
        Text(text)
            .font(font)
            .lineLimit(lineLimit)
            .background(
                Text(text)
                    .font(font)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .background(
                        GeometryReader { fullGeo in
                            Color.clear.onAppear {
                                DispatchQueue.main.async {
                                    let fullHeight = fullGeo.size.height
                                    let limitedHeight = UIFont.preferredFont(forTextStyle: .body).lineHeight * CGFloat(lineLimit)
                                    let truncated = fullHeight > limitedHeight
                                    isTruncated = truncated
                                    onTruncationChange(truncated)
                                }
                            }
                        }
                    )
            )
    }
}


struct SeeMorePopupView: View {
    let title: String
    let description: String
    let onBuy: () -> Void
    let ctaLabel:String?
    
    var body: some View {
        VStack(spacing: 14) {

            Text(title)
                .font(.inter(.semiBold, size: 18))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)

            Text(description)
                .font(.inter(.medium, size: 16))
               .foregroundColor(Color(hex: "#666666"))

            Button(action: onBuy) {
                Text( ctaLabel ?? "Buy Now")
                    .font(.inter(.medium, size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(hexString: "#FF9900"))
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}




final class DynamicHeightSheetController<Content: View>: UIViewController {

    private let host: UIHostingController<Content>

    init(content: Content) {
        self.host = UIHostingController(rootView: content)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        host.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let sheet = sheetPresentationController else { return }

        let targetHeight = host.view.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width,
                   height: UIView.layoutFittingCompressedSize.height)
        ).height

        sheet.detents = [
            .custom { _ in
                min(targetHeight + 16, UIScreen.main.bounds.height * 0.8)
            }
        ]

        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 22
        sheet.largestUndimmedDetentIdentifier = .none
    }
}


struct DynamicHeightSheet<Content: View>: UIViewControllerRepresentable {

    let content: Content

    func makeUIViewController(context: Context) -> UIViewController {
        DynamicHeightSheetController(content: content)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
