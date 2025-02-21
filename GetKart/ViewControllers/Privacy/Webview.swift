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
    
    func makeUIView(context:Context) -> WKWebView{
        let wkWebview = WKWebView()
        
        if let urll = url {
            let request = URLRequest(url: urll)
            wkWebview.load(request)
        }
        return wkWebview
    }
    
    func updateUIView(_ uiView:WKWebView, context:Context){
        
    }
}
