//
//  CategoryPlanVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit
import SwiftUI
class CategoryPlanVC: UIViewController, LocationSelectedDelegate{

    
     @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
     @IBOutlet weak var tblView:UITableView!
     @IBOutlet weak var btnShowPackage:UIButton!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var bgViewDesc:UIView!

    
     let titleArray =  ["Category","Location"]
     var subTitleArrray = ["Select Category","Select Location"]
     let iconArray =  ["category","location_icon_orange"]
    
    var latitude:String = ""
    var longitude:String = ""
    var city:String = ""
    var state:String = ""
    var country:String = ""
 
    var categoryName = ""
    var category_id = 0
    
    
     //MARK: Controller life cycle methods
     override func viewDidLoad() {
         super.viewDidLoad()
         btnBack.setImageColor(color: .label)
         cnstrntHtNavBar.constant = self.getNavBarHt
         // Do any additional setup after loading the view.
         tblView.register(UINib(nibName: "ProfileListTblCell", bundle: nil), forCellReuseIdentifier: "ProfileListTblCell")
         btnShowPackage.layer.cornerRadius = 7.0
         btnShowPackage.clipsToBounds = true
                  
         let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
         let theme = AppTheme(rawValue: savedTheme) ?? .system
         lblDesc.textColor = .label

         if theme == .dark{
             bgViewDesc.backgroundColor = UIColor(hexString: "#342b1e")
         }else{
             bgViewDesc.backgroundColor = UIColor(hexString: "#FEF6E9")
         }
         
         NotificationCenter.default.addObserver(self,selector: #selector(handleLocationSelected(_:)),
                                                name:NSNotification.Name(rawValue:NotiKeysLocSelected.buyPackageNewLocation.rawValue), object: nil)
     }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleLocationSelected(_ notification: Notification) {
        
        if let userInfo = notification.userInfo as? [String: Any]
        {
            let city = userInfo["city"] as? String ?? ""
            let state = userInfo["state"] as? String ?? ""
            let country = userInfo["country"] as? String ?? ""
            let latitude = userInfo["latitude"] as? String ?? ""
            let longitude = userInfo["longitude"] as? String ?? ""
            let locality = userInfo["locality"] as? String ?? ""
            
            print("Received Location: \(city), \(state), \(country)")
            
            
            self.latitude = latitude
            self.longitude = longitude
            self.city = city
            self.state = state
            self.country = country
            
            
            subTitleArrray[1] = city + ", " + state + ", " + country
            
            self.tblView.reloadData()
            if self.country.count > 0 && self.category_id > 0 {
                btnShowPackage.isEnabled = true
                btnShowPackage.backgroundColor = .orange
                btnShowPackage.setTitleColor(.white, for: .normal)
            }
            
            
        }
    }
        
    //MARK: UIButton Action Methods
    
    @IBAction func backButtonAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func fetchCountryListing(){
       ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            let arrCountry = obj.data?.data ?? []
           var rootView = CountryLocationView(arrCountries: arrCountry, popType: .buyPackage, navigationController: self.navigationController)
           rootView.delLocationSelected = self
           let vc = UIHostingController(rootView:rootView )
           self.navigationController?.pushViewController(vc, animated: true)
       }
   }
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String) {

        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.state = state
        self.country = country
        
        
        subTitleArrray[1] = city + ", " + state + ", " + country
        
        self.tblView.reloadData()
        if self.country.count > 0 && self.category_id > 0 {
            btnShowPackage.isEnabled = true
            btnShowPackage.backgroundColor = .orange
            btnShowPackage.setTitleColor(.white, for: .normal)
        }
        
    }
    
    func saveCategoryInfo(category_id:Int, categoryName:String ) {
        self.category_id = category_id
        self.categoryName = categoryName
        subTitleArrray[0] = categoryName
        self.tblView.reloadData()
        
        if self.country.count > 0 && self.category_id > 0 {
            btnShowPackage.isEnabled = true
            btnShowPackage.backgroundColor = .orange
            btnShowPackage.setTitleColor(.white, for: .normal)
        }
    }
    
    
    @IBAction func showPackageButtonAction(_ sender : UIButton){
        
        if self.country.count > 0 && self.category_id > 0 {
            
            if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPackageVC") as? CategoryPackageVC{
                destvc.hidesBottomBarWhenPushed = true
                destvc.categoryId = category_id
                destvc.categoryName = categoryName
                destvc.city = city
                destvc.country = country
                destvc.state = state
                destvc.latitude = latitude
                destvc.longitude = longitude
                self.navigationController?.pushViewController(destvc, animated: true)
            }
        }else{
          
            AlertView.sharedManager.showToast(message: "Select category and location")
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
        cell.lblSubTitle.text = subTitleArrray[indexPath.row]
        if subTitleArrray[indexPath.row] == "" {
            cell.lblSubTitle.isHidden = true
        }else {
            cell.lblSubTitle.isHidden = false
        }
        cell.imgVwIcon.image = UIImage(named: iconArray[indexPath.row])
        cell.imgVwArrow.isHidden = false
        cell.btnSwitch.isHidden = true
        
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if titleArray[indexPath.row] == "Category" {            
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "CategoriesVC") as? CategoriesVC {
                destVC.popType = .buyPackage
                destVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
        }else if titleArray[indexPath.row] == "Location" {
            self.fetchCountryListing()
        }
    }
    
    
}
      
