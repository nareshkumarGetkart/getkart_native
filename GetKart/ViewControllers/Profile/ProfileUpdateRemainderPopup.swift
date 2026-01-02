//
//  ProfileUpdateRemainderPopup.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/12/25.
//

import SwiftUI

struct ProfileUpdateRemainderPopup: View {
    
    var onClose: () -> Void
    var onCompleteProfile: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Dim background
            Color(.label).opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                // Close button
                HStack {
                    Spacer()
                    
                    Button {
                        onClose()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(.label))
                            .padding(1)
                    }

                }

                // Avatar + alert badge
                ZStack(alignment: .bottomTrailing) {
                    Image("remainderProfile") // replace with your asset
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    
                    Circle()
                        .fill(Color(.white))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "exclamationmark")
                                .foregroundColor(.red)
                                .font(.system(size: 15, weight: .bold))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.red, lineWidth: 3) // optional white border
                        )
                        .offset(x: -5, y: 1)
                    
                }

                // Title
                Text("Update your profile to build\ntrust and sell faster.")
                    .font(.system(size: 18, weight: .bold)).foregroundColor(Color(.label))
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("Verified profiles get more views and faster deals.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                // CTA button
                
                Button {
                    onCompleteProfile()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Complete Profile")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                }

                // Remind later
                Button {
                    onClose()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Remind me later")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.label))
                }
            }
            .padding(15)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    ProfileUpdateRemainderPopup(onClose: {}, onCompleteProfile: {})
}




struct ProfilePopupManager {

    private static let lastShownKey = "ProfilePopupLastShown"

    static func shouldShowPopup() -> Bool {
        guard let lastShown = UserDefaults.standard.object(forKey: lastShownKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastShown) >= 24 * 60 * 60
    }

    static func markAsShown() {
        UserDefaults.standard.set(Date(), forKey: lastShownKey)
    }
}
