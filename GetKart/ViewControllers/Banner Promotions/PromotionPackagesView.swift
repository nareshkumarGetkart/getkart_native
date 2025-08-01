//
//  PromotionPackagesView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/25.
//

import SwiftUI

struct PromotionPackagesView: View {
    
    var navigationController:UINavigationController?
    var packageSelectedPressed: (()->Void)?

    var body: some View {
        HStack{
            Text("Promotion Pakages").font(.manrope(.medium, size: 20))
            
            Spacer()
            Button {
                self.navigationController?.dismiss(animated: true)
            } label: {
                Image("Cross").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }
            
        }.frame(height:44).padding([.leading,.trailing,.top])
        
        VStack(spacing:15){
            
            Divider()

            Text("Want more product views? Banner Ads bring users straight to you.")
            ScrollView{
                VStack(alignment:.leading, spacing:10){
                    PromotionPackageCell().onTapGesture {
                        self.navigationController?.dismiss(animated: true)
                        packageSelectedPressed?()
                    }
                    PromotionPackageCell().onTapGesture {
                        self.navigationController?.dismiss(animated: true)
                        packageSelectedPressed?()                }
                    
                    PromotionPackageCell().onTapGesture {
                        self.navigationController?.dismiss(animated: true)
                        packageSelectedPressed?()                }
                    
                    PromotionPackageCell()
                        .onTapGesture {
                            self.navigationController?.dismiss(animated: true)
                            packageSelectedPressed?()
                        }
                    Spacer()

                }
                
            }
        }.padding()
        
    }
}

#Preview {
    PromotionPackagesView()
}



struct PromotionPackageCell:View {
    
    var body: some View {
        
        HStack{
            Text("100 Clicks").font(.manrope(.medium, size: 16)).padding(.leading)
            Spacer()
            Text("2% Savings").font(.manrope(.medium, size: 10)).background(Color(.systemYellow))
            Text("\(Local.shared.currencySymbol) 17,500").font(.manrope(.regular, size: 16)).padding(.trailing)
        }.frame(height:55).overlay{
            
            RoundedRectangle(cornerRadius: 8.0).stroke(Color.gray,lineWidth: 0.6)
        }.contentShape(Rectangle())

        
    }
}
