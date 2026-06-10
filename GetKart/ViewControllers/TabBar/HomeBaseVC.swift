//
//  HomeBaseVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI
import FittedSheets

class HomeBaseVC: UITabBarController {
    
    // MARK: - Actions
   var controllers: [UIViewController]?
   private let middleButton = UIButton()
   private var lastSelectedIndex: Int = 0
   private var hasLayedOutBadge = false // prevent badge re-add loop

    //  inject CustomTabBar before anything loads so hitTest actually fires
    override func loadView() {
        super.loadView()
        let customTabBar = CustomTabBar()
        self.setValue(customTabBar, forKey: "tabBar")
    }

    //MARK: - Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.chatUnreadCount),
                                               name: NSNotification.Name(rawValue: SocketEvents.chatUnreadCount.rawValue), object: nil)
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.label
        tabBar.tintColor = .orange
        tabBar.unselectedItemTintColor = UIColor.label
        delegate = self
        self.setViewControllers(getControllers(), animated: false)

        let images = ["gridUnSel","search","","chat","profile"]
        let imagesSel = ["gridSel","search","","chat_active","profile_active"]
        
        guard let items = self.tabBar.items else {
            return
        }
        
        for x in 0..<items.count-1 {
            items[x].tag = x
            tabBar.items?[x].image = nil
            tabBar.items?[x].image = UIImage(named: images[x])?.withRenderingMode(.alwaysTemplate)
            items[x].selectedImage = UIImage(named:imagesSel[x])?.withRenderingMode(.alwaysOriginal)
           
        }
        setupMiddleButton()

        // link middleButton reference into CustomTabBar so hitTest works
        if let customTabBar = tabBar as? CustomTabBar {
            customTabBar.middleButton = middleButton
        }
        
      
        
    }
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Constant.shared.isLaunchFirstTime == 1 {
            Constant.shared.isLaunchFirstTime = 0
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(SocketEvents.socketConnected.rawValue), object: nil, queue: .main) { _ in
                AppDelegate.sharedInstance.navigateToNotificationType()
            }
            // Trigger connection if not already started
            SocketIOManager.sharedInstance.checkSocketStatus()
        }
    }

    // reposition middle button and badge after layout so frames are correct on all iOS versions including iOS 26
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let buttonSize: CGFloat = 65
        middleButton.frame = CGRect(
            x: (view.bounds.width / 2) - (buttonSize / 2),
            y: -20,
            width: buttonSize,
            height: buttonSize
        )
        tabBar.bringSubviewToFront(middleButton)
                
        //  stable visibility check (no flicker)
            let tabBarVisible = tabBar.alpha > 0.01 && tabBar.frame.height > 10

            middleButton.isHidden = !tabBarVisible
            middleButton.isUserInteractionEnabled = tabBarVisible
        
        // only add badge once after frames are ready
      /*  if !hasLayedOutBadge {
            hasLayedOutBadge = true
            addNewBadgeOnBoardTab()
        }*/
    }

    //MARK: - Other Helpful Methods
    func setupMiddleButton() {
        let buttonSize: CGFloat = 65
        let buttonRadius: CGFloat = buttonSize / 2
        
        // frame is set in viewDidLayoutSubviews, not here
        middleButton.layer.cornerRadius = buttonRadius
        middleButton.backgroundColor = .clear
        middleButton.setImage(UIImage(named: "plus_button"), for: .normal)
        middleButton.tintColor = .white
        middleButton.addTarget(self, action: #selector(middleButtonTapped), for: .touchUpInside)
        middleButton.titleLabel?.font = .Manrope.medium(size: 15.0).font
        
        // Add shadow
        middleButton.layer.shadowColor = UIColor.black.cgColor
        middleButton.layer.shadowOpacity = 0.3
        middleButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        middleButton.layer.shadowRadius = 4
        
        tabBar.addSubview(middleButton)
        tabBar.bringSubviewToFront(middleButton)
     
    }
    
    @objc func chatUnreadCount(notification: Notification) {
        guard let data = notification.userInfo else{
            return
        }
        
        if let dataDict = data["data"] as? Dictionary<String,Any>{
            
            let unreadCount = dataDict["unreadCount"] as? Int ?? 0
            removeChatUnreadCountRedDot()

            if unreadCount > 0{
                showNChatUnreadCountRedDot(count: unreadCount)
            }else{
            }
        }
    }

    
    @objc func middleButtonTapped() {
        print("Middle button tapped!")
        
        presentHostingController()
        
        // Handle action (e.g., present a modal view)
       /* if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            if let selectedVC =  self.selectedViewController as? UINavigationController {
                print(selectedVC)
                if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                    destVC.hidesBottomBarWhenPushed = true
                    destVC.popType = .createPost
                    selectedVC.pushViewController(destVC, animated: true)
                }
            }
        }*/
    }
    
    
    func getControllers() -> [UINavigationController]{
                
      /*  let homeVc = StoryBoard.main.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        homeVc.tabBarItem = UITabBarItem(title: "Classified", image: UIImage(named: "home")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"home_active")?.withRenderingMode(.alwaysOriginal))
    */
     
        /*  let boardVc = UIHostingController(rootView: BoardView(navigationController: self.navigationController))
        boardVc.tabBarItem = UITabBarItem(title: "Board", image: UIImage(named: "gridUnSel")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"gridSel")?.withRenderingMode(.alwaysOriginal))
       */
        
        /* let adsVc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
        adsVc.tabBarItem = UITabBarItem(title: "My ads", image: UIImage(named: "myads")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"myads_active")?.withRenderingMode(.alwaysOriginal))
        */
        
       /*
        let homeVc = UIHostingController(rootView: BoardSearchView(tabBarController: self))
        homeVc.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"search")?.withRenderingMode(.alwaysOriginal))
        */
        
        let searchVc = LazyHostingController { [weak self] in
            BoardSearchView(tabBarController: self)
        }
        searchVc.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "search")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"search")?.withRenderingMode(.alwaysOriginal))

         
        let boardVc = UIHostingController(rootView: BoardHomeView(tabBarController: self))
        boardVc.tabBarItem = UITabBarItem(title: "Board", image: UIImage(named: "gridUnSel")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"gridSel")?.withRenderingMode(.alwaysOriginal))
                

        let chatVc = StoryBoard.main.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
        chatVc.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chat")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"chat_active")?.withRenderingMode(.alwaysOriginal))

        
        let profileVc = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
         profileVc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"profile_active")?.withRenderingMode(.alwaysOriginal))
        

        let dummyVC = UIViewController() // Empty view controller for spacing
        dummyVC.tabBarItem = UITabBarItem(title: "", image: nil, tag: 2)
        dummyVC.title = ""
        let dummyNav = UINavigationController(rootViewController: dummyVC)
        dummyNav.navigationBar.isHidden = true

        let vc1 = UINavigationController(rootViewController: boardVc)
        let vc2 = UINavigationController(rootViewController: searchVc)
        let vc3 = UINavigationController(rootViewController: chatVc)
        let vc4 = UINavigationController(rootViewController: profileVc)
                
        vc1.navigationBar.isHidden = true
        vc2.navigationBar.isHidden = true
        vc3.navigationBar.isHidden = true
        vc4.navigationBar.isHidden = true
        
        vc1.title = "Board"
        vc2.title = "Search"
        vc3.title = "Chat"
        vc4.title = "Profile"
        
        return [vc1,vc2,dummyNav,vc3,vc4]
    }
    
    
  

    func presentPostOptions(from controller: UIViewController) {
        let sheetVC = UIHostingController(rootView:
            PostOptionsSheet(
                onBoardTap: {
                    print("Board tapped")
                },
            
                onBannerTap: {
                    print("Banner tapped")
                },
                onClose: {
                    controller.dismiss(animated: true)
                }
            )
        )
        
        sheetVC.modalPresentationStyle = .overFullScreen
        sheetVC.view.backgroundColor = .clear   // important
        controller.present(sheetVC, animated: true)
    }

    
  /*  func presentHostingController(){
        
        let controller = UIHostingController(
            rootView: PostOptionsSheet(onBoardTap: {}, onBannerTap: {}, onIdeaTap: {}, onClose: {}))

        
        let useInlineMode = view != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.intrinsic],
            options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 18
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
    
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 18
        sheet.dismissOnOverlayTap = true
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
      
        
        let settingView = PostOptionsSheet(
            
            
            onBoardTap: {
                print("Board tapped")
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    if let selectedVC =  self.selectedViewController as? UINavigationController {
                        let destvc = UIHostingController(rootView: UploadImageVideoView(navigationController: selectedVC))
                        destvc.hidesBottomBarWhenPushed = true
                        selectedVC.pushViewController(destvc, animated: true)
                    }
                }
            },
          
            onBannerTap: {
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                print("Banner tapped")
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    if let selectedVC =  self.selectedViewController as? UINavigationController {
                        
                        let destvc = UIHostingController(rootView: BannerPromotionsView(navigationController: selectedVC))
                        destvc.hidesBottomBarWhenPushed = true
                        selectedVC.pushViewController(destvc, animated: true)
                    }
                    
                }
            }
            , onIdeaTap: {
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                print("Banner tapped")
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    if let selectedVC =  self.selectedViewController as? UINavigationController {
                        
                        let destvc = UIHostingController(rootView: CreateIdeaView(navigationController: selectedVC))
                        destvc.hidesBottomBarWhenPushed = true
                        selectedVC.pushViewController(destvc, animated: true)
                    }
                    
                }
            }
            ,
            onClose: {
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                controller.dismiss(animated: true)
            }
        )
        
        controller.rootView = settingView
        
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
        
    }

*/
    

    // FIX — build the real view first, then wrap it once
    private func presentHostingController() {
        // Build sheet first so closures can reference it
        var sheet: SheetViewController!  // set below

        let settingView = PostOptionsSheet(
            onBoardTap: { [weak self] in
                sheet.attemptDismiss(animated: true)
                guard AppDelegate.sharedInstance.isUserLoggedInRequest(),
                      let nav = self?.selectedViewController as? UINavigationController else { return }
                let vc = UIHostingController(rootView: UploadImageVideoView(navigationController: nav))
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            },
            onBannerTap: { [weak self] in
                sheet.attemptDismiss(animated: true)
                guard AppDelegate.sharedInstance.isUserLoggedInRequest(),
                      let nav = self?.selectedViewController as? UINavigationController else { return }
                let vc = UIHostingController(rootView: BannerPromotionsView(navigationController: nav))
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            },
            onIdeaTap: { [weak self] in
                sheet.attemptDismiss(animated: true)
                guard AppDelegate.sharedInstance.isUserLoggedInRequest(),
                      let nav = self?.selectedViewController as? UINavigationController else { return }
                let vc = UIHostingController(rootView: CreateIdeaView(navigationController: nav))
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            },
            onClose: { sheet.attemptDismiss(animated: true) }
        )

        let controller = UIHostingController(rootView: settingView)  // ← only one, correct view
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.isHidden = true

        sheet = SheetViewController(
            controller: nav,
            sizes: [.intrinsic],
            options: SheetOptions(presentingViewCornerRadius: 0, useInlineMode: view != nil)
        )
        sheet.cornerRadius = 18
        sheet.dismissOnOverlayTap = true
        sheet.dismissOnPull = false
        sheet.gripColor = .clear

        if let topVC = AppDelegate.sharedInstance.navigationController?.topViewController {
            sheet.animateIn(to: topVC.view, in: topVC)
        } else {
            navigationController?.present(sheet, animated: true)
        }
    }
   
    
    func addNewBadgeOnBoardTab() {
        let boardIndex = 0
        let badgeTag = 7777
        
        tabBar.viewWithTag(badgeTag)?.removeFromSuperview()
        
        guard let items = tabBar.items, !items.isEmpty else { return }
        
        let badgeWidth:  CGFloat = 22
        let badgeHeight: CGFloat = 12
        var badgeX: CGFloat = 0
        var badgeY: CGFloat = 8
        
        // Try UIControl filter first (works on iOS 17 and below)
        let tabBarButtons = tabBar.subviews
            .filter { $0 is UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }
        if #available(iOS 26, *) {
            //  Liquid Glass tab bar (iOS 26+) — UIControl returns empty, use frame math
            let totalTabs     = items.count
            let tabWidth      = tabBar.bounds.width / CGFloat(totalTabs)
            let tabRightEdge  = tabWidth
            
            let boardItem = items[boardIndex]
            let iconImage = boardItem.selectedImage ?? boardItem.image
            let iconSize  = iconImage?.size ?? CGSize(width: 25, height: 25)
            
            let iconMargin    = (tabWidth - iconSize.width) / 2.0
            let iconRightEdge = tabRightEdge - iconMargin
            badgeX =  iconRightEdge + (badgeWidth / 2.0) + 1.7 //iconRightEdge //- badgeWidth
            badgeY = 10
            
        } else {
            if boardIndex < tabBarButtons.count {
                
                //  Classic tab bar (iOS 17 and below) — use actual button frame
                let boardButton = tabBarButtons[boardIndex]
                let buttonFrameInTabBar = boardButton.convert(boardButton.bounds, to: tabBar)
                badgeX = buttonFrameInTabBar.midX + 0
            }
            
        }
        
        let badgeImageView = UIImageView(image: UIImage(named: "NEW"))
        badgeImageView.tag = badgeTag
        badgeImageView.contentMode = .scaleAspectFit
        badgeImageView.frame = CGRect(
            x: badgeX,
            y: badgeY,
            width: badgeWidth,
            height: badgeHeight
        )
        
        tabBar.addSubview(badgeImageView)
        tabBar.bringSubviewToFront(badgeImageView)
        tabBar.bringSubviewToFront(middleButton)
    }
    
    func removeNewBadgeFromBoardTab() {
        tabBar.viewWithTag(7777)?.removeFromSuperview()
    }
    
    
    func showNChatUnreadCountRedDot(count: Int) {
        // Chat is at index 3
        showSmallRedDot(at: 3, tabBar: self.tabBar)
    }

    func removeChatUnreadCountRedDot() {
        // Chat is at index 3
        removeSmallRedDot(at: 3, tabBar: self.tabBar)
    }

    private func showSmallRedDot(at index: Int, tabBar: UITabBar) {

        let dotTag = 9999 + index
        tabBar.viewWithTag(dotTag)?.removeFromSuperview()

        let dotSize: CGFloat = 9

        let dot = UIView()
        dot.tag = dotTag
        dot.backgroundColor = .systemRed
        dot.layer.cornerRadius = dotSize / 2
        dot.clipsToBounds = true

        guard let items = tabBar.items, index < items.count else { return }

    
        if #available(iOS 26, *) {
            
            let totalTabs = items.count
            let tabWidth = tabBar.bounds.width / CGFloat(totalTabs)

            // slot start and end
            let tabLeft = CGFloat(index) * tabWidth
            let tabCenterX = tabLeft + (tabWidth / 2)

            // icon Y in liquid glass is always around center
            let iconCenterY = tabBar.bounds.height / 2 - 6

            dot.frame = CGRect(
                x: tabCenterX ,
                y: iconCenterY - 20,
                width: dotSize,
                height: dotSize
            )
        } else {

            let tabBarButtons = tabBar.subviews
                .compactMap { $0 as? UIControl }
                .filter { $0 != middleButton }
                .sorted { $0.frame.minX < $1.frame.minX }

            guard index < tabBarButtons.count else { return }

            let itemView = tabBarButtons[index]
            let frame = itemView.convert(itemView.bounds, to: tabBar)

            dot.frame = CGRect(
                x: frame.midX + 10,
                y: frame.minY + 6,
                width: dotSize,
                height: dotSize
            )
        }

        tabBar.addSubview(dot)
        tabBar.bringSubviewToFront(dot)
        tabBar.bringSubviewToFront(middleButton)
    }
    
    private func removeSmallRedDot(at index: Int, tabBar: UITabBar) {
        let dotTag = 9999 + index
        tabBar.viewWithTag(dotTag)?.removeFromSuperview()
    }
    
}

extension HomeBaseVC: UITabBarControllerDelegate {
    //MARK: Delegate
  
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let index = viewControllers?.firstIndex(of: viewController) else { return false }

        // always catch dummy center tab (index 2) first
        if index == 2 {
            middleButtonTapped()
            return false
        }

        if index == 0 {
            return true
        } else if index == 3 {
            if AppDelegate.sharedInstance.isUserLoggedInRequest() == false {
                return false
            }
        }

        return true
    }

    
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {

        let currentIndex = tabBarController.selectedIndex

        // SAME tab tapped again = double tap
        if currentIndex == lastSelectedIndex {

           /* if currentIndex == 0,
               let nav = viewControllers?[0] as? UINavigationController,
               let homeVC = nav.topViewController as? HomeVC {
                homeVC.scrollToTop()
            }

            if currentIndex == 1 {
                NotificationCenter.default.post(
                    name: Notification.Name(NotificationKeys.scrollBoardToTop),
                    object: nil
                )
            }*/
            
            if currentIndex == 1,
               let nav = viewControllers?[1] as? UINavigationController,
               let homeVC = nav.topViewController as? HomeVC {
                homeVC.scrollToTop()
            }

            if currentIndex == 0 {
                NotificationCenter.default.post(
                    name: Notification.Name(NotificationKeys.scrollBoardToTop),
                    object: nil
                )
            }
        }

        lastSelectedIndex = currentIndex
    }

}




// CustomTabBar is injected via loadView so hitTest actually fires on iOS 26
class CustomTabBar: UITabBar {

    weak var middleButton: UIButton?
   
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        //  If tabBar is hidden OR not interactable, ignore all touches
        if self.isHidden || self.alpha < 0.01 || self.isUserInteractionEnabled == false {
            return nil
        }

        //  If touch is on middle button, forward it
        if let middleButton = middleButton,
           middleButton.isHidden == false,
           middleButton.alpha > 0.01,
           middleButton.isUserInteractionEnabled {

            let convertedPoint = middleButton.convert(point, from: self)
            if middleButton.bounds.contains(convertedPoint) {
                return middleButton
            }
        }

        // Normal tab bar handling
        return super.hitTest(point, with: event)
    }
}




extension UIView {
    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
}


// Lazy wrapper — ViewController only loads its rootView on first access
private class LazyHostingController<Content: View>: UIViewController {
    private let builder: () -> Content
    private var hosted: UIHostingController<Content>?

    init(builder: @escaping () -> Content) {
        self.builder = builder
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        let hc = UIHostingController(rootView: builder())
        addChild(hc)
        hc.view.frame = view.bounds
        hc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hc.view)
        hc.didMove(toParent: self)
        hosted = hc
    }
}




/*
class HomeBaseVC: UITabBarController {
    
    // MARK: - Actions
   var controllers: [UIViewController]?
   private let middleButton = UIButton()
   private var lastSelectedIndex: Int = 0

    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.chatUnreadCount),
                                               name: NSNotification.Name(rawValue: SocketEvents.chatUnreadCount.rawValue), object: nil)
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.label
        tabBar.tintColor = .orange
        tabBar.unselectedItemTintColor = UIColor.label
        delegate = self
        self.setViewControllers(getControllers(), animated: false)

//        let images = ["home","gridUnSel","","chat","profile"]
//        let imagesSel = ["home_active","gridSel","","chat_active","profile_active"]
       
        let images = ["gridUnSel","classifiedIcon","","chat","profile"]
        let imagesSel = ["gridSel","classifiedIconFill","","chat_active","profile_active"]
        
        guard let items = self.tabBar.items else {
            return
        }
        
        for x in 0..<items.count-1 {
            items[x].tag = x
            tabBar.items?[x].image = nil
            tabBar.items?[x].image = UIImage(named: images[x])?.withRenderingMode(.alwaysTemplate)
            items[x].selectedImage = UIImage(named:imagesSel[x])?.withRenderingMode(.alwaysOriginal)
           
        }
        setupMiddleButton()
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.chatUnreadCount.rawValue, [:])
        addNewBadgeOnBoardTab()
    }
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Constant.shared.isLaunchFirstTime == 1 {
            Constant.shared.isLaunchFirstTime = 0
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(SocketEvents.socketConnected.rawValue), object: nil, queue: .main) { _ in
                AppDelegate.sharedInstance.navigateToNotificationType()
            }
            // Trigger connection if not already started
            SocketIOManager.sharedInstance.checkSocketStatus()
        }
    }
    

    //MARK: Other Helpful Methods
    func setupMiddleButton() {
        let buttonSize: CGFloat = 65
        let buttonRadius: CGFloat = buttonSize / 2
        
        // Configure button appearance
        middleButton.frame = CGRect(x: (view.bounds.width / 2) - buttonRadius, y: -20, width: buttonSize, height: buttonSize)
        middleButton.layer.cornerRadius = buttonRadius
        middleButton.backgroundColor = .clear
        middleButton.setImage(UIImage(named: "plus_button"), for: .normal)
        middleButton.tintColor = .white
        middleButton.addTarget(self, action: #selector(middleButtonTapped), for: .touchUpInside)
        middleButton.titleLabel?.font = .Manrope.medium(size: 15.0).font
        
        // Add shadow
        middleButton.layer.shadowColor = UIColor.black.cgColor
        middleButton.layer.shadowOpacity = 0.3
        middleButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        middleButton.layer.shadowRadius = 4
        
        tabBar.addSubview(middleButton)
        tabBar.bringSubviewToFront(middleButton)
     
    }
    
    @objc func chatUnreadCount(notification: Notification) {
        guard let data = notification.userInfo else{
            return
        }
        
        if let dataDict = data["data"] as? Dictionary<String,Any>{
            
            let unreadCount = dataDict["unreadCount"] as? Int ?? 0
            removeChatUnreadCountRedDot()

            if unreadCount > 0{
                showNChatUnreadCountRedDot(count: unreadCount)
            }else{
            }
        }
    }

    
    @objc func middleButtonTapped() {
        print("Middle button tapped!")
        
        presentHostingController()
        
        // Handle action (e.g., present a modal view)
       /* if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            if let selectedVC =  self.selectedViewController as? UINavigationController {
                print(selectedVC)
                if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                    destVC.hidesBottomBarWhenPushed = true
                    destVC.popType = .createPost
                    selectedVC.pushViewController(destVC, animated: true)
                }
            }
        }*/
    }
    
    
    func getControllers() -> [UINavigationController]{
                
        let homeVc = StoryBoard.main.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        homeVc.tabBarItem = UITabBarItem(title: "Classified", image: UIImage(named: "home")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"home_active")?.withRenderingMode(.alwaysOriginal))
    
     /*  let boardVc = UIHostingController(rootView: BoardView(navigationController: self.navigationController))
        boardVc.tabBarItem = UITabBarItem(title: "Board", image: UIImage(named: "gridUnSel")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"gridSel")?.withRenderingMode(.alwaysOriginal))
       */
         
        let boardVc = UIHostingController(rootView: PublicBoardView(tabBarController: self))
        boardVc.tabBarItem = UITabBarItem(title: "Board", image: UIImage(named: "gridUnSel")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"gridSel")?.withRenderingMode(.alwaysOriginal))
        


        let chatVc = StoryBoard.main.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
        chatVc.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chat")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"chat_active")?.withRenderingMode(.alwaysOriginal))

       /* let adsVc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
        adsVc.tabBarItem = UITabBarItem(title: "My ads", image: UIImage(named: "myads")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"myads_active")?.withRenderingMode(.alwaysOriginal))
        */
        let profileVc = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
         profileVc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"profile_active")?.withRenderingMode(.alwaysOriginal))
        
        //let images = ["home","chat","","myads","profile"]

        let dummyVC = UIViewController() // Empty view controller for spacing
        dummyVC.tabBarItem = UITabBarItem(title: "", image: nil, tag: 2)
        dummyVC.title = ""
        let dummyNav = UINavigationController(rootViewController: dummyVC)
        dummyNav.navigationBar.isHidden = true

//        let vc1 = UINavigationController(rootViewController: homeVc)
//        let vc2 = UINavigationController(rootViewController: boardVc)
        
        let vc1 = UINavigationController(rootViewController: boardVc)
        let vc2 = UINavigationController(rootViewController: homeVc)
        
        let vc3 = UINavigationController(rootViewController: chatVc)
        let vc4 = UINavigationController(rootViewController: profileVc)
        
        
        
        vc1.navigationBar.isHidden = true
        vc2.navigationBar.isHidden = true
        vc3.navigationBar.isHidden = true
        vc4.navigationBar.isHidden = true
        
        vc1.title = "Used"
        vc2.title = "Board"
        vc3.title = "Chat"
        vc4.title = "Profile"
        
        return [vc1,vc2,dummyNav,vc3,vc4]
    }
    
    
  

    func presentPostOptions(from controller: UIViewController) {
        let sheetVC = UIHostingController(rootView:
            PostOptionsSheet(
                onBoardTap: {
                    print("Board tapped")
                },
                onAdsTap: {
                    print("Ads tapped")
                    if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                         if let selectedVC =  self.selectedViewController as? UINavigationController {
                             print(selectedVC)
                             if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                                 destVC.hidesBottomBarWhenPushed = true
                                 destVC.popType = .createPost
                                 selectedVC.pushViewController(destVC, animated: true)
                             }
                         }
                     }
                },
                onBannerTap: {
                    print("Banner tapped")
                },
                onClose: {
                    controller.dismiss(animated: true)
                }
            )
        )
        
        sheetVC.modalPresentationStyle = .overFullScreen
        sheetVC.view.backgroundColor = .clear   // important
        controller.present(sheetVC, animated: true)
    }

    
    func presentHostingController(){
        
        let controller = UIHostingController(
            rootView: PostOptionsSheet(onBoardTap: {}, onAdsTap: {}, onBannerTap: {}, onIdeaTap: {}, onClose: {}))
        
        
        let useInlineMode = view != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.intrinsic],
            options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 18
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
    
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 18
        sheet.dismissOnOverlayTap = true
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
      
        
        let settingView = PostOptionsSheet(
            
            
            onBoardTap: {
                print("Board tapped")
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    if let selectedVC =  self.selectedViewController as? UINavigationController {
                        let destvc = UIHostingController(rootView: UploadImageVideoView(navigationController: selectedVC))
                        destvc.hidesBottomBarWhenPushed = true
                        selectedVC.pushViewController(destvc, animated: true)
                    }
                }
            },
            onAdsTap: {
                print("Ads tapped")
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    if let selectedVC =  self.selectedViewController as? UINavigationController {
                        print(selectedVC)
                        if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                            destVC.hidesBottomBarWhenPushed = true
                            destVC.popType = .createPost
                            selectedVC.pushViewController(destVC, animated: true)
                        }
                    }
                }
            },
            onBannerTap: {
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                print("Banner tapped")
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    if let selectedVC =  self.selectedViewController as? UINavigationController {
                        
                        let destvc = UIHostingController(rootView: BannerPromotionsView(navigationController: selectedVC))
                        destvc.hidesBottomBarWhenPushed = true
                        selectedVC.pushViewController(destvc, animated: true)
                    }
                    
                }
            }
            , onIdeaTap: {
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                print("Banner tapped")
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    if let selectedVC =  self.selectedViewController as? UINavigationController {
                        
                        let destvc = UIHostingController(rootView: CreateIdeaView(navigationController: selectedVC))
                        destvc.hidesBottomBarWhenPushed = true
                        selectedVC.pushViewController(destvc, animated: true)
                    }
                    
                }
            }
            ,
            onClose: {
                if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
                controller.dismiss(animated: true)
            }
        )
        
        controller.rootView = settingView
        
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
        
    }


    func addNewBadgeOnBoardTab() {
        let boardIndex = 0 //1
        let badgeTag = 7777

        tabBar.viewWithTag(badgeTag)?.removeFromSuperview()

        let tabBarButtons = tabBar.subviews
            .filter { $0 is UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }

        guard boardIndex < tabBarButtons.count else { return }

        let boardButton = tabBarButtons[boardIndex]

        let badgeImageView = UIImageView(image: UIImage(named: "NEW"))
        badgeImageView.tag = badgeTag
        badgeImageView.contentMode = .scaleAspectFit

        let badgeWidth: CGFloat = 22
        let badgeHeight: CGFloat = 10

        // ❗ Convert button frame to tabBar coordinate system
        let buttonFrameInTabBar = boardButton.convert(boardButton.bounds, to: tabBar)

        badgeImageView.frame = CGRect(
            x: buttonFrameInTabBar.midX + 0,
            y: 6, // fixed relative to tabBar
            width: badgeWidth,
            height: badgeHeight
        )

        tabBar.addSubview(badgeImageView)
    }

    func removeNewBadgeFromBoardTab() {
        tabBar.viewWithTag(7777)?.removeFromSuperview()
    }
}


extension HomeBaseVC: UITabBarControllerDelegate {
    //MARK: Delegate
    
    func showNChatUnreadCountRedDot(count:Int){
   
        self.showSmallRedDot(at: 4, tabBar: self.tabBar)
    }
    
    func removeChatUnreadCountRedDot(){
        self.removeSmallRedDot(at: 4, tabBar: self.tabBar)
    }
    private func showSmallRedDot(at index: Int, tabBar: UITabBar) {
        let dotTag = 9999 + index

        // Remove existing dot
        tabBar.viewWithTag(dotTag)?.removeFromSuperview()

        // Get only visible tab bar buttons
        let tabBarButtons = tabBar.subviews
            .compactMap { $0 as? UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }

        guard index < tabBarButtons.count else { return }

        let itemView = tabBarButtons[index]

        let dotSize: CGFloat = 9

        let dot = UIView()
        dot.frame = CGRect(
            x: itemView.bounds.midX + 7,
            y: 5,
            width: dotSize,
            height: dotSize
        )

        dot.backgroundColor = .systemRed
        dot.layer.cornerRadius = dotSize / 2
        dot.clipsToBounds = true
        dot.tag = dotTag

        itemView.addSubview(dot)
    }

    private func removeSmallRedDot(at index: Int, tabBar: UITabBar) {
        let dotTag = 9999 + index
        tabBar.viewWithTag(dotTag)?.removeFromSuperview()
    }

    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let index =  viewControllers?.firstIndex(of: viewController) else{ return false}
        
        if index == 0{
            return true
       
        }else if  index == 3 {

            if AppDelegate.sharedInstance.isUserLoggedInRequest() == false {
                return false
            }
        }else if index == 2 {
            middleButtonTapped()
            return false // Prevent selection of the middle (dummy) tab
        }
        return true
    }
    
//    func tabBarController(_ tabBarController: UITabBarController,
//                          didSelect viewController: UIViewController) {
//
//    }
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {

        let currentIndex = tabBarController.selectedIndex

        // SAME tab tapped again = double tap
        if currentIndex == lastSelectedIndex {

           /* if currentIndex == 0,
               let nav = viewControllers?[0] as? UINavigationController,
               let homeVC = nav.topViewController as? HomeVC {
                homeVC.scrollToTop()
            }

            if currentIndex == 1 {
                NotificationCenter.default.post(
                    name: Notification.Name(NotificationKeys.scrollBoardToTop),
                    object: nil
                )
            }*/
            
            if currentIndex == 1,
               let nav = viewControllers?[1] as? UINavigationController,
               let homeVC = nav.topViewController as? HomeVC {
                homeVC.scrollToTop()
            }

            if currentIndex == 0 {
                NotificationCenter.default.post(
                    name: Notification.Name(NotificationKeys.scrollBoardToTop),
                    object: nil
                )
            }
        }

        lastSelectedIndex = currentIndex
    }

}




class CustomTabBar: UITabBar {

    weak var middleButton: UIButton?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let middleButton = middleButton else {
            return super.hitTest(point, with: event)
        }

        let convertedPoint = middleButton.convert(point, from: self)

        if middleButton.bounds.contains(convertedPoint) {
            return middleButton
        }

        return super.hitTest(point, with: event)
    }
}
*/

