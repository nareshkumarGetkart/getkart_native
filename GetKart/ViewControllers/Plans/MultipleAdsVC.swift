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
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "PackageAdsCell", bundle: nil), forCellReuseIdentifier: "PackageAdsCell")

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
        
        return 70.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 7
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageAdsCell") as! PackageAdsCell
        cell.bgView.addShadow()
        cell.lblOriginalAmt.attributedText = "₹ 1,249".setStrikeText(color: .gray)

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
    }
}
      
