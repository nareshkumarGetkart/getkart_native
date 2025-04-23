//
//  UserVerifyStep2.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import SwiftUI

struct UserVerifyStep2: View{
    
    var navigation:UINavigationController?
    var businessName:String?

    var body: some View {
        
        // Top Navigation Bar
        HStack {
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding()
            }
            Spacer()
        }.frame(height: 44)
       
        
        Spacer()
        VStack(spacing: 30) {
            
            // Title with Progress Indicator
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Identity Verification")
                        .font(.manrope(.bold, size: 18))
                    Spacer()
                    Text("Step 2 of 3")
                        .foregroundColor(.gray)
                }
                
                // Progress Bar
                ProgressView(value: 0.4)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
            }.padding(.top,15)
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading){
                //  HStack{
                
                Text("Gain Instant Trust")
                    .font(.manrope(.medium, size: 22))
                    .multilineTextAlignment(.leading)
                
                //                    Spacer()
                //                }
                //
                Text("Follow these steps to complete your verification")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }

            VStack(spacing: 20) {
                VerificationOption(title: "Selfie Verification", subtitle: "Selfie Verification = Higher Trust & Response Rate", iconImg: "selfieVeriSymbol")
                VerificationOption(title: "ID Proof Verification", subtitle: "Double Verification = Double Trust & Response", iconImg: "docVerifySymbol")
            }.padding(.horizontal)

            Spacer()

            Button(action: {
                // Continue action
                
                var swidtUIView = TakeSelfieView(navigation:navigation)
                swidtUIView.businessName = businessName
                let hostVC = UIHostingController(rootView: swidtUIView)

                self.navigation?.pushViewController(hostVC, animated: true)
            }) {
                Text("Start now")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }    .background(Color(.systemGray6))
            .navigationBarHidden(true)

           // .padding()
    }
}

#Preview {
    UserVerifyStep2(navigation:nil)
}

struct VerificationOption: View {
    var title: String
    var subtitle: String
    var iconImg:String

    var body: some View {
        VStack(alignment: .center) {
            HStack{
                Spacer()
                Image(iconImg)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.white))
        .cornerRadius(12)
    }
}


/*
{
    
    
    
    @State private var businessName: String = ""
    @State private var selectedFile: String? = nil
    var navigation:UINavigationController?

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
                    Text("User Verification")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Text("Step 2 of 2")
                        .foregroundColor(.gray)
                }

                // Progress Bar
                ProgressView(value: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
            }.padding(.top,30)
            .padding(.horizontal, 20)

            // ID Verification Section
            VStack(alignment: .leading, spacing: 5) {
                Text("ID Verification")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Select a documents type below to confirm your identity")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // Business Name Field
            VStack(alignment: .leading, spacing: 5) {
                Text("Business Name")
                    .font(.body)
                    .foregroundColor(.black)

                TextField("", text: $businessName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                HStack {
                    Spacer()
                    Text("\(businessName.count)/50")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)

            // File Upload Section
            VStack(alignment: .leading, spacing: 5) {
                Text("Valid Government-Issued ID")
                    .font(.body)
                    .foregroundColor(.black)

                Button(action: {
                    // File Upload Action
                }) {
                    VStack {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Text("Add File")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5])))
                }

                Text("Allowed file types: PNG, JPG, JPEG, SVG, PDF")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            // Continue Button
            Button(action: {
                // Continue action
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
             //   navigation?.popToViewController(ofClass: UIHostingController<UserVerifyView>.self)
 
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
        }
        .background(Color(UIColor.systemGray6)) // Light gray background
        .navigationBarTitleDisplayMode(.inline).navigationBarHidden(true).edgesIgnoringSafeArea(.top)
    }
}
*/




extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}
