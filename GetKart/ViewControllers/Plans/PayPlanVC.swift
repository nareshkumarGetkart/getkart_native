//
//  PayPlanVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/04/25.
//

import UIKit
import FittedSheets
import PhonePePayment

class PayPlanVC: UIViewController {
    
    private var merchantId = ""
    private var api_key = ""
    private var phonePeAppId = ""
    private var ppPayment = PPPayment()
    var planObj:PlanModel?
    
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var btnPay:UIButton!

    //MARK: COntroller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPay.layer.cornerRadius = 8.0
        btnPay.clipsToBounds = true
        lblPrice.text = "\(Local.shared.currencySymbol) \(planObj?.finalPrice ?? 0)"
        btnPay.setTitle("\(Local.shared.currencySymbol) \(planObj?.finalPrice ?? 0)", for: .normal)
        self.getPaymentSettings()
    }
    
    //MARK: UIbutton Action Methods
    @IBAction func closeBtnAction(_ sender:UIButton){
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func payBtnAction(_ sender:UIButton){
        
      
        self.createPhonePayOrder(package_id: planObj?.id ?? 0)
    }
    
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
            
            AlertView.sharedManager.presentAlertWith(title: "", msg: "\(state)" as NSString, buttonTitles: ["ok"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                
            }
            if self.sheetViewController?.options.useInlineMode == true {
                self.sheetViewController?.attemptDismiss(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
}
