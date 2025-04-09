//
//  CategoryPackageVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit
import FittedSheets


class CategoryPackageVC: UIViewController {
    
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var lblSelectedLoc:UILabel!
    @IBOutlet weak var lblSelectedCategory:UILabel!

    var categoryId = 0
    var categoryName = ""
    var city = ""
    
    var planListArray = [[PlanModel]]()

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        tblView.register(UINib(nibName: "PackageCell", bundle: nil), forCellReuseIdentifier: "PackageCell")
        self.lblSelectedCategory.text = "Category: \(categoryName)"
        self.lblSelectedLoc.text = "Location: \(city)"

        getPackagesApi()
    }
   
   //MARK: UIButton Action Methods
   
   @IBAction func backButtonAction(_ sender : UIButton){
       self.navigationController?.popViewController(animated: true)
   }
   
   @IBAction func showPackageButtonAction(_ sender : UIButton){

   }
    
    //MARK: Api Methods
    
    func getPackagesApi(){
        
        let strURL = Constant.shared.get_package // + "?category_id=\(categoryId)&city=\(city)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strURL) { (obj:Plan) in
            
            if obj.code == 200 {
                self.planListArray.append(contentsOf: obj.data ?? [])
                self.tblView.reloadData()
            }
        }
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
        cell.lblOriginalAmount.attributedText = "\(Local.shared.currencySymbol) \(obj.price ?? 0)".setStrikeText(color: .gray)
        cell.lblAmount.text = "\(Local.shared.currencySymbol) \(obj.finalPrice ?? 0)"
        cell.lblPercentOff.text = "\(obj.discountInPercentage ?? 0) % off"
        cell.lblFeatures.text = obj.description ?? ""
        cell.imgVwIcon.kf.setImage(with: URL(string:obj.icon ?? ""))
        cell.bgViewMain.layer.cornerRadius = 8.0
        cell.bgViewMain.clipsToBounds = true
        cell.btnViewPlans.tag = indexPath.section
        cell.btnViewPlans.addTarget(self, action: #selector(viewPlansBtnAction(_ :)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @objc func viewPlansBtnAction(_ sender : UIButton){
        
        let controller = StoryBoard.chat.instantiateViewController(identifier: "MultipleAdsVC")
        as! MultipleAdsVC
        controller.planListArray = planListArray[sender.tag]
        let useInlineMode = view != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 0.7
        if UIDevice().hasNotch{
            fixedSize = 0.6
        }else{
            if UIScreen.main.bounds.size.height <= 700 {
                fixedSize = 0.75
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
        sheet.cornerRadius = 25
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
    }
}
      

