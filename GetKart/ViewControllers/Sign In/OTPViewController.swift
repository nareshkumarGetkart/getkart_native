//
//  OTPViewController.swift
//  GetKart
//
//  Created by gurmukh singh on 2/21/25.
//

import UIKit
import SwiftUI

class OTPViewController: UIViewController {
    @IBOutlet weak var lblMobileNo:UILabel!
    @IBOutlet weak var txtOtp:UITextFieldX!
    @IBOutlet weak var btnResendOtp:UIButton!
    @IBOutlet weak var btnSignIn:UIButton!
    private var timer: Timer?
    private var remainingSeconds = 60
    var countryCode = ""
    var mobile = ""
    
    //MARK: Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMobileNo.text = countryCode + mobile
        self.btnSignIn.backgroundColor = UIColor.gray
        startTimer()
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
        
        if (txtOtp.text?.count ?? 0) >= 4 {
            self.verifyMobileOTPApi()
        }
    }
    
    @IBAction func reSendOTPApi(){
        
        resendOtpApi()
        startTimer()
        
    }
    
    //MARK: Api Methods
    func verifyMobileOTPApi(){
        
        let params = ["mobile": mobile, "countryCode":countryCode, "otp":txtOtp.text ?? ""] as [String : Any]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.verifyMobileOtpUrl, param: params, methodType: .post,showLoader:true) { [weak self] responseObject, error in
            
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                 
                    self?.userSignupApi()
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
    
    
    
    //MARK: Api Methods
    
    func resendOtpApi(){
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
    
    func userSignupApi(){
        timer?.invalidate()
        timer = nil
        
        let timestamp = Date.timeStamp
        let params = ["mobile": mobile, "firebase_id":"msg91_\(timestamp)", "type":"phone","platform_type":"ios", "fcm_id":"\(Local.shared.getFCMToken())", "country_code":"\(countryCode)"] as [String : Any]
        
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
                        RealmManager.shared.saveUserInfo(userInfo: objUserInfo)
                        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                        print(objLoggedInUser)
                        
                        let hostingController = UIHostingController(rootView: MyLocationView(navigationController: self.navigationController)) // Wrap in UIHostingController
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
