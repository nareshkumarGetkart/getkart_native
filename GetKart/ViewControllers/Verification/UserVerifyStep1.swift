//
//  UserVerifyStep1.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import SwiftUI

struct UserVerifyStep1: View {
  
    var navigation:UINavigationController?
    @State private var fullName: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var businessName: String = ""
    @State private var apiGetsCalled = false
    
    var body: some View {
        // Top Navigation Bar
        HStack {
            Button(action: {
                // Action to go back
                self.navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    .padding()
            }
            Spacer()
        }.frame(height: 44)
            .onAppear{
                if !apiGetsCalled{
                    getUserProfileApi()
                    apiGetsCalled = true
                }
            }
        
        VStack {
            ScrollView{
            
            // Title with Progress Indicator
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("User Information")
                        .font(.manrope(.bold, size: 18))
                    Spacer()
                    Text("Step 1 of 3")
                        .foregroundColor(.gray)
                }
                
                // Progress Bar
                ProgressView(value: 0.2)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
                
            }.padding(.top,15)
                .padding(.horizontal, 20)
            
            // Personal Information Section
            VStack(alignment: .leading, spacing: 5) {
                Text("Enter Your Details")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Submit accurate information for verification")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Input Fields
            VStack(spacing: 10) {
                CustomTextField(title: "Full Name", text: $fullName).disabled(true)
                CustomTextField(title: "Business Name", text: $businessName)
                CustomTextField(title: "Address", text: $address).disabled(true)
                CustomTextField(title: "Phone Number", text: $phoneNumber, keyboardType: .phonePad).disabled(true)
                CustomTextField(title: "Email Address", text: $email, keyboardType: .emailAddress).disabled(true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom,15)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                // Continue action
                validateForm()
          
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
                
            
          /*  // Skip for Later Button
            Button(action: {
                // Skip action
                for controller in navigation?.viewControllers ?? []{
                    
                    if controller is HomeBaseVC{
                        self.navigation?.popToViewController(controller, animated: true)
                        break
                    }
                }
            }) {
                Text("Skip for later")
                    .font(.body)
                    .foregroundColor(.black)
                    .underline()
            }
            .padding(.top, 10)
            .padding(.bottom, 30)*/
        }
        }.navigationBarBackButtonHidden(true)
        .background(Color(UIColor.systemGray6)) // Light gray background
        .navigationBarTitleDisplayMode(.inline).navigationBarHidden(true).edgesIgnoringSafeArea(.top)

    }
    
    // Form Validation
    private func validateForm() {
        if fullName.isEmpty || email.isEmpty || phoneNumber.isEmpty || address.isEmpty || businessName.isEmpty {
            print("Please fill all the fields.")
            UIApplication.shared.endEditing()
            AlertView.sharedManager.showToast(message: "All field are required.")
        } else {
            print("Form Submitted!")
            var swidtUIView = UserVerifyStep2(navigation:navigation)
            swidtUIView.businessName = businessName
            let hostVC = UIHostingController(rootView: swidtUIView)
            self.navigation?.pushViewController(hostVC, animated: true)
        }
    }
    
    
    func getUserProfileApi(){
        
       // let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        
        let strUrl = Constant.shared.get_seller + "?id=\(Local.shared.getUserId())"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:SellerParse) in
            
            if obj.data != nil {
                
                self.fullName = obj.data?.seller?.name ?? ""
                self.email = obj.data?.seller?.email ?? ""
                self.phoneNumber = obj.data?.seller?.mobile ?? ""
                self.address = obj.data?.seller?.address ?? ""
           //     self.businessName = obj.data?.seller?.businessName ?? ""

               
            }
        }
    }
}

#Preview {
    UserVerifyStep1(navigation:nil)
}


// Reusable Text Field Component
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.manrope(.regular, size: 15))
                .foregroundColor(Color(UIColor.label))
            TextField("", text: $text).tint(Color(UIColor.systemOrange))
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .keyboardType(keyboardType)
        }
    }
}

