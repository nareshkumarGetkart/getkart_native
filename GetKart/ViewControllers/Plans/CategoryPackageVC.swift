//
//  CategoryPackageVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit
import FittedSheets
import SwiftUI

class CategoryPackageVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var lblSelectedLoc:UILabel!
    @IBOutlet weak var lblSelectedCategory:UILabel!
    @IBOutlet weak var collectionViewBanner:UICollectionView!
    @IBOutlet weak var lblOfferingTitle:UILabel!

    
    var categoryId = 0
    var categoryName = ""
    var city = ""
    var country = ""
    var state = ""
    var latitude = ""
    var longitude = ""
    var itemId:Int?

    var planListArray = [[PlanModel]]()
    var bannerArray = [String]()
    var isAdvertisement = false
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.setImageColor(color: .label)
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "PackageCell", bundle: nil), forCellReuseIdentifier: "PackageCell")
        collectionViewBanner.register(UINib(nibName: "BannerCell", bundle: nil), forCellWithReuseIdentifier: "BannerCell")
        lblOfferingTitle.isHidden = true
        self.lblSelectedCategory.text = "Category: \(categoryName)"
        self.lblSelectedLoc.text = "Location: \(city + ", " + state + ", " + country)"
        getPackagesBannersApi()
        getPackagesApi()
        tblView.showsVerticalScrollIndicator = false
    }
   
   //MARK: UIButton Action Methods
   
   @IBAction func backButtonAction(_ sender : UIButton){
       self.navigationController?.popViewController(animated: true)
   }
   
   @IBAction func showPackageButtonAction(_ sender : UIButton){

   }
    
    //MARK: Api Methods
    
    func getPackagesApi(){
        
        var strURL = Constant.shared.get_package + "?category_id=\(categoryId)&country=\(country)&state=\(state)&city=\(city)&latitude=\(latitude)&longitude=\(longitude)&platform=ios"
        
        if isAdvertisement{
            strURL.append("&type=advertisement")
        }
        
        if let id = itemId, id > 0{
            strURL.append("&item_id=\(id)")
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strURL) { (obj:Plan) in
            
            if obj.code == 200 {
                self.planListArray.append(contentsOf: obj.data ?? [])
                self.tblView.reloadData()
                self.lblOfferingTitle.isHidden = false
            }
        }
    }
    
    
    func getPackagesBannersApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_package_banner) { (obj:PlanBanner) in
            
            if obj.code == 200 {
                self.bannerArray.append(contentsOf: obj.data ?? [])
                self.collectionViewBanner.reloadData()
                self.lblOfferingTitle.isHidden = false

            }
        }
    }
    
    
}

extension CategoryPackageVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewBanner.frame.size.width, height: 175)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerCell
        cell.imgVwBanner.kf.setImage(with:  URL(string: bannerArray[indexPath.item]) , placeholder:UIImage(named: "getkartplaceholder"))
        
        return cell
        
    }
    
}

extension CategoryPackageVC: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return planListArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return planListArray[section].count > 0 ? 1 : 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageCell") as! PackageCell
        
        let obj = planListArray[indexPath.section][indexPath.row]
        cell.lblTitle.text = obj.name
        cell.lblAmount.text = "\(Local.shared.currencySymbol)\(obj.finalPrice ?? "0")"
        if (obj.discountInPercentage ?? "0") == "0"{
            cell.lblPercentOff.text = ""
            cell.imgVwPercentageOffIcon.isHidden = true
            cell.lblOriginalAmount.attributedText = NSAttributedString(string: "")

        }else{
            cell.lblPercentOff.text = "\(obj.discountInPercentage ?? "0") % off"
            cell.imgVwPercentageOffIcon.isHidden = false
            cell.lblOriginalAmount.attributedText = "\(Local.shared.currencySymbol)\(obj.price ?? "0")".setStrikeText(color: .gray)
        }
        
       
        cell.lblSubtitle.text = obj.title ?? ""
        cell.lblFeatures.text = obj.description ?? ""
        cell.imgVwIcon.kf.setImage(with: URL(string:obj.icon ?? ""))
        cell.bgViewMain.layer.cornerRadius = 8.0
        cell.bgViewMain.clipsToBounds = true
        cell.btnViewPlans.tag = indexPath.section
        cell.btnViewPlans.addTarget(self, action: #selector(viewPlansBtnAction(_ :)), for: .touchUpInside)
//        DispatchQueue.main.async {
//            cell.bgViewMain.addShadow()
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @objc func viewPlansBtnAction(_ sender : UIButton){
        
        let controller = StoryBoard.chat.instantiateViewController(identifier: "MultipleAdsVC")
        as! MultipleAdsVC
        controller.callbackSelectedPlans  = { [weak self](selectedObj) -> Void in
            print("callback")
            print(selectedObj.id ?? 0)
            self?.presentPayView(planObj: selectedObj)
        }
    
        controller.planListArray = planListArray[sender.tag]
        let useInlineMode = view != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 0.55
        if UIDevice().hasNotch{
            fixedSize = 0.55
        }else{
            if UIScreen.main.bounds.size.height <= 700 {
                fixedSize = 0.70
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
        // sheet.dismissOnOverlayTap = false
        sheet.cornerRadius = 20
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
    }
    
    
    func presentPayView(planObj:PlanModel){
        
        let controller = StoryBoard.chat.instantiateViewController(identifier: "PayPlanVC")
        as! PayPlanVC
        controller.planObj = planObj
        
        controller.categoryId = categoryId
        controller.categoryName = categoryName
        controller.city = city
        controller.country = country
        controller.state = state
        controller.latitude = latitude
        controller.longitude = longitude
        controller.paymentFor = .adsPlan
        controller.itemId = itemId
        controller.callbackPaymentSuccess = { [weak self](isSuccess) -> Void in
            
            if controller.sheetViewController?.options.useInlineMode == true {
                controller.sheetViewController?.attemptDismiss(animated: true)
            } else {
                controller.dismiss(animated: true, completion: nil)
            }
            
            if isSuccess == true {
                let vc = UIHostingController(rootView: PlanBoughtSuccessView(navigationController: self?.navigationController))
                vc.modalPresentationStyle = .overFullScreen // Full-screen modal
                vc.modalTransitionStyle = .crossDissolve   // Fade-in effect
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                self?.present(vc, animated: true, completion: nil)
            }
        }
        
        let useInlineMode = view != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 0.2
        if UIDevice().hasNotch{
            fixedSize = 0.2
        }else{
            if UIScreen.main.bounds.size.height <= 700 {
                fixedSize = 0.3
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
        // sheet.dismissOnOverlayTap = false
        sheet.cornerRadius = 15
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
    }
}
      

