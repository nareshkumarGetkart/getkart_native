//
//  PromotionPackagesView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/25.
//

import SwiftUI

struct PromotionPackagesView: View {
    
    var navigationController:UINavigationController?
    var packageSelectedPressed: ((_ selPkgObj:PlanModel)->Void)?
    @State private var planListArray:Array<PlanModel>?
    var body: some View {
        HStack{
            Text("Promotion Pakages").font(.manrope(.medium, size: 20))
            
            Spacer()
            Button {
                self.navigationController?.dismiss(animated: true)
            } label: {
                Image("Cross").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }
            
        }.frame(height:30).padding([.leading,.trailing,.top])
        
        VStack(spacing:15){
            
            Divider()

            Text("Want more product views? Banner Ads bring users straight to you.")
            ScrollView{
                VStack(alignment:.leading, spacing:10){
                    
                    
                    ForEach(planListArray ?? [], id: \.id) { pkgObj in
                           PromotionPackageCell(obj: pkgObj)
                               .onTapGesture {
                                   self.navigationController?.dismiss(animated: true)
                                   packageSelectedPressed?(pkgObj)
                               }
                       }
                   
                    Spacer()

                }
                
            }.onAppear() {
                getPackagesApi()
            }
        }.padding()
        
    }
    
    func getPackagesApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_campaign_package ) { (obj:PromotionPkg) in
            
            if obj.code == 200 {
                planListArray = obj.data
            }
        }
    }

}

#Preview {
    PromotionPackagesView()
}



struct PromotionPackageCell:View {
    
    let obj:PlanModel
    var body: some View {
        
        HStack{
            Text(obj.name ?? "").font(.manrope(.medium, size: 16)).padding(.leading)
            Spacer()
            if (obj.discountInPercentage ?? "0") != "0"{

                Text(" \(obj.discountInPercentage ?? "0")% Savings ").frame(height:20).font(.manrope(.medium, size: 13)).background(Color(.systemYellow))
                
                
                let originalPrice = "\(obj.price ?? "0")".formatNumberWithComma()

                Text("\(Local.shared.currencySymbol) \(originalPrice)")
                               .font(.subheadline)
                               .foregroundColor(.gray)
                               .strikethrough(true, color: .gray)
                
                let amt = "\(obj.finalPrice ?? "0")".formatNumberWithComma()
                Text("\(Local.shared.currencySymbol) \(amt)").font(.manrope(.regular, size: 16)).padding(.trailing)
            }else{
                let amt = "\(obj.price ?? "0")".formatNumberWithComma()
                Text("\(Local.shared.currencySymbol) \(amt)").font(.manrope(.regular, size: 16)).padding(.trailing)
            }
        
          
        }.frame(height:55).overlay{
            
            RoundedRectangle(cornerRadius: 8.0).stroke(Color.gray,lineWidth: 0.6)
        }.contentShape(Rectangle())

        
    }
}
