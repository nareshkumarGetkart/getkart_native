//
//  MultipleAdsVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit
import FittedSheets

class MultipleAdsVC: UIViewController {
    
    @IBOutlet weak var lblHeader:UILabel!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    
    var planListArray = [PlanModel]()

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "PackageAdsCell", bundle: nil), forCellReuseIdentifier: "PackageAdsCell")
        lblHeader.text = planListArray.first?.name ?? ""
    }
    
    //MARK: UIbutton Action Methods
    @IBAction func closeBtnAction(_ sender:UIButton){
     
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}


extension MultipleAdsVC: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return planListArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageAdsCell") as! PackageAdsCell
        
        let obj = planListArray[indexPath.row]
       // cell.bgView.addShadow(shadowColor: UIColor.gray.cgColor, shadowOpacity: 0.5)
        cell.lblOriginalAmt.attributedText = "\(Local.shared.currencySymbol) \(obj.finalPrice ?? 0)".setStrikeText(color: .gray)
        cell.lblAmount.text = "\(Local.shared.currencySymbol) \(obj.price ?? 0)"
        cell.lblDiscountPercentage.text = "\(obj.discountInPercentage ?? 0)% Savings"
        cell.lblNumberOfAds.text = "\(obj.itemLimit ?? "") Ad"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
    }
}
      
