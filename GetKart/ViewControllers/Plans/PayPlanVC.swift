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


enum PaymentForEnum{
    
    case adsPlan
    case bannerPromotion
    case bannerPromotionDraft
    
}

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
    @IBOutlet weak var lblDesc:UILabel!

    var InAppReceipt = ""
    
    var callbackPaymentSuccess: ((_ isSuccess: Bool) -> Void)?
    
    var campaign_banner_id:Int?

    var paymentFor:PaymentForEnum? = .adsPlan
    var banner_id:Int = 0
    var payment_transaction_id:Int = 0
    
    var categoryId = 0
    var categoryName = ""
    var city = ""
    var country = ""
    var state = ""
    var latitude = ""
    var longitude = ""
   // var isBannerPromotionPay = false
    var radius = 10
    var area = ""
    var pincode = ""
    var selectedImage:UIImage?
    var strUrl = ""
    
    
    //MARK: Controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPay.layer.cornerRadius = 8.0
        btnPay.clipsToBounds = true
        if paymentFor == .bannerPromotion || paymentFor == .bannerPromotionDraft{
            lblDesc.text = "You've selected the \(planObj?.name ?? "") Plan"
            lblPrice.text = "Let's Get You More Views & Sales"
            btnPay.setTitle("Pay \(Local.shared.currencySymbol) \(planObj?.finalPrice ?? "0")", for: .normal)
            lblDesc.textAlignment = .center
            lblPrice.textAlignment = .center

        }else{
            lblDesc.text = ""
            lblPrice.text = "Total \(Local.shared.currencySymbol) \(planObj?.finalPrice ?? "0")"
            btnPay.setTitle("Pay \(Local.shared.currencySymbol) \(planObj?.finalPrice ?? "0")", for: .normal)
        }
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
            
            //  if isBannerPromotionPay{
                
            if paymentFor == .bannerPromotion{
                
                getIntentForBannerPromotions(package_id: planObj?.id ?? 0)
           
            } else if paymentFor == .bannerPromotionDraft{
                
                revokeCampaignPaymentApi(package_id:  planObj?.id ?? 0)
                
            }else{
                self.createPhonePayOrder(package_id: planObj?.id ?? 0)

            }

        }
    }
    
    func getPaymentSettings(){
        
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
                    
                    guard let self = self else { return }
                    
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        self.payment_method_type = dataDict["payment_method_type"] as? Int ?? 0
                        
                        if self.payment_method_type == 1 {
                            //IN App Purchase
                            
                        }else if self.payment_method_type == 3 {//Phone Pay
                            if let PhonePeDict = dataDict["PhonePe"] as? Dictionary<String, Any>  {
                                self.api_key = PhonePeDict["api_key"] as? String ?? ""
                                self.merchantId = PhonePeDict["merchent_id"] as? String ?? ""
                                
                                var flowId = ""
            
                                if Local.shared.getUserId() > 0{
                                    flowId = "\(Local.shared.getUserId())"
                                }
                                
                                self.payment_method = "PhonePe"
                                
                                if devEnvironment == .live {
                                    self.ppPayment = PPPayment(environment: .production,
                                                               flowId: flowId,
                                                               merchantId: self.merchantId,
                                                               enableLogging: false)
                                }else {
                                    self.ppPayment = PPPayment(environment: .sandbox,
                                                               flowId: flowId,
                                                               merchantId: self.merchantId, enableLogging: true)
                                }

                            }
                        }
                    }
                    
                }else{
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
                }
            }
        }
    }
    
    
    func updateOrderApi(){
        
        let campaignBannerId = (campaign_banner_id ?? 0) > 0 ? "\(campaign_banner_id ?? 0)" : ""
        let params:Dictionary<String, Any> = ["merchantOrderId":self.paymentIntentId,"campaign_banner_id":campaignBannerId]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.order_update, param: params,methodType: .post,showLoader: true) { responseObject, error in
            
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
                    if self.sheetViewController?.options.useInlineMode == true {
                        self.sheetViewController?.attemptDismiss(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
                }
            }
        }
        
    }
    
    

  
    
    func revokeCampaignPaymentApi(package_id:Int){
        
        let params = ["banner_id":banner_id,"payment_method":"PhonePe","package_id":(planObj?.id ?? ""),"payment_transaction_id":payment_transaction_id,"platform_type":"app"] as [String : Any]

        URLhandler.sharedinstance.makeCall(url:  Constant.shared.revoke_campaign_payment, param: params, showLoader: true) {[weak self] responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        
                        if let campaign_banner_id =  dataDict["campaign_banner_id"] as? Int{
                            self?.campaign_banner_id = campaign_banner_id
                        }
                        
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
                    
                    AlertView.sharedManager.showToast(message: message)

                }
            }
        }
    }

    
    func getIntentForBannerPromotions(package_id:Int){

    
        let params = ["radius":radius,"country":country,"city":city,"state":state,"area":area,"pincode":pincode,"latitude":latitude,"longitude":longitude,"payment_method":"PhonePe","package_id":(planObj?.id ?? ""),"status":"active","type":"redirect","url":strUrl,"platform_type":"app"] as [String : Any]
        
        guard let img = selectedImage?.wxCompress() else{ return }
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: img, imageName: "image", url: Constant.shared.campaign_payment_intent, params: params) {[weak self] responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        
                        if let campaign_banner_id =  dataDict["campaign_banner_id"] as? Int{
                            self?.campaign_banner_id = campaign_banner_id
                        }
                        
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
                    
                    AlertView.sharedManager.showToast(message: message)

                }
            }
        }
    }
    
    
  /*  curl --location 'https://admin.gupsup.com/api/v1/campaign-payment-intent' \
    --header 'Authorization: Bearer 36916|d4AUyGpAiRXqMeXmFI1Y2MxDMs3uWTqVFPoYbWfn5cbd09d4' \
    --header 'Accept: application/json' \
    --form 'image=@"/home/khusyal/Desktop/error_17382998.png"' \
    --form 'country="India"' \
    --form 'state="Maharashtra"' \
    --form 'city="Mumbai"' \
    --form 'area="Andheri East"' \
    --form 'pincode="400059"' \
    --form 'latitude="19.1136"' \
    --form 'longitude="72.8697"' \
    --form 'radius="15"' \
    --form 'type="redirect"' \
    --form 'url="https://example.com/job-promotions"' \
    --form 'status="active"' \
    --form 'city="Delhi"' \
    --form 'package_id="516"' \
    --form 'payment_method="PhonePe"'
     
    */
    
    
    func createPhonePayOrder(package_id:Int){
                
        let params:Dictionary<String, Any> = ["package_id":package_id, "payment_method":payment_method, "platform_type":"app","category_id":categoryId,"city":city,"state":state]
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
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    
    func startCheckoutPhonePay(orderId: String, token:String){
        let appSchema =  "getkart.com"//"Getkart IOS App"
        ppPayment.startCheckoutFlow(merchantId: merchantId,
                                    orderId: orderId,
                                    token: token,
                                    appSchema: appSchema,
                                    on: self) { _, state in
            
            self.updateOrderApi()
            print(state)
         /*
            AlertView.sharedManager.presentAlertWith(title: "", msg: "\(state)" as NSString, buttonTitles: ["ok"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                
            }
            if self.sheetViewController?.options.useInlineMode == true {
                self.sheetViewController?.attemptDismiss(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            */
        }
    }
}



extension PayPlanVC {
    
    func updateInAppPurchaseOrderApi(transactionId:String){
        //
        let params:Dictionary<String, Any> = ["purchase_token":transactionId, "payment_method":"apple", "package_id":planObj?.id ?? 0, "receipt": self.InAppReceipt,"category_id":categoryId,"city":city]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.in_app_purchase, param: params,methodType: .post,showLoader: true) { responseObject, error in
            
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
                }else{
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)

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
