//
//  ProfileVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI
import StoreKit
import Kingfisher
import FittedSheets


extension ProfileVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationController?.viewControllers.count ?? 0 > 1
    }
}

class ProfileVC: UIViewController {
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnSetting:UIButton!
    @IBOutlet weak var lblAppVersion:UILabel!

  /*  let titleArray =  ["Anonymous","My Boost Ads","Buy Packages","Order History & Invoices","Dark Theme","Notifications","Blogs","Favorites","FAQs","Share this App","Rate us","Contact us","About us","Terms & Conditions","Privacy Policy","Refunds & Cancellation policy","Delete Account","Logout"]
      
    let iconArray =  ["","promoted","subscription","transaction","dark_theme","notification","article","like_fill","faq","share","rate_us","contact_us","about_us","t_c","privacypolicy","privacypolicy","delete_account","logout"]*/
    //,"Banner Promotions"
    var titleArray =  ["Anonymous","My Boost Ads","Buy Packages","Order History & Invoices","Dark Theme","Notifications","Blogs","Favorites","FAQs","Share this App","Rate us","Contact us","About us","Terms & Conditions","Privacy Policy","Refunds & Cancellation policy"]
      
//,"mediaPromotion"
    var iconArray =  ["","promoted","buyPackages","transaction","dark_theme","notification","article","like_fill","faq","share","rate_us","contact_us","about_us","t_c","privacypolicy","privacypolicy"]
      
    var verifiRejectedReason:String = ""
    var verifiSttaus:String = ""
    var isBannerPromotion = 0
    
    private  lazy var topRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                                    #selector(handlePullDownRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.systemYellow
        return refreshControl
    }()

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "ProfileListTblCell", bundle: nil), forCellReuseIdentifier: "ProfileListTblCell")
        
        tblView.register(UINib(nibName: "AnonymousUserCell", bundle: nil), forCellReuseIdentifier: "AnonymousUserCell")
        getUserProfileApi()
        self.topRefreshControl.backgroundColor = .clear
        tblView.refreshControl = topRefreshControl
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        btnSetting.layer.cornerRadius = btnSetting.frame.size.height/2.0
        btnSetting.clipsToBounds = true
        btnSetting.backgroundColor = Themes.sharedInstance.themeColor.withAlphaComponent(0.2)
        lblAppVersion.text = "App version : \(UIDevice.appVersion)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tblView.reloadData()
//        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
//       
//        if objLoggedInUser.id != nil {
            if Local.shared.getUserId() > 0{
            if Local.shared.isToRefreshVerifiedStatusApi == true{
                
                getVerificationStatusApi()
            }
                self.btnSetting.isHidden = false

            }else{
                self.btnSetting.isHidden = true
            }
    }
    
    //MARK: UIButton Action Methods
    @IBAction func settingsBtnAction(_ sender : UIButton){
        presentSettingView()
    }
    
    //MARK: Pull Down refresh
    @objc func handlePullDownRefresh(_ refreshControl: UIRefreshControl){
        
        if !AppDelegate.sharedInstance.isInternetConnected{
            AlertView.sharedManager.showToast(message: "No internet connection")
      
        }else if Local.shared.getUserId() > 0{
            getVerificationStatusApi()
        }
        refreshControl.endRefreshing()
    }
    
     
    func getVerificationStatusApi(){
        URLhandler.sharedinstance.makeCall(url: Constant.shared.verification_request, param: nil,methodType: .get) { responseObject, error in
            
            if error == nil{
                
                if let result = responseObject{
                    
                    if let data = result["data"] as? Dictionary<String, Any>{
                        self.verifiRejectedReason = data["rejection_reason"] as? String ?? ""
                        self.verifiSttaus = data["status"] as? String ?? ""
                        self.tblView.reloadData()
                        Local.shared.isToRefreshVerifiedStatusApi = false
                    }
                }
                
            }
        }
    }
    
    func getUserProfileApi(){
        
//        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
//        
//        if objLoggedInUser.id != nil {
            
            if Local.shared.getUserId() > 0{

            let strUrl = Constant.shared.get_seller + "?id=\(Local.shared.getUserId())"

            URLhandler.sharedinstance.makeCall(url: strUrl, param: nil,methodType: .get) { responseObject, error in
                
                if error == nil{
                    
                    let result = responseObject! as NSDictionary
                    let code = result["code"] as? Int ?? 0
                    let message = result["message"] as? String ?? ""
                    
                    if code == 200{
                        
                        if let data = result["data"] as? Dictionary<String,Any>{
                            
                            if let seller = data["seller"] as? Dictionary<String,Any>{
                                
                                if let intValue = seller["isBannerPromotion"] as? Int {
                                    self.isBannerPromotion = intValue
                                } else if let boolValue = seller["isBannerPromotion"] as? Bool {
                                    self.isBannerPromotion = boolValue ? 1 : 0
                                } else {
                                    self.isBannerPromotion = 0
                                }
                            }
                            
                            let strToCheck =  "Banner Promotions"
                            if self.isBannerPromotion == 0{

                                if let index = self.titleArray.firstIndex(of: strToCheck) {
                                    self.titleArray.remove(at: index)
                                    self.iconArray.remove(at: index)
                                }
                               
                            }else{
                                if !self.titleArray.contains(strToCheck){
                                    self.titleArray.insert(strToCheck, at: 3)
                                    self.iconArray.insert("mediaPromotion", at: 3)
                                }
                            }
                       
                            RealmManager.shared.updateUserData(dict: data)
                            self.tblView.reloadData()
                        }
                    }
                }
            }
        }
    }
}


extension ProfileVC:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 125
        }
        
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
//        if objLoggedInUser.id != nil {
        if Local.shared.getUserId() > 0{

            return titleArray.count
        }else{
            return (titleArray.count-2)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnonymousUserCell") as! AnonymousUserCell
            let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
            
            if objLoggedInUser.id != nil {
                cell.bgViewAnonymousUser.isHidden = true
                cell.bgViewLoggedInUser.isHidden = false
                cell.btnGetVerifiedBadge.isHidden = true
                cell.bgViewVerified.isHidden = true
                cell.lblStatus.isHidden = true
                cell.btnResubmit.isHidden = true
                cell.lblName.text =  objLoggedInUser.name ?? ""
                cell.lblEmail.text =  objLoggedInUser.email ?? ""
                cell.lblEmail.isHidden = (objLoggedInUser.email ?? "").count == 0
                                
                if verifiSttaus.lowercased() == "pending"{
                    cell.lblStatus.text =  "Under review" //verifiSttaus.capitalized
                    cell.lblStatus.backgroundColor = Themes.sharedInstance.themeColor
                    cell.lblStatus.isHidden = false
                    cell.btnResubmit.isHidden = true
                    cell.btnGetVerifiedBadge.isHidden = true
                    cell.bgViewVerified.isHidden = true

                }else if verifiSttaus.lowercased() == "rejected"{
                    cell.lblStatus.text =  verifiSttaus.capitalized
                    cell.lblStatus.backgroundColor = UIColor.red
                    cell.lblStatus.isHidden = false
                    cell.btnResubmit.isHidden = false
                    cell.btnGetVerifiedBadge.isHidden = true
                    cell.bgViewVerified.isHidden = true
                }else if verifiSttaus.lowercased() == "approved"{
                    
                    cell.btnGetVerifiedBadge.isHidden = true
                    cell.bgViewVerified.isHidden = false
                }else{
                    
                    if (objLoggedInUser.is_verified ?? 0) == 1{
                        cell.btnGetVerifiedBadge.isHidden = true
                        cell.bgViewVerified.isHidden = false
                    }else{
                        cell.btnGetVerifiedBadge.isHidden = false
                        cell.bgViewVerified.isHidden = true
                    }
                }
                
                /*
                 1 If Username Exists-> Username's First Character as Image Icon
                 2 if no user name then-> profile placeholder (Guest User)
                 3 if user upload image  then will show user's profile image
                 */
                
                 cell.btnGetVerifiedBadge.addTarget(self, action: #selector(getVerified), for: .touchUpInside)
                
                // cell.imgVwProfile.kf.setImage(with: URL(string: objLoggedInUser.profile ?? ""), placeholder: UIImage(named: "user-circle"), options: nil, progressBlock: nil, completionHandler: nil)
                
                
                cell.imgVwProfile.configure(name: objLoggedInUser.name ?? "", imageUrl: objLoggedInUser.profile ?? "")

//                if (objLoggedInUser.profile ?? "").count == 0{
//                    cell.imgVwProfile.configure(name: objLoggedInUser.name ?? "", imageUrl: objLoggedInUser.profile ?? "")
//
//                }else if (objLoggedInUser.name ?? "") == "Guest User"{
//                    
//                }else{
//                    cell.imgVwProfile.configure(name: objLoggedInUser.name ?? "", imageUrl: objLoggedInUser.profile ?? "")
//
//                }
                
               // if (objLoggedInUser.profile ?? "").count == 0{
                    cell.imgVwProfile.layer.borderColor = Themes.sharedInstance.themeColor.cgColor
                    cell.imgVwProfile.layer.borderWidth = 1.5
                    cell.imgVwProfile.clipsToBounds = true
//                }else{
//                    cell.imgVwProfile.layer.borderColor = UIColor.clear.cgColor
//                    cell.imgVwProfile.layer.borderWidth = 0.0
//                    cell.imgVwProfile.clipsToBounds = true
//                }

                cell.btnResubmit.addTarget(self, action: #selector(getVerified), for: .touchUpInside)
                cell.lblStatus.isUserInteractionEnabled = true
                cell.lblStatus.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(statusTapped)))
                cell.btnPencil.addTarget(self, action: #selector(editProfileBtnACtion), for: .touchUpInside)
                cell.btnEditProfile.addTarget(self, action: #selector(editProfileBtnACtion), for: .touchUpInside)

            }else{
                cell.bgViewLoggedInUser.isHidden = true
                cell.bgViewAnonymousUser.isHidden = false
                cell.btnLogin.addTarget(self, action: #selector(loginToScren), for: .touchUpInside)
                
            }
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListTblCell") as! ProfileListTblCell
            
            cell.lblTitle.text = titleArray[indexPath.row]
            cell.imgVwIcon.image = UIImage(named: iconArray[indexPath.row])
            cell.imgVwIcon.setImageTintColor(color: Themes.sharedInstance.themeColor)
            
            let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
            let theme = AppTheme(rawValue: savedTheme) ?? .system
            
            if theme == .dark{
                cell.bgviewIcon.backgroundColor = UIColor(hexString: "#342b1e")

            }else{
                cell.bgviewIcon.backgroundColor = UIColor(hexString: "#FFF7EA")
            }            
            
            if titleArray[indexPath.row] == "Dark Theme"{
                cell.imgVwArrow.isHidden = true
                cell.btnSwitch.isHidden = false
                cell.btnSwitch.addTarget(self, action: #selector(didTapSwitch(_:)), for: .touchUpInside)
              
                
                cell.btnSwitch.isOn = (theme == .dark) ? true : false
                
            }else{
                cell.imgVwArrow.isHidden = false
                cell.btnSwitch.isHidden = true
            }
            
            return cell
        }
        
        // return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
        }else{
                        
            
            if titleArray[indexPath.row] == "Contact us"{
                
                let destVC = UIHostingController(rootView: ContactUsView(navigationController:self.navigationController))
                destVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destVC, animated: true)
                
            }else if titleArray[indexPath.row] == "My Boost Ads"{
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    let destVC = UIHostingController(rootView: MyBoostAdsView(navigation: self.navigationController))
                    destVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(destVC, animated: true)
                }
                
            } else if titleArray[indexPath.row] == "Buy Packages"{
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    
                    if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPlanVC") as? CategoryPlanVC{
                        destvc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(destvc, animated: true)
                    }
                }
                
            }else if titleArray[indexPath.row] ==  "Banner Promotions"{
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    
                    let destvc = UIHostingController(rootView: BannerPromotionsView(navigationController: navigationController))
                    destvc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(destvc, animated: true)
                    
                }
            } else if titleArray[indexPath.row] == "FAQs"{
                
                let destVC = UIHostingController(rootView: FaqView(navigationController: self.navigationController))
                destVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destVC, animated: true)
                
            }else if titleArray[indexPath.row] == "Language"{
                
                let destVC = UIHostingController(rootView: LanguageView())
                destVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }else if titleArray[indexPath.row] == "Blogs"{
                
                let hostingController = UIHostingController(rootView: Blogsview(title: "Blogs",navigationController: self.navigationController)) // Wrap in UIHostingController
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
                
            }else if titleArray[indexPath.row] == "Privacy Policy"{
                
                let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Privacy Policy", type: .privacy) // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
                
            }else if titleArray[indexPath.row] == "Refunds & Cancellation policy"{
                
                let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Refunds & Cancellation policy", type: .refundAndCancellationPolicy,htmlString: "") // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
                
            }else if titleArray[indexPath.row] == "About us"{
                
                let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "About us", type: .aboutUs) // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
            }else if titleArray[indexPath.row] == "Terms & Conditions"{
                
                let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Terms & Conditions", type: .termsAndConditions) // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
            }else if titleArray[indexPath.row] == "Notifications"{
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    
                    let hostingController = UIHostingController(rootView: NotificationView(navigation:self.navigationController)) // Wrap in UIHostingController
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
                }
                
            }else if titleArray[indexPath.row] == "Favorites"{
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    let hostingController = UIHostingController(rootView: FavoritesView(navigation:self.navigationController)) // Wrap in UIHostingController
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
                }
                
            }else if titleArray[indexPath.row] == "Rate us"{
                
                rateApp()
                
            }else if titleArray[indexPath.row] == "Share this App"{
                ShareMedia.shareMediafrom(type: .appShare, mediaId: "", controller: self)
                
            }else if titleArray[indexPath.row] ==  "Order History & Invoices"{
                
                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                    
                    let hostingController = UIHostingController(rootView: TransactionHistoryView(navigation:self.navigationController)) // Wrap in UIHostingController
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
                }
            }else if titleArray[indexPath.row] ==  "Delete Account"{
                let deleteAccountView = UIHostingController(rootView: DeleteAccountView())
                deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
                deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
                deleteAccountView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                present(deleteAccountView, animated: true, completion: nil)
                
            }else if titleArray[indexPath.row] ==  "Logout"{
                let deleteAccountView = UIHostingController(rootView: LogoutView(navigationController: self.navigationController))
                deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
                deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
                deleteAccountView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                present(deleteAccountView, animated: true, completion: nil)
            }
        }
    }
    
    
    
    @objc func presentSettingView(){
        
        
        let controller = UIHostingController(rootView: SettingsView( callbackAction: {action in }))
       
        
        let useInlineMode = view != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 0.47
        if UIDevice().hasNotch{
            fixedSize = 0.47
        }else{
            if UIScreen.main.bounds.size.height <= 700 {
                fixedSize = 0.58
            }
        }
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
              
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.percent(Float(fixedSize)),.intrinsic],
            options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
        sheet.allowGestureThroughOverlay = false
        sheet.cornerRadius = 15
        sheet.dismissOnPull = false
        sheet.gripColor = .clear
     
        let settingView =  SettingsView(navigationController: self.navigationController) { [weak self] action in

               if sheet.options.useInlineMode == true {
                    sheet.attemptDismiss(animated: true)
                } else {
                    sheet.dismiss(animated: true, completion: nil)
                }
            
            if action == "logout"{

                self?.presentLogoutView()
           
            }else if action == "delete"{
                self?.presentDeleteAccountView()
              
            }
        }
        
        controller.rootView = settingView
   
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
    }
    
 
    
    func presentLogoutView(){
        let logoutView = UIHostingController(rootView: LogoutView(navigationController: self.navigationController))
        logoutView.modalPresentationStyle = .overFullScreen // Full-screen modal
        logoutView.modalTransitionStyle = .crossDissolve   // Fade-in effect
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        
        if theme == .dark{
            logoutView.view.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8) // Semi-transparent background

        }else{
            logoutView.view.backgroundColor = UIColor.label.withAlphaComponent(0.8) // Semi-transparent background
        }
        self.present(logoutView, animated: true, completion: nil)
    }
    
    func presentDeleteAccountView(){
        let deleteAccountView = UIHostingController(rootView: DeleteAccountView())
        deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
        deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        
        if theme == .dark{
            deleteAccountView.view.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.8) // Semi-transparent background
        }else{
            deleteAccountView.view.backgroundColor = UIColor.label.withAlphaComponent(0.8) // Semi-transparent background
        }
        self.present(deleteAccountView, animated: true, completion: nil)
    }
    @objc func statusTapped(){
        
        if verifiSttaus.lowercased() == "rejected"{
            if verifiRejectedReason.count > 0{
                AlertView.sharedManager.displayMessageWithAlert(title: "Rejected Reason", msg: verifiRejectedReason)
            }
        }
    }
    
 /*   func isUserLoggedInRequest() -> Bool {
        
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
    */
    
    @objc func didTapSwitch(_ sender: UISwitch) {
        print("Switch tapped at tag:", sender.tag)
        // Or identify the indexPath and update model
        if sender.isOn{
            updateAppTheme(to: .dark)
        }else{
            updateAppTheme(to: .light)
        }
    }
    
    
    func updateAppTheme(to theme: AppTheme) {
        UserDefaults.standard.set(theme.rawValue, forKey: LocalKeys.appTheme.rawValue)
        // Apply it immediately
        AppDelegate.sharedInstance.applyTheme()
        self.tblView.reloadData()
    }
    
    
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "id1488570846") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }else{
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //MARK: Selector methods
    @objc func loginToScren(){
        AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func editProfileBtnACtion(){
        let destVC = UIHostingController(rootView: ProfileEditView(navigationController:self.navigationController))
        destVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    @objc func getVerified(){
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        if objLoggedInUser.id != nil {
            if (objLoggedInUser.email?.count ?? 0) == 0 || (objLoggedInUser.mobile?.count ?? 0) == 0  || (objLoggedInUser.name?.count ?? 0) == 0 || (objLoggedInUser.address?.count ?? 0) == 0 {
                
                AlertView.sharedManager.presentAlertWith(title: "", msg: "Complete your profile to apply verification request.", buttonTitles: ["Cancel","OK"], onController: self) { title, index in
                    
                    if index == 1{
                        let destVC = UIHostingController(rootView: ProfileEditView(navigationController:self.navigationController))
                        destVC.hidesBottomBarWhenPushed = true

                        self.navigationController?.pushViewController(destVC, animated: true)
                    }
                }
                
            }else{
               
                let hostingController = UIHostingController(rootView: UserVerifyView(navigation:self.navigationController)) // Wrap in UIHostingController
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
            }
                
            
        }
            
      
    }
}










enum AppTheme: String {
    case system
    case light
    case dark
}
