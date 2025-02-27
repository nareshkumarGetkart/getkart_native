//
//  Untitled.swift
//  GetKart
//
//  Created by gurmukh singh on 2/19/25.
//
import UIKit
import GoogleSignInSwift
import AuthenticationServices
import GoogleSignIn
import SwiftUI

enum SocialMediaLoginType{
    case gmail, apple
}

class LoginVC: UIViewController {
    @IBOutlet weak var scrScrollView:UIScrollView!
    @IBOutlet weak var txtEmailPhone:UITextFieldX!
    @IBOutlet weak var btnCountryCode:UIButton!
    @IBOutlet weak var lblError:UILabel!
    @IBOutlet weak var lblCharCount:UILabel!
    @IBOutlet weak var btnContinueLogin:UIButtonX!
    @IBOutlet weak var viewContent:UIView!
    
    var countryCode = ""
    var socialId:String = ""
    var socialName:String = ""
    var socialEmail:String = ""
    var loginType:SocialMediaLoginType = SocialMediaLoginType.apple
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmailPhone.addTarget(self, action: #selector(changedCharacters(textField:)), for: .editingChanged)
        txtEmailPhone.maxLength = 50
        txtEmailPhone.text = ""
        txtEmailPhone.leftPadding = 10
        self.fetChAndSetInitialCodeFromLocale()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 650)
        

    }
    
    func fetChAndSetInitialCodeFromLocale(){
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryCode: String = locale.countryCode ?? ""
        for countryDic in CountryCodeJson {
            if (countryDic["locale"] as? String ?? "").lowercased() == countryCode.lowercased() {
                self.countryCode = "+\(countryDic["code"] ?? "")"
                self.btnCountryCode.setTitle(self.countryCode, for: .normal)
                break
            }
        }
    }
    
    @IBAction func countruCodeButton(_ sender : UIButton){
        
        if let destVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "MobileCodeVC") as? MobileCodeVC{
           
            destVC.selectedCountryCallBack = { countryDic in
                print(countryDic)
                
                self.countryCode = "+\(countryDic["code"] ?? "")"
                self.btnCountryCode.setTitle(self.countryCode, for: .normal)
            }
            destVC.modalPresentationStyle = .overCurrentContext
            self.present(destVC, animated: true, completion: nil)
        }
    }
    
    @objc func changedCharacters(textField: UITextField){
        guard let input = textField.text else { return }
        // do with your text whatever you want
        print(input)
        if txtEmailPhone.text?.count ?? 0 > 50 {
            lblCharCount.text = "50/50"
        }else {
            lblCharCount.text = "\(txtEmailPhone.text?.count ?? 0)/50"
        }
        
        if input.isNumeric == true {
            txtEmailPhone.leftPadding = 50
            btnCountryCode.isHidden = false
        }else {
            txtEmailPhone.leftPadding = 10
            btnCountryCode.isHidden = true
        }
    }
    @IBAction func skipButtonAction() {
        if let vc = StoryBoard.main.instantiateViewController(identifier: "HomeBaseVC") as? HomeBaseVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func continueLoginAction() {
        
        self.view.endEditing(true)
        txtEmailPhone.layer.borderColor = UIColor.black.cgColor
        lblError.isHidden = true
        self.btnContinueLogin.backgroundColor = UIColor(hexString: "555357", alpha: 1.0)
        
        if txtEmailPhone.text?.isValidEmail() == true {
            let vc = StoryBoard.preLogin.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if txtEmailPhone.text?.isValidPhone() == true {
            /*let vc = StoryBoard.preLogin.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
            self.navigationController?.pushViewController(vc, animated: true)
             */
            self.sendOTPApi()
            
        }else {
            txtEmailPhone.layer.borderColor = UIColor.red.cgColor
            lblError.isHidden = false
            self.btnContinueLogin.backgroundColor = UIColor.orange
        }
    }
    
    func sendOTPApi(){
        
        var params = ["mobile": txtEmailPhone.text ?? "", "countryCode":"\(countryCode)"] as [String : Any]
        
        
      
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
                    let vc = StoryBoard.preLogin.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                    vc.countryCode = self?.countryCode ?? ""
                    vc.mobile =  self?.txtEmailPhone.text ?? ""
                    self?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    
    
    
    @IBAction func signUpBtnAction(_ sender : UIButton){
        
        let swiftUIView = SignUpView(navigationController: self.navigationController) // Create SwiftUI view
        let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
        navigationController?.pushViewController(hostingController, animated: true) // Push to navigation stack
    }

    
    @IBAction func termsAndCondition(_ sender : UIButton){
        
        let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Terms of service", type: .termsAndConditions) // Create SwiftUI view
        let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
        navigationController?.pushViewController(hostingController, animated: true) // Push to navigation stack
    }
    
    @IBAction func privacyCondition(_ sender : UIButton){
        
        let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Privacy Policy", type: .privacy) // Create SwiftUI view
        let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
        navigationController?.pushViewController(hostingController, animated: true) // Push to navigation stack
    }

    
    
}

extension LoginVC:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        return true
    }
}

extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @IBAction func loginWithGoogleButton(_ sender : UIButton){
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else {
                print("Error: ",error?.localizedDescription)
                return }
            guard let signInResult = signInResult else { return }

            let user = signInResult.user
            
            let gmailUserID = user.userID
            let emailAddress = user.profile?.email
            let fullName = user.profile?.name
           // let givenName = user.profile?.givenName
            //let familyName = user.profile?.familyName
            //let profilePicUrl = user.profile?.imageURL(withDimension: 320)
            
            self.socialEmail = emailAddress ?? ""
            self.socialName = fullName ?? ""
            self.socialId = gmailUserID ?? ""
            self.loginType = .gmail
           
           // self.loginWithSocialID()
            
        }
        
    }
    
        
    
    @IBAction func loginWithAppleButton(_ sender : UIButton){
        
        
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
   
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            
            
            // Create an account in your system.
            let socialUser = appleIDCredential.user
            let socialFullName = appleIDCredential.fullName?.givenName ?? ""
            let socialEmails = appleIDCredential.email ?? ""
            
            print("socialUser \(appleIDCredential.user), socialFullName: \(socialFullName) , socialEmail: \(socialEmail)")
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            //self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
            
                      
            socialEmail = socialEmails
            socialName = socialFullName
            socialId = socialUser
            loginType = .apple
            
            //self.loginWithSocialID()
            
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            print(username, password)
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
               // self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}
