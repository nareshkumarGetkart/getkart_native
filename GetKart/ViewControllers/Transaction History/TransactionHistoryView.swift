//
//  TransactionHistoryView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI

struct TransactionHistoryView: View {
    
    var  navigation:UINavigationController?
    let transactions: [TransactionModel] = [
        TransactionModel(platform: "google", transactionId: "GPA.3335-8423-5985-68820", amount: "₹249.0"),
        TransactionModel(platform: "google", transactionId: "GPA.3386-8591-5918-25179", amount: "₹149.0"),
        TransactionModel(platform: "google", transactionId: "GPA.3379-7910-0293-40790", amount: "₹49.0"),
        TransactionModel(platform: "google", transactionId: "GPA.3334-0395-6145-36064", amount: "₹199.0"),
        TransactionModel(platform: "google", transactionId: "GPA.3334-0395-6145-36064", amount: "₹199.0")]
        
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
                HStack{  }.frame(height: 5)
                VStack(spacing: 15) {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction).background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                }
            }
                        
        }.padding([.leading,.trailing],10).background(Color(.systemGray6))
        
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
            
            HStack{
                
            }.frame(width: 3,height: 40).background(Color.orange).cornerRadius(5)
            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.platform.capitalized)
                    .font(.caption)
                    .padding(5)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(5)
                Text(transaction.transactionId)
                    .font(.body)
                    .foregroundColor(.black)
            }.padding(5)
            Spacer()
            
            Button(action: {
                UIPasteboard.general.string = transaction.transactionId
            }) {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.gray)
            }
            
            Text(transaction.amount)
                .font(.headline)
                .foregroundColor(.orange).padding(.trailing,5)
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
