//
//  SellerBuyerPopup.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 06/07/26.
//

import SwiftUI

struct SellerBuyerPopup: View  {
    @Environment(\.presentationMode) var presentationMode

    //@Binding var isPresented: Bool
    @State var selectedMode: UserMode = .seller
    var isToShowCancelButton:Bool = true

    var submitAction: ((UserMode) -> Void)?

    var body: some View {

        ZStack {

            Color.black
                .opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 18) {

                HStack(spacing: 18) {

                   // ForEach(UserMode.allCases, id: \.self) { mode in
                ForEach(UserMode.allCases.filter { $0 != .none }, id: \.self) { mode in

                        ModeCard(
                            mode: mode,
                            isSelected: selectedMode == mode
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedMode = mode
                            }
                        }
                    }
                }

                Text(selectedMode.description)
                   // .font(.system(size: 17))
                    .font(.inter(.regular,size: 15))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                   // .padding(.horizontal)

                Button {

                    submitAction?(selectedMode)
                    presentationMode.wrappedValue.dismiss()

                } label: {

                    Text("Submit")
                        .font(.inter(.semiBold,size: 15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(
                            selectedMode == .none ? Color.gray.opacity(0.3) : Color.orange
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedMode == .none)

                if isToShowCancelButton{
                    Button {
                        
                        // isPresented = false
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        
                        Text("Cancel")
                            .font(.inter(.semiBold,size: 15))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(radius: 20)
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    SellerBuyerPopup()
}


struct ModeCard: View {

    let mode: UserMode
    let isSelected: Bool

    var body: some View {

        VStack(spacing: 12) {

            Image(mode.image)
                .resizable()
                .scaledToFit()
                .frame(width: 78, height: 78)

            VStack{
                Text(mode.title)
                    .font(.inter(.semiBold,size: 16))
                //.font(.title3.bold())
                
                Text(mode.subtitle)
                //.font(.subheadline)
                    .font(.inter(.regular,size: 14))
                    .foregroundStyle(.gray)
            }

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            Color.orange.opacity(isSelected ? 0.08 : 0.08)
        )
        .overlay {

            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected ? Color.orange : Color.clear,
                    lineWidth: 2
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

enum UserMode: String, CaseIterable {
    case seller
    case buyer
    case none

    var title: String {
        switch self {
        case .seller: return "Seller"
        case .buyer: return "Buyer"
        case .none:
            return ""
        }
    }

    var subtitle: String {
        switch self {
        case .seller:
            return "Sell and manage"
        case .buyer:
            return "Shop and discover"
        case .none:
            return ""
        }
    }

    var image: String {
        switch self {
        case .seller:
            return "seller"      // Replace with your asset
        case .buyer:
            return "buyer"      // Replace with your asset
        case .none:
            return ""
        }
    }

    var description: String {
        switch self {
        case .seller:
            return """
            Create boards, share ideas, promote products with videos, and reach more buyers. Switch between Buyer and Seller modes anytime.
            """
        case .buyer:
            return """
            Discover boards, explore products, watch promotional videos, and find great deals. Switch between Buyer and Seller modes anytime.
            """
        case .none:
            return """
            Choose the option that best describes how you use the platform.
            """
        }
    }
}
