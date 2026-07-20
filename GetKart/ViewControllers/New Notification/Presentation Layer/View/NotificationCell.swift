//
//  NotificationCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/07/26.
//


//
//  NotificationCell.swift
//

import SwiftUI
import Kingfisher

struct NotificationCell: View {

    let notification: NotificationModel

    var body: some View {

        HStack(alignment: .top, spacing: 12) {

            // Profile Image
            KFImage(URL(string: notification.image ?? ""))
                .placeholder {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray.opacity(0.5))
                }
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {

                Text(notification.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(notification.message ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)

                Text(formattedDate(notification.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)

            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
    }

    private func formattedDate(_ value: String?) -> String {

        guard let value else { return "" }

        let formatter = ISO8601DateFormatter()

        guard let date = formatter.date(from: value) else {

            return value
        }

        let output = DateFormatter()
        output.dateFormat = "dd MMM yyyy • hh:mm a"

        return output.string(from: date)
    }
}
