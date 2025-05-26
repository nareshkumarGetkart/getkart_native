//
//  SortSheetView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/04/25.
//

import SwiftUI

struct SortSheetView: View {
    @Binding var isPresented: Bool
    @Binding var selectedSort: String
    let onSortSelected: (String) -> Void

    let sortOptions = [
        "Default",
        "New to Old",
        "Old to New",
        "Price High to Low",
        "Price Low to High"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)

            Text("Sort by")
                .font(.headline)
                .padding()

            ForEach(sortOptions, id: \.self) { option in
                Button(action: {
                    selectedSort = option
                    onSortSelected(option)
                    isPresented = false
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedSort == option {
                            Image(systemName: "checkmark").foregroundColor(Color(Themes.sharedInstance.themeColor))
                        }
                    }
                    .padding()
                }
                Divider()
            }
        }
        .padding(.bottom, 20)
    }
}

//#Preview {
//    SortSheetView(isPresented: <#Binding<Bool>#>, selectedSort: <#Binding<String>#>, onSortSelected: <#(String) -> Void#>)
//}
