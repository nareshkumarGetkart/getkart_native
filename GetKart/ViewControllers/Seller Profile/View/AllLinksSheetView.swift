//
//  AllLinksSheetView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 21/08/26.
//

import SwiftUI

struct AllLinksSheetView: View {

    let links: [String]

    var body: some View {

        VStack(spacing: 0) {

            // Header
            Text("Links")
                .font(.inter(.medium,size:18))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)

            Divider()

            ScrollView {

                LazyVStack(spacing: 0) {

                    ForEach(Array(links.enumerated()), id: \.offset) { index, link in

                        Button {
                            openURL(link)
                        } label: {

                            HStack(spacing: 16) {

                                // Link icon
                                Image(systemName: "link")
                                    .font(.inter(.medium,size:15))
                                    .foregroundColor(.primary)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 1)
                                    )

                                // URL
                                Text(link)
                                    .font(.inter(.regular,size:17))
                                    .foregroundColor(.primary)
                                    .underline()
                                    .lineLimit(1)
                                    .truncationMode(.middle)

                                Spacer()
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < links.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }

    private func openURL(_ string: String) {

        var urlString = string

        if !string.lowercased().hasPrefix("http://") &&
           !string.lowercased().hasPrefix("https://") {

            urlString = "https://\(string)"
        }

        guard let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.open(url)
    }
}
