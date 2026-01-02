//
//  HomeVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI
import Kingfisher
import FittedSheets
import Foundation
import CommonCrypto

extension HomeVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationController?.viewControllers.count ?? 0 > 1
    }
}

class HomeVC: UIViewController, LocationSelectedDelegate {
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var btnLocation:UIButton!
    @IBOutlet weak var loaderBgView:UIView!
    @IBOutlet weak var cnstrntLoaderHt:NSLayoutConstraint!

    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemYellow
        return refreshControl
    }()
    
    private var homeVModel:HomeViewModel?

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        btnLocation.layer.cornerRadius = 8.0
        btnLocation.backgroundColor = .systemBackground
        btnLocation.setImageColor(color: .label)
        btnLocation.clipsToBounds = true
        configureTableView()
        updateLocationLabel(city: Local.shared.getUserCity(), state: Local.shared.getUserState(), country: Local.shared.getUserCountry(), locality:  Local.shared.getUserLocality())
        homeVModel = HomeViewModel()
        homeVModel?.delegate = self
        homeVModel?.getProductListApi()
        
        NotificationCenter.default.addObserver(self,selector:
                                                #selector(handleLocationSelected(_:)),
                                               name:NSNotification.Name(rawValue:NotiKeysLocSelected.homeNewLocation.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self,selector:
                                                #selector(noInternet(notification:)),
                                               name:NSNotification.Name(rawValue:NotificationKeys.noInternet.rawValue),
                                               object: nil)
      
       
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        
        if Local.shared.getUserId() > 0{
                getpopupApi()
        }
     
  }
    
   
   
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !AppDelegate.sharedInstance.isInternetConnected{
            homeVModel?.isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
            return
        }
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Clear caches, release unnecessary memory
        ImageCache.default.clearMemoryCache()
    }

    func registerCells(){
        tblView.register(UINib(nibName: "HomeTblCell", bundle: nil), forCellReuseIdentifier: "HomeTblCell")
        tblView.register(UINib(nibName: "HomeHorizontalCell", bundle: nil), forCellReuseIdentifier: "HomeHorizontalCell")
        tblView.register(UINib(nibName: "BannerTblCell", bundle: nil), forCellReuseIdentifier: "BannerTblCell")
    }
    
    func scrollToTop() {
        DispatchQueue.main.async {
            // scroll code here
            let topIndex = IndexPath(row: 0, section: 0)
            if self.tblView?.numberOfRows(inSection: 0) ?? 0 > 0 {
                self.tblView?.scrollToRow(at: topIndex, at: .top, animated: true)
            }
        }
    }
    
    
    //MARK: Observer Location
    @objc func handleLocationSelected(_ notification: Notification) {
        
        if let userInfo = notification.userInfo as? [String: Any]
        {
            let city = userInfo["city"] as? String ?? ""
            let state = userInfo["state"] as? String ?? ""
            let country = userInfo["country"] as? String ?? ""
            let latitude = userInfo["latitude"] as? String ?? ""
            let longitude = userInfo["longitude"] as? String ?? ""
            let locality = userInfo["locality"] as? String ?? ""
            
            handleLocationUpdate(city: city, state: state, country: country, latitude: latitude, longitude: longitude, locality: locality)
         
        }
    }

    @objc func noInternet(notification:Notification?){
        
        homeVModel?.isDataLoading = false
        AlertView.sharedManager.showToast(message: "No internet connection")
    }
    
    



    func dummyPopupCheck(togetvalues:Int){
        
        
        if togetvalues == 0{
            self.presentHostingController(objPopup: PopupModel(userID:639, title: "Boost Your Free Item's Visibility",
                                                                          subtitle: "Upgrade your listing for better exposure and faster response.",
                                                                          description: "<ul><li>You have items saved as draft that are not visible to others.</li>                                            <li>Complete the required details to make your item live.</li>                                            <li>Publishing your item increases visibility and chances of response.</li>                                            <li>Make sure the images and description are clear and accurate.</li>                                            <li>Click 'Publish Now' to make your draft item available to others.</li>                                        </ul>", image:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892ea49d25f30.982046931754458697.png", mandatoryClick: false,
                                                                          buttonTitle: "Okay",
                                                               type: 1, itemID: 49625, secondButtonTitle: ""))
              
        }else if togetvalues == 1{
            
      
   

            self.presentHostingController(objPopup: PopupModel(userID:639, title:
                                                                     """
                                                                     <span style='display:block; text-align:center; color:#000000; font-size:23px; font-family:Inter; font-weight:500; word-wrap:break-word;'>
                                                                         Highlight your ad at the top<br/>and boost sales
                                                                     </span>
                                                                     """,
                                                                      subtitle: "",
                                                                      description: "", image:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/sliders/2025/12/692d8387443e45.785661921764590471.png", mandatoryClick: false,
                                                                      buttonTitle: "Okay",
                                                               type: 5, itemID: 49625, secondButtonTitle: ""))
        }else if togetvalues == 2{
            self.presentHostingController(objPopup: PopupModel(userID:639, title:"""
<span style="color:#808080; font-size:24px;">For a limited time, enjoy posting </span><span style="color:#000000; font-size:23px;"><strong>3 ads completely FREE</strong></span><span style="color:#808080; font-size:24px;"> — no charges</span>
"""
                                                               ,
                                                               subtitle: "",
                                                               description:""
                                                               , image:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/sliders/2025/12/692e8a4ce04351.605374521764657740.png", mandatoryClick: false,
                                                               buttonTitle: "Post Now",
                                                               type: 5, itemID: 49625, secondButtonTitle: ""))
            
        }else if togetvalues == 3{
            self.presentHostingController(objPopup: PopupModel(userID:639, title: "You have draft items pending!",
                                                                      subtitle: "Complete your draft item and publish it to reach more people.",
                                                                      description: "<ul><li>You have items saved as draft that are not visible to others.</li>                                            <li>Complete the required details to make your item live.</li>                                            <li>Publishing your item increases visibility and chances of response.</li>                                            <li>Make sure the images and description are clear and accurate.</li>                                            <li>Click 'Publish Now' to make your draft item available to others.</li>                                        </ul>", image:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892f2a328ee10.794870231754460835.png", mandatoryClick: false,
                                                                      buttonTitle: "Publish Now",
                                                               type: 1, itemID: 49625, secondButtonTitle: ""))
            
        }else if togetvalues == 4{
            self.presentHostingController(objPopup: PopupModel(userID:639, title: 
                                                                      """
                                                                      <div style="text-align: center"><span style="color: #C80B66; font-size: 22px; font-family: Inter; font-weight: 600; word-wrap: break-word">Awesome!</span><span style="color: black; font-size: 22px; font-family: Inter; font-weight: 600; word-wrap: break-word"> </span><span style="color: #1D1D1D; font-size: 22px; font-family: Inter; font-weight: 600; word-wrap: break-word">Your </span><span style="color: #C80B66; font-size: 22px; font-family: Inter; font-weight: 600; word-wrap: break-word">Ad</span><span style="color: #1D1D1D; font-size: 22px; font-family: Inter; font-weight: 600; word-wrap: break-word"> is live. Boost to get<br/>more buyers and sell fast.</span></div>
                                                                      """
                                                                      ,
                                                                      subtitle: "",
                                                                      description: "", image:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892f2a328ee10.794870231754460835.png", mandatoryClick: false,
                                                                      buttonTitle: "Publish Now",
                                                               type: 1, itemID: 49625, secondButtonTitle: ""))
            
        }else if togetvalues == 5{
            self.presentHostingController(objPopup: PopupModel(userID:639, title:
                                                                      """
                                                                      <center>
                                                                          <b><font color="#000000">Boost Your Post For Just &#8377;35</font></b>
                                                                      </center>
                                                                      """
                                                                      ,
                                                                      subtitle: " <font color='#424243'>Get 5x more views &amp; reach more buyers instantly.</font><br><font color='#424243'>• Lowest Price &nbsp; • Top of List &nbsp; • 30 days Visibility</font>",
                                                                      description: "", image:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892f2a328ee10.794870231754460835.png", mandatoryClick: false,
                                                                      buttonTitle: "Publish Now",
                                                               type: 5, itemID: 49625, secondButtonTitle: ""))
            
        }else if togetvalues == 6{
            
            self.showBoostYourBoardPopup(obj:PopupModel(userID:639, title: ""
                                                                      ,
                                                                      subtitle: "",
                                                                      description: "", image:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/sliders/2025/12/6954d90b924726.419396251767168267.png", mandatoryClick: false,
                                                                      buttonTitle: "Boost for ₹75",
                                                               type: 6, itemID: 10497, secondButtonTitle: "Maybe Later"))
        }
          
        
        /*  self.presentHostingController(objPopup: PopupModel(userID:639, title: "Boost Your Free Item's Visibility",
                                                                   subtitle: "Upgrade your listing for better exposure and faster response.",
                                                                   description: "<ul>                                                <li>Your item is currently listed as a Free Post.</li>                                                <li>Free posts have limited reach and visibility.</li>                                                <li>Upgrade to a premium package to get more views and responses.</li>                                                <li>Premium listings appear at the top and reach more interested buyers.</li>                                                <li>Click 'Boost Now' to enhance your item's performance.</li>                                            </ul>", image:"https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892ea49d25f30.982046931754458697.png", mandatoryClick: false,
                                                                   buttonTitle: "Okay",
                                                                   type: 1, itemID: 49625))
                
                
                return*/
           
    }
    
    
  
/*
 ""
<p style="text-align:center;">For a limited time, enjoying posting <strong>3 ads completely FREE</strong> — no charges</p>
""
 dummyPopupCheck(togetvalues: 0)
    return
 */
    //MARK: Api methods
    func getpopupApi(){
//        dummyPopupCheck(togetvalues: 6)
//           return
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: Constant.shared.alert_popup) { [weak self](obj:PopupParseModel) in
            
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
                } else if (obj.data.type ?? 0) == 1 || (obj.data.type ?? 0) == 2 || (obj.data.type ?? 0) == 3  || (obj.data.type ?? 0) == 4 || (obj.data.type ?? 0) == 5 {
                    self?.presentHostingController(objPopup: obj.data)
               
                }else if (obj.data.type ?? 0) == 6{
                    //Boost board
                    self?.showBoostYourBoardPopup(obj: obj.data)
                    
                }
            }
        }
    }
    
  
    
    func presentHostingController(objPopup:PopupModel){
        
        let controller = UIHostingController(
            rootView: BottomSheetPopupView(objPopup: objPopup,pushToScreenFromPopup: {  (obj,dismissOnly) in }))
       
        
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
        sheet.cornerRadius = 15
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
        
        
        
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 15
        sheet.dismissOnOverlayTap = true
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
        
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
     
        let settingView =  BottomSheetPopupView(objPopup: objPopup,pushToScreenFromPopup: { [weak self] (obj,dismissOnly) in
            
            if sheet.options.useInlineMode == true {
                sheet.attemptDismiss(animated: true)
            } else {
               sheet.dismiss(animated: true, completion: nil)
            }
            
            
            if dismissOnly{
                
            }else{
                if (obj.type ?? 0) == 1  {
                    
                    self?.pushToMyAdsScreen()
                    
                }else if (obj.type ?? 0) == 2  || (obj.type ?? 0) == 3  && (obj.itemID ?? 0) > 0{
                    /*
                     If any add in Draft message will get popped up to Buy Plans type = 1
                     If user has Free Approved Add then pop up message to Buy  Plan type = 2
                     If user has Paid Ad from Listing Plan then Pop up message to Boost Plan type = 3
                     type == 5 banner promotion
                     */
                    let siftUIview = ItemDetailView(navController:  self?.navigationController, itemId: objPopup.itemID ?? 0, itemObj: nil, slug: "")
                    let hostingController = UIHostingController(rootView:siftUIview)
                    hostingController.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(hostingController, animated: true)
                    
                }else if (obj.type ?? 0) == 4  {
                    //If User has just registered and not posted any ad than Pop up message to Run Ad  type = 4
                    
                    if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                        destVC.hidesBottomBarWhenPushed = true
                        destVC.popType = .createPost
                        self?.navigationController?.pushViewController(destVC, animated: true)
                    }
                }else if (obj.type ?? 0) == 5  {
                    //5 banner promotion
                    let destVC = UIHostingController(rootView:  BannerPromotionsView(navigationController: self?.navigationController))
                    destVC.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(destVC, animated: true)
                    
                }else if (obj.type ?? 0) == 6  {
                    //Boost board
                    
                }
            }
        })

        
        controller.rootView = settingView
        
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
        
    }
    
    
    func showBoostYourBoardPopup(obj:PopupModel) {

        let popupView = BoostYourBoardPopupView(
            onBoost: {
                print("Boost tapped")
                if (obj.itemID ?? 0) > 0{
                    let destVC = UIHostingController(rootView: BoardAnalyticsView(navigationController: self.navigationController, boardId: obj.itemID ?? 0))
                    self.navigationController?.pushViewController(destVC, animated: true)
                }else{
                    let destVC = UIHostingController(rootView: MyBoardsView(navigationController: self.navigationController))
                    self.navigationController?.pushViewController(destVC, animated: true)
                }
            },
            onLater: {
                print("Later tapped")
            },
            onClose: {
                self.dismiss(animated: true)
            },
            objPopup:obj
        )

        let hostingVC = UIHostingController(rootView: popupView)
        hostingVC.modalPresentationStyle = .overFullScreen
        hostingVC.view.backgroundColor = .clear
        present(hostingVC, animated: false)
    }


    
  /*  func presentHostingController(objPopup:PopupModel){
        
        let controller = UIHostingController(rootView: BottomSheetPopupView(objPopup: objPopup, pushToScreenFromPopup: { [weak self] (obj,dismissOnly) in

            self?.sheet.attemptDismiss(animated: true)
            if dismissOnly{
                
            }else{
                if (obj.type ?? 0) == 1  {
                    self?.pushToMyAdsScreen()
                }else if (obj.type ?? 0) == 2  || (obj.type ?? 0) == 3  && (obj.itemID ?? 0) > 0{
                /*
                 If any add in Draft message will get popped up to Buy Plans type = 1
                 If user has Free Approved Add then pop up message to Buy  Plan type = 2
                 If user has Paid Ad from Listing Plan then Pop up message to Boost Plan type = 3
                 type == 5 banner promotion
                */
                    let siftUIview = ItemDetailView(navController:  self?.navigationController, itemId: objPopup.itemID ?? 0, itemObj: nil, slug: "")
                    let hostingController = UIHostingController(rootView:siftUIview)
                    hostingController.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(hostingController, animated: true)
                    
                }else if (obj.type ?? 0) == 4  {
                    //If User has just registered and not posted any ad than Pop up message to Run Ad  type = 4
                                   
                    if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                        destVC.hidesBottomBarWhenPushed = true
                        destVC.popType = .createPost
                        self?.navigationController?.pushViewController(destVC, animated: true)
                    }
                }else if (obj.type ?? 0) == 5  {
                    //5 banner promotion
                    let destVC = UIHostingController(rootView:  BannerPromotionsView(navigationController: self?.navigationController))
                    destVC.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(destVC, animated: true)
                }
            }
        }))
        
        let useInlineMode = view != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 550
        
        if (objPopup.image?.count ?? 0) == 0{
            fixedSize = fixedSize - 150
        }
        if (objPopup.subtitle?.count ?? 0) == 0{
            fixedSize = fixedSize - 50
        }
        
        if (objPopup.description?.count ?? 0) == 0{
            fixedSize = fixedSize - 70
        }else{
            fixedSize = fixedSize + 15
        }
        nav.navigationBar.isHidden = true
        
        
        sheet = SheetViewController(
            controller: controller,
           //sizes: [.fixed(CGFloat(fixedSize)),.intrinsic],
            sizes: [.intrinsic],

            options: SheetOptions(presentingViewCornerRadius : 20 , useInlineMode: true))
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 20
        sheet.dismissOnOverlayTap = true
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
        
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
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            guard let sh = sheet else{ return }
            self.navigationController?.present(sh, animated: true, completion: nil)
        }
      
    }
    */
    
    
    func pushToMyAdsScreen(){
        
        
       /* for controller in AppDelegate.sharedInstance.navigationController?.viewControllers ?? []{
            
            if let destvc =  controller as? HomeBaseVC{
                
                
                if let navController = destvc.viewControllers?[0] as? UINavigationController {
                    navController.popToRootViewController(animated: false)

                }
                
                if let navController = destvc.viewControllers?[1] as? UINavigationController {
                    navController.popToRootViewController(animated: false)

                }
                
                if let navController = destvc.viewControllers?[2] as? UINavigationController {
                    navController.popToRootViewController(animated: false)

                }
                
                if let navController = destvc.viewControllers?[4] as? UINavigationController {
                    navController.popToRootViewController(animated: false)
                }
                
                destvc.selectedIndex = 3
                
                if let navController = destvc.viewControllers?[4] as? UINavigationController {
                  
                    navController.popToRootViewController(animated: false)

                    // Notify the 3rd view controller to refresh
                    if  let thirdVC = navController.viewControllers.first as? MyAdsVC {
                        thirdVC.refreshMyAds()
                        break
                    }
                }
            }
        }*/
        
            let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "MyAdsVC") as! MyAdsVC
            destVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    //MARK: Pull Down refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        
        if !AppDelegate.sharedInstance.isInternetConnected{
            homeVModel?.isDataLoading = false
            AlertView.sharedManager.showToast(message: "No internet connection")
            
        }else if !(homeVModel?.isDataLoading ?? false) {
            homeVModel?.page = 1
            homeVModel?.itemObj?.data = nil
            homeVModel?.featuredObj = nil
            homeVModel?.itemObj?.data?.removeAll()
            homeVModel?.featuredObj?.removeAll()
            self.tblView.reloadData()
            homeVModel?.getProductListApi()
            homeVModel?.getSliderListApi()
            if (homeVModel?.categoryObj?.data?.count ?? 0) == 0{
                homeVModel?.getCategoriesListApi()
            }
            homeVModel?.getFeaturedListApi()
        }
        refreshControl.endRefreshing()
    }
     
    //MARK: UIButton Action
    
    @IBAction func locationBtnAction(_ sender : UIButton){
/*
//        let swiftUIView = CreateAdSecondView(navigationController: self.navigationController)
//        let destVC = UIHostingController(rootView: swiftUIView)
//        destVC.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(destVC, animated: true)
//      return
//        
        */
        var rootView = CountryLocationView(popType: .home, navigationController: self.navigationController)
        rootView.delLocationSelected = self
           let vc = UIHostingController(rootView:rootView)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
         
       
    
}
    
    @IBAction func searchBtnAction(_ sender : UIButton){

        let swiftUIview = SearchWithSortView(categroryId: 0, navigationController:self.navigationController, categoryName:  "", categoryIds: "", categoryImg: "",pushToSuggestion:true)
        let vc = UIHostingController(rootView: swiftUIview)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func micBtnAction(_ sender : UIButton){
        
        
    }
    
    @IBAction func filterBtnAction(_ sender : UIButton){
        
        
        let swiftUIview = SearchWithSortView(categroryId: 0, navigationController:self.navigationController, categoryName:  "", categoryIds: "", categoryImg: "",pushToSuggestion:false,pushToFilter:true)
        let vc = UIHostingController(rootView: swiftUIview)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func logoBtnAction(_ sender : UIButton){
        
        
    }

    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String){

        handleLocationUpdate(city: city, state: state, country: country, latitude: latitude, longitude: longitude, locality: locality)
      
    }
}

extension HomeVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return (homeVModel?.categoryObj?.data?.count ?? 0) > 0 ? 135 : 0
        }
        if indexPath.section == 2{
            
            if (homeVModel?.featuredObj?.count ?? 0) == 0{
                return 0
            }else if let obj = homeVModel?.featuredObj?[indexPath.item]{
                if (obj.sectionData?.count ?? 0) == 0{ return 0} // section is empty
                if (obj.style == "style_1") || (obj.style == "style_2") || (obj.style == "style_4"){
                    return  315
                }
            }
        }
       
        return  UITableView.automaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            //Banner
            return (homeVModel?.sliderArray?.count ?? 0) > 0 ? 1 : 0
            
        case 1:
            //Category
            return (homeVModel?.categoryObj?.data?.count ?? 0) > 0 ? 1 : 0
            
        case 2:
            //Featured
            return  (homeVModel?.featuredObj?.count ?? 0) > 0 ? (homeVModel?.featuredObj?.count ?? 0) : 0
        case 3:
            //Items
            return (homeVModel?.itemObj?.data?.count ?? 0) > 0 ? 1 : 0
        default:
            return 0
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTblCell") as! BannerTblCell
            if let banners = homeVModel?.sliderArray {
                cell.configure(with: banners)
            }
             cell.navigationController = self.navigationController

//            cell.listArray = homeVModel?.sliderArray
//            cell.collctnView.updateConstraints()
//            cell.collctnView.reloadData()
//            cell.updateConstraints()
            return cell
            
        } else if indexPath.section == 1 {
            guard let cell = tblView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as? HomeHorizontalCell else { return UITableViewCell() }
            cell.cnstrntHeightSeeAllView.constant = 0
            cell.btnSeeAll.setTitle("", for: .normal)
            cell.cellTypes = .categories
            cell.listArray = homeVModel?.categoryObj?.data
            cell.layoutIfNeeded()
            cell.collctnView.layoutIfNeeded()
            cell.collctnView.updateConstraints()
            cell.collctnView.reloadData()
            cell.updateConstraints()
            cell.navigationController = self.navigationController
            return cell
        
            
        }else if indexPath.section == 2{
            let obj = homeVModel?.featuredObj?[indexPath.item]
            
            if (obj?.style == "style_1"){
                //Horizontal && increase width
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.istoIncreaseWidth = true
                cell.cnstrntHeightSeeAllView.constant = 30
                cell.btnSeeAll.setTitle("See All", for: .normal)
                cell.cellTypes = .product
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.section = indexPath.section
                cell.rowIndex = indexPath.row
                cell.delegateUpdateList = self
                cell.layoutIfNeeded()
                cell.updateConstraints()
                cell.collctnView.updateConstraints()
                cell.collctnView.reloadData()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                cell.navigationController = self.navigationController
                return cell
                
            }else if (obj?.style == "style_2"){
                //Horizontal
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.collctnView.collectionViewLayout.invalidateLayout()
                cell.istoIncreaseWidth = false
                cell.cnstrntHeightSeeAllView.constant = 30
                cell.btnSeeAll.setTitle("See All", for: .normal)
                cell.cellTypes = .product
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.section = indexPath.section
                cell.rowIndex = indexPath.row
                cell.delegateUpdateList = self
                cell.layoutIfNeeded()
                cell.collctnView.layoutIfNeeded()
                cell.updateConstraints()
                cell.collctnView.updateConstraints()
                cell.collctnView.reloadData()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                cell.navigationController = self.navigationController
                return cell
                
            }else if (obj?.style == "style_3"){
                //vertical
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
                cell.istoIncreaseWidth = false
                cell.cnstrntHeightSeeAllView.constant = 30
                cell.btnSeeAll.setTitle("See All", for: .normal)
                cell.cllctnView.isScrollEnabled = false
                cell.cellTypes = .product
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.section = indexPath.section
                cell.rowIndex = indexPath.row
                cell.delegateUpdateList = self
                cell.layoutIfNeeded()
                cell.cllctnView.layoutIfNeeded()
                cell.cllctnView.updateConstraints()
                cell.cllctnView.reloadData()
                cell.updateConstraints()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                cell.navigationController = self.navigationController
                return cell
                
            }else if (obj?.style == "style_4"){
                //Horizontal && increase width
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHorizontalCell") as! HomeHorizontalCell
                cell.cnstrntHeightSeeAllView.constant = 30
                cell.btnSeeAll.setTitle("See All", for: .normal)
                cell.cellTypes = .product
                cell.istoIncreaseWidth = true
                cell.listArray = obj?.sectionData
                cell.lblTtitle.text = obj?.title
                cell.section = indexPath.section
                cell.rowIndex = indexPath.row
                cell.delegateUpdateList = self
                cell.layoutIfNeeded()
                cell.collctnView.layoutIfNeeded()
                cell.updateConstraints()
                cell.collctnView.updateConstraints()
                cell.collctnView.reloadData()
                cell.btnSeeAll.tag = indexPath.section + indexPath.row
                cell.btnSeeAll.addTarget(self, action: #selector(selectedSeeAll(_ :)), for: .touchUpInside)
                cell.navigationController = self.navigationController
                return cell
                
            }
            
            return UITableViewCell()
            
        }else if indexPath.section == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTblCell") as! HomeTblCell
            cell.cnstrntHeightSeeAllView.constant = 30 //0
            cell.btnSeeAll.setTitle("", for: .normal)
            cell.cllctnView.isScrollEnabled = false
            cell.lblTtitle.text = "Suggested for You"
            cell.cellTypes = .product
            cell.listArray = homeVModel?.itemObj?.data
            cell.section = indexPath.section
            cell.rowIndex = indexPath.row
            cell.delegateUpdateList = self
            cell.cllctnView.layoutIfNeeded()
            cell.cllctnView.updateConstraints()
            cell.cllctnView.reloadData()
            cell.updateConstraints()
            cell.navigationController = self.navigationController

            return cell
        }
        return UITableViewCell()

    }
    
    
    
    @objc func selectedSeeAll(_ sender : UIButton){
        
        let tag =  sender.tag  - 2
        
        let sectionObj =  homeVModel?.featuredObj?[tag]
        if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "SeeAllItemVC") as? SeeAllItemVC {
            destVC.obj = sectionObj
            destVC.city = homeVModel?.city ?? ""
            destVC.state = homeVModel?.state ?? ""
            destVC.country = homeVModel?.country ?? ""
            destVC.latitude = homeVModel?.latitude ?? ""
            destVC.longitude = homeVModel?.longitude ?? ""
            
            destVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
            // print("up")
            if scrollView == tblView{
                return
            }
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 400)
        {
            if scrollView == tblView{
                if homeVModel?.isDataLoading == false && (homeVModel?.itemObj?.data?.count ?? 0) > 0{
                    homeVModel?.getProductListApi()
                }
            }
        }
    }
}


extension HomeVC: RefreshScreen{
    
    
    func refreshFeaturedsList(){
        
        if (homeVModel?.featuredObj?.count ?? 0) == 0{
            self.tblView.reloadData()
            
        }else{
            tblView.reloadSections(IndexSet(integer: 2), with: .none)
        }
    }
    
    func refreshBannerList(){
        
        tblView.reloadSections(IndexSet(integer: 0), with: .none)

    }
    func refreshCategoriesList(){
        
        tblView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    func refreshScreen(){
        self.tblView.reloadData()
        tblView.setNeedsLayout()
        tblView.layoutIfNeeded()
    }
    
    
    func newItemRecieve(newItemArray:[Any]?){
        guard let newItems = newItemArray as? [ItemModel], !newItems.isEmpty else { return }
        
        let section = 3
        let oldCount = homeVModel?.itemObj?.data?.count ?? 0
        homeVModel?.itemObj?.data?.append(contentsOf: newItems)
        let newCount = homeVModel?.itemObj?.data?.count ?? 0
        
        let newIndexPaths = (oldCount..<newCount).map { IndexPath(item: $0, section: 0) }
        
        DispatchQueue.main.async {
            if let cell = self.tblView.cellForRow(at: IndexPath(row: 0, section: section)) as? HomeTblCell {
                cell.listArray = self.homeVModel?.itemObj?.data
                cell.cllctnView.performBatchUpdates({
                    cell.cllctnView.insertItems(at: newIndexPaths)
                }, completion: nil)
            } else {
                // If cell not visible, reload section to reflect new data when it comes into view
                self.tblView.reloadSections(IndexSet(integer: section), with: .none)
            }
            
            // Recalculate height if needed
            self.tblView.beginUpdates()
            self.tblView.endUpdates()
        }
    }
}


extension HomeVC:UPdateListDelegate{
    
    func updateArray(section:Int,rowIndex:Int,arrIndex:Int,obj:Any?){

        switch section {
            
        case 0: break
            //Banner
            
        case 1: break
            //Category
            
        case 2:
            //Featured
            if let selObj = obj as? ItemModel{
                homeVModel?.featuredObj?[rowIndex].sectionData?[arrIndex] = selObj
            }
        case 3:
            //Items
            if let selObj = obj as? ItemModel{
                homeVModel?.itemObj?.data?[rowIndex] = selObj
            }
        default:
            break
            
        }
        
    }
    
}


// Optimized HomeVC

extension HomeVC {


    func refreshTableOnFilterOrLocationChange() {
        homeVModel?.page = 1
        homeVModel?.itemObj?.data?.removeAll()
        homeVModel?.featuredObj?.removeAll()
        tblView.reloadData()
    }

    func configureTableView() {
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 200
        tblView.refreshControl = topRefreshControl
        self.topRefreshControl.backgroundColor = .clear
        
        registerCells()
    }

    func handleLocationUpdate(city: String, state: String, country: String, latitude: String, longitude: String,locality:String) {
        homeVModel?.city = city
        homeVModel?.state = state
        homeVModel?.country = country
        homeVModel?.latitude = latitude
        homeVModel?.longitude = longitude
        homeVModel?.area = locality
        refreshTableOnFilterOrLocationChange()
        homeVModel?.getFeaturedListApi()
        homeVModel?.getProductListApi()
        homeVModel?.getSliderListApi()

        updateLocationLabel(city: city, state: state, country: country,locality: locality)
    }
    

    func updateLocationLabel(city: String, state: String, country: String,locality:String) {
        var locStr = city
       
        if !locality.isEmpty { locStr  = "\(locality), \(city)" }
        if !state.isEmpty { locStr += ", \(state)" }
        if !country.isEmpty { locStr += ", \(country)" }
        lblAddress.text = locStr.isEmpty ? "All \(country)" : locStr
        
        if state.count == 0 && city.count == 0{
            if country.count == 0{
                lblAddress.text =  "All India"
            }else{
                lblAddress.text =  "All \(country)"
            }
        }
        if let text = lblAddress.text, text.hasPrefix(",") {
            lblAddress.text = String(text.dropFirst())
        }
    }
}





