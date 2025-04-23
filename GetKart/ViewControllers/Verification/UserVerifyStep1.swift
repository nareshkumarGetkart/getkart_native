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

    var body: some View {
        // Top Navigation Bar
        HStack {
            Button(action: {
                // Action to go back
                AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding()
            }
            Spacer()
        }.frame(height: 44)
       
        
        
        VStack {
           
            // Title with Progress Indicator
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("User Information")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Text("Step 1 of 3")
                        .foregroundColor(.gray)
                }
                
                // Progress Bar
                ProgressView(value: 0.5)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
            }.padding(.top,30)
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
            VStack(spacing: 15) {
                CustomTextField(title: "Full Name", text: $fullName)
                CustomTextField(title: "Business Name", text: $businessName)
                CustomTextField(title: "Address", text: $address)
                CustomTextField(title: "Phone Number", text: $phoneNumber, keyboardType: .phonePad)
                CustomTextField(title: "Email Address", text: $email, keyboardType: .emailAddress)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                // Continue action
                let hostVC = UIHostingController(rootView: UserVerifyStep2(navigation:navigation))

                self.navigation?.pushViewController(hostVC, animated: true)
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
            
            // Skip for Later Button
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
            .padding(.bottom, 30)
        }.navigationBarBackButtonHidden(true)
        .background(Color(UIColor.systemGray6)) // Light gray background
        .navigationBarTitleDisplayMode(.inline).navigationBarHidden(true).edgesIgnoringSafeArea(.top)

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
                .font(.body)
                .foregroundColor(.black)
            TextField("", text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .keyboardType(keyboardType)
        }
    }
}

