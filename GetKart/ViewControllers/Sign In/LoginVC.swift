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
import FirebaseAuth
import FirebaseCore

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
    
    @IBOutlet weak var btnContinueEmail:UIButtonX!
    @IBOutlet weak var btnContinueGmail:UIButtonX!
    @IBOutlet weak var btnContinueApple:UIButtonX!
    
    private var countryCode = ""
    private var socialId:String = ""
    private var socialName:String = ""
    private  var socialEmail:String = ""
    private  var firebaseIdEmail:String = ""

    private  var loginType:SocialMediaLoginType = SocialMediaLoginType.apple
    
    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.navigationController?.viewControllers.remove(at: 0)
        }
        
        txtEmailPhone.autocorrectionType = .no
        txtEmailPhone.keyboardType = .phonePad
        txtEmailPhone.textContentType = .telephoneNumber
        txtEmailPhone.addTarget(self, action: #selector(changedCharacters(textField:)), for: .editingChanged)
        txtEmailPhone.maxLength = 50
        txtEmailPhone.text = ""
        txtEmailPhone.leftPadding = 50
        txtEmailPhone.delegate = self
        self.fetChAndSetInitialCodeFromLocale()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 650)
        btnContinueEmail.layer.borderColor = UIColor.label.cgColor
        btnContinueGmail.layer.borderColor = UIColor.label.cgColor
        btnContinueApple.layer.borderColor = UIColor.label.cgColor
        
        btnContinueEmail.setImageTintColor(color: .label)
        btnContinueApple.setImageTintColor(color: .label)
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
    
    //MARK: UIButton Action Methods
    
    @IBAction func loginWithEmailButton(_ sender : UIButton){
        
        if let destVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "SIgnInWithEmailVC") as? SIgnInWithEmailVC{
        destVC.delegate = self
        self.navigationController?.pushViewController(destVC, animated: true)
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
        // print(input)
        /*if txtEmailPhone.text?.count ?? 0 > 50 {
            lblCharCount.text = "50/50"
        }else {
            lblCharCount.text = "\(txtEmailPhone.text?.count ?? 0)/50"
        }*/
        
        if  txtEmailPhone.text!.hasPrefix( self.countryCode) == true {
            if txtEmailPhone.text!.count >  self.countryCode.count {
                txtEmailPhone.text  = String(txtEmailPhone.text!.dropFirst( self.countryCode.count).trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        /*if input.isNumeric == true {
         txtEmailPhone.leftPadding = 50
         btnCountryCode.isHidden = false
         }else {
         txtEmailPhone.leftPadding = 10
         btnCountryCode.isHidden = true
         }*/
    }
    
    @IBAction func skipButtonAction() {
        self.txtEmailPhone.text = ""
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
           
            self.sendOTPApi()
            
        }else {
            txtEmailPhone.layer.borderColor = UIColor.red.cgColor
            lblError.isHidden = false
            self.btnContinueLogin.backgroundColor = UIColor.orange
        }
    }
    
    
    func sendOTPApi(){
        
        let params = ["mobile": txtEmailPhone.text ?? "", "countryCode":"\(countryCode)"] as [String : Any]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.sendMobileOtpUrl, param: params, methodType: .post,showLoader:false) { [weak self] responseObject, error in
            
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                    
                    let vc = StoryBoard.preLogin.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                    vc.countryCode = self?.countryCode ?? ""
                    vc.mobile =  self?.txtEmailPhone.text ?? ""
                    self?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    AlertView.sharedManager.showToast(message: message)
                    
                    self?.txtEmailPhone.layer.borderColor = UIColor.red.cgColor
                    self?.lblError.isHidden = false
                    self?.btnContinueLogin.backgroundColor = UIColor.orange
                }
                
            }
        }
    }
    
    
    
    @IBAction func signUpBtnAction(_ sender : UIButton){
        
        let swiftUIView = SignUpView(navigationController: self.navigationController)
        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    
    @IBAction func termsAndCondition(_ sender : UIButton){
        
        let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Terms of service", type: .termsAndConditions)
        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @IBAction func privacyCondition(_ sender : UIButton){
        
        let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Privacy Policy", type: .privacy)
        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}


extension LoginVC:UITextFieldDelegate {
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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

extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
   
    @IBAction func loginWithGoogleButton(_ sender : UIButton){
        
       // GIDSignIn.sharedInstance.signIn(withPresenting: self)
        signInWithGoogle()
        
      /*  GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
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
            
            self.signInUsingGmailorAppleApi()
        }*/
    }


    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing client ID.")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
//        guard let presentingVC = UIApplication.shared.windows.first?.rootViewController else {
//            print("No presenting view controller.")
//            return
//        }
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            if let user = result?.user {
                
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
                
              
                
                let idToken = user.idToken?.tokenString ?? ""
                let accessToken = user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: accessToken)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase Sign-In error: \(error.localizedDescription)")
                        return
                    }
                    
                    // Success!
                    print("User is signed in with Firebase: \(authResult?.user.uid ?? "")")
                    self.firebaseIdEmail = authResult?.user.uid ?? ""
                    self.signInUsingGmailorAppleApi()

                }
            }
        }
    }

    
    
    func signInUsingGmailorAppleApi(){
       
       // let timestamp = Date.timeStamp
        var params: Dictionary<String,Any> =  [:]
        
        if self.loginType == .gmail {
            
            params = ["firebase_id":"\(self.firebaseIdEmail)","social_id":"\(self.socialId)", "type":"google","platform_type":"ios", "fcm_id":"\(Local.shared.getFCMToken())","email":self.socialEmail, "name":self.socialName, "country_code":"\(countryCode)","device_id":UIDevice.getDeviceUIDid(),"device_model":UIDevice.getDeviceModelName()]
        }else{
            
            params = ["firebase_id":"\(self.firebaseIdEmail)","social_id":"\(self.socialId)", "type":"apple","platform_type":"ios", "fcm_id":"\(Local.shared.getFCMToken())", "name":self.socialName, "country_code":"\(countryCode)","device_id":UIDevice.getDeviceUIDid(),"device_model":UIDevice.getDeviceModelName()]
            if self.socialEmail.count > 0{
                params["email"] = self.socialEmail
            }
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
                        self.navigationController?.pushViewController(hostingController, animated: true)
                    }
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
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
       
            socialEmail = socialEmails
            socialName = socialFullName
            socialId = socialUser
            loginType = .apple
            
            
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: ""
            )

            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { [self] (authResult, error) in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    return
                }
                print("Firebase signed in with Apple!")
                // Handle user info
                
                guard let user = authResult?.user else {
                       print("No Firebase user found after sign-in.")
                       return
                   }
                
                print(user)
                self.socialEmail =  user.email ?? ""
                self.socialName =  user.displayName ?? ""
                self.socialId = socialUser
                self.loginType = .apple
                self.firebaseIdEmail = user.uid
                self.signInUsingGmailorAppleApi()

            }
            
            
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


extension LoginVC:SignInWithEmailSkipDelegate{
    func skipAction(){
        skipButtonAction()
    }
}

