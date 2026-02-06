//
//  HomeBaseVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI
import FittedSheets


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

        let images = ["home","gridUnSel","","chat","profile"]
        let imagesSel = ["home_active","gridSel","","chat_active","profile_active"]
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
       /*setupDoubleTapGesture()*/
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
        homeVc.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"home_active")?.withRenderingMode(.alwaysOriginal))
    
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

        let vc1 = UINavigationController(rootViewController: homeVc)
        let vc2 = UINavigationController(rootViewController: boardVc)
//      let vc3 = UINavigationController(rootViewController: adsVc)
        let vc3 = UINavigationController(rootViewController: chatVc)
        let vc4 = UINavigationController(rootViewController: profileVc)
        
        
        
        vc1.navigationBar.isHidden = true
        vc2.navigationBar.isHidden = true
        vc3.navigationBar.isHidden = true
        vc4.navigationBar.isHidden = true
        
        vc1.title = "Home"
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
            rootView: PostOptionsSheet(onBoardTap: {}, onAdsTap: {}, onBannerTap: {}, onClose: {}))
        
        
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
      
        /* if (objPopup.mandatoryClick ?? false){
         
         sheet.dismissOnOverlayTap = false
         sheet.dismissOnPull = false
         sheet.allowPullingPastMaxHeight = false
         sheet.allowPullingPastMinHeight = false
         sheet.shouldRecognizePanGestureWithUIControls = false
         sheet.sheetViewController?.shouldRecognizePanGestureWithUIControls = false
         sheet.sheetViewController?.allowGestureThroughOverlay = false
         sheet.sheetViewController?.dismissOnPull = false
         sheet.allowPullingPastMinHeight = false
         }*/
        
        
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
                        
                        let destvc = UIHostingController(rootView: CreateBoardView(navigationController: selectedVC))
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
            },
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
    
    
   /* func addNewBadgeOnBoardTab() {
        // Board tab index = 1
        let boardIndex = 1
        let badgeTag = 7777

        // Remove if already added
        tabBar.viewWithTag(badgeTag)?.removeFromSuperview()

        let tabBarButtons = tabBar.subviews
            .filter { $0 is UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }

        guard boardIndex < tabBarButtons.count else { return }

        let boardButton = tabBarButtons[boardIndex]

        let badgeImageView = UIImageView(image: UIImage(named: "NEW"))
        badgeImageView.tag = badgeTag
        badgeImageView.contentMode = .scaleAspectFit

        // Adjust size for "thin" look
        let badgeWidth: CGFloat = 22
        let badgeHeight: CGFloat = 10

        badgeImageView.frame = CGRect(
            x: boardButton.frame.width / 2 + 2,
            y: 6,
            width: badgeWidth,
            height: badgeHeight
        )

        boardButton.addSubview(badgeImageView)
    }*/

    func addNewBadgeOnBoardTab() {
        let boardIndex = 1
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

    
    /*
     func tabBarController(_ tabBarController: UITabBarController,
                           didSelect viewController: UIViewController) {

         if let index = viewControllers?.firstIndex(of: viewController),
            index == 1 {
             removeNewBadgeFromBoardTab()
         }
     }

     */
}


extension HomeBaseVC: UITabBarControllerDelegate {
    //MARK: Delegate
    
    func showNChatUnreadCountRedDot(count:Int){
        
       // let str = count > 10 ? "10+" : "\(count)"
       // tabBar.items?[1].badgeValue = str
        self.showSmallRedDot(at: 4, tabBar: self.tabBar)
    }
    
    func removeChatUnreadCountRedDot(){
       // tabBar.items?[1].badgeValue = nil
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

   /*
    private func showSmallRedDot(at index: Int, tabBar: UITabBar) {
        let dotTag = 9999 + index

        // Remove existing dot if any
        tabBar.viewWithTag(dotTag)?.removeFromSuperview()

        // Get the tab bar button views (UIControl)
        let tabBarButtons = tabBar.subviews
            .filter { $0 is UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }

        guard index < tabBarButtons.count else { return }

        let itemView = tabBarButtons[index]

        // Create the dot
        let dotSize: CGFloat = 9
        let dot = UIView(frame: CGRect(x: itemView.frame.width / 2 + 6, y: 6, width: dotSize, height: dotSize))
        dot.backgroundColor = .red
        dot.layer.cornerRadius = dotSize / 2
        dot.clipsToBounds = true
        dot.tag = dotTag

        itemView.addSubview(dot)
    }
*/
    private func removeSmallRedDot(at index: Int, tabBar: UITabBar) {
        let dotTag = 9999 + index
        tabBar.viewWithTag(dotTag)?.removeFromSuperview()
    }

    
    private func setupDoubleTapGesture() {
        guard let items = tabBar.items else { return }

            let tabBarButtons = tabBar.subviews
                .filter { $0 is UIControl && $0.isUserInteractionEnabled }
                .sorted(by: { $0.frame.origin.x < $1.frame.origin.x }) // Sort by position

            for (index, button) in tabBarButtons.enumerated() {
                if index == 2 { continue } // Skip dummy middle tab

                if index == 0 || index == 1{
                    button.gestureRecognizers?.removeAll()
                    
                    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
                    doubleTap.numberOfTapsRequired = 2
                    button.addGestureRecognizer(doubleTap)
                    button.tag = index
                }
            }
       }
        
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        
        if index == selectedIndex,
           let nav = viewControllers?[index] as? UINavigationController,
           let homeVC = nav.topViewController as? HomeVC {
            homeVC.scrollToTop()
            return
        }
        // BOARD TAB (SwiftUI)
            if index == 1, index == selectedIndex {
                NotificationCenter.default.post(
                    name: Notification.Name(NotificationKeys.scrollBoardToTop),
                    object: nil
                )
            }
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let index =  viewControllers?.firstIndex(of: viewController) else{ return false}
        
        if index == 0{
            return true
       
//        }else if index == 1 || index == 3 {
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

            if currentIndex == 0,
               let nav = viewControllers?[0] as? UINavigationController,
               let homeVC = nav.topViewController as? HomeVC {
                homeVC.scrollToTop()
            }

            if currentIndex == 1 {
                NotificationCenter.default.post(
                    name: Notification.Name(NotificationKeys.scrollBoardToTop),
                    object: nil
                )
            }
        }

        lastSelectedIndex = currentIndex
    }

}
