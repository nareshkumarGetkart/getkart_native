//
//  WalletInfoSheetView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/07/26.
//


import SwiftUI

struct WalletInfoSheetView: View {

    @Environment(\.dismiss) private var dismiss

    var points: [String] = []

    let termsClick:()->Void
    var isTerms:Bool = false
    var body: some View {

        VStack(spacing: 18) {

            // Drag Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 45, height: 5)
                .padding(.top,8)

            if isTerms{
                Text("Getkart Credits – Terms & Conditions")
                    .font(.inter(.medium,size: 17))
            }else{
                // Bulb Image
                Image("bulbIcon")
                    .font(.system(size: 48))
                    .foregroundStyle(.yellow)
                
                Text("How it works")
                    .font(.inter(.bold,size: 20))
            }

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 15) {

                    ForEach(points.indices, id: \.self) { index in

                        HStack(alignment: .top, spacing: 10) {

//                            if isTerms{
//                                
//                            }else{
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 8, height: 8)
                                    .padding(.top,8)
                                
                           // }
                            Text(points[index])
                                .font(.inter(.regular,size: 15))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal,10)
            }
            if isTerms{
                
            }else{
                Button {
                    
                    // Open Terms
                    termsClick()
                    
                } label: {
                    
                    Text("Terms & Conditions")
                        .font(.inter(.medium,size: 15))
                        .underline()
                       // .foregroundColor(.black)
                        .foregroundColor(Color(hex:"#192E73"))
                }
                .padding(.bottom,20)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
    
    func getThemeSelected() ->AppTheme{
        
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        return theme
    }
}

//#Preview {
//    WalletInfoSheetView()
//}
