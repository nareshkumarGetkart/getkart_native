//
//  SuccessVerifyStepView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/04/25.
//

import SwiftUI

struct SuccessVerifyStepView: View {
    var navigation:UINavigationController?

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image("verification_success")
                .resizable()
                .scaledToFit()
                .frame(height: 210)
            

            Text("Thank you!")
                .font(.largeTitle)
                .bold()

            Text("Your verification data has been submitted successfully. Expect verification within 24 hours")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: {
                
                navigation?.popToRootViewController(animated: true)
            }) {
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
        .navigationBarHidden(true)
        .background(Color(UIColor.white))
    }
}


#Preview {
    SuccessVerifyStepView()
}
