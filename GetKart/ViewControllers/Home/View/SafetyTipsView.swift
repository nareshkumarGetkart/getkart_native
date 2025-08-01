//
//  SafetyTipsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 07/03/25.
//

import SwiftUI

struct SafetyTipsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var listArray = [TipsModel]()
    var onContinueOfferTap: (() -> Void)?

    var body: some View {
        
        ZStack {
            
            VStack {
                
                Image("safety_tips")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.orange)
                    .padding(.top, 50)
                
                Text("Safety Tips")
                    .font(.title2)
                    .bold()
                    .padding(.top, 5)
                    .foregroundColor(Color(UIColor.label)).padding(.bottom,30)
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    ForEach(listArray) { obj in
                        Divider()
                        SafetyTipRow(obj.description ?? "",icon: obj.icon ?? "")
                    }
                   
                }
                .padding([.horizontal,.bottom],20)
                
                
                Button("Continue to offer") {

                    presentationMode.wrappedValue.dismiss()
                    onContinueOfferTap?()

                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 20)
                

            } .edgesIgnoringSafeArea(.all)
                .background(Color(UIColor.systemBackground))
    
        }.onAppear{
            if listArray.count == 0{
                getSafetyTipsApi()
            }
        }
        
        .onDisappear {
        }
    }
    
    
    
    func SafetyTipRow(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            AsyncImage(url: URL(string: icon)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            } placeholder: {
                Image("caution")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }

            Text(text)
                .font(.manrope(.medium, size: 16))
                .foregroundColor(Color(UIColor.label))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true) // 👈 This is key!
        }
        .frame(maxWidth: .infinity, alignment: .leading) // 👈 Makes row expand properly
    }

    
    
    func getSafetyTipsApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.tips) { (obj:SafetyTipsParse) in
            
            if obj.data != nil {
                self.listArray = obj.data ?? []
            }
            
        }
    }
}

#Preview {
    SafetyTipsView()
}




