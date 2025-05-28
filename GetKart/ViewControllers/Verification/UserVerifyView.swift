//
//  UserVerificationVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import SwiftUI

struct UserVerifyView: View {
    var navigation:UINavigationController?
    
    var body: some View {
        
        HStack {
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
                    .padding()
            }
            Spacer()
        }.frame(height: 44)
       
        
            VStack {
                // Top Navigation Bar
               
                Spacer()
                
                // Illustration (Replace with actual asset)
                Image("user_verification") // Add image to Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Title
                Text("User Verification")
                    .font(.manrope(.medium, size: 22))
                    .padding(.top, 20)
                
                // Description
                Text("Increase trust and attract more buyers by verifying now")
                    .font(.manrope(.regular, size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 5)
                
                
                Text("It will only take 2 minutes")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 5)

                Spacer()
                
                // Start Verification Button
                Button(action: {
                    // Start verification action
                    
                    let hostVC = UIHostingController(rootView: UserVerifyStep1(navigation:navigation))
                    self.navigation?.pushViewController(hostVC, animated: true)
                }) {
                    Text("Start Verification")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                // Skip for Later Button
                Button(action: {
                    // Skip action
                    navigation?.popViewController(animated: true)

                }) {
                    Text("Skip for later")
                        .font(.body)
                        .foregroundColor(.black)
                        .underline()
                }
                .padding(.top, 10)
                .contentShape(Rectangle())
                .padding(.bottom, 30)
            }.navigationBarBackButtonHidden(true)
            .background(Color(UIColor.systemGray6)) // Light gray background
            .navigationBarTitleDisplayMode(.inline).navigationBarHidden(true).edgesIgnoringSafeArea(.top)
        }
    
}

#Preview {
    UserVerifyView(navigation:nil)
}


