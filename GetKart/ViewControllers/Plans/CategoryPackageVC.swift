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

 
      
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "PackageCell", bundle: nil), forCellReuseIdentifier: "PackageCell")
       
    }
   
   //MARK: UIButton Action Methods
   
   @IBAction func backButtonAction(_ sender : UIButton){
       self.navigationController?.popViewController(animated: true)
   }
   
   @IBAction func showPackageButtonAction(_ sender : UIButton){

   }
    
}

extension CategoryPackageVC: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2 
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageCell") as! PackageCell
        
        cell.lblOriginalAmount.attributedText = "₹ 1,249".setStrikeText(color: .gray)
        cell.lblAmount.text = "₹ 1,149"
        cell.bgViewMain.layer.cornerRadius = 8.0
        cell.bgViewMain.clipsToBounds = true
        cell.btnViewPlans.tag = indexPath.row
        cell.btnViewPlans.addTarget(self, action: #selector(viewPlansBtnAction(_ :)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
    }
    
    
    @objc func viewPlansBtnAction(_ sender : UIButton){
        
        let controller = StoryBoard.chat.instantiateViewController(identifier: "MultipleAdsVC")
        as! MultipleAdsVC
          
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
      

