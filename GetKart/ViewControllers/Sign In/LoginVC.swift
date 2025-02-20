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

enum SocialMediaLoginType{
    case gmail, apple
}

class LoginVC: UIViewController {
    @IBOutlet weak var scrScrollView:UIScrollView!
    @IBOutlet weak var txtEmailPhone:UITextFieldX!
    @IBOutlet weak var lblError:UILabel!
    @IBOutlet weak var lblCharCount:UILabel!
    
    var socialId:String = ""
    var socialName:String = ""
    var socialEmail:String = ""
    var loginType:SocialMediaLoginType = SocialMediaLoginType.apple
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 650)
        txtEmailPhone.addTarget(self, action: #selector(changedCharacters(textField:)), for: .editingChanged)
        txtEmailPhone.maxLength = 50

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
    }
    
    @IBAction func continueLoginAction() {
        self.view.endEditing(true)
        txtEmailPhone.layer.borderColor = UIColor.black.cgColor
        lblError.isHidden = true
        
        if txtEmailPhone.text?.isValidEmail() == true {
            
        }else if txtEmailPhone.text?.isValidPhone() == true {
            
        }else {
            txtEmailPhone.layer.borderColor = UIColor.red.cgColor
            lblError.isHidden = false
        }
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
