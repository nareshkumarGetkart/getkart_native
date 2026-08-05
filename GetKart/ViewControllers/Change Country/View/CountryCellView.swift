//
//  CountryCellView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/07/26.
//

import SwiftUI

struct CountryCellView: View {
    
    let obj: Countries
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {

        Button(action: onTap) {
            HStack {
                Text(obj.emoji ?? "").font(.inter(.medium,size: 30.0)).frame(width: 30, height: 30)
                Text(obj.name ?? "").font(.inter(.regular,size: 16.0))

                Spacer()

                Image(isSelected ? "radio_sel" : "radio_un")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
            .padding(.horizontal)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

//#Preview {
//    CountryCellView(obj: <#Countries#>)
//}
