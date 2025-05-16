//
//  TakeFrontDocumentView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/04/25.
//

import SwiftUI

struct TakeFrontDocumentView: View {
    @State private var showCapturedImage = false
    @State private var capturedFrontImage: UIImage?
    var navigation:UINavigationController?
    var businessName:String?
    var capturedSelfieImage:UIImage?

  //  @State private var coordinator: CameraView.CameraCoordinator?

    var body: some View {
        
        // Top Navigation Bar
        HStack {
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    .padding()
            }
            Spacer()
        }.frame(height: 44)
        
        VStack {
            
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Submit the front of your ID Proof")
                        .font(.manrope(.bold, size: 18))
                    Spacer()
                    Text("Step 3 of 3")
                        .foregroundColor(.gray)
                }
                
                // Progress Bar
                ProgressView(value: 0.8)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
                
                Text("Secure verification, no data sharing")
                    .font(.manrope(.medium, size: 18))
                    .padding(.top,7)
           
            }.padding(.top,15)
            .padding(.horizontal, 20)
            
            Text("Take a clear photo of the front side of your ID. Only Aadhaar Card, Driving License, Voter ID, or Passport will be accepted")
                .font(.manrope(.regular, size: 14))
                .multilineTextAlignment(.leading)
                .padding()
                

            
            if let image = capturedFrontImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity) // allows it to stretch to full width
                    .frame(height: 350)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Spacer()
                HStack {
                    Button("Re-take") {
                        capturedFrontImage = nil
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .foregroundColor(.orange)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 1)
                    }
                    
                    Button("Next") {
                        // Navigate to next screen
                        var swidtUIView = TakeBackDocumentView(navigation:navigation)
                        swidtUIView.businessName = businessName
                        swidtUIView.frontImage = capturedFrontImage
                        swidtUIView.selfieImage = capturedSelfieImage
                        let hostVC = UIHostingController(rootView: swidtUIView)
                        self.navigation?.pushViewController(hostVC, animated: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    //.padding(.horizontal)
                }
                .padding()
                
            } else {
                ZStack {
                    CameraView(capturedImage: $capturedFrontImage, onImageCaptured: {
                        
                    }, isFrontCamera: false, cameraHeight: 350)
                    .frame(height: 350)
                    .cornerRadius(12)
                    VStack {
                        Spacer()
                        
                        Text("Place the front side of the ID Proof inside this box")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#FFB546"))
                            .foregroundColor(.white)
                            .font(.manrope(.regular, size: 14))
                            .clipShape(
                                RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight])
                            )
                    }
                }.frame(height: 350)
                 .padding(.horizontal)
                
                Spacer()
                
                Button("Capture") {
                 
                    NotificationCenter.default.post(name: .init("capturePhoto"), object: nil)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
            }

        }
        .navigationBarHidden(true)
        .background(Color(UIColor.systemGray6))
    }
}

#Preview {
    TakeFrontDocumentView()
}


/*
 
 struct IDCaptureStepView: View {
     var body: some View {
         VStack {
             Text("Submit the front of your ID Proof")
                 .font(.title2.bold())
                 .padding(.top)

             ProgressView(value: 3, total: 3)
                 .padding()

             Text("Secure verification, no data sharing")
                 .font(.subheadline)

             Image("aadhaar_sample") // Replace with actual camera or placeholder
                 .resizable()
                 .scaledToFit()
                 .frame(height: 220)
                 .cornerRadius(12)

             Text("Take a clear photo of the front side of your ID...")
                 .font(.caption)
                 .multilineTextAlignment(.center)
                 .padding()

             HStack {
                 Button("Re-take") {
                     // Logic
                 }
                 .buttonStyle(.bordered)

                 Button("Next") {
                     // Logic
                 }
                 .buttonStyle(.borderedProminent)
             }
             .padding()
         }
     }
 }

 import SwiftUI

 struct IdentityVerificationView: View {
     var body: some View {
         VStack(spacing: 30) {
             Text("Identity Verification")
                 .font(.title)
                 .bold()

             Text("Gain Instant Trust")
                 .font(.headline)

             Text("Follow these steps to complete your verification")
                 .font(.subheadline)
                 .multilineTextAlignment(.center)

             VStack(spacing: 20) {
                 VerificationOption(title: "Selfie Verification", subtitle: "Selfie Verification = Higher Trust & Response Rate")
                 VerificationOption(title: "ID Proof Verification", subtitle: "Double Verification = Double Trust & Response")
             }

             Spacer()

             Button(action: {}) {
                 Text("Start now")
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.orange)
                     .foregroundColor(.white)
                     .cornerRadius(10)
             }
             .padding()
         }
         .padding()
     }
 }

 struct VerificationOption: View {
     var title: String
     var subtitle: String

     var body: some View {
         VStack(alignment: .leading) {
             Text(title)
                 .font(.headline)
             Text(subtitle)
                 .font(.caption)
                 .foregroundColor(.gray)
         }
         .padding()
         .frame(maxWidth: .infinity, alignment: .leading)
         .background(Color(.systemGray6))
         .cornerRadius(12)
     }
 }

 struct TakeSelfieView: View {
     @State private var showNext = false
     var body: some View {
         VStack(spacing: 30) {
             Text("Take a Selfie")
                 .font(.title)
                 .bold()

             Text("Ensure your face is clear and visible")
                 .font(.subheadline)
                 .multilineTextAlignment(.center)

             VStack {
                 Image("selfie") // Replace with actual camera feed or captured image
                     .resizable()
                     .scaledToFit()
                     .frame(height: 300)
                     .cornerRadius(12)

                 Text("Look at the camera and smile!")
                     .padding(8)
                     .frame(maxWidth: .infinity)
                     .background(Color.orange.opacity(0.8))
                     .foregroundColor(.white)
                     .cornerRadius(10)
             }

             if showNext {
                 HStack(spacing: 20) {
                     Button("Re-take") {}
                         .frame(maxWidth: .infinity)
                         .padding()
                         .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange))

                     Button("Next") {}
                         .frame(maxWidth: .infinity)
                         .padding()
                         .background(Color.orange)
                         .foregroundColor(.white)
                         .cornerRadius(10)
                 }
             } else {
                 Button("Capture") {
                     showNext = true
                 }
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color.orange)
                 .foregroundColor(.white)
                 .cornerRadius(10)
             }

             Spacer()
         }
         .padding()
     }
 }

 struct SubmissionView: View {
     var body: some View {
         VStack(spacing: 30) {
             Spacer()
             Image(systemName: "checkmark.seal.fill")
                 .resizable()
                 .frame(width: 100, height: 100)
                 .foregroundColor(.orange)

             Text("Thank you!")
                 .font(.largeTitle)
                 .bold()

             Text("Your verification data has been submitted successfully. Expect verification within 24 hours")
                 .font(.body)
                 .multilineTextAlignment(.center)
                 .padding(.horizontal)

             Spacer()

             Button(action: {}) {
                 Text("Back to home")
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.orange)
                     .foregroundColor(.white)
                     .cornerRadius(10)
             }
             .padding()
         }
         .padding()
     }
 }

 struct ContentView: View {
     var body: some View {
         TabView {
             IdentityVerificationView()
             TakeSelfieView()
             SubmissionView()
         }
         .tabViewStyle(PageTabViewStyle())
     }
 }

 #Preview {
     ContentView()
 }

 */
