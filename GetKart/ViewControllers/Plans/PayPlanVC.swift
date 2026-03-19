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
import PayUCheckoutProKit
import PayUCheckoutProBaseKit
import PayUParamsKit
import CryptoKit
import PayUCommonUI


class PayPlanVC: UIViewController {
   
    var callbackPaymentSuccess: ((_ isSuccess: Bool) -> Void)?
    private var merchantId = ""
    private var api_key = ""
    private var phonePeAppId = ""
    private var ppPayment: PPPayment?
    var planObj:PlanModel?
    var paymentIntentId = ""
    var payment_method = ""
    var payment_method_type = 0  //1 => inapp , 2 => strip , 3 => phonepe , 4 =>  payu
    private  var saltKeyPayu = ""

    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var btnPay:UIButton!
    @IBOutlet weak var lblDesc:UILabel!
   
    var InAppReceipt = ""
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
    var itemId:Int?

    
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
    
    //MARK: UIButton Action Methods
    @IBAction func closeBtnAction(_ sender:UIButton){
        
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func payBtnAction(_ sender:UIButton){
        if payment_method_type == 1 {
            //In App
            if paymentFor == .bannerPromotion{
                inAppCampaignPaymentIntent()
                
            }else if paymentFor == .bannerPromotionDraft{
                revokeCampaignPaymentApi(package_id:  planObj?.id ?? 0)
                
            }else{
                self.IAPPaymentForm(order_id: "", user_id: 0, id: 0)
            }
            
        }else if payment_method_type == 3 {
            //Phone Pay
            if paymentFor == .bannerPromotion{
                
                getIntentForBannerPromotions(package_id: planObj?.id ?? 0)
                
            } else if paymentFor == .bannerPromotionDraft{
                
                revokeCampaignPaymentApi(package_id:  planObj?.id ?? 0)
                
            }else{
                self.createPhonePayOrder(package_id: planObj?.id ?? 0)
            }
            
        }else if payment_method_type == 4 {
            
            //Payu pay
            if paymentFor == .bannerPromotion{
                
                getIntentForBannerPromotions(package_id: planObj?.id ?? 0)
                
            } else if paymentFor == .bannerPromotionDraft{
                
                revokeCampaignPaymentApi(package_id:  planObj?.id ?? 0)
                
            }else{
                self.createPayUIntent(package_id: planObj?.id ?? 0)
            }
        }
    }
    
    //MARK: Api Methods
    
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
                            
                        }else if self.payment_method_type == 3 {
                            //Phone Pay
                            if let PhonePeDict = dataDict["PhonePe"] as? Dictionary<String, Any>  {
                                
                                self.api_key = PhonePeDict["api_key"] as? String ?? ""
                                self.merchantId = PhonePeDict["merchent_id"] as? String ?? ""
                                let flowId = "\(Local.shared.getUserId())"
                                if let method = PaymentMethod(rawValue: self.payment_method_type) {
                                    self.payment_method = method.title
                                }
                                
                                self.ppPayment = PPPayment(environment: (devEnvironment == .live) ? .production : .sandbox,
                                                           flowId: flowId,
                                                           merchantId: self.merchantId,
                                                           enableLogging: (devEnvironment == .live) ? false : true)
                                
                            }
                        }else if self.payment_method_type == 4 {
                            //PayuMoney Pay
                            if let PayuDict = dataDict["Payu"] as? Dictionary<String, Any>  {
                                self.api_key = PayuDict["api_key"] as? String ?? ""
                                self.saltKeyPayu = PayuDict["secret_key"] as? String ?? ""
                                if let method = PaymentMethod(rawValue: self.payment_method_type) {
                                    self.payment_method = method.title
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
    
    
   private func updateOrderApi(order_status:Bool=true){
        
        let campaignBannerId = (campaign_banner_id ?? 0) > 0 ? "\(campaign_banner_id ?? 0)" : ""
        var params:Dictionary<String, Any> = ["merchantOrderId":self.paymentIntentId,"campaign_banner_id":campaignBannerId,"order_status":order_status]
        
        if let postItemId = itemId{
            params["item_id"] = postItemId
        }
        
        if let method = PaymentMethod(rawValue: self.payment_method_type) {
            params["payment_method"] = method.title
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
}

extension PayPlanVC{
    
    //MARK: Banner promotion
    
    func revokeCampaignPaymentApi(package_id:Int){
        
        var params = ["banner_id":banner_id,"package_id":(planObj?.id ?? ""),"payment_transaction_id":payment_transaction_id,"platform_type":"app"] as [String : Any]

        if let method = PaymentMethod(rawValue: self.payment_method_type) {
            params["payment_method"] = method.title
        }
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
                        
                        if self?.payment_method_type == 1{
                            
                            self?.IAPPaymentForm(order_id: "", user_id: 0, id: 0)
                       
                        }else if self?.payment_method_type == 2{
                            
                        }else{
                           
                            if let payment_intentDict = dataDict["payment_intent"] as? Dictionary<String, Any> {
                                self?.paymentIntentId = payment_intentDict["id"] as? String ?? ""
                               
                                if let payment_gateway_response = payment_intentDict["payment_gateway_response"] as? Dictionary<String, Any>  {
                                    //phone pe
                                    let orderId = payment_gateway_response["orderId"] as? String ?? ""
                                    let token  = payment_gateway_response["token"] as? String ?? ""
                                    self?.startCheckoutPhonePay(orderId: orderId, token: token)
                                }
                            }
                            
                            if let payment_transactionDict = dataDict["payment_transaction"] as? Dictionary<String, Any> {
                                //payu
                                let  order_id = payment_transactionDict["order_id"] as? String ?? ""
                                let  amount = payment_transactionDict["amount"] as? Int ?? 0
                                self?.paymentIntentId = "\(payment_transactionDict["id"] as? Int ?? 0)"
                                self?.openPayuMoney(order_id: order_id, amount: amount)
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
    
        var params = ["radius":radius,"country":country,"city":city,"state":state,"area":area,"pincode":pincode,"latitude":latitude,"longitude":longitude,"package_id":(planObj?.id ?? ""),"status":"active","type":"redirect","url":strUrl,"platform_type":"app"] as [String : Any]
        
        if let method = PaymentMethod(rawValue: self.payment_method_type) {
            params["payment_method"] = method.title
        }
        
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
                            //phone pe
                            self?.paymentIntentId = payment_intentDict["id"] as? String ?? ""
                            
                            if let payment_gateway_response = payment_intentDict["payment_gateway_response"] as? Dictionary<String, Any>  {
                                
                                let orderId = payment_gateway_response["orderId"] as? String ?? ""
                                let token  = payment_gateway_response["token"] as? String ?? ""
                                self?.startCheckoutPhonePay(orderId: orderId, token: token)
                            }
                        }
                        
                        
                        if let payment_transactionDict = dataDict["payment_transaction"] as? Dictionary<String, Any> {
                            //payu
                            let  order_id = payment_transactionDict["order_id"] as? String ?? ""
                            let  amount = payment_transactionDict["amount"] as? Int ?? 0
                            self?.paymentIntentId = "\(payment_transactionDict["id"] as? Int ?? 0)"
                            self?.openPayuMoney(order_id: order_id, amount: amount)
                        }
                    }
                    
                }else{
                    
                    AlertView.sharedManager.showToast(message: message)

                }
            }
        }
    }
  
}

extension PayPlanVC{
    //MARK: Phone Pe
    
    func createPhonePayOrder(package_id:Int){
                
        var params:Dictionary<String, Any> = ["package_id":package_id, "payment_method":payment_method, "platform_type":"app","category_id":categoryId,"city":city,"state":state]
        
        if let postItemId = itemId{
            params["item_id"] = postItemId
        }
        
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
        ppPayment?.startCheckoutFlow(merchantId: merchantId,
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

extension PayPlanVC{
    //MARK: Payu
    
    func createPayUIntent(package_id:Int){
                
        var params:Dictionary<String, Any> = ["package_id":package_id, "payment_method":payment_method, "platform_type":"app","category_id":categoryId,"city":city,"state":state]
        
        if let postItemId = itemId{
            params["item_id"] = postItemId
        }
      
        URLhandler.sharedinstance.makeCall(url: Constant.shared.payu_payment_intent, param: params, methodType: .post,showLoader:true) { [weak self] responseObject, error in
            
            
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
                        
                        /*if let payment_intentDict = dataDict["payment_intent"] as? Dictionary<String, Any> {
                            let hash = payment_intentDict["hash"] as? String ?? ""
                            let payment_transaction_id = payment_intentDict["payment_transaction_id"] as? Int ?? 0
                        }*/

                      
                        if let payment_transactionDict = dataDict["payment_transaction"] as? Dictionary<String, Any> {
                            
                            let  order_id = payment_transactionDict["order_id"] as? String ?? ""
                            let  amount = payment_transactionDict["amount"] as? Int ?? 0
                            self?.paymentIntentId = "\(payment_transactionDict["id"] as? Int ?? 0)"
                            self?.openPayuMoney(order_id: order_id, amount: amount)
                        }
                    }
                }else{
                    AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    func openPayuMoney(order_id:String, amount:Int) {

        let userInfo = RealmManager.shared.fetchLoggedInUserInfo()

        let email = (userInfo.email?.isEmpty == false) ? userInfo.email! : "test@test.com"

        let paymentParam = PayUPaymentParam(
            key: api_key,
            transactionId: order_id,
            amount: String(format: "%.2f", Double(amount)),
            productInfo: "Getkart Product",
            firstName: userInfo.name ?? "Test",
            email: email,
            phone: userInfo.mobile ?? "9999999999",
            surl: Constant.shared.payuSuccessURL,
            furl: Constant.shared.payuFailureURL,
            environment: (devEnvironment == .live) ? .production : .test
        )
        
        

        paymentParam.userCredential = "\(api_key):\(email)"

        
        
       /* $metaData = 't' .'-'. $customMetaData['payment_transaction_id'] .'-'. 'p' .'-'. $customMetaData['package_id']. 'item' .'-'. $customMetaData['item_id'];
        t-123-p-123-item-123
        */
        
        var strUdf1Val = "t-\(paymentIntentId)-p-\(planObj?.id ?? 0)-item-"
        
        if let postItemId = itemId{
             strUdf1Val = "t-\(paymentIntentId)-p-\(planObj?.id ?? 0)-item-\(postItemId)"

        }

        paymentParam.additionalParam = [
            "udf1": strUdf1Val,
            "udf2": "",
            "udf3": "",
            "udf4": "",
            "udf5": ""
        ]

        paymentParam.userCredential = "\(api_key):\(email)"
        // PayU Configuration
        let config = PayUCheckoutProConfig()
        config.merchantName = "Getkart"
        config.showExitConfirmationOnCheckoutScreen = true
        
      

        // Open PayU Checkout
        PayUCheckoutPro.open(
            on: (AppDelegate.sharedInstance.navigationController?.topViewController!)!,
            paymentParam: paymentParam,
            config: config,
            delegate: self
        )
        
        
      /*  PayUCheckoutPro.open(on: <#T##UIViewController#>, paymentParam: <#T##PayUPaymentParam#>, config: <#T##PayUCheckoutProConfig?#>, delegate: <#T##any PayUCheckoutProDelegate#>)
        PayUCheckoutPro.open(
            on: self,
            paymentParam: paymentParam,
            config: config,
            delegate: self
        ) { (hashName, hashString, completion) in

            print("HashName:", hashName)
            print("HashString:", hashString)

            self.fetchHashFromServer(hashName: hashName,
                                     hashString: hashString) { hash in

                completion(hash ?? "")
            }
        }*/
    }
    
    
    func fetchHashFromServer(hashName: String,
                             hashString: String,
                             completion: @escaping (String?) -> Void) {

        let url = URL(string: "https://yourserver.com/generate-hash")!

        let body: [String: Any] = [
            "hashName": hashName,
            "hashString": hashString
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data else {
                completion(nil)
                return
            }

            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let hash = json?["hash"] as? String

            completion(hash)

        }.resume()
    }
    
    //MARK: Generate HAsh
    
    func generatePayUHash(
        key: String,
        txnId: String,
        amount: String,
        productInfo: String,
        firstName: String,
        email: String,
        salt: String
    ) -> String {

        let hashString = "\(key)|\(txnId)|\(amount)|\(productInfo)|\(firstName)|\(email)|||||||||||\(salt)"
        
        print("Hash String:", hashString)

        let hash = hashString.sha512()
        
        print("Generated Hash:", hash)

        return hash
    }
  
}



extension PayPlanVC: PayUCheckoutProDelegate {
   
    
    /*func generateHash(for param: DictOfString, onCompletion: @escaping PayUHashGenerationCompletion) {
        // Send this string to your backend and append the salt at the end and send the sha512 back to us, do not calculate the hash at your client side, for security is reasons, hash has to be calculated at the server side
        let hashStringWithoutSalt = param[HashConstant.hashString] ?? ""
        // Or you can send below string hashName to your backend and send the sha512 back to us, do not calculate the hash at your client side, for security is reasons, hash has to be calculated at the server side
        let hashName = param[HashConstant.hashName] ?? ""
        let postSalt = param[HashConstant.postSalt] ?? "" //// compulsory for Additional Charges and Split Payment
        // Set the hash in below string which is fetched from your server
            //  "<create SHA -512 hash of 'hashString+salt+postSalt'>"
        
       //
        //fetchHashFromServer(hashName: hashName, hashString: <#T##String#>, completion: <#T##(String?) -> Void#>)
        
        
       // onCompletion([hashName : hashFetchedFromServer])
    }*/
    
   func generateHash(
        for param: DictOfString,
        onCompletion: @escaping PayUHashGenerationCompletion
    ) {


        guard let hashName = param["hashName"],
              let hashString = param["hashString"] else { return }

        print("HashName:", hashName)
        print("HashString:", hashString)

        let finalHash = generateSHA512(hashString + saltKeyPayu)

        onCompletion([hashName: finalHash])
    }
    
    func generateSHA512(_ value: String) -> String {

        let data = Data(value.utf8)
        let hash = SHA512.hash(data: data)

        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    func onPaymentSuccess(response: Any?) {
        print("Payment Success:", response ?? "")
        self.updateOrderApi(order_status: true)

    }

    func onPaymentFailure(response: Any?) {
        print("Payment Failed:", response ?? "")
        self.updateOrderApi(order_status: false)

    }

    func onPaymentCancel(isTxnInitiated: Bool) {
        print("Payment Cancelled")
        self.updateOrderApi(order_status: false)

    }

    func onError(_ error: Error?) {
        print("Payment Error:", error ?? "")
    }
}
extension PayPlanVC {
    //MARK: For campaign banner intent

    func inAppCampaignPaymentIntent(){
        
        var params = ["radius":radius,"country":country,"city":city,"state":state,"area":area,"pincode":pincode,"latitude":latitude,"longitude":longitude,"package_id":(planObj?.id ?? ""),"status":"active","type":"redirect","url":strUrl,"platform_type":"app"] as [String : Any]
        
        if let method = PaymentMethod(rawValue: self.payment_method_type) {
            params["payment_method"] = method.title
        }
        
        guard let img = selectedImage?.wxCompress() else{ return }
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: img, imageName: "image", url: Constant.shared.inapp_campaign_payment_intent, params: params) { [weak self] responseObject, error in
            
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

   // func updateInAppPurchaseOrderApi(transactionId:String){
        //
        let campaignBannerId = (campaign_banner_id ?? 0) > 0 ? "\(campaign_banner_id ?? 0)" : ""

        var params:Dictionary<String, Any> = ["purchase_token":transactionId, "package_id":planObj?.id ?? 0, "receipt": self.InAppReceipt,"category_id":categoryId,"city":city,"campaign_banner_id":campaignBannerId]
        
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
        
        if let method = PaymentMethod(rawValue: self.payment_method_type) {
            params["payment_method"] = method.title
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
                           // self?.updateInAppPurchaseOrderApi(transactionId: transactionId)
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





extension String {
    func sha512() -> String {
        let data = Data(self.utf8)
        let digest = SHA512.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
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
