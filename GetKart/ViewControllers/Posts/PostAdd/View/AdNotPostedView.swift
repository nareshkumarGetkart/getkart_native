//
//  AdNotPostedView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 07/05/25.
//

import SwiftUI

struct AdNotPostedView: View {
    var navigationController: UINavigationController?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    // back action
                    navigationController?.popToRootViewController(animated: true)
                }) {
                    Image(systemName: "chevron.left").renderingMode(.template).foregroundColor(.black)
                }
                Spacer()

            }
            .padding()
            
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.yellow)
                
                Text("Your Ad was not posted")
                    .font(.headline)
                    .padding(.bottom)
            }
            .padding(.top)
            
            Text("What to do next?")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
         
            
            Spacer()
            
            Button(action: {
                // Pay action
                
            }) {
                Text("Buy Plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}



#Preview {
    AdNotPostedView()
}


