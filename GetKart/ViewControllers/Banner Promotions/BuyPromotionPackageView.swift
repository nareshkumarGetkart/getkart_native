//
//  BuyPromotionPackageView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/25.
//

import SwiftUI

struct BuyPromotionPackageView: View {
    
    var navigationController:UINavigationController?
    
    var buyButtonPressed: (()->Void)?
    
    var body: some View {
        HStack{
            Spacer()
            
            Text("Let's Get You More Views & Sales").font(.manrope(.medium, size: 18))
            
            Spacer()
            Button {
                self.navigationController?.dismiss(animated: true)
            } label: {
                Image("Cross").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }
        }.frame(height:44).padding([.leading,.trailing,.top])
        
        VStack{
            Text("You've selected the 100 Clicks Plan").font(.manrope(.regular, size: 14.0))
            Spacer()

            Button {
                self.navigationController?.dismiss(animated: true)
                buyButtonPressed?()
            } label: {
                Text("Pay ₹ 2,500").foregroundColor(.white)
            }.frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                .background(
                    RoundedRectangle(cornerRadius: 8.0).fill(Color(hexString: "#FF9900"))
                )
                .padding([.leading,.trailing])
        }
    }
}

#Preview {
    BuyPromotionPackageView( buyButtonPressed: {})
}
