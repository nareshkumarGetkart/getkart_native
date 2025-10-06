//
//  SellerVeriedSheetView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 29/09/25.
//

import SwiftUI

struct SellerVeriedSheetView: View {
    
 //   var callbackAction: () -> Void

    var body: some View {
        VStack(spacing: 10){
            HStack{ Spacer()}.frame(height: 5)
            Spacer()
            Text("Verified Seller").font(.title)
            VStack(alignment: .leading){
                HStack{
                    
                    Image("verifiedIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 40,height: 40)
                    Text("In order to confirm genuine sellers on Getkart, we have received and verified this seller's identity proof.").font(Font.manrope(.medium, size: 16))
                    
                }
                
                Text("Go on and complete your transaction securely.").font(Font.manrope(.regular, size: 14)).foregroundColor(.gray).padding(.leading,45)
                
            }.padding(5)
            
            Spacer()
        }
    }
}

#Preview {
    SellerVeriedSheetView()
}
