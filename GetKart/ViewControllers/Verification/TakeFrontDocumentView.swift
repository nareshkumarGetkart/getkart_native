//
//  TakeFrontDocumentView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/04/25.
//

import SwiftUI

struct TakeFrontDocumentView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    TakeFrontDocumentView()
}


/*
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
