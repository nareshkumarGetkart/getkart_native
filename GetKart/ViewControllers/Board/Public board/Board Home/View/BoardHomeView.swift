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

 let maxEqualizationHeight: CGFloat = 100
 let maxCardHeight: CGFloat = 350 // or whatever looks good

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
   // @State private var showWalletRewardPopup = false
    @StateObject private var popupState = PopupState()
    @State private var unreadNotificationCount = 0

    
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

            if selectedCategoryId > 0 {
                tabContentView
            } else {
                HStack { Spacer() }.frame(height: 30).padding()
                PinterestSkeletonGrid().padding(.top, 5)
            }
        }

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
                        showCompleteProfilePopup = false
                        updateProfile(fullName: name)

                    }
                )
                .background(.clear)
                .presentationBackground(.clear)
            }
        
            .fullScreenCover(isPresented: $popupState.showWalletRewardPopup) {
                
               
                if let obj = popupState.popupObj{
                    
                    RewardWalletPopup(
                        objPopup:obj,
                        buttonAction: {
                            
                            print("Button tapped")
                            popupState.showWalletRewardPopup = false
                            pushToMyWalletView()
                        },
                        closeAction: {
                            
                            popupState.showWalletRewardPopup = false
                        }
                    )
                    .background(.clear)
                    .presentationBackground(.clear)
                }
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
            getAlertPopupApi()
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
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.getAlertPopupApi()
                        }
                       
                        
                    }
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
            }
        }
    }
    
    
    func pushToMyWalletView(){
        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            
            let boardNav = tabBarController?.viewControllers?[0] as? UINavigationController
            let hostingController = UIHostingController(rootView: MyWalletView(navigation: boardNav))
            hostingController.hidesBottomBarWhenPushed = true
            boardNav?.pushViewController(hostingController, animated: true)
        }
    }
}


final class PopupState: ObservableObject {
    @Published var popupObj: PopupModel?
    @Published var showWalletRewardPopup = false
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

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.getAlertPopupApi()
                        }

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
    
    func getAlertPopupApi(){
      
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
                        
                    }else if (obj.data.type ?? 0) == 7{
                        //Wallet reward
                        DispatchQueue.main.async {
                            self.popupState.popupObj = obj.data
                            self.popupState.showWalletRewardPopup = true
                        }
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
            preloadedImage: image,        //  Pass already downloaded image
            preloadedImageHeight: imageHeight, //  Pass already computed height
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
            if Local.shared.companyLogo.count > 0, let url = URL(string: Local.shared.companyLogo) {
                // Use KFAnimatedImage to support both static images and animated GIFs
                KFAnimatedImage(url)
                    .placeholder {
                        // Optional: Show local Logo while downloading
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 50)
                    }
                    .fade(duration: 0.25)
                    .scaledToFit() // Replaces resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 50)
            } else {
                // Fallback if URL string is empty or invalid
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 50)
            }
            
            
            Spacer()
            notificationButton
            interestButton
        }
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .onAppear{
            if Local.shared.getUserId() > 0{
                getNotificationCount()
            }
        }
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
    
    
    var notificationButton: some View {
        Button {
            if AppDelegate.sharedInstance.isUserLoggedInRequest() {
                guard let tabBar = tabBarController,
                      let navigationController = tabBar.viewControllers?[0] as? UINavigationController else {
                    return
                }
                
                let hostingController = UIHostingController(
                    rootView: NotificationView(navigation: navigationController)
                )
                
                hostingController.hidesBottomBarWhenPushed = true
                navigationController.pushViewController(
                    hostingController,
                    animated: true
                )
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image("notificationOutline")
                    .padding(8)
                
                // Red dot when there are unread notifications
                if unreadNotificationCount > 0 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: -5, y: 5)
                }
            }
        }
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
    
    func getNotificationCount() {
        URLhandler.sharedinstance.makeCall(
            url: Constant.shared.get_notification_unread_count,
            param: nil,
            methodType: .get
        ) { responseObject, error in
            
            if error == nil,
               let result = responseObject,
               let data = result["data"] as? [String: Any] {
                
                let count = data["unread_count"] as? Int ?? 0
                
                DispatchQueue.main.async {
                    unreadNotificationCount = count
                }
            }
        }
    }
}


#Preview {
    BoardHomeView(tabBarController: nil)
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
                .frame(maxWidth: .infinity, minHeight: 190, maxHeight: 220)
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
      //  .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
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


private let columnWidth: CGFloat = UIScreen.main.bounds.width / 2 - 10
  

//MARK: - CardItemViewNew
struct CardItemViewNew: View {
    let item:             ItemModel
    let onLike:           (Bool, Int) -> Void
    let onTap:            () -> Void
    let onTapBoostButton: () -> Void
    let onTapProfile:(Int) -> Void
    var isToShowBoostButton = true
    var imageRatio: CGFloat = 1.2
 
    var body: some View {
        if item.boardType == 1 {
            PromotionalAdsCardStaggeredNew(product: item, onTapBottomtButton: onTapBoostButton) { userId in
                onTapProfile(userId)
            }
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
                                   // .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
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
                        Text("\((product.commentsCount ?? 0).priceFormat())").font(.inter(.medium, size: 12)).foregroundColor(Color(.label))
                    }
                }
                HStack(spacing: 3) {
                    Image("eye").renderingMode(.template).foregroundColor(Color(.label))
                    if (product.impressions ?? 0) > 0 {
                        Text("\((product.impressions ?? 0).priceFormat())").font(.inter(.medium, size: 12)).foregroundColor(Color(.label))
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

            if Local.shared.countryName.lowercased() == "india"{
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
        }
        .background(Color(.systemBackground))
       // .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
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
    let onTapProfile:(Int) -> Void
    
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
                HStack{
                    
                   
                    
                    if product.isFeature ?? false {
                        Text("Sponsored")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium)).padding(5)
                    }

                    Spacer()
                    
                    // Profile BUTTON
                    Button {
                        onTapProfile(product.user?.id ?? 0)
                        
                    } label: {
                        
                        ContactImageSwiftUIView(
                            name: product.user?.name ?? "",
                            imageUrl: product.user?.profile ?? "",
                            fallbackImageName: "user-circle",
                            imgWidth: 32,
                            imgHeight: 32,
                            fontsize:18
                        )
                        
                        .clipShape(Circle())
                    }.padding(5)
                }
            }
            .frame(maxWidth: columnWidth)
            .frame(minHeight:260, maxHeight:maxCardHeight + 10)
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
           // .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2) //  shadow added
            .onTapGesture {
                onTapBottomtButton()
                outboundClickApi()
            }
        }
        .background(Color(.systemBackground))
        //.shadow(color: .black.opacity(0.05), radius: 4, y: 2)
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



