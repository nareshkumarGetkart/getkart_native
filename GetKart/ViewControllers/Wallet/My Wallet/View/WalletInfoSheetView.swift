//
//  WalletInfoSheetView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/07/26.
//


import SwiftUI

struct WalletInfoSheetView: View {

    @Environment(\.dismiss) private var dismiss

    let points: [String] = [
        "Getkart Cash is a wallet service offered by the Company to its customers, which can be used for boost your Products.",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text.",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
    ]

    var body: some View {

        VStack(spacing: 18) {

            // Drag Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 45, height: 5)
                .padding(.top,8)

            // Bulb Image
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("How it works")
                .font(.inter(.bold,size: 18))

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 18) {

                    ForEach(points.indices, id: \.self) { index in

                        HStack(alignment: .top, spacing: 10) {

                            Circle()
                                .fill(Color.gray)
                                .frame(width: 8, height: 8)
                                .padding(.top,8)

                            Text(points[index])
                                .font(.inter(.regular,size: 16))                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Button {

                // Open Terms

            } label: {

                Text("Terms & Conditions")
                    .font(.inter(.semiBold,size: 15))
                    .underline()
                    .foregroundColor(.black)
            }
            .padding(.bottom,20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
    }
}

#Preview {
    WalletInfoSheetView()
}
