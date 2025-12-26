//
//  CategoryPopupView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/12/25.
//

import SwiftUI

struct CategoryPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedCategory: String?
    @Binding var selectedCategoryId: Int?


    @StateObject private var objViewModel:CategoryViewModel = CategoryViewModel(type: 2)

//    let categories: [CategoryModelNew] = [
//        CategoryModelNew(title: "Electronics"),
//        CategoryModelNew(title: "Mobiles & Accessories"),
//        CategoryModelNew(title: "Computers & Laptops"),
//        CategoryModelNew(title: "Home Appliances"),
//        CategoryModelNew(title: "Fashion (Men & Women)"),
//        CategoryModelNew(title: "Footwear"),
//        CategoryModelNew(title: "Beauty & Personal Care"),
//        CategoryModelNew(title: "Health & Wellness")
//    ]

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }
                ScrollView{
                    Spacer()

                VStack(spacing: 0) {
                    ForEach(objViewModel.listArray ?? [] , id:\.id) { category in
                        Button {
                            selectedCategory = category.name ?? ""
                            selectedCategoryId = category.id
                            isPresented = false
                        } label: {
                            HStack(spacing: 14) {
                                Circle()
                                    .strokeBorder(Color.gray.opacity(0.5), lineWidth: 2)
                                    .background(
                                        Circle()
                                            .fill(selectedCategory == (category.name ?? "") ? Color.orange : Color.clear)
                                            .padding(4)
                                    )
                                    .frame(width: 22, height: 22)
                                
                                Text(category.name ?? "")
                                    .font(.manrope(.semiBold, size: 16.0))
                                    .foregroundColor(Color(.label))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                    
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .padding(.horizontal, 24)
                .shadow(color: Color.black.opacity(0.15), radius: 20)
                    Spacer()
                }.frame(minHeight:300, maxHeight:600)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}



//struct CategoryModelNew: Identifiable {
//    let id = UUID()
//    let title: String
//}


