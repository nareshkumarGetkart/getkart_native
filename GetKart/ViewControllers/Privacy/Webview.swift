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
    
    func makeUIView(context:Context) -> WKWebView{
        let wkWebview = WKWebView()
        wkWebview.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if (htmlText?.count ?? 0) > 0 {
 
           // wkWebview.loadHTMLString(htmlText ?? "", baseURL: nil)
        }else  if let urll = url {
            let request = URLRequest(url: urll)
            wkWebview.load(request)
        }
        return wkWebview
    }
    
    func updateUIView(_ uiView:WKWebView, context:Context){
        if (htmlText?.count ?? 0) > 0 {
            // Load the HTML String
            uiView.loadHTMLString(htmlText ?? "", baseURL: nil)

        }

        
    }
}



