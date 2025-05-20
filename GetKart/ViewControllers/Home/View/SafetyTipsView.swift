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
           // Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            VStack {
                
                
                Image("safety_tips")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.orange)
                    .padding(.top, 20)
                
                Text("Safety Tips")
                    .font(.title2)
                    .bold()
                    .padding(.top, 5)
                    .foregroundColor(Color(UIColor.label))
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    ForEach(listArray) { obj in
                        SafetyTipRow(obj.description ?? "")
                    }
                   
                }
                .padding([.horizontal,.bottom])
                
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
    
    
    

    func SafetyTipRow(_ text: String) -> some View {
        HStack {
            Image("active_mark")
            Text(text).font(.manrope(.medium, size: 16))
                .font(.body)
                .foregroundColor(Color(UIColor.label))
        }
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




