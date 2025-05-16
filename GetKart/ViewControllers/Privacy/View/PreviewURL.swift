//
//  PreviewURL.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/05/25.
//

import SwiftUI



struct PreviewURL: View {
    @Environment(\.presentationMode) var presentationMode
    var fileURLString: String

    var body: some View {
        VStack(spacing: 0) {
            // Custom Back Button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left").foregroundColor(Color(UIColor.label))
                        Text("Back").foregroundColor(Color(UIColor.label))
                    }
                }
                .padding()
                Spacer()
            }
            .background(Color(UIColor.systemGray6))
            .foregroundColor(.blue)

            Divider()

            // WebView for Image or PDF
            if let url = URL(string: fileURLString) {
                WebView(url: url)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                Text("Invalid URL")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationBarHidden(true)
    }
}



#Preview {
    PreviewURL(fileURLString: "")
}



import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
