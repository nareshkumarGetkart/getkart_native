//
//  MultipleAdsVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit
import FittedSheets
import PhonePePayment

class MultipleAdsVC: UIViewController {
    
    @IBOutlet weak var lblHeader:UILabel!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var tblView:UITableView!
    
    var planListArray = [PlanModel]()
    var selectedIndex = -1
    var callbackSelectedPlans: ((_ selPlanObj: PlanModel) -> Void)?

    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.register(UINib(nibName: "PackageAdsCell", bundle: nil), forCellReuseIdentifier: "PackageAdsCell")
        lblHeader.text = planListArray.first?.name ?? ""
        lblSubTitle.text = planListArray.first?.title ?? ""
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
        
        return planListArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageAdsCell") as! PackageAdsCell
        
        let obj = planListArray[indexPath.row]
        cell.lblAmount.text = "\(Local.shared.currencySymbol) \(obj.finalPrice ?? "0")"
        cell.lblNumberOfAds.text = "\(obj.itemLimit ?? "") Ad"
        
        if (obj.discountInPercentage ?? "0") == "0"{
            cell.lblDiscountPercentage.text = ""
            cell.lblDiscountPercentage.isHidden = true
            cell.lblOriginalAmt.attributedText = NSAttributedString(string: "")

        }else{
            cell.lblDiscountPercentage.text = "\(obj.discountInPercentage ?? "0")% Savings"
            cell.lblDiscountPercentage.isHidden = false
            cell.lblOriginalAmt.attributedText = "\(Local.shared.currencySymbol) \(obj.price ?? "0")".setStrikeText(color: .gray)
        }
    
        
        if selectedIndex == indexPath.row{
            cell.bgView.layer.borderColor = UIColor(hexString: "#FF9900").cgColor
        }else{
            cell.bgView.layer.borderColor = UIColor.gray.cgColor
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.tblView.reloadData()
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        callbackSelectedPlans?(planListArray[indexPath.row])

        // self.createPhonePayOrder(package_id: obj.id ?? 0)
    }
    /*
    func getPaymentSettings(){
        let params:Dictionary<String, Any> = [:]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.getPaymentSettings, param: nil, methodType: .get,showLoader:true) { [weak self] responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        if let PhonePeDict = dataDict["PhonePe"] as? Dictionary<String, Any>  {
                            self?.api_key = PhonePeDict["api_key"] as? String ?? ""
                            self?.merchantId = PhonePeDict["merchent_id"] as? String ?? ""
                            
                            var flowId = ""
                            let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                            if objLoggedInUser.id != nil {
                                flowId = "\(objLoggedInUser.id ?? 0)"
                            }
                            
                            if devEnvironment == .live {
                                self?.ppPayment = PPPayment(environment: .production,
                                                          flowId: flowId,
                                                       merchantId: self?.merchantId ?? "",
                                                       enableLogging: false)
                            }else {
                                self?.ppPayment = PPPayment(environment: .sandbox,
                                                          flowId: flowId,
                                                      merchantId: self?.merchantId ?? "", enableLogging: true)
                            }
                            
                        }
                    }
                    
                    
                    
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    func createPhonePayOrder(package_id:Int){
        
        let params:Dictionary<String, Any> = ["package_id":package_id,"payment_method":"PhonePe", "platform_type":"app"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.paymentIntent, param: params, methodType: .post,showLoader:true) { [weak self] responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        if let payment_intentDict = dataDict["payment_intent"] as? Dictionary<String, Any> {
                            if let payment_gateway_response = payment_intentDict["payment_gateway_response"] as? Dictionary<String, Any>  {
                                let orderId = payment_gateway_response["orderId"] as? String ?? ""
                                let token  = payment_gateway_response["token"] as? String ?? ""
                                self?.startCheckoutPhonePay(orderId: orderId, token: token)
                            }
                        }
                    }
                   
                    
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    
    func startCheckoutPhonePay(orderId: String, token:String){
        let appSchema = "Getkart IOS App"
        ppPayment.startCheckoutFlow(merchantId: merchantId,
                                    orderId: orderId,
                                    token: token,
                                    appSchema: appSchema,
                                    on: self) { _, state in
                    print(state)
        }
    }
    */
}
      
