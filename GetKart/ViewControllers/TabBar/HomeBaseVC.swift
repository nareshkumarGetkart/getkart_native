//
//  HomeBaseVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit

class HomeBaseVC: UITabBarController {
    
    var controllers: [UIViewController]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
