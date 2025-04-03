//
//  CategoryPlanVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit

class CategoryPlanVC: UIViewController {

    
     @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
     @IBOutlet weak var tblView:UITableView!
     @IBOutlet weak var btnShowPackage:UIButton!
    @IBOutlet weak var btnBack:UIButton!

    
     let titleArray =  ["Category","Location"]
     let iconArray =  ["category","location_icon_orange"]
       
     //MARK: Controller life cycle methods
     override func viewDidLoad() {
         super.viewDidLoad()
         cnstrntHtNavBar.constant = self.getNavBarHt
         // Do any additional setup after loading the view.
         tblView.register(UINib(nibName: "ProfileListTblCell", bundle: nil), forCellReuseIdentifier: "ProfileListTblCell")
         btnShowPackage.layer.cornerRadius = 7.0
         btnShowPackage.clipsToBounds = true
     }
    
    //MARK: UIButton Action Methods
    
    @IBAction func backButtonAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPackageButtonAction(_ sender : UIButton){

        if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPackageVC") as? CategoryPackageVC{
            destvc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(destvc, animated: true)
        }
    }
     
}

extension CategoryPlanVC: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titleArray.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListTblCell") as! ProfileListTblCell
        
        cell.lblTitle.text = titleArray[indexPath.row]
        cell.imgVwIcon.image = UIImage(named: iconArray[indexPath.row])
        cell.imgVwArrow.isHidden = false
        cell.btnSwitch.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
      
