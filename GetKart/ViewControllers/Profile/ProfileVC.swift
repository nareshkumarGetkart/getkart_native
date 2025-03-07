//
//  ProfileVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit
import SwiftUI
import StoreKit

class ProfileVC: UIViewController {
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    
    let titleArray =  ["Anonymous","My Boost Ads","Subscription","Transaction History","Language","Dark Theme","Notifications","Blogs","Favorites","FAQs","Share this App","Rate us","Contact us","About us","Terms of Service","Privacy Policy","Refunds & Cancellation policy","Delete Account","Logout"]
      
    let iconArray =  ["","promoted","subscription","transaction","language","dark_theme","notification","article","like_fill","faq","share","rate_us","contact_us","about_us","t_c","privacypolicy","privacypolicy","delete_account","logout"]
      
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
      
            if titleArray[indexPath.row] == "Refunds & Cancellation policy"{
                
            }else if titleArray[indexPath.row] == "My Boost Ads"{
                if isUserLoggedInRequest(){
                    
                }
                
            }
            else if titleArray[indexPath.row] == "Subscription"{
                
                if isUserLoggedInRequest(){
                    
                }
                
                
            }else if titleArray[indexPath.row] == "Language"{
                
                let deleteAccountView = UIHostingController(rootView: LanguageView())
                AppDelegate.sharedInstance.navigationController?.pushViewController(deleteAccountView, animated: true)
                
            }else if titleArray[indexPath.row] == "Notifications"{
                if isUserLoggedInRequest(){
                    
                    let hostingController = UIHostingController(rootView: NotificationView(navigation:AppDelegate.sharedInstance.navigationController)) // Wrap in UIHostingController
                    AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                }
                
            }else if titleArray[indexPath.row] == "Favorites"{
                
                if isUserLoggedInRequest(){
                    let hostingController = UIHostingController(rootView: FavoritesView(navigation:AppDelegate.sharedInstance.navigationController)) // Wrap in UIHostingController
                    AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                }
                
            }else if titleArray[indexPath.row] == "Rate us"{
                
                rateApp()
                
            }else if titleArray[indexPath.row] == "Share this App"{
                ShareMedia.shareMediafrom(type: .appShare, mediaId: "", controller: self)
                
            }else if titleArray[indexPath.row] ==  "Transaction History"{
               
                if isUserLoggedInRequest(){
                    
                    let hostingController = UIHostingController(rootView: TransactionHistoryView(navigation:AppDelegate.sharedInstance.navigationController)) // Wrap in UIHostingController
                    AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                    
                }
            }else if titleArray[indexPath.row] ==  "Delete Account"{
                let deleteAccountView = UIHostingController(rootView: DeleteAccountView())
                deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
                deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
                deleteAccountView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                present(deleteAccountView, animated: true, completion: nil)
                
            }else if titleArray[indexPath.row] ==  "Logout"{
                let deleteAccountView = UIHostingController(rootView: LogoutView())
                deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
                deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
                deleteAccountView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                present(deleteAccountView, animated: true, completion: nil)
            }
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
    
    @objc func getVerified(){
        
        let hostingController = UIHostingController(rootView: UserVerifyView(navigation:AppDelegate.sharedInstance.navigationController)) // Wrap in UIHostingController
        AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
    }
}





