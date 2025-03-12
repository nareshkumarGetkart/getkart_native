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


struct PrivacyView: View {
    
    var navigationController: UINavigationController?
    var title:String
    var type:ViewType
    @State var htmlString:String?

    var body: some View {
       // let ht = UIDevice().hasNotch ? (navigationController?.getNavBarHt ?? 0.0) - 20 : (navigationController?.getNavBarHt ?? 0.0) + 20
        HStack{
            
            Button {
                
                AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)

            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text(title).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background()
        //+ 44.0
        
        VStack{

           // if (htmlString?.count ?? 0) > 1{
                
                let metaTag = """
                   <meta name="viewport" content="width=device-width, initial-scale=3.0, maximum-scale=5.0, minimum-scale=3.0, user-scalable=yes">
                   """
                
                ScrollView{
//                    if (htmlString ?? "").contains("<head>") {
//                        let txt = ((htmlString ?? "").replacingOccurrences(of: "<head>", with: "<head>\(metaTag)"))
//                        
//                        Text(convertHtmlToAttributedString(txt)).font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom)
//                    } else {
                        let txt   = ("<html><head>\(metaTag)</head><body>\(htmlString ?? "")</body></html>")
                        Text(convertHtmlToAttributedString(txt)).font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom)
                    //}
                }
               // Webview(url:nil, htmlText:htmlString ?? "")
               
//            }
//            else  if let url = URL(string:getUrlTYpe(type: type)){
//                Webview(url: url, htmlText: "").navigationBarBackButtonHidden(true)
//            }
        }.navigationBarTitleDisplayMode(.inline).navigationBarHidden(true).onAppear{
            callApi(type: type)
        }
    }
    
    
    func getUrlTYpe(type:ViewType) ->String{
       var url:String = ""

       if type == .privacy{
           url =  Constant.shared.privacy_policy
       }else if type == .faq{
           url = "https://getkart.com/privacy-polic"
       }else if type == .termsAndConditions{
           url =  Constant.shared.privacy_policy
       }else if type == .aboutUs{
           url = "https://getkart.com/privacy-polic"
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
                          
                          if let cancellation_refund_policy = data["cancellation_refund_policy"] as? String{
                              
                              htmlString = cancellation_refund_policy
                              
                          }else if let privacy_policy = data["privacy_policy"] as? String{
                              
                              htmlString = privacy_policy
                              
                          }
                      }
                      
                  }
              }
        }

    }
}

#Preview {
    PrivacyView(navigationController: nil, title: "Privacy", type: .privacy)
}
