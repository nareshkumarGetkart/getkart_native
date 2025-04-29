//
//  PayPlanVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/04/25.
//

import UIKit
import FittedSheets
import PhonePePayment
import StoreKit
import SwiftUI
class PayPlanVC: UIViewController {
    
    private var merchantId = ""
    private var api_key = ""
    private var phonePeAppId = ""
    private var ppPayment = PPPayment()
    var planObj:PlanModel?
    
    var paymentIntentId = ""
    var payment_method = ""
    var payment_method_type = 0
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var btnPay:UIButton!
    var InAppReceipt = ""
    
    var callbackPaymentSuccess: ((_ isSuccess: Bool) -> Void)?
    
    //MARK: COntroller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPay.layer.cornerRadius = 8.0
        btnPay.clipsToBounds = true
        lblPrice.text = "\(Local.shared.currencySymbol) \(planObj?.finalPrice ?? 0)"
        btnPay.setTitle("Pay \(Local.shared.currencySymbol) \(planObj?.finalPrice ?? 0)", for: .normal)
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
        if payment_method_type == 1 {//In App
            self.IAPPaymentForm()
        }else if payment_method_type == 3 {//Phone Pay
            self.createPhonePayOrder(package_id: planObj?.id ?? 0)
        }
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
                        self?.payment_method_type = dataDict["payment_method_type"] as? Int ?? 0
                        if self?.payment_method_type == 1 {
                            
                        }else if self?.payment_method_type == 3 {//Phone Pay
                            if let PhonePeDict = dataDict["PhonePe"] as? Dictionary<String, Any>  {
                                self?.api_key = PhonePeDict["api_key"] as? String ?? ""
                                self?.merchantId = PhonePeDict["merchent_id"] as? String ?? ""
                                
                                var flowId = ""
                                let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                                if objLoggedInUser.id != nil {
                                    flowId = "\(objLoggedInUser.id ?? 0)"
                                }
                                
                                self?.payment_method = "PhonePe"
                                
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
                    }
                    
                    
                    
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    
    
    func updateOrderApi(){
        let params:Dictionary<String, Any> = ["merchantOrderId":self.paymentIntentId]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.order_update, param: params,methodType: .post) { responseObject, error in
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    self.callbackPaymentSuccess?(true)
                }
            }
        }
        
    }
    
    
    
    func createPhonePayOrder(package_id:Int){
        
        let params:Dictionary<String, Any> = ["package_id":package_id, "payment_method":payment_method, "platform_type":"app"]
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
                            
                            self?.paymentIntentId = payment_intentDict["id"] as? String ?? ""
                            
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
            
            self.updateOrderApi()
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



extension PayPlanVC {
    
    func updateInAppPurchaseOrderApi(transactionId:String){
        //
        let params:Dictionary<String, Any> = ["purchase_token":transactionId, "payment_method":"apple", "package_id":planObj?.id ?? 0, "receipt": self.InAppReceipt]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.in_app_purchase, param: params,methodType: .post) { responseObject, error in
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    self.callbackPaymentSuccess?(true)
                }
            }
        }
        
    }
    internal func IAPPaymentForm(){
        
        if self.planObj != nil {
            let productIDs:Array<String> = [self.planObj?.iosProductID ?? ""]
            //let productIDs:Array<String> = ["ads_bronze_package"]
            
            var productsArray:Array<SKProduct> = Array()
            IAPHandler.shared.setProductIds(ids: productIDs)
            Themes.sharedInstance.activityView(uiView: self.view, isUserInteractionenabled: true)
            
            IAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
                DispatchQueue.main.async {
                    Themes.sharedInstance.removeActivityView(uiView: self!.view)
                }
                guard let sSelf = self else {return}
                
                
                productsArray = products
                if productsArray.count > 0 {
                    DispatchQueue.main.async {
                        Themes.sharedInstance.activityView(uiView: self!.view, isUserInteractionenabled: true)
                    }
                    IAPHandler.shared.purchase(product: productsArray[0]) { (alert, product, transaction) in
                        DispatchQueue.main.async {
                            Themes.sharedInstance.removeActivityView(uiView: self!.view)
                        }
                        
                        if let tran = transaction, let prod = product {
                            //use transaction details and purchased product as you want
                            print("transaction: \(transaction)")
                            print("payment_id \(transaction?.transactionIdentifier ?? "")")
                            let transactionId = transaction?.transactionIdentifier ?? ""
                            self?.getInAppReceipt()
                            
                            self?.updateInAppPurchaseOrderApi(transactionId: transactionId)
                            
                            
                        }
                        //Show payment successfull messsage
                    }
                }
                
            }
        }
        
    }
    
    
    func getInAppReceipt() {
        // Get the receipt if it's available.
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                InAppReceipt = receiptData.base64EncodedString(options: [])
                print("InAppReceipt :\(InAppReceipt)")
                // Read receiptData.
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }
}
