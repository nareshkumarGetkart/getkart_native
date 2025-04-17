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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.sharedInstance.checkSocketStatus()
//       tabBar.isTranslucent = true
        tabBar.tintColor = .orange
    
        delegate = self
        //self.view.backgroundColor = .white
        self.setViewControllers(getControllers(), animated: false)
        
        let images = ["home","chat","","myads","profile"]
        let imagesSel = ["home_active","chat_active","","myads_active","profile_active"]

        guard let items = self.tabBar.items else {
            return
        }
        for x in 0..<items.count-1 {
            items[x].tag = x
            items[x].image = UIImage(named:images[x])?.withRenderingMode(.alwaysOriginal)
            items[x].selectedImage = UIImage(named:imagesSel[x])?.withRenderingMode(.alwaysOriginal)

        }
        setupMiddleButton()

        
        AppDelegate.sharedInstance.navigateToNotificationType()
        Constant.shared.isLaunchFirstTime = 0
        
        // Do any additional setup after loading the view.
    }
    
    func setupMiddleButton() {
            let buttonSize: CGFloat = 60
            let buttonRadius: CGFloat = buttonSize / 2
            
            // Configure button appearance
            middleButton.frame = CGRect(x: (view.bounds.width / 2) - buttonRadius, y: -20, width: buttonSize, height: buttonSize)
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

    
    func isUserLoggedInRequest() -> Bool {
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        if objLoggedInUser.id != nil {
          
            return true
            
        }else{
            
            let deleteAccountView = UIHostingController(rootView: LoginRequiredView(loginCallback: {
                //Login
                AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
                
            }))
            deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
            deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
            deleteAccountView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
            present(deleteAccountView, animated: true, completion: nil)
            return false
        }
    }
    
    
        @objc func middleButtonTapped() {
            print("Middle button tapped!")
            // Handle action (e.g., present a modal view)
            if isUserLoggedInRequest(){
                
               
                let url = Constant.shared.getLimits + "?package_type=item_listing"
                
                URLhandler.sharedinstance.makeCall(url: url, param: nil, methodType: .get,showLoader:true) { [weak self] responseObject, error in
                    
                
                    if(error != nil)
                    {
                        //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                        print(error ?? "defaultValue")
                        
                    }else{
                        
                        let result = responseObject! as NSDictionary
                        let status = result["code"] as? Int ?? 0
                        let message = result["message"] as? String ?? ""

                        if status == 200{
                            
                            
                            if let selectedVC =  self?.selectedViewController as? UINavigationController {
                                print(selectedVC)
                                if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                                    destVC.hidesBottomBarWhenPushed = true
                                    destVC.popType = .createPost
                                    selectedVC.pushViewController(destVC, animated: true)
                                    
                                }
                                
                            }
                            
                            
                        }else{
                            //self?.delegate?.showError(message: message)
                        }
                        
                    }
                }
               
                
                
            }
          
        }
    
    
    
    func getControllers() -> [UINavigationController]{
                
        let homeVc = StoryBoard.main.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        homeVc.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"home_active")?.withRenderingMode(.alwaysOriginal))

        
        let chatVc = StoryBoard.main.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
        chatVc.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"chat_active")?.withRenderingMode(.alwaysOriginal))

        let adsVc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
        adsVc.tabBarItem = UITabBarItem(title: "My ads", image: UIImage(named: "myads")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"myads_active")?.withRenderingMode(.alwaysOriginal))

        let profileVc = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
         profileVc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"profile_active")?.withRenderingMode(.alwaysOriginal))

        
        
        //        let images = ["home","chat","","myads","profile"]

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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let index = viewControllers?.firstIndex(of: viewController), index == 1 || index == 3 {
            
            if isUserLoggedInRequest() == false {
                return false
            }
        }

        if let index = viewControllers?.firstIndex(of: viewController), index == 2 {
            return false // Prevent selection of the middle (dummy) tab
        }
        return true
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        
//        tabBar.items?.forEach { item in
//                   if let selectedVC = viewControllers?.first(where: { $0.tabBarItem == item }) {
//                       item.image = selectedVC == viewController ? item.selectedImage?.withRenderingMode(.alwaysOriginal) : item.image?.withRenderingMode(.alwaysOriginal)
//                   }
//               }
        
//        guard let items = self.tabBar.items else {
//            return
//        }
//        
//        let images = ["home","chat","","myads","profile"]
//        
//        for x in 0..<items.count-1 {
//            items[x].image = UIImage(named:images[x])?.withRenderingMode(.alwaysOriginal)
//        }
        
        
        switch tabBarController.selectedIndex{
            
        case 0:
            break
            
        case 1:
         
            break
            
        case 2:
            //Center tab
            
            break
        case 3:
            
            break
        case 4:
            
            
            break
            
        default:
            break
            
        }
        
    }
}
