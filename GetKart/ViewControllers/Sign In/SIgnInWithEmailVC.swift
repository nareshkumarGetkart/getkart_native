//
//  SIgnInWithEmailVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/05/25.
//

import UIKit


protocol SignInWithEmailSkipDelegate:AnyObject{
    func skipAction()
}

class SIgnInWithEmailVC: UIViewController {

    @IBOutlet weak var txtFdEmail:UITextFieldX!
    @IBOutlet weak var btnContinueLogin:UIButtonX!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var lblError:UILabel!

    weak var delegate:SignInWithEmailSkipDelegate?
    
    //MARK: Controller lIfe cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.setImageTintColor(color: .label)
        lblError.text = ""
    }
    

    //MARK: UIButton Action Methods
    @IBAction func backBtnAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueBtnAction(_ sender : UIButton){
        self.view.endEditing(true)
        txtFdEmail.layer.borderColor =  UIColor.black.cgColor

        if txtFdEmail.text?.isValidEmail() == true {
            lblError.text = ""
            
            sendEmailOtp()
        }else{
            lblError.text = "Please enter valid email id."
            txtFdEmail.layer.borderColor = UIColor.red.cgColor

        }
    }
    
    
    @IBAction func skipButtonAction() {
        self.navigationController?.popViewController(animated: false)
        self.delegate?.skipAction()

    }

    //MARK: Api Methods
    
    func sendEmailOtp(){
      //  let timestamp = Date.timeStamp
        let params: Dictionary<String,String> =  ["email":txtFdEmail.text ?? "","type":"login"]
              
        URLhandler.sharedinstance.makeCall(url: Constant.shared.send_email_otp, param: params, methodType: .post,showLoader:false) {[weak self]  responseObject, error in
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    
                   // AlertView.sharedManager.showToast(message: message)
                    DispatchQueue.main.async {
                        let vc = StoryBoard.preLogin.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                        vc.mobile =  self?.txtFdEmail.text ?? ""
                        vc.isMobileLogin = false
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                               
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    

}


extension SIgnInWithEmailVC:UITextFieldDelegate {
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        lblError.text = ""
        txtFdEmail.layer.borderColor =  UIColor.black.cgColor

        // Current text in the text field
          let currentText = textField.text ?? ""
          
          // Construct the new text after applying the replacement
          if let stringRange = Range(range, in: currentText) {
              let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
              
              if updatedText.count <  5{
                  self.btnContinueLogin.backgroundColor = UIColor.gray

              }else{
                  self.btnContinueLogin.backgroundColor = UIColor.orange

              }
          }
        
        return true
    }
}
