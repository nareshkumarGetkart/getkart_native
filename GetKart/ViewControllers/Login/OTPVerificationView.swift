//
//  OTPVerificationView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/26.
//

import SwiftUI


struct OTPVerificationView: View {
    
    @State private var otp: String = ""
    
    // MARK: - Resend Timer
    @State private var resendSeconds: Int = 0
    @State private var resendTimer: Timer?
    let navigationController:UINavigationController?
    
    // Replace this with your actual email
    var email: String = "radheshyam@gmail.com"
    var name:String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // MARK: - Skip Button
                HStack {
                    Spacer()
                    
                    Button {
                        // Skip action
                        skipBtnAction()
                    } label: {
                        Text("Skip")
                            .font(.inter(.medium,size:16))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .frame(height: 40)
                            .background(
                                Color.red.opacity(0.12)
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 10)
                .padding(.trailing, 22)
                
                // MARK: - Title
                Text("Check Your Email")
                    .font(.inter(.medium,size:30))
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .padding(.top, 50)
                
                // MARK: - Description
                VStack(spacing: 2) {
                    Text("Enter the 6-digit verification code sent to")
                        .font(.inter(.regular,size:16))
                    Text(maskEmail(email))
                        .font(.inter(.regular,size:16))
                }
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                
                // MARK: - OTP TextField
                TextField("Enter OTP here...", text: $otp)
                    .font(.inter(.regular,size:15))
                    .foregroundColor(.black)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .padding(.horizontal, 20)
                    .frame(height: 55)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.gray.opacity(0.65),
                                lineWidth: 1
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    .onChange(of: otp) { newValue in
                        // Only allow 4 digits
                        let filtered = newValue.filter { $0.isNumber }
                        
                        if filtered.count > 6 {
                            otp = String(filtered.prefix(6))
                        } else {
                            otp = filtered
                        }
                    }
                
                // MARK: - Resend OTP
                HStack {
                    Spacer()
                    
                    if resendSeconds > 0 {
                        
                        // Countdown
                        Text("Resend OTP (\(resendSeconds)s)")
                            .font(.inter(.medium,size:16))                            .foregroundColor(.gray)
                        
                    } else {
                        
                        // Resend Button
                        Button {
                            resendOTP()
                        } label: {
                            Text("Resend OTP")
                                .font(.inter(.medium,size:16))                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, 14)
                .padding(.trailing, 24)
                
                // MARK: - Continue Button
                Button {
                    verifyOTP()
                } label: {
                    Text("Continue")
                        .font(.inter(.medium,size:16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            Color(red: 0.27, green: 0.27, blue: 0.27)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                Spacer()
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .background(Color.white)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    func skipBtnAction(){
        if let vc = StoryBoard.main.instantiateViewController(identifier: "HomeBaseVC") as? HomeBaseVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    // MARK: - Mask Email
    
    private func maskEmail(_ email: String) -> String {
        
        let components = email.split(separator: "@")
        
        guard components.count == 2 else {
            return email
        }
        
        let username = String(components[0])
        let domain = String(components[1])
        
        guard username.count > 2 else {
            return email
        }
        
        let firstTwo = String(username.prefix(2))
        let stars = String(
            repeating: "*",
            count: max(username.count - 2, 3)
        )
        
        return "\(firstTwo)\(stars)@\(domain)"
    }
    
    
    // MARK: - Resend OTP
    
    private func resendOTP() {
        
        // Prevent multiple calls
        guard resendSeconds == 0 else {
            return
        }
        
        // ------------------------------------------------
        // Call your resend OTP API here
        // ------------------------------------------------
        sendOTPApi()
        print("Resend OTP API called")
        
        // Start 60 second countdown
        startResendTimer()
        
        
    }
    
    // MARK: - Start Timer
    
    private func startResendTimer() {
        
        resendTimer?.invalidate()
        
        resendSeconds = 60
        
        resendTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { timer in
            
            if resendSeconds > 1 {
                
                resendSeconds -= 1
                
            } else {
                
                resendSeconds = 0
                timer.invalidate()
                resendTimer = nil
            }
        }
    }
    
    // MARK: - Verify OTP
    
    private func verifyOTP() {
        guard otp.count == 6 else {
            return
        }
        
        print("OTP: \(otp)")
        
        // Call your verification API here
        verifyEmailOTPApi()
    }
    
    
    
    
    func sendOTPApi(){
        //  let timestamp = Date.timeStamp
          let params: Dictionary<String,String> =  ["email":email,"type":"signup"]
                
          URLhandler.sharedinstance.makeCall(url: Constant.shared.send_email_otp, param: params, methodType: .post,showLoader:false) {  responseObject, error in
              
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
    
    func verifyEmailOTPApi(){
        
        let params = ["email": email,"otp":otp,"type":"signup"] as [String : Any]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.verify_email_otp, param: params, methodType: .post,showLoader:true) {  responseObject, error in
            
            
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
                            
                           self.userSignupApi(tempToken: temp_token)

                        }
                    }
                   
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
    func userSignupApi(tempToken:String){
        resendTimer?.invalidate()
        resendTimer = nil
        
        let timestamp = Date.timeStamp
        let params = ["email": email,"name":name, "firebase_id":"msg91_\(timestamp)", "type":"email","platform_type":"ios", "fcm_id":"\(Local.shared.getFCMToken())", "temp_token_":tempToken,"device_id":UIDevice.getDeviceUIDid(),"device_model":UIDevice.getDeviceModelName()] as [String : Any]
        
        
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
                        
                        FaceBookAppEvents.saveLoginEvent(userObj: objUserInfo, screenName: "otp_screen")
                        
                        if let vc = StoryBoard.main.instantiateViewController(identifier: "HomeBaseVC") as? HomeBaseVC {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    }
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
}

#Preview {
    OTPVerificationView(navigationController: nil)
}




