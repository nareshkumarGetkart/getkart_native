//
//  PrivacyView.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 17/02/25.
//

import SwiftUI


enum ViewType{
    
    case privacy
    case termsAndConditions
    case faq
    case blogs
    case aboutUs
    case refundAndCancellationPolicy
}
/*

struct PrivacyView: View {
    
    var navigationController: UINavigationController?
    var title:String
    var type:ViewType
    @State var htmlString:String?
    @State private var renderedHtmlText: AttributedString = AttributedString("Loading...")

    var body: some View {
       // let ht = UIDevice().hasNotch ? (navigationController?.getNavBarHt ?? 0.0) - 20 : (navigationController?.getNavBarHt ?? 0.0) + 20
        HStack{
            
            Button {
                
                navigationController?.popViewController(animated: true)

            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text(title).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background()
        //+ 44.0
        
        VStack{

            HStack{Spacer()}
                
                let metaTag = """
                   <meta name="viewport" content="width=device-width, initial-scale=3.0, maximum-scale=5.0, minimum-scale=3.0, user-scalable=yes">
                   """
                
                ScrollView{
                     /*   let txt   = ("<html><head>\(metaTag)</head><body>\(htmlString ?? "")</body></html>")
                        Text(convertHtmlToAttributedString(txt)).font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom)
                    */
                    Text(renderedHtmlText)
                                       .font(.manrope(.regular, size: 17))
                                       .padding([.leading, .trailing, .top], 8)
                                       .padding(.bottom)
                }

        }.background(Color(.systemGray6)).navigationBarTitleDisplayMode(.inline).navigationBarHidden(true).onAppear{
            callApi(type: type)
        }
    }
    
    
    func getUrlTYpe(type:ViewType) ->String{
       var url:String = ""

       if type == .privacy{
           
           url =  Constant.shared.privacy_policy
      
       }else if type == .termsAndConditions{
           url =  Constant.shared.terms_conditions
       }else if type == .aboutUs{
           url =  Constant.shared.about_us
           
       }else if type == .refundAndCancellationPolicy{
           
           url =  Constant.shared.cancellation_refund_policy
           
       }
        
        
       return url
   }
    
    func convertHtmlToAttributedString(_ txtHtml: String) -> AttributedString {
        guard let data = txtHtml.data(using: .utf8) else { return AttributedString("Failed to load") }

        // Convert HTML to NSAttributedString
        if let nsAttributedString = try? NSAttributedString(data: data,
                                                            options: [.documentType: NSAttributedString.DocumentType.html,
                                                                      .characterEncoding: String.Encoding.utf8.rawValue],
                                                            documentAttributes: nil) {
            // Convert NSAttributedString to SwiftUI's AttributedString
            if var attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) {
                // Apply font to the entire attributed string
                attributedString.font = .system(size: 15)

                return attributedString
            }
        }
        return AttributedString("Failed to convert HTML")
    }
    
    
    
    func callApi(type:ViewType){
        
        
        URLhandler.sharedinstance.makeCall(url: getUrlTYpe(type:type), param: nil,methodType: .get) { responseObject, error in
            
              if(error != nil)
                {
                    //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                    print(error ?? "defaultValue")
                    
              }else{
                  
                  let result = responseObject! as NSDictionary
                  let status = result["code"] as? Int ?? 0
                  let message = result["message"] as? String ?? ""
                  
                  if status == 200{
                      
                      if let data = result["data"] as? Dictionary<String,Any>{
                          
                          var rawHtml: String?

                          if let cancellation_refund_policy = data["cancellation_refund_policy"] as? String{
                              
                              rawHtml = cancellation_refund_policy
                              
                          }else if let privacy_policy = data["privacy_policy"] as? String{
                              
                              rawHtml = privacy_policy
                              
                          }else if let terms_conditions = data["terms_conditions"] as? String{
                              
                              rawHtml = terms_conditions
                              
                          }else if let about_us = data["about_us"] as? String{
                              
                              rawHtml = about_us
                              
                          }
                          
                          
                          DispatchQueue.main.async {
                                              htmlString = rawHtml
                                              if let html = rawHtml {
                                                  let metaTag = """
                                                      <meta name="viewport" content="width=device-width, initial-scale=3.0, maximum-scale=5.0, minimum-scale=3.0, user-scalable=yes">
                                                  """
                                                  let fullHtml = "<html><head>\(metaTag)</head><body>\(html)</body></html>"
                                                  renderedHtmlText = convertHtmlToAttributedString(fullHtml)
                                              }
                                          }
                          
                          
                      }
                      
                  }
              }
        }

    }
}
*/

import SwiftUI
import WebKit

struct PrivacyView: View {
    
    var navigationController: UINavigationController?
    var title: String
    var type: ViewType
    @State  var htmlString: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }
                .frame(width: 40, height: 40)

                Text(title)
                    .font(.custom("Manrope-Bold", size: 20))
                    .foregroundColor(Color(UIColor.label))

                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal)
            .background(Color(UIColor.systemBackground))

            // WebView content
            if let html = htmlString {
                WebViewHTML(htmlContent: wrapHtmlContent(html))
                    //.padding()
                    .background(Color(.systemGray6))
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .onAppear {
            callApi(type: type)
        }
    }

    // MARK: - API Call

    func callApi(type: ViewType) {
        URLhandler.sharedinstance.makeCall(url: getUrlTYpe(type: type), param: nil, methodType: .get) { responseObject, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let result = responseObject,
                  let data = result["data"] as? [String: Any],
                  result["code"] as? Int == 200 else {
                return
            }

            var rawHtml: String?

            switch type {
            case .privacy:
                rawHtml = data["privacy_policy"] as? String
            case .termsAndConditions:
                rawHtml = data["terms_conditions"] as? String
            case .aboutUs:
                rawHtml = data["about_us"] as? String
            case .refundAndCancellationPolicy:
                rawHtml = data["cancellation_refund_policy"] as? String
            case .faq:
                rawHtml = ""
            case .blogs:
                rawHtml = ""
            }

            DispatchQueue.main.async {
                htmlString = rawHtml
            }
        }
    }

    // MARK: - HTML Wrapper

    func wrapHtmlContent(_ body: String) -> String {
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.light.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .light
        let isDark = (theme == .dark)

        let metaTag = """
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        """
        let style = """
        <style>
            body {
                font-family: -apple-system, HelveticaNeue, sans-serif;
                font-size: 17px;
               # color: #000000;
         color: \(isDark ? "#ffffff" : "#000000");
        background-color: \(isDark ? "#000000" : "#ffffff");
                padding: 10px;
            }
        </style>
        """
        return """
        <html>
        <head>
        \(metaTag)
        \(style)
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }

    func getUrlTYpe(type: ViewType) -> String {
        switch type {
        case .privacy:
            return Constant.shared.privacy_policy
        case .termsAndConditions:
            return Constant.shared.terms_conditions
        case .aboutUs:
            return Constant.shared.about_us
        case .refundAndCancellationPolicy:
            return Constant.shared.cancellation_refund_policy
        case .faq:
            return ""
        case .blogs:
            return ""
        }
    }
}

#Preview {
    PrivacyView(navigationController: nil, title: "Privacy", type: .privacy)
}



import SwiftUI
import WebKit

struct WebViewHTML: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
        
    }
}
