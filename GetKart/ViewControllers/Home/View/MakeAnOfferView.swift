//
//  MakeAnOfferView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/03/25.
//

import SwiftUI

struct MakeAnOfferView: View {
    @Binding var isPresented: Bool
    @State private var offer: String = ""

    let sellerPrice: String
    var onOfferSubmit: (String) -> Void  // Callback for offer submission

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                          .edgesIgnoringSafeArea(.all)
                          .onTapGesture {
                              withAnimation {
                                  isPresented = false
                              }
                          }
            
            // Popup Card
            VStack(spacing: 15) {
                Text("Make an offer")
                    .font(.headline)
                    .padding(.top)
                
                Divider()
                
                Text("Seller's Price \(Local.shared.currencySymbol) \(sellerPrice)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Your Offer", text: $offer) .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 45)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("Cancel").foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        withAnimation {
                            onOfferSubmit(offer) // Pass the offer back
                            isPresented = false
                        }
                    }) {
                        Text("Send")
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 10)
            }
            .padding()
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
            .transition(.scale)
            
        }.background(.clear).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
   // MakeAnOfferView(isPresented: .constant(true), sellerPrice: "") { str in
        
    //}
   // MakeAnOfferView(isPresented: .constant(true),off)
}






