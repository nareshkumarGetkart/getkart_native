//
//  MobileNumberView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/09/25.
//

import SwiftUI

struct MobileNumberView: View {
    
    var navigationController:UINavigationController?
    @State private var phoneNumber: String = ""
    var onDismissUpdatedMobile: (String) -> Void              // outgoing

    var body: some View {

        VStack{
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                
                Text("Mobile Verification").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
            
         
            // Mobile Number TextField with inline title
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.orange, lineWidth: 2)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Mobile Number")
                            .font(.system(size: 12))
                            .padding(.horizontal, 5)
                            .background(Color(.systemGray6)) // matches background
                            .offset(y: -10) // move it into border line
                            .foregroundColor(.black).padding(.leading,6)
                    }
                    
                    TextField("", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
            }.frame(height: 50)
                .padding(.horizontal, 16).padding(.top,40).padding(.bottom,20)
                        
                        // Send OTP Button
                        Button(action: {
                            // handle send OTP
                            sendOTPApi(countryCode: "+91")
                        }) {
                            Text("Send OTP")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(phoneNumber.count >= 10 ? Color.orange : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(24)
                        }.frame(height: 50)
                        .disabled(phoneNumber.count < 10)
                        .padding(.horizontal, 24)
            Spacer()
        }
        .background(Color(.systemGray6))
        

    }
    
    func pushToVerifyMobileNumber(mobileno:String){
        DispatchQueue.main.async {                      // ✅ ensure on main thread
            
            let destVc = UIHostingController(rootView: VerifyMobileNumberView(mobileNo:mobileno, onDismiss: {
                mob in
                onDismissUpdatedMobile(mob)
                self.navigationController?.popViewController(animated: false)
            }))
            self.navigationController?.pushViewController(destVc, animated: true)
        }
    }
    
    
    func sendOTPApi(countryCode:String){
        
        let params = ["mobile": Int(phoneNumber.trim()) ?? 0, "countryCode":"\(countryCode)"] as [String : Any]
              
        URLhandler.sharedinstance.makeCall(url: Constant.shared.sendMobileOtpUrl, param: params, methodType: .post,showLoader:true) { responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    self.pushToVerifyMobileNumber(mobileno:"\(Int(phoneNumber.trim()) ?? 0)")

                }else{
                    AlertView.sharedManager.showToast(message: message)

                }
                
            }
        }
    }

}

#Preview {
    MobileNumberView(navigationController:nil, onDismissUpdatedMobile: {str in})
}


