//
//  Webview.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 17/02/25.
//

import UIKit
import SwiftUI
import WebKit

struct Webview: UIViewRepresentable{
    
    let url:URL?
    let htmlText:String?
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if url != nil {
            let request = URLRequest(url: url!)
            
            webView.load(request)
        } else {
            webView.loadHTMLString(preparedHtml, baseURL: nil)
        }
    }
    
    private var preparedHtml: String {
            let metaTag = """
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0, user-scalable=yes">
            """
            if (htmlText ?? "").contains("<head>") {
                return htmlText?.replacingOccurrences(of: "<head>", with: "<head>\(metaTag)") ?? ""
            } else {
                return "<html><head>\(metaTag)</head><body>\(htmlText ?? "")</body></html>"
            }
        }
}



