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
    var countryCode = ""
    var mobile = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMobileNo.text = countryCode + mobile
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInAction(){
       /* let hostingController = UIHostingController(rootView: MyLocationView(navigationController: self.navigationController)) // Wrap in UIHostingController
        navigationController?.pushViewController(hostingController, animated: true) // Push to navigation stack
        */
        self.verifyMobileOTPApi()
    }
    
    func verifyMobileOTPApi(){
        
        var params = ["mobile": mobile, "countryCode":countryCode, "otp":txtOtp.text ?? ""] as [String : Any]
        
        
      
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
                    
                    /*if let payload =  result["payload"] as? Dictionary<String,Any>{
                        
                        self?.uid = payload["uid"] as? String ?? ""
                        
                        self?.delegate?.navigateToNextScreen(message: message)
                    }*/
                    let hostingController = UIHostingController(rootView: MyLocationView(navigationController: self?.navigationController, countryCode: self?.countryCode ?? "", mobile: self?.mobile ?? "")) // Wrap in UIHostingController
                    
                    self?.navigationController?.pushViewController(hostingController, animated: true) // Push to navigation stack
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    @IBAction func reSendOTPApi(){
        
        var params = ["mobile": mobile, "countryCode":countryCode] as [String : Any]
        
        
      
        URLhandler.sharedinstance.makeCall(url: Constant.shared.sendMobileOtpUrl, param: params, methodType: .post,showLoader:true) { [weak self] responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    
                    /*if let payload =  result["payload"] as? Dictionary<String,Any>{
                        
                        self?.uid = payload["uid"] as? String ?? ""
                        
                        self?.delegate?.navigateToNextScreen(message: message)
                    }*/
                    AlertView.sharedManager.showToast(message: message)
                    //self?.view.makeToast(message: message , duration: 3, position: HRToastActivityPositionDefault)
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
}
