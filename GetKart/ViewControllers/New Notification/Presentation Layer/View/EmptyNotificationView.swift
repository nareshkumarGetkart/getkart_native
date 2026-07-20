//
//  EmptyNotificationView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//

//
//  EmptyNotificationView.swift
//

import SwiftUI

struct EmptyNotificationView: View {

    var body: some View {

        VStack(spacing: 20) {

            Image(systemName: "bell.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)

            Text("No Notifications")
                .font(.title3)
                .fontWeight(.semibold)

            Text("You're all caught up.")
                .font(.subheadline)
                .foregroundColor(.gray)

        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
    }
}
