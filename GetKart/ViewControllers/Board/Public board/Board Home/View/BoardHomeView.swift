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
import Kingfisher

//MARK: - BoardHomeView

private let maxEqualizationHeight: CGFloat = 100
private let maxCardHeight: CGFloat = 350 // or whatever looks good

struct BoardHomeView: View {

    @State private var selectedCategoryId: Int = 55555
    @State private var selectedName: String = "All"
    let tabBarController: UITabBarController?
    @StateObject private var categoryVM = CategoryViewModelOptimized(type: 2, isToShowLoader: false)
    @StateObject private var boardStore = BoardStoreNew()
    @State private var loadedCategoryIds: [Int] = [55555]
    private let maxLoadedTabs = 3
    @State private var isUpdatedEvents: Bool = true
    @State private var showCompleteProfilePopup = false
    
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
        
            .fullScreenCover(isPresented: $showCompleteProfilePopup) {
                CompleteProfilePopup(
                    onClose: {
                        showCompleteProfilePopup = false
                    },
                    onSave: { name in
                        print(name)
                        updateProfile(fullName: name)
                        showCompleteProfilePopup = false
                    }
                )
                .background(.clear)
                .presentationBackground(.clear)
            }
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
    
    func updateProfile(fullName:String){
       
        let params = ["name":fullName] as [String : Any]

        
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: nil, imageName: "profile", url: Constant.shared.update_profile, params: params) { responseObject, error in
            
            if error == nil{
                
                
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200{
                    
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        
                        RealmManager.shared.updateUserData(dict: data)
                       
                        
                    }
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
            }
        }
    }
    
}



extension BoardHomeView{
    
    //MARK: Api methods
    
    
    func updateUserTypeApi(type:Int){
        
        let reqDict = ["user_type":type]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.update_user_type, param: reqDict,methodType: .post,showLoader: true) { responseObject, error in
            
            if error == nil{
                if let result = responseObject{
                    let code = result["code"] as? Int ?? 0
                    if code == 200{
                        RealmManager.shared.updateUserType(type: type)
                    }
                }
            }
            
        }
    }
    
    func getUserSelectionPopupApi(){
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.get_userSelection_popup, param: nil,methodType: .get) { response, error in
            if error == nil{
                
                if let result = response{
                    if let data = result["data"] as? Dictionary<String,Any>{
                        let user_type = data["user_type"] as? Int ?? 0
                        RealmManager.shared.updateUserType(type: user_type)
                        
                        if user_type == 0{
                            showBuyerSellerPopup()
                        }
                    }
                }
                
            }
        }
       
    }
    
    func getpopupApi(){
      
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        
        print("USER TYPE == \(objLoggedInUser.userType)")
        if objLoggedInUser.userType == 0 || objLoggedInUser.userType == nil{
            /*
             user_type => 0 means user neither seller nor buyer
             user_type => 1 means user is buyer
             user_type => 2 means user is seller
             */
            //showBuyerSellerPopup()
            getUserSelectionPopupApi()
            
        }else if (objLoggedInUser.name ?? "").lowercased() == "guest user" || (objLoggedInUser.name ?? "").count == 0 {
            showCompleteProfilePopup = true
       
        }else{
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
    }
  
    func presentHostingController(objPopup: PopupModel) {
        
        let boardNav = tabBarController?.viewControllers?[0] as? UINavigationController
        
        guard let topVC = AppDelegate.sharedInstance.navigationController?.topViewController,
              let topView = topVC.view else { return }
        
        if let imageUrl = objPopup.image, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            
            KingfisherManager.shared.retrieveImage(with: url) { result in  // ✅ No [weak self]
                
                DispatchQueue.main.async {
                    var imageHeight: CGFloat = 220
                    var downloadedImage: UIImage? = nil
                    
                    switch result {
                    case .success(let value):
                        downloadedImage = value.image
                        let screenWidth = UIScreen.main.bounds.width
                        let aspectRatio = value.image.size.height / value.image.size.width
                        let computed = screenWidth * aspectRatio
                        imageHeight = min(max(computed, 160), 420)
                        
                    case .failure:
                        imageHeight = 220
                    }
                    
                    self.showSheet(  // ✅ Just self — safe for structs
                        objPopup: objPopup,
                        image: downloadedImage,
                        imageHeight: imageHeight,
                        topVC: topVC,
                        topView: topView,
                        boardNav: boardNav
                    )
                }
            }
            
        } else {
            showSheet(
                objPopup: objPopup,
                image: nil,
                imageHeight: 0,
                topVC: topVC,
                topView: topView,
                boardNav: boardNav
            )
        }
    }

    private func showSheet(
        objPopup: PopupModel,
        image: UIImage?,
        imageHeight: CGFloat,
        topVC: UIViewController,
        topView: UIView,
        boardNav: UINavigationController?
    ) {
        var sheet: SheetViewController!

        let settingView = BottomSheetPopupView1(
            objPopup: objPopup,
            preloadedImage: image,        // ✅ Pass already downloaded image
            preloadedImageHeight: imageHeight, // ✅ Pass already computed height
            pushToScreenFromPopup: { obj, dismissOnly in
               // guard let self = self else { return }
                
                if sheet.options.useInlineMode {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                
                guard !dismissOnly else { return }
                
                switch obj.type ?? 0 {
                case 5:
                    let destVC = UIHostingController(
                        rootView: BannerPromotionsView(navigationController: boardNav)
                    )
                    destVC.hidesBottomBarWhenPushed = true
                    boardNav?.pushViewController(destVC, animated: true)
                case 6:
                    break
                default:
                    break
                }
            }
        )

        let controller = UIHostingController(rootView: settingView)
        controller.view.backgroundColor = .white
        controller.disableSafeArea()

        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.isHidden = true
        nav.view.backgroundColor = .white

        sheet = SheetViewController(
            controller: nav,
            sizes: [.intrinsic],
            options: SheetOptions(
                presentingViewCornerRadius: 0,
                shrinkPresentingViewController: false, useInlineMode: true
            )
        )

        sheet.cornerRadius = 15
        sheet.allowGestureThroughOverlay = false
        sheet.dismissOnOverlayTap = true
        sheet.dismissOnPull = false

        if objPopup.mandatoryClick ?? false {
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

        sheet.animateIn(to: topView, in: topVC)
    }
    
  /*  func presentHostingController(objPopup:PopupModel){
        
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
    */
    
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
    
    
    func showBuyerSellerPopup(){
        let boardNav = tabBarController?.viewControllers?[0] as? UINavigationController

        let popupView = SellerBuyerPopup(selectedMode:.none, isToShowCancelButton: false) { mode in
            
            print(mode)
            if mode == .seller{
                self.updateUserTypeApi(type: 2)

            }else{
                self.updateUserTypeApi(type: 1)

            }

        }
        
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
     /*   if shouldEqualizeBottom {
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
                   // frames[idx].size.height += diff
                    
                    // Don't stretch beyond maxCardHeight
                           let currentH = frames[idx].size.height
                           frames[idx].size.height = min(currentH + diff, maxCardHeight)
                }
            } else if rightHeight < leftHeight {
                let diff = leftHeight - rightHeight
                if  let idx = lastInColumn[1] {
                   // frames[idx].size.height += diff
                    
                    // Don't stretch beyond maxCardHeight
                           let currentH = frames[idx].size.height
                           frames[idx].size.height = min(currentH + diff, maxCardHeight)
                }
            }
        }

        cache.frames = frames
        cache.size = CGSize(width: totalWidth, height: maxHeight)
        return cache.size
        
        */
        
        if shouldEqualizeBottom {

            if leftHeight < rightHeight {

                let diff = rightHeight - leftHeight

                if let idx = lastInColumn[0] {

                    let currentHeight = frames[idx].size.height

                    // Never stretch too much
                    let allowedGrowth = min(diff, maxEqualizationHeight)

                    // Never exceed max card height
                    let newHeight = min(
                        currentHeight + allowedGrowth,
                        580 //maxCardHeight
                    )

                    let actualGrowth = newHeight - currentHeight

                    frames[idx].size.height = newHeight

                    // IMPORTANT
                    columnHeights[0] += actualGrowth
                }

            } else if rightHeight < leftHeight {

                let diff = leftHeight - rightHeight

                if let idx = lastInColumn[1] {

                    let currentHeight = frames[idx].size.height

                    let allowedGrowth = min(
                        diff,
                        maxEqualizationHeight
                    )

                    let newHeight = min(
                        currentHeight + allowedGrowth,
                        570 //maxCardHeight
                    )

                    let actualGrowth = newHeight - currentHeight

                    frames[idx].size.height = newHeight

                    // IMPORTANT
                    columnHeights[1] += actualGrowth
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
        .frame(height: 35)
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

/*
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
        .onDisappear{
           self.player?.pause()
           self.player?.isMuted = true
        }

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
        .onTapGesture {
            recordOutboundClick()
            self.player?.pause()
            self.player?.isMuted = true
        }
       // .onTapGesture(perform: recordOutboundClick)
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

*/

import SwiftUI
import AVFoundation

struct BoardVideoBannerCard: View {

    let product: ItemModel

    let onClickedView: (URL) -> Void

    @StateObject
    private var video = BannerVideoPlayer()

    @State
    private var isMuted = true

    var body: some View {

        VStack(spacing: 0) {

            ZStack(alignment: .topTrailing) {

                PlayerLayerView(player: video.player)
                    .frame(height: 210)
                    .clipped()

                Button {

                    isMuted.toggle()

                    video.mute(isMuted)

                } label: {

                    Image(systemName: isMuted ?
                          "speaker.slash.fill" :
                          "speaker.wave.2.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.black.opacity(0.55))
                        .clipShape(Circle())
                }
                .padding()
            }

            learnMoreBar
        }
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
        .task {

            guard
                let url = URL(string: product.banner?.image ?? "")
            else {
                return
            }

            video.load(url: url)

            video.play()
        }
        .onDisappear {

            video.pause()

            video.mute(true)

            isMuted = true
        }
    }

    private var learnMoreBar: some View {

        HStack {

            Text("Learn more")

            Spacer()

            Image(systemName: "arrow.up.right")
        }
        .padding(.horizontal)
        .frame(height: 36)
        .background(Color(.systemBackground))
        .onTapGesture {
            isMuted = true
            video.mute(true)
            recordOutboundClick()
        }
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


import SwiftUI
import AVFoundation

final class BannerVideoPlayer: ObservableObject {

    let player = AVPlayer()

    private var observer: NSObjectProtocol?

    func load(url: URL) {

        // Already loaded
        if let asset = player.currentItem?.asset as? AVURLAsset,
           asset.url == url {
            return
        }

        cleanup()

        let item = AVPlayerItem(url: url)

        player.replaceCurrentItem(with: item)

        player.actionAtItemEnd = .none
        player.isMuted = true

        observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in

            self?.player.seek(to: .zero)

            self?.player.play()
        }
    }

    func play() {

        player.play()
    }

    func pause() {

        player.pause()
    }

    func mute(_ mute: Bool) {

        player.isMuted = mute
    }

    deinit {

        cleanup()
    }

    private func cleanup() {

        if let observer {

            NotificationCenter.default.removeObserver(observer)

            self.observer = nil
        }
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
        let cellular = NetworkMonitor.shared.isCellular //NetworkCondition.isCellular
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
            .frame(minHeight:290, maxHeight:maxCardHeight + 30)

            .clipped()
    }
    
    var body: some View {
     
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
        let cellular = NetworkMonitor.shared.isCellular //NetworkCondition.isCellular
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
            .frame(maxHeight:maxCardHeight)
            .clipped()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {

            ZStack(alignment: .bottomTrailing) {
           
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
        let cellular = NetworkMonitor.shared.isCellular //NetworkCondition.isCellular
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

            ZStack(alignment: .topLeading) {
                kfImage
                if product.isFeature ?? false {
                    Text("Sponsored")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium)).padding(5)
                }
            }
            .frame(maxWidth: columnWidth)
            .frame(minHeight:260, maxHeight:maxCardHeight + 10)// .frame(maxHeight:.infinity)
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



import UIKit
import ObjectiveC

extension UIHostingController {
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass))
            .appending("_IgnoreSafeArea")
        
        // Reuse if already created
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
            return
        }
        
        guard let viewSubclass = objc_allocateClassPair(viewClass, viewSubclassName, 0) else { return }
        
        if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
            let block: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in .zero }
            class_addMethod(
                viewSubclass,
                #selector(getter: UIView.safeAreaInsets),
                imp_implementationWithBlock(block),
                method_getTypeEncoding(method)
            )
        }
        
        objc_registerClassPair(viewSubclass)
        object_setClass(view, viewSubclass)
    }
}
