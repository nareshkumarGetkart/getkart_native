//
//  PaymentGatewayCentralized.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 22/12/25.
//

import Foundation
import UIKit
import FittedSheets
import PhonePePayment
import StoreKit
import SwiftUI

class PaymentGatewayCentralized{
    
    private var ppPayment = PPPayment()
    private var merchantId = ""
    private var api_key = ""
    private var phonePeAppId = ""
    private  var paymentIntentId = ""
    private  var payment_method = ""
    private  var payment_method_type = 0
    private   var InAppReceipt = ""
    var planObj:PlanModel?
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
    var radius = 10
    var area = ""
    var pincode = ""
    var selectedImage:UIImage?
    var strUrl = ""
    var callbackPaymentSuccess: ((_ isSuccess: Bool) -> Void)?
    var itemId:Int?
   
    var selectedPlanId = 0
    var selIOSProductID = ""
    
    //MARK: Initialization Methods
    func initializeDefaults(){
        if selectedPlanId == 0{
            //Done this because not want to add dependency of passing planmodel object only id is sufficient
            selectedPlanId = planObj?.id ?? 0
            selIOSProductID = planObj?.iosProductID ?? ""
        }
        getPaymentSettings()
    }
    
    
  
    
    
    //MARK: Methods
  private  func getPaymentSettings(){
        
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
                    
                   // guard let self = self else { return }
                    
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        self?.payment_method_type = dataDict["payment_method_type"] as? Int ?? 0
                        
                        if self?.payment_method_type == 1 {
                            //IN App Purchase
                          //  DispatchQueue.main.async {
                               // self?.openPaymentPay()

                           // }
                            
                            self?.IAPPaymentForm(order_id: "", user_id: 0, id: 0)

                            
                        }else if self?.payment_method_type == 3 {//Phone Pay
                            if let PhonePeDict = dataDict["PhonePe"] as? Dictionary<String, Any>  {
                                self?.api_key = PhonePeDict["api_key"] as? String ?? ""
                                self?.merchantId = PhonePeDict["merchent_id"] as? String ?? ""
                                
                                var flowId = ""
            
                                if Local.shared.getUserId() > 0{
                                    flowId = "\(Local.shared.getUserId())"
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
                            
                          //  DispatchQueue.main.async {
                                self?.openPaymentPay()

                           // }
                        }
                      
                    }
                    
                }else{
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
                }
            }
        }
    }
    
    
  private  func openPaymentPay(){
      if payment_method_type == 1 {//In App
          
          if paymentFor == .bannerPromotion{
              self.inAppCampaignPaymentIntent()
          }else{
              self.IAPPaymentForm(order_id: "", user_id: 0, id: 0)
          }
          
      }else if payment_method_type == 3 {//Phone Pay
            
            //  if isBannerPromotionPay{
                
            if paymentFor == .bannerPromotion{
                
//                getIntentForBannerPromotions(package_id: planObj?.id ?? 0)
                getIntentForBannerPromotions(package_id: selectedPlanId)

                
           
            } else if paymentFor == .bannerPromotionDraft{
                
//                revokeCampaignPaymentApi(package_id:  planObj?.id ?? 0)
                
                revokeCampaignPaymentApi(package_id: selectedPlanId)

                
            }else{
                
//                self.createPhonePayOrder(package_id: planObj?.id ?? 0)

                self.createPhonePayOrder(package_id: selectedPlanId)

            }

        }
    }
    
    private  func updateOrderApi(){
        
        let campaignBannerId = (campaign_banner_id ?? 0) > 0 ? "\(campaign_banner_id ?? 0)" : ""
        var params:Dictionary<String, Any> = ["merchantOrderId":self.paymentIntentId,"campaign_banner_id":campaignBannerId]
        
        if let postItemId = itemId{
            params["item_id"] = postItemId
        }
        
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
                    
                    if let postItemId = self.itemId{
                        //Post notification to update screens
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue), object:  ["boardId":postItemId], userInfo: nil)
                    }
                    self.callbackPaymentSuccess?(true)
//                    if self.sheetViewController?.options.useInlineMode == true {
//                        self.sheetViewController?.attemptDismiss(animated: true)
//                    } else {
//                        self.dismiss(animated: true, completion: nil)
//                    }
                }else{
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
                }
            }
        }
        
    }
    
    

  
    
    private func revokeCampaignPaymentApi(package_id:Int){
        
        let params = ["banner_id":banner_id,"payment_method":"PhonePe","package_id":selectedPlanId,"payment_transaction_id":payment_transaction_id,"platform_type":"app"] as [String : Any]

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

    
    private func getIntentForBannerPromotions(package_id:Int){

    
        let params = ["radius":radius,"country":country,"city":city,"state":state,"area":area,"pincode":pincode,"latitude":latitude,"longitude":longitude,"payment_method":"PhonePe","package_id":(selectedPlanId),"status":"active","type":"redirect","url":strUrl,"platform_type":"app"] as [String : Any]
        
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
    
    
    private func createPhonePayOrder(package_id:Int){
                
        var params:Dictionary<String, Any> = ["package_id":package_id, "payment_method":payment_method, "platform_type":"app","category_id":categoryId,"city":city,"state":state]
        
        var strURL = Constant.shared.paymentIntent
        
        if paymentFor == .boostBoard{
            strURL = Constant.shared.board_payment_intent
            params["board_id"] = itemId ?? 0
        }
        URLhandler.sharedinstance.makeCall(url: strURL, param: params, methodType: .post,showLoader:true) { [weak self] responseObject, error in
            
            
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
                                    on: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { _, state in
            
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
    
    //MARK: For campaign banner intent
    func inAppCampaignPaymentIntent(){
        
        let params = ["radius":radius,"country":country,"city":city,"state":state,"area":area,"pincode":pincode,"latitude":latitude,"longitude":longitude,"payment_method":"apple","package_id":selectedPlanId,"status":"active","type":"redirect","url":strUrl,"platform_type":"app"] as [String : Any]
        
        guard let img = selectedImage?.wxCompress() else{ return }
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: img, imageName: "image", url: Constant.shared.inapp_campaign_payment_intent, params: params) {[weak self] responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    if let dataDict = result["data"] as? Dictionary<String, Any> {
                        
                        if let campaign_banner_id =  dataDict["campaign_banner_id"] as? Int{
                            self?.campaign_banner_id = campaign_banner_id
                        }
                        
                        if let payment_transaction = dataDict["payment_transaction"] as? Dictionary<String, Any>  {
                            
                            let orderId = payment_transaction["order_id"] as? String ?? ""
                            let id = payment_transaction["id"] as? Int ?? 0
                            let user_id = payment_transaction["user_id"] as? Int ?? 0
                            
                            self?.IAPPaymentForm(order_id: orderId, user_id: user_id, id: id)
                        }
                    }
                    
                }else{
                    
                    AlertView.sharedManager.showToast(message: message)

                }
            }
        }
    }
    
    private  func updateInAppPurchaseOrderApi(transactionId:String,order_id:String,user_id:Int,id:Int){
        //
//        let params:Dictionary<String, Any> = ["purchase_token":transactionId, "payment_method":"apple", "package_id":selectedPlanId, "receipt": self.InAppReceipt,"category_id":categoryId,"city":city]
//      
      let campaignBannerId = (campaign_banner_id ?? 0) > 0 ? "\(campaign_banner_id ?? 0)" : ""

      var params:Dictionary<String, Any> = ["purchase_token":transactionId, "payment_method":"apple", "package_id":selectedPlanId, "receipt": self.InAppReceipt,"category_id":categoryId,"city":city,"campaign_banner_id":campaignBannerId]
      
       if let postItemId = itemId{
          params["item_id"] = postItemId
       }
        
        if order_id.count > 0{
            params["order_id"] = order_id
        }
      
       
        if user_id > 0{
            params["user_id"] = user_id
        }
      
        if id > 0{
            params["id"] = id
        }
    
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
                    
                    if let postItemId = self.itemId{
                        //Post notification to update screens
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue), object:  ["boardId":postItemId], userInfo: nil)
                    }
                    self.callbackPaymentSuccess?(true)
                }else{
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)

                }
            }
        }
    }
    
    
    internal func IAPPaymentForm(order_id:String,user_id:Int,id:Int){
        if  selIOSProductID.count > 0 {

//        if self.planObj != nil || iosProductID != nil  {
//            let productIDs:Array<String> = [self.planObj?.iosProductID ?? ""]
            let productIDs:Array<String> = [self.selIOSProductID]

            //let productIDs:Array<String> = ["ads_bronze_package"]
            
            var productsArray:Array<SKProduct> = Array()
            IAPHandler.shared.setProductIds(ids: productIDs)
            Themes.sharedInstance.activityView(uiView: (AppDelegate.sharedInstance.navigationController?.topViewController)!.view, isUserInteractionenabled: true)
            
            IAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
                DispatchQueue.main.async {
                    Themes.sharedInstance.removeActivityView(uiView: (AppDelegate.sharedInstance.navigationController?.topViewController)!.view)
                }
                guard let sSelf = self else {return}
                
                productsArray = products
                if productsArray.count > 0 {
                    DispatchQueue.main.async {
                        Themes.sharedInstance.activityView(uiView: (AppDelegate.sharedInstance.navigationController?.topViewController)!.view, isUserInteractionenabled: true)
                    }
                    IAPHandler.shared.purchase(product: productsArray[0]) { (alert, product, transaction) in
                        DispatchQueue.main.async {
                            Themes.sharedInstance.removeActivityView(uiView: (AppDelegate.sharedInstance.navigationController?.topViewController)!.view)
                        }
                        
                        if let tran = transaction, let prod = product {
                            //use transaction details and purchased product as you want
                            print("transaction: \(transaction)")
                            print("payment_id \(transaction?.transactionIdentifier ?? "")")
                            let transactionId = transaction?.transactionIdentifier ?? ""
                            self?.getInAppReceipt()
                         //   self?.updateInAppPurchaseOrderApi(transactionId: transactionId,)
                            self?.updateInAppPurchaseOrderApi(transactionId: transactionId, order_id: order_id, user_id: user_id, id: id)
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
