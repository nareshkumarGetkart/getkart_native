//
//  ReportAdsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 07/03/25.
//

import SwiftUI

struct ReportAdsView: View {
   
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedReason: String? = nil

    let reportReasons = [
        "Item Not as Described",
        "Misleading Description",
        "Incomplete Information",
        "Poor Quality Images",
        "Pricing Discrepancies",
        "Unresponsive Seller",
        "Fake Items",
        "Other"
    ]

    var body: some View {
        
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Report item")
                    .font(.title2)
                    .bold()
                    .padding([.top, .bottom], 10)
                
                ForEach(reportReasons, id: \.self) { reason in
                    Button(action: {
                        selectedReason = reason
                    }) {
                        Text(reason)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedReason == reason ? Color.orange.opacity(0.2) : Color(UIColor.systemGray6))
                            .foregroundColor(selectedReason == reason ? .orange : .black)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedReason == reason ? Color.orange : Color.clear, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }.font(.manrope(.semiBold, size: 15)).foregroundColor(.black)
                        .frame(maxWidth: .infinity,minHeight: 40,maxHeight: 40)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(20).padding(5)
                    
                    Button("Ok") {
                        // Handle report submission
                        presentationMode.wrappedValue.dismiss()
                    }.font(.manrope(.semiBold, size: 15))
                    .frame(maxWidth: .infinity,minHeight: 40,maxHeight:40)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(5)
                }.padding(.vertical)
                .padding(.horizontal)
                .padding(.bottom, 1)
            } .edgesIgnoringSafeArea(.all)
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
        }
    }
}


#Preview {
    ReportAdsView()
}



