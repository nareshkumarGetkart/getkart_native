//
//  OTPViewController.swift
//  GetKart
//
//  Created by gurmukh singh on 2/21/25.
//

import UIKit
import SwiftUI


var SALT_TOKEN_TO_SEND = ""

class OTPViewController: UIViewController {
    @IBOutlet weak var lblMobileNo:UILabel!
    @IBOutlet weak var txtOtp:UITextFieldX!
    @IBOutlet weak var btnResendOtp:UIButton!
    @IBOutlet weak var btnSignIn:UIButton!
    @IBOutlet weak var lblMessage:UILabel!

    private var timer: Timer?
    private var remainingSeconds = 60
    var countryCode = ""
    var mobile = ""
    var isMobileLogin = true
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMobileNo.text = countryCode + mobile
        self.btnSignIn.backgroundColor = UIColor.gray
        if isMobileLogin == true {
            lblMessage.text = "Sign in with mobile"
            startTimer()
        }else{
            btnResendOtp.isHidden = true
            lblMessage.text = "Sign in with email"
        }
    }
    
    deinit{
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: Other Helpful Methods
    private func startTimer() {
        remainingSeconds = 60
        btnResendOtp.setTitle("Resend OTP (\(remainingSeconds))", for: .normal)
        btnResendOtp.isEnabled = false
        btnResendOtp.alpha = 0.5
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func updateTimer() {
        remainingSeconds -= 1
        btnResendOtp.setTitle("Resend OTP (\(remainingSeconds))", for: .normal)
        
        if remainingSeconds <= 0 {
            timer?.invalidate()
            timer = nil
            btnResendOtp.setTitle("Resend OTP", for: .normal)
            btnResendOtp.isEnabled = true
            btnResendOtp.alpha = 1.0
        }
    }
    
    //MARK: UIButton Action Methods
    @IBAction func changeAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func skipBtnAction(){
        if let vc = StoryBoard.main.instantiateViewController(identifier: "HomeBaseVC") as? HomeBaseVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func signInAction(){
        self.view.endEditing(true)
        if (txtOtp.text?.count ?? 0) >= 4 {
            if isMobileLogin == true {
                
                self.verifyMobileOTPApi()
            }else{
                self.verifyEmailOTPApi()
            }
        }
    }
    
    @IBAction func reSendOTPApi(){
        saltGeneratorApi()
      //  resendOtpApi()
        startTimer()
        
    }
    
    //MARK: Api Methods
    func verifyMobileOTPApi(){
        
      //  let params = ["mobile": mobile, "countryCode":countryCode, "otp":txtOtp.text ?? ""] as [String : Any]
        
        let shortKey = UIDevice.generateShortKeyWithSalt(customValue: UIDevice.MY_CUSTOM_KEY, salt: UIDevice.MY_CUSTOM_SALT)

        let params = ["mobile": mobile, "countryCode":"\(countryCode)", "otp":txtOtp.text ?? "","appversion":UIDevice.appVersion,"authtype":"\(shortKey)","plateform":"ios","deviceid":"\(UIDevice.getDeviceUIDid())","salt_token":"\(SALT_TOKEN_TO_SEND)"] as [String : Any]
 
        URLhandler.sharedinstance.makeCall(url: Constant.shared.verify_mobile_otp_handler, param: params, methodType: .post,showLoader:true) { [weak self] responseObject, error in
            
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    if let  data = result["data"] as? Dictionary<String, Any>{
                        
                       if let temp_token = data["temp_token_"] as? String{
                            
                           self?.userSignupApi(tempToken: temp_token)

                        }
                    }
                 
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
    
    
    
    func verifyEmailOTPApi(){
        
        let params = ["email": mobile,"otp":txtOtp.text ?? "","type":"login"] as [String : Any]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.verify_email_otp, param: params, methodType: .post,showLoader:true) { [weak self] responseObject, error in
            
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                 
                    if let  data = result["data"] as? Dictionary<String, Any>{
                        
                       if let temp_token = data["temp_token_"] as? String{
                            
                           self?.userSignupApi(tempToken: temp_token)

                        }
                    }
                   
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
    
    //MARK: Api Methods
    
    
    func saltGeneratorApi(){
        
        
        let shortKey = UIDevice.generateShortKeyWithSalt(customValue: UIDevice.MY_CUSTOM_KEY, salt: UIDevice.MY_CUSTOM_SALT)
        let params = ["mobile": mobile, "countryCode":"\(countryCode)","appversion":UIDevice.appVersion,"authtype":"\(shortKey)","plateform":"ios","deviceid":"\(UIDevice.getDeviceUIDid())"] as [String : Any]
        
        
//        'http://localhost/api/v1/salt-handler?deviceid=123&plateform=ios&authtype=basic&appversion=1.2&mobile=9312069552&countryCode=%2B91' \
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.salt_handler, param: params, methodType: .post,showLoader:false) { [weak self] responseObject, error in
            
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
               // let message = result["message"] as? String ?? ""
                
                if status == 200{
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        if let salt_token = data["salt_token"] as? String{
                            self?.sendOTPApi(saltKey: salt_token)
                        }
                    }
               
                }
                
            }
        }
    }
    
    
    func sendOTPApi(saltKey:String){
      
        let shortKey = UIDevice.generateShortKeyWithSalt(customValue: UIDevice.MY_CUSTOM_KEY, salt: UIDevice.MY_CUSTOM_SALT)

        let params = ["mobile": mobile, "countryCode":"\(countryCode)","salt_token":saltKey,"appversion":UIDevice.appVersion,"authtype":"\(shortKey)","plateform":"ios","deviceid":"\(UIDevice.getDeviceUIDid())"] as [String : Any]
        
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.send_mobile_otp_handler, param: params, methodType: .post,showLoader:false) {  responseObject, error in
            
//        URLhandler.sharedinstance.makeCall(url: Constant.shared.sendMobileOtpUrl, param: params, methodType: .post,showLoader:false) { [weak self] responseObject, error in
//
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        if let salt_token = data["salt_token"] as? String{
                            SALT_TOKEN_TO_SEND = salt_token
                        }
                    }
                    AlertView.sharedManager.showToast(message: message)
                }else{
                    AlertView.sharedManager.showToast(message: message)

                }
                
            }
        }
    }
    
    
    
    
  /*  func resendOtpApi(){
        let params = ["mobile": mobile, "countryCode":countryCode] as [String : Any]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.sendMobileOtpUrl, param: params, methodType: .post,showLoader:true) {  responseObject, error in
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    AlertView.sharedManager.showToast(message: message)
                }else{
                    AlertView.sharedManager.showToast(message: message)

                }
                
            }
        }
    }
    */
    
    func userSignupApi(tempToken:String){
        timer?.invalidate()
        timer = nil
        
        let timestamp = Date.timeStamp
        var params = ["mobile": mobile, "firebase_id":"msg91_\(timestamp)", "type":"phone","platform_type":"ios", "fcm_id":"\(Local.shared.getFCMToken())", "country_code":"\(countryCode)","temp_token_":tempToken,"device_id":UIDevice.getDeviceUIDid(),"device_model":UIDevice.getDeviceModelName()] as [String : Any]
        
        if isMobileLogin == false {
            
            params = ["email": mobile, "firebase_id":"msg91_\(timestamp)", "type":"email","platform_type":"ios", "fcm_id":"\(Local.shared.getFCMToken())", "temp_token_":tempToken,"device_id":UIDevice.getDeviceUIDid(),"device_model":UIDevice.getDeviceModelName()] as [String : Any]
        }
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.userSignupUrl, param: params, methodType: .post,showLoader:true) {  responseObject, error in
            
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                 let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    if let payload =  result["data"] as? Dictionary<String,Any>{
                        
                        let token = result["token"] as? String ?? ""
                        let objUserInfo = UserInfo(dict: payload, token: token)
                        Local.shared.saveUserId(userId: objUserInfo.id ?? 0)
                        RealmManager.shared.saveUserInfo(userInfo: objUserInfo)
                        SocketIOManager.sharedInstance.checkSocketStatus()
                        let hostingController = UIHostingController(rootView: MyLocationView(navigationController: self.navigationController))
                        self.navigationController?.pushViewController(hostingController, animated: true) // Push to
                        
                    }
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
}


extension OTPViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Current text in the text field
        let currentText = textField.text ?? ""
        
        // Construct the new text after applying the replacement
        if let stringRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.count <  4{
                self.btnSignIn.backgroundColor = UIColor.gray
                
            }else{
                self.btnSignIn.backgroundColor = UIColor.orange
            }
        }
        
        return true
    }
}
