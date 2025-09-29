//
//  VerifyMobileNumberView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/09/25.
//

import SwiftUI
/*
struct VerifyMobileNumberView: View {
    @State private var otpFields = ["", "", "", ""]
    @FocusState private var focusedField: Int?
    var navigationController: UINavigationController?

    var body: some View {
        VStack {
            // Header
            HStack {
                Button {
                    navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }
                .frame(width: 40, height: 40)

                Text("Mobile Verification")
                    .font(.custom("Manrope-Bold", size: 20))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }
            .frame(height: 44)
            .background(Color(UIColor.systemBackground))

            Spacer().frame(height: 40)

            Text("Enter the 4-digit OTP")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // OTP fields
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { i in
                    TextField("", text: Binding(
                        get: { otpFields[i] },
                        set: { handleChange($0, index: i) }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .focused($focusedField, equals: i)       // controlled focus
                    .onTapGesture { focusedField = i }       // allow manual tap
                }
            }
            .onAppear {
                // set initial focus on next run loop
                DispatchQueue.main.async { focusedField = 0 }
            }

            Button {
                // Verify OTP action
            } label: {
                Text("Verify OTP")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isOTPComplete ? Color.orange : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(24)
            }
            .disabled(!isOTPComplete)
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }

    private var isOTPComplete: Bool {
        otpFields.allSatisfy { $0.count == 1 }
    }

    private func handleChange(_ value: String, index: Int) {
        // Accept only a single digit
        otpFields[index] = String(value.prefix(1))

        if value.count == 1 {
            // move forward
            focusedField = index < 3 ? index + 1 : nil
        } else if value.isEmpty, index > 0 {
            // move back on delete
            focusedField = index - 1
        }
    }
}
*/

#Preview {
    VerifyMobileNumberView(onDismiss: {str in })
}


import SwiftUI

struct VerifyMobileNumberView: View {
    @State private var otpFields = Array(repeating: "", count: 4)
    @FocusState private var focusedField: Int?
    @Environment(\.dismiss) private var dismiss     // prefer for SwiftUI dismissal
    var mobileNo = ""
    var onDismiss: (String) -> Void              // outgoing

    var body: some View {
        VStack {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2).tint(Color.orange)
                }
                .frame(width: 40, height: 40)

                Text("Verify OTP")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal)
            
            Spacer().frame(height: 40)

            Text("Enter the 4-digit OTP")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // OTP fields
            HStack(spacing: 16) {
                ForEach(0..<otpFields.count, id: \.self) { i in
                    TextField("", text: $otpFields[i])
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)     // helps iOS autofill
                        .multilineTextAlignment(.center)
                        .frame(width: 56, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        ).tint(Color.orange)
                        .focused($focusedField, equals: i)
                        .onTapGesture { focusedField = i }
                        .onChange(of: otpFields[i]) { newValue in
                            handleChange(newValue, index: i)
                        }
                }
            }
            .padding(.top, 20)
            .onAppear {
                // small delay to ensure focus works when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    focusedField = 0
                }
            }

            Button {
                verifyOTP()
            } label: {
                Text("Verify OTP")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isOTPComplete ? Color.orange : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(24)
            }.frame(height: 50)
            .disabled(!isOTPComplete)
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()
        }
       // .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
    }

    // MARK: - Helpers

    private var isOTPComplete: Bool {
        otpFields.allSatisfy { $0.count == 1 }
    }

    private func handleChange(_ value: String, index: Int) {
        // keep only digits
        let digits = value.filter { $0.isNumber }

        // If user pasted multiple digits or typed fast, distribute across fields
        if digits.count > 1 {
            distributePastedString(digits, startingAt: index)
            return
        }

        // single-digit behavior (or cleared)
        otpFields[index] = String(digits.prefix(1))

        if otpFields[index].count == 1 {
            // move forward
            if index < otpFields.count - 1 {
                focusedField = index + 1
            } else {
                focusedField = nil
            }
        } else if otpFields[index].isEmpty {
            // move back on delete
            if index > 0 {
                focusedField = index - 1
            }
        }
    }

    private func distributePastedString(_ string: String, startingAt index: Int) {
        var chars = Array(string)
        var pos = index
        while !chars.isEmpty && pos < otpFields.count {
            otpFields[pos] = String(chars.removeFirst())
            pos += 1
        }
        // if filled all, dismiss keyboard
        focusedField = (pos < otpFields.count) ? pos : nil
    }

    private func verifyOTP() {
       // let code = otpFields.joined()
        // call your verify API here
       // print("Verifying OTP:", code)
//    }
//    
//    func verifyMobileOTPApi(){
//        
        let otp = otpFields.joined()

        let params = ["mobile": mobileNo, "countryCode":"+91", "otp":otp] as [String : Any]
        
        
      
        URLhandler.sharedinstance.makeCall(url: Constant.shared.mobile_verify_update, param: params, methodType: .post,showLoader:true) {  responseObject, error in
            
        
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
                        
                        RealmManager.shared.updateUserData(dict: data)
                    }
                    onDismiss(mobileNo)
                    dismiss()

                }else{

                }
                
            }
        }
    }
    
}
