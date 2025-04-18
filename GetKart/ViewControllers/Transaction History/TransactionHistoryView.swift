//
//  TransactionHistoryView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI

struct TransactionHistoryView: View {
    
    var  navigation:UINavigationController?
   
    @State var transactions = [TransactionModel]()
        
    var body: some View {
        HStack {
         
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding()
            }
            Text("Transaction History").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            
            Spacer()
        }.frame(height: 44)
               
        
        
        VStack{
            
            ScrollView {
                HStack{ Spacer() }.frame(height: 5)
                VStack(spacing: 15) {
                    ForEach(transactions) { transaction in
                      
                        TransactionRow(transaction: transaction).background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                }
            }
            
            Spacer()
                        
        }.padding([.leading,.trailing],10).background(Color(.systemGray6)).onAppear{
            getTransactionHistory()
        }.navigationBarHidden(true)
        
    }
    
    func getTransactionHistory(){
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: Constant.shared.payment_transactions) { (obj:TransactionParse) in
            if obj.code == 200 {
                self.transactions = obj.data ?? []
            }
        }
    }
}

#Preview {
    TransactionHistoryView(navigation:nil)
}




struct TransactionHistoryCell:View {
    var body: some View {
        VStack{
            
        }
    }
}



struct TransactionRow: View {
    let transaction: TransactionModel
    
    var body: some View {
        HStack {
            
            
            AsyncImage(url: URL(string: "")) { img in
                
                img.resizable().aspectRatio(contentMode: .fit).frame(width:60,height: 60).cornerRadius(6)
            } placeholder: {
                Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit).frame(width:60,height: 60).cornerRadius(6)
            }

//            HStack{
//                
//            }.frame(width: 3,height: 40).background(Color.orange).cornerRadius(5)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("Banner Promotions")
                    .font(Font.manrope(.medium, size: 16))
                    .foregroundColor(.black)
                
                Text("Purchased from \(transaction.paymentGateway?.capitalized ?? "")" )
                    .font(Font.manrope(.regular, size: 16))
                    .foregroundColor(.black)

//                    .padding(5)
//                    .background(Color.orange.opacity(0.2))
//                    .cornerRadius(5)
                Button(action: {
                    UIPasteboard.general.string = transaction.orderID
                    AlertView.sharedManager.showToast(message: "Copied successfully")

                }) {
                    Text("Transaction ID").font(Font.manrope(.regular, size: 13)).foregroundColor(.gray)
                    Image("ic_baseline-content-copy").frame(width: 10, height: 10, alignment: .center)
                        .foregroundColor(.gray).padding(.leading,10)
                }
                
                Text(transaction.orderID ?? "")
                    .font(Font.manrope(.regular, size: 13))
                    .foregroundColor(.black)
            }.padding(5)
            Spacer()
            
           

            VStack(alignment: .trailing){
                
                Text("\(Local.shared.currencySymbol) \(transaction.amount ?? 0)")
                    .font(.headline)
                    .foregroundColor(.orange).padding(.trailing,10)
                
                Text(transaction.paymentStatus ?? "")
                    .foregroundColor(.gray).padding(.trailing,10)
                
                Text("17 sept 2023")
                    .foregroundColor(.gray).padding(.trailing,10)
                
                Text("11:00 AM")
                    .foregroundColor(.gray).padding(.trailing,10)
                
            }
        }
        .padding([.top,.bottom],10)
        .background(Color.white).cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        
    }
}
