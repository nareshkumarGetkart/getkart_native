//
//  CustomImageView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 07/03/25.
//

import SwiftUI
import SVGKit

struct SVGImageView: UIViewRepresentable {
    let url: URL?
    let placeholder: UIImage?

    init(url: URL?, placeholder: UIImage? = UIImage(named: "getkartplaceholder")) {
        self.url = url
        self.placeholder = placeholder
    }

    func makeUIView(context: Context) -> SVGKFastImageView {
        let emptyImage = SVGKImage()
        let imageView = SVGKFastImageView(svgkImage: emptyImage)
        imageView?.contentMode = .scaleAspectFit
        imageView?.backgroundColor = .clear
        return imageView!
    }

    func updateUIView(_ imageView: SVGKFastImageView, context: Context) {
        guard let url = url else {
            print("⚠️ Invalid URL")
            return
        }

        // Load SVG with URLSession
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ SVG download failed: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let svgImage = SVGKImage(data: data) else {
                print("❌ Failed to create SVGKImage from data")
                return
            }

            svgImage.scaleToFit(inside: CGSize(width: 30, height: 30))

            DispatchQueue.main.async {
                imageView.image = svgImage
                imageView.contentMode = .scaleAspectFit
                imageView.setNeedsLayout()
                imageView.setNeedsDisplay()
                print("✅ SVG loaded successfully: \(url)")
            }
        }.resume()
    }
}



import SwiftUI
import WebKit

struct RemoteSVGWebView: UIViewRepresentable {
    let svgURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body, html {
                    margin: 0;
                    padding: 0;
                    background: transparent;
                }
                img {
                    width: 100%;
                    height: auto;
                    display: block;
                }
            </style>
        </head>
        <body>
            <img src="\(svgURL.absoluteString)" alt="SVG Image" />
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}

