//
//  ChatListVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI

extension ChatListVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationController?.viewControllers.count ?? 0 > 1
    }
}


protocol PageVisible {
    func pageDidBecomeVisible()
}


class ChatListVC: UIViewController {
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    
    
    @IBOutlet weak var btnBlockUser:UIButton!

    private var pageMenu: CAPSPageMenu?
    private var viewNotification: UIView?
    private var viewBack: UIView?
    private var viewDemo: UIView?
    private var viewGiftDemo: UIView?
    private var viewCenterDemo: UIView?
    private var demoTaps = 0
    private  var viewSecretMsg = UIView()
    private  let imgSecretBack = UIImageView()
    private let lblSecretMsg = UILabel()
    
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBlockUser.setImageColor(color: .label)
        cnstrntHtNavBar.constant = self.getNavBarHt
       
        
        var controllerArray : [UIViewController] = []
        
        let peopleVC = StoryBoard.main.instantiateViewController(withIdentifier: "BuyingChatVC") as! BuyingChatVC
        peopleVC.title = "Buying"
        peopleVC.navController = self.navigationController
        controllerArray.append(peopleVC)
        
        let premiumVC =  StoryBoard.main.instantiateViewController(withIdentifier: "SellingChatVC") as! SellingChatVC
        premiumVC.title = "Selling"
        premiumVC.navController = self.navigationController
        controllerArray.append(premiumVC)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(2.0),
            .menuItemSeparatorPercentageHeight(0.05),
            .menuItemWidth(self.view.frame.size.width/2-50),
            .centerMenuItems(true),
            .bottomMenuHairlineColor(UIColor.clear),
            .selectionIndicatorColor(Themes.sharedInstance.themeColor),
            .scrollMenuBackgroundColor(UIColor.systemBackground),
            .selectedMenuItemLabelColor(.label),
            .unselectedMenuItemLabelColor(.darkGray),
            .menuHeight(40),
            .selectionIndicatorHeight(2),
            .menuItemFont(UIFont.Manrope.medium(size: 16).font),
            
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, cnstrntHtNavBar.constant, self.view.frame.width, self.view.frame.height-cnstrntHtNavBar.constant-(self.tabBarController?.tabBar.frame.height ?? 0)), pageMenuOptions: parameters)
        pageMenu?.delegate = self
        pageMenu?.menuScrollView.isScrollEnabled = false
        pageMenu?.controllerScrollView.isScrollEnabled = false
        self.view.addSubview(pageMenu!.view)
        
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //pageMenu?.controllerArray[pageMenu?.currentPageIndex ?? 0].viewWillAppear(true)
        
        (pageMenu?.controllerArray[pageMenu?.currentPageIndex ?? 0] as? PageVisible)?.pageDidBecomeVisible()
        SocketIOManager.sharedInstance.checkSocketStatus()
    }
    
    @IBAction func blockedUSerBtnAction(_ sender : UIButton){
        
        let hostingController = UIHostingController(rootView: BlockedUserView(navigationController: self.navigationController)) // Wrap in UIHostingController
        hostingController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(hostingController, animated: true)
      //  AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true) // Push to navigation stack
    }
    
}

extension ChatListVC : CAPSPageMenuDelegate {

  
    func willMoveToPage(_ controller: UIViewController, index: Int){
        print(index)
    }

    func didMoveToPage(_ controller: UIViewController, index: Int){
        print(index)
    }

}
