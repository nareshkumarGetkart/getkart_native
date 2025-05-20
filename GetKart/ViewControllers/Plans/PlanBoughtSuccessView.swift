//
//  PlanBoughtSuccessView.swift
//  GetKart
//
//  Created by gurmukh singh on 4/29/25.
//

import SwiftUI



struct PlanBoughtSuccessView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var navigationController: UINavigationController?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image("boughtSuccess") // Replace with actual asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90).padding(.top,20)
                
                Text("Thankyou").font(Font.manrope(.semiBold, size: 16))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.label))
                Text("Your transaction was successful!").font(Font.manrope(.regular, size: 16)).foregroundColor(Color(UIColor.label))
                
                HStack {
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        self.navigationController?.popToRootViewController(animated: true)
                       
                    }) {
                        Text("OK").font(Font.manrope(.regular, size: 16)).foregroundColor(.white).padding()
                            .frame(maxWidth: .infinity,idealHeight:40,maxHeight:40)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }.padding(.bottom,10)
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 30)
        }
    }
    
}

#Preview {
    PlanBoughtSuccessView()
}
