//
//  HomeBaseVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit

class HomeBaseVC: UITabBarController {
    
    
    // MARK: - Actions
   
    var controllers: [UIViewController]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tabBar.isTranslucent = false
//        tabBar.tintColor = .white
        delegate = self
        
        self.setViewControllers(getControllers(), animated: false)

        
        let images = ["home","chat","myads","profile"]
        guard let items = self.tabBar.items else {
            return
        }
        for x in 0..<items.count-1 {
            items[x].image = UIImage(named:images[x])?.withRenderingMode(.alwaysOriginal)
        }
        

        // Do any additional setup after loading the view.
    }
    
    
    func getControllers() -> [UINavigationController]{
                
        let homeVc = StoryBoard.main.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let chatVc = StoryBoard.main.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
        let adsVc = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
        let profileVc = StoryBoard.main.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        
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
        
        return [vc1,vc2,vc3,vc4]
    }
}


extension HomeBaseVC: UITabBarControllerDelegate {
    //MARK: Delegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        return true
        
    }
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        
        guard let items = self.tabBar.items else {
            return
        }
        
        let images = ["home","chat","myads","profile"]
        
        for x in 0..<items.count-1 {
            items[x].image = UIImage(named:images[x])?.withRenderingMode(.alwaysOriginal)
        }
        
        
        switch tabBarController.selectedIndex{
            
        case 0:
            items[tabBarController.selectedIndex].image = UIImage(named: "home_active")?.withRenderingMode(.alwaysOriginal)
            break
            
        case 1:
            items[tabBarController.selectedIndex].image = UIImage(named: "chat_active")?.withRenderingMode(.alwaysOriginal)
            break
   
        case 2:
            items[tabBarController.selectedIndex].image = UIImage(named: "myads_active")?.withRenderingMode(.alwaysOriginal)
            break
        case 3:
       
            items[tabBarController.selectedIndex].image = UIImage(named: "profile_active")?.withRenderingMode(.alwaysOriginal)

            break
            
        default:
            break
            
        }

    }
}
