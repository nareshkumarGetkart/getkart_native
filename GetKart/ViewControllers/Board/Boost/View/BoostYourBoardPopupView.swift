//
//  BoostYourBoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/01/26.
//

import SwiftUI
import Kingfisher

struct BoostYourBoardPopupView: View {

    var onBoost: () -> Void
    var onLater: () -> Void
    var onClose: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var objPopup: PopupModel = PopupModel(
        userID: 0,
        title: "",
        subtitle: "",
        description: "",
        image: "",
        mandatoryClick: true,
        buttonTitle: "",
        type: 0,
        itemID: 0,
        secondButtonTitle: ""
    )

    var body: some View {

        ZStack {

            // 🔴 Background Dim
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {

                // 🔹 Image + Close Overlay
                ZStack(alignment: .topTrailing) {

                    KFImage(URL(string: objPopup.image ?? ""))
                        .placeholder {
                            Image("getkartplaceholder")
                                .resizable()
                                .scaledToFit()
                        }
                        .resizable()
                        .scaledToFit()               // ✅ Full image visible
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16, corners: [.topLeft, .topRight])

                    Button {
                        onClose()
                        presentationMode.wrappedValue.dismiss()

                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(.black))
                            .padding(5)
//                            .background(Color.black.opacity(0.8))
//                            .clipShape(Circle())
                    }
                    .padding(5)
                }

                // 🔹 Buttons
                HStack(spacing: 12) {

                    Button {
                        onBoost()
                        presentationMode.wrappedValue.dismiss()

                    } label: {
                        Text(objPopup.buttonTitle ?? "Okay")
                            .font(Font.inter(.semiBold, size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.orange)
                            .cornerRadius(7)
                    }

                    if (objPopup.secondButtonTitle ?? "").count > 0 {
                        Button {
                            onLater()
                            presentationMode.wrappedValue.dismiss()

                        } label: {
                            Text(objPopup.secondButtonTitle ?? "Maybe Later")
                                .font(Font.inter(.medium, size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(Color.gray.opacity(0.4))
                                )
                        }
                    }
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .shadow(radius: 20)
        }
    }
}


#Preview {
    BoostYourBoardPopupView(onBoost: {}, onLater: {}, onClose: {})
}



/*
ZStack(alignment: .topTrailing) {

    KFImage(URL(string: objPopup.image ?? ""))
        .placeholder {
            Image("getkartplaceholder")
                .resizable()
                .scaledToFill()
        }
        .resizable()
        .scaledToFill()
        .frame(height: 100)
        .clipped()

    Button {
        onClose()
    } label: {
        Image(systemName: "xmark")
            .foregroundColor(.white)
            .padding(8)
            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
    }
    .padding(8)
}
.padding(.horizontal)
.padding(.top, 10)
*/
