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

    @StateObject private var objViewModel = CategoryViewModel(type: 2)

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
                            ForEach(objViewModel.listArray ?? [], id: \.id) { category in
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
                                                    .fill(
                                                        selectedCategory == category.name
                                                        ? Color.orange
                                                        : Color.clear
                                                    )
                                                    .padding(4)
                                            )
                                            .frame(width: 22, height: 22)

                                        Text(category.name ?? "")
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
                .frame(maxHeight: 600)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous)) //  KEY FIX
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.gray, lineWidth: 0.2)   // Border color here
                )
                .shadow(color: Color.black.opacity(0.15), radius: 20)
                .scaleEffect(isPresented ? 1 : 0.9)   // 👈 popup animation
                .opacity(isPresented ? 1 : 0)
                .padding(.horizontal, 25)
                
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

/*struct CategoryPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedCategory: String?
    @Binding var selectedCategoryId: Int?
    @StateObject private var objViewModel:CategoryViewModel = CategoryViewModel(type: 2)

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
        .cornerRadius(14)

    }
}
*/


