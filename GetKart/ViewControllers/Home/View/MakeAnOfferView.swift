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

    let sellerPrice: Double
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
                
                Text("Seller's Price \(Local.shared.currencySymbol) \((sellerPrice ?? 0.0).formatNumber())")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Your Offer", text: $offer) .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 45)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)
                    .onChange(of: offer) { newValue in
                        // Remove leading zeros unless the whole string is "0"
                        if newValue.hasPrefix("0") && newValue != "0" {
                            offer = String(newValue.drop(while: { $0 == "0" }))
                        }
                    }

                
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
                            if offer.trim().count > 0 &&  offer != "0" {
                                
                                if let value = Double(offer.trim()),value > 0{
                                    
                                    if value > sellerPrice{
                                        UIApplication.shared.endEditing()
                                        AlertView.sharedManager.showToast(message: "Offer price is more than seller price")
                                    }else{
                                        onOfferSubmit(offer) // Pass the offer back
                                        isPresented = false
                                    }
                                }
                            }else{
                                UIApplication.shared.endEditing()
                                AlertView.sharedManager.showToast(message: "Please enter offer price")
                            }
                       
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






