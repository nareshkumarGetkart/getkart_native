//
//  LoginRequiredView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/02/25.
//

import SwiftUI

struct LoginRequiredView: View {
    
    var loginCallback: () -> Void = {}

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            
            Spacer()
                VStack(alignment: .leading,spacing: 10){
                    HStack{
                        VStack(alignment: .leading,spacing: 5){
                            Text("Login is required to access").font(Font.manrope(.medium, size: 17)).foregroundColor(.black)
                            Text("Tap on login to authorize").font(Font.manrope(.regular, size: 14)).foregroundColor(.black).padding(.bottom,10)
                            
                            Button {
                                loginCallback()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Login now").font(Font.manrope(.medium, size: 16)).foregroundColor(.white)
                            }.frame(width:130, height: 40).background(.orange).cornerRadius(4)
                        }.padding()
                        Spacer()
                    }.padding(.top,10)
                }.background(Color.white).frame(height: 180)
                
             .background(.clear).onTapGesture {
                presentationMode.wrappedValue.dismiss()
            }
        }.ignoresSafeArea(.all).background(.clear).contentShape(Rectangle()).onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    LoginRequiredView()
}
