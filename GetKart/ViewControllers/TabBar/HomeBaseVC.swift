//
//  HomeBaseVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI



class HomeBaseVC: UITabBarController {
    
    
    // MARK: - Actions
    var controllers: [UIViewController]?
    let middleButton = UIButton()
    
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().unselectedItemTintColor = UIColor.label
        tabBar.tintColor = .orange
        tabBar.unselectedItemTintColor = UIColor.label
        delegate = self
        self.setViewControllers(getControllers(), animated: false)
        
        let images = ["home","chat","","myads","profile"]
        let imagesSel = ["home_active","chat_active","","myads_active","profile_active"]

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
        setupDoubleTapGesture()
        
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
            middleButton.frame = CGRect(x: (view.bounds.width / 2) - buttonRadius, y: -25, width: buttonSize, height: buttonSize)
            middleButton.layer.cornerRadius = buttonRadius
            middleButton.backgroundColor = .clear
            middleButton.setImage(UIImage(named: "plus_button"), for: .normal)
            middleButton.tintColor = .white
            middleButton.addTarget(self, action: #selector(middleButtonTapped), for: .touchUpInside)
        
        // Add shadow
            middleButton.layer.shadowColor = UIColor.black.cgColor
            middleButton.layer.shadowOpacity = 0.3
            middleButton.layer.shadowOffset = CGSize(width: 2, height: 2)
            middleButton.layer.shadowRadius = 4

            tabBar.addSubview(middleButton)
            tabBar.bringSubviewToFront(middleButton)
        }
    
    
    

    
    @objc func middleButtonTapped() {
        print("Middle button tapped!")
        // Handle action (e.g., present a modal view)
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
    }
    
    
    
    func getControllers() -> [UINavigationController]{
                
        let homeVc = StoryBoard.main.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        homeVc.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"home_active")?.withRenderingMode(.alwaysOriginal))

        
        let chatVc = StoryBoard.main.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
        chatVc.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chat")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"chat_active")?.withRenderingMode(.alwaysOriginal))

        let adsVc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
        adsVc.tabBarItem = UITabBarItem(title: "My ads", image: UIImage(named: "myads")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"myads_active")?.withRenderingMode(.alwaysOriginal))

        let profileVc = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
         profileVc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile")?.withTintColor(.label, renderingMode: .alwaysOriginal), selectedImage: UIImage(named:"profile_active")?.withRenderingMode(.alwaysOriginal))
        
        //let images = ["home","chat","","myads","profile"]

        let dummyVC = UIViewController() // Empty view controller for spacing
        dummyVC.tabBarItem = UITabBarItem(title: "", image: nil, tag: 2)
        dummyVC.title = ""
        let dummyNav = UINavigationController(rootViewController: dummyVC)
        dummyNav.navigationBar.isHidden = true

        let vc1 = UINavigationController(rootViewController: homeVc)
        let vc2 = UINavigationController(rootViewController: chatVc)
        let vc3 = UINavigationController(rootViewController: adsVc)
        let vc4 = UINavigationController(rootViewController: profileVc)
        
        vc1.navigationBar.isHidden = true
        vc2.navigationBar.isHidden = true
        vc3.navigationBar.isHidden = true
        vc4.navigationBar.isHidden = true
        
        vc1.title = "Home"
        vc2.title = "Chat"
        vc3.title = "My ads"
        vc4.title = "Profile"
        
        return [vc1,vc2,dummyNav,vc3,vc4]
    }
}


extension HomeBaseVC: UITabBarControllerDelegate {
    //MARK: Delegate
    
    func showNChatUnreadCountRedDot(){
        self.showSmallRedDot(at: 1, tabBar: self.tabBar)
    }
    
    func removeChatUnreadCountRedDot(){
        self.removeSmallRedDot(at: 1, tabBar: self.tabBar)
    }
    
    func showSmallRedDot(at index: Int, tabBar: UITabBar) {
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
        let dotSize: CGFloat = 8
        let dot = UIView(frame: CGRect(x: itemView.frame.width / 2 + 6, y: 6, width: dotSize, height: dotSize))
        dot.backgroundColor = .red
        dot.layer.cornerRadius = dotSize / 2
        dot.clipsToBounds = true
        dot.tag = dotTag

        itemView.addSubview(dot)
    }

    func removeSmallRedDot(at index: Int, tabBar: UITabBar) {
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

                if index == 0 {
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
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let index =  viewControllers?.firstIndex(of: viewController) else{ return false}
        
        if index == 0{
            return true
       
        }else if index == 1 || index == 3 {
            if AppDelegate.sharedInstance.isUserLoggedInRequest() == false {
                return false
            }
        }else if index == 2 {
            middleButtonTapped()
            return false // Prevent selection of the middle (dummy) tab
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
    
    }
}
