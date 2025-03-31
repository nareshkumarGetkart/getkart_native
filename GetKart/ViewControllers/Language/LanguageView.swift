//
//  LanguageView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/02/25.
//

import SwiftUI


struct LanguageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        HStack{
            
            Button {
                
                presentationMode.wrappedValue.dismiss()
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text("Choose Language").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background(Color.white).navigationBarHidden(true)
        Spacer()
        VStack(alignment:.leading){
            
            HStack{
                Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit).frame(width: 60,height: 60).cornerRadius(30)
                Text("English").font(Font.manrope(.medium, size: 16)).foregroundColor(.white)
                Spacer()
            }.background(Color.orange).cornerRadius(8.0)
            
            Spacer()

        }.padding().background(Color(.systemGray6))
    }
}


#Preview {
    LanguageView()
}
