//
//  PreviewURL.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/05/25.
//

import SwiftUI
import SafariServices



struct PreviewURL: View {
    @Environment(\.presentationMode) var presentationMode
    var fileURLString: String
    @State private var isLoading = true   // 👈 ADD
    var isCopyUrl:Bool = false   // 👈 ADD
    @State private var showShareSheet:Bool = false
    
    var body: some View {
        VStack(alignment:.leading ,spacing: 0) {
            // Custom Back Button
            HStack(spacing:0) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label)).frame(width: 40, height: 40)
                    
                }
                
                if isCopyUrl{
                    Text(fileURLString).padding(5).multilineTextAlignment(.leading)
                        .font(.inter(.regular, size: 14)).lineLimit(1)
                        .foregroundColor(Color(.label))
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        .padding()
                  
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        Image("Share-outline").renderingMode(.template)
                            .foregroundColor(Color(UIColor.label)).frame(width: 40, height: 40)
                    }
                    .actionSheet(isPresented: $showShareSheet) {
                        ActionSheet(
                            title: Text(""),
                            message: nil,
                            buttons: [
                                .default(Text("Copy Link"), action: {
                                    UIPasteboard.general.string = fileURLString
                                    AlertView.sharedManager.showToast(message: "Copied successfully.")
                                }),
                                .default(Text("Share"), action: {
                                    
                                    ShareMedia.shareMediafrom(type: .normalShare, mediaId: fileURLString, controller: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
                                }),
                                .cancel()
                            ]
                        )
                    }
                    
                    Button {
                        if let url = URL(string: fileURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            print("Invalid URL: \(fileURLString)")
                        }
                    } label: {
                        Image("globe")
                            .renderingMode(.template)
                            .foregroundColor(Color(UIColor.label))
                            .frame(width: 40, height: 40)
                    }
                    .frame(width: 40, height: 40)
                }else{
                    Spacer()
                }
                
            }
            .background(Color(UIColor.systemGray6))
           // .foregroundColor(Color(UIColor.label))
            .frame(height:44)
            
            Divider()
            
            // WebView + Loader
            ZStack {
                if let url = URL(string: fileURLString) {
                    WebView(url: url, isLoading: $isLoading)
                } else {
                    Text("Invalid URL")
                        .foregroundColor(.red)
                        .padding()
                }
                
                // 👇 LOADER
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    
    func openOption(){
        
        let sheet = UIAlertController(
            title: "",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        sheet.addAction(UIAlertAction(title: "Open in browser", style: .default, handler: { action in
            
            if let url = URL(string: fileURLString)  {
              
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Cannot open URL")
                }
            }
        }))
        
        sheet.addAction(UIAlertAction(title: "Copy link", style: .default, handler: { action in
            
            UIPasteboard.general.string = fileURLString
            AlertView.sharedManager.showToast(message: "Copied successfully.")
        }))
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController?
            .present(sheet, animated: true)
    }
    
    

    private func openSafariView(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .fullScreen

        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .present(safariVC, animated: true)
    }
  
}

import SwiftUI
import WebKit

/*struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
*/



import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    let url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = true

        isLoading = true
        loadContent(in: webView)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func loadContent(in webView: WKWebView) {
        let ext = url.pathExtension.lowercased()

        if isImage(ext) {
            loadImageAspectFit(webView)
        } else {
            webView.load(URLRequest(url: url))
        }
    }

    private func isImage(_ ext: String) -> Bool {
        ["jpg", "jpeg", "png", "gif", "webp"].contains(ext)
    }

    private func loadImageAspectFit(_ webView: WKWebView) {
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                margin: 0;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                background: white;
            }
            img {
                max-width: 100%;
                max-height: 100%;
                object-fit: contain;
            }
        </style>
        </head>
        <body>
            <img src="\(url.absoluteString)" />
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // 👇 Instagram
            if url.absoluteString.contains("instagram.com") {
                openInstagram(url)
               // decisionHandler(.cancel)
                //return
            }

            // 👇 WhatsApp
            if url.absoluteString.contains("wa.me") ||
               url.absoluteString.contains("whatsapp.com") {
                openWhatsApp(url)
              //  decisionHandler(.cancel)
              //  return
            }
            
            // 📘 Facebook
               if url.absoluteString.contains("facebook.com") || url.absoluteString.contains("fb.com") {
                  // openFacebook(url)
//                   decisionHandler(.cancel)
//                   return
               }

            decisionHandler(.allow)
        }
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
        
        private func openInstagram(_ url: URL) {
            let username = url.pathComponents.last ?? ""

            let appURL = URL(string: "instagram://user?username=\(username)")!
            let webURL = url

            if UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL)
            } else {
                UIApplication.shared.open(webURL)
            }
        }

        private func openFacebook(_ url: URL) {
            let appURL = URL(string: "fb://facewebmodal/f?href=\(url.absoluteString)")!

            if UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL)
            } else {
                UIApplication.shared.open(appURL)
            }
        }

        private func openWhatsApp(_ url: URL) {
            let appURL = URL(string: url.absoluteString.replacingOccurrences(of: "https://", with: "whatsapp://"))!

            if UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL)
            } else {
                UIApplication.shared.open(url)
            }
        }

    }
}



import SwiftUI
import SafariServices


struct SafariView: UIViewControllerRepresentable {

    let url: URL
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.delegate = context.coordinator
        vc.modalPresentationStyle = .fullScreen
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

    final class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            dismiss()   // 👈 DONE button tapped
        }
    }
}
