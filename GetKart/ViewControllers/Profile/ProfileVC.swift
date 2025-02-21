//
//  ProfileVC.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit

class ProfileVC: UIViewController {
   
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!

    var isLoggedIn = false
    
    let titleArray =  ["Anonymous","My Boost Ads","Subscription","Transaction History","Language","Dark Theme","Notifications","Blogs","Favorites","FAQs","Share this App","Rate us","Contact us","About us","Terms of Service","Privacy Policy","Refunds & Cancellation policy","Delete Account","Logout"]
      
    let iconArray =  ["","promoted","subscription","transaction","language","dark_theme","notification","article","like_fill","doc.text.fill","share","rate_us","contact_us","about_us","t_c","privacypolicy","privacypolicy","delete_account","logout"]
      
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "ProfileListTblCell", bundle: nil), forCellReuseIdentifier: "ProfileListTblCell")
        
        tblView.register(UINib(nibName: "AnonymousUserCell", bundle: nil), forCellReuseIdentifier: "AnonymousUserCell")

        
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
       
        return titleArray.count + (isLoggedIn ? 0  : -2)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnonymousUserCell") as! AnonymousUserCell
            if isLoggedIn{
                cell.bgViewAnonymousUser.isHidden = true
                cell.bgViewLoggedInUser.isHidden = false

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
    
    
    //MARK: Selector methods
    @objc func loginToScren(){
        AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: true)
    }
}
