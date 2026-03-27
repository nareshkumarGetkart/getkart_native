//
//  CategoryPopupView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/12/25.
//

import SwiftUI

struct CallToActionPopupView: View {
   
    @Binding var isPresented: Bool
    @Binding var selectedCategory: String?
    @Binding var selectedCategoryId: Int?
    @State private var listArray:Array<CallToActionModel> = []
    
    var type = 0 //type : // 0=product,1=business,2=ideas
    

    var body: some View {
       
        ZStack {
            if isPresented {
                // Dim background
                Color(.systemGray5).opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                
                
                // Popup container
                VStack {
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(listArray, id: \.value) { ctaObj in
                                Button {
                                    selectedCategory = ctaObj.label ?? ""
                                    selectedCategoryId = ctaObj.value ?? 0
                                    isPresented = false
                                } label: {
                                    HStack(spacing: 14) {
                                        Circle()
                                            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 2)
                                            .background(
                                                Circle()
                                                    .fill(
                                                        selectedCategory == ctaObj.label
                                                        ? Color.orange
                                                        : Color.clear
                                                    )
                                                    .padding(4)
                                            )
                                            .frame(width: 22, height: 22)
                                        
                                        Text(ctaObj.label ?? "")
                                            .font(.manrope(.semiBold, size: 16))
                                            .foregroundColor(Color(.label))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 9)
                                }
                            }
                        }.padding([.bottom,.top],15)
                    }
                }
                .frame( maxHeight: 350)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous)) // KEY FIX
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.gray, lineWidth: 0.2)   //  Border color here
                )
                .shadow(color: Color.black.opacity(0.15), radius: 20)
                .scaleEffect(isPresented ? 1 : 0.9)   //  popup animation
                .opacity(isPresented ? 1 : 0)
                .padding(.horizontal, 25)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
        .onAppear{
            getCallToActionApi()
        }
    }
    
    
    func getCallToActionApi(){
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_cta_options + "?type=\(type)") { (obj:CallToActionModelData) in
            
            if obj.code == 200{
                self.listArray = obj.data ?? []
            }
        }
    }
}






import Foundation

// MARK: - Data Model
struct CallToActionModelData: Codable {
    let code: Int?
    let data: [CallToActionModel]?
    let message: String?
}

// MARK: - CallToActionModel
struct CallToActionModel: Codable {
    let label: String?
    let value: Int?
}



