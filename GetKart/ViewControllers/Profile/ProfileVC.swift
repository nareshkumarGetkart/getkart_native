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

class ProfileVC: UIViewController {
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    
    let titleArray =  ["Anonymous","My Boost Ads","Buy Packages","Order History","Dark Theme","Notifications","Blogs","Favorites","FAQs","Share this App","Rate us","Contact us","About us","Terms of Service","Privacy Policy","Refunds & Cancellation policy","Delete Account","Logout"]
      
    let iconArray =  ["","promoted","subscription","transaction","dark_theme","notification","article","like_fill","faq","share","rate_us","contact_us","about_us","t_c","privacypolicy","privacypolicy","delete_account","logout"]
      
    var verifiRejectedReason:String = ""
    var verifiSttaus:String = ""

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "ProfileListTblCell", bundle: nil), forCellReuseIdentifier: "ProfileListTblCell")
        
        tblView.register(UINib(nibName: "AnonymousUserCell", bundle: nil), forCellReuseIdentifier: "AnonymousUserCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tblView.reloadData()
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        if objLoggedInUser.id != nil {
            getVerificationStatusApi()
        }
    }
    
    
    func getVerificationStatusApi(){
        URLhandler.sharedinstance.makeCall(url: Constant.shared.verification_request, param: nil,methodType: .get) { responseObject, error in
            
            if error == nil{
                
                if let result = responseObject{
                    
                    if let data = result["data"] as? Dictionary<String, Any>{
                        self.verifiRejectedReason = data["rejection_reason"] as? String ?? ""
                        self.verifiSttaus = data["status"] as? String ?? ""
                        self.tblView.reloadData()

                    }
                }
                
            }
        }
    }
}


extension ProfileVC:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 120
        }
        
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        if objLoggedInUser.id != nil {
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
                cell.btnGetVerifiedBadge.addTarget(self, action: #selector(getVerified), for: .touchUpInside)
                
                cell.imgVwProfile.kf.setImage(with: URL(string: objLoggedInUser.profile ?? ""), placeholder: UIImage(named: "user-circle"), options: nil, progressBlock: nil, completionHandler: nil)

                cell.lblName.text =  objLoggedInUser.name ?? ""
                cell.lblEmail.text =  objLoggedInUser.email ?? ""
                cell.lblStatus.isHidden = true
                cell.btnResubmit.isHidden = true
                cell.lblEmail.isHidden = (objLoggedInUser.email ?? "").count == 0
                

                if (objLoggedInUser.is_verified ?? 0) == 1 || verifiSttaus.lowercased() == "approved"{
                    cell.btnGetVerifiedBadge.isHidden = true
                    cell.bgViewVerified.isHidden = false
                    
                }else{
                    cell.btnGetVerifiedBadge.isHidden = false
                    cell.bgViewVerified.isHidden = true
                }
                
                if verifiSttaus.lowercased() == "pending"{
                    cell.lblStatus.text = verifiSttaus.capitalized
                    cell.lblStatus.backgroundColor = Themes.sharedInstance.themeColor
                    cell.lblStatus.isHidden = false
                    cell.btnResubmit.isHidden = true
                    cell.btnGetVerifiedBadge.isHidden = true

                }else if verifiSttaus.lowercased() == "rejected"{
                    cell.lblStatus.text = verifiSttaus.capitalized
                    cell.lblStatus.backgroundColor = UIColor.red
                    cell.lblStatus.isHidden = false
                    cell.btnResubmit.isHidden = false
                    cell.btnGetVerifiedBadge.isHidden = true
                }
                cell.btnResubmit.addTarget(self, action: #selector(getVerified), for: .touchUpInside)
                cell.lblStatus.isUserInteractionEnabled = true
                cell.lblStatus.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(statusTapped)))
                cell.btnPencil.addTarget(self, action: #selector(editProfileBtnACtion), for: .touchUpInside)
                                
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
            cell.imgVwIcon.setImageTintColor(color: .orange)
            if titleArray[indexPath.row] == "Dark Theme"{
                cell.imgVwArrow.isHidden = true
                cell.btnSwitch.isHidden = false
                
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
              
                if isUserLoggedInRequest(){
                    let destVC = UIHostingController(rootView: MyBoostAdsView(navigation: self.navigationController))
                    destVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(destVC, animated: true)
                }
                
            } else if titleArray[indexPath.row] == "Buy Packages"{
                
                if isUserLoggedInRequest(){
                    
                    if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPlanVC") as? CategoryPlanVC{
                        destvc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(destvc, animated: true)
                    }
                }
                
            }else if titleArray[indexPath.row] == "FAQs"{
                
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
            }else if titleArray[indexPath.row] == "Terms of Service"{
                
                let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Terms of Service", type: .termsAndConditions) // Create SwiftUI view
                let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
                hostingController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(hostingController, animated: true)
            }else if titleArray[indexPath.row] == "Notifications"{
                if isUserLoggedInRequest(){
                    
                    let hostingController = UIHostingController(rootView: NotificationView(navigation:self.navigationController)) // Wrap in UIHostingController
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
                }
                
            }else if titleArray[indexPath.row] == "Favorites"{
                
                if isUserLoggedInRequest(){
                    let hostingController = UIHostingController(rootView: FavoritesView(navigation:self.navigationController)) // Wrap in UIHostingController
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: true)
                }
                
            }else if titleArray[indexPath.row] == "Rate us"{
                
                rateApp()
                
            }else if titleArray[indexPath.row] == "Share this App"{
                ShareMedia.shareMediafrom(type: .appShare, mediaId: "", controller: self)
                
            }else if titleArray[indexPath.row] ==  "Order History"{
                
                if isUserLoggedInRequest(){
                    
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
    
    
    @objc func statusTapped(){
        if verifiRejectedReason.count > 0{
            AlertView.sharedManager.displayMessageWithAlert(title: "Rejected Reason", msg: verifiRejectedReason)
        }
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
    
    
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "id1488570846") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //MARK: Selector methods
    @objc func loginToScren(){
        AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func editProfileBtnACtion(){
        let destVC = UIHostingController(rootView: ProfileEditView())
        AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
    }
    
    @objc func getVerified(){
        
        let hostingController = UIHostingController(rootView: UserVerifyView(navigation:self.navigationController)) // Wrap in UIHostingController
        hostingController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
}









