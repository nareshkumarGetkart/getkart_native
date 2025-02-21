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
    
    var body: some View {
        let ht = UIDevice().hasNotch ? (navigationController?.getNavBarHt ?? 0.0) - 20 : (navigationController?.getNavBarHt ?? 0.0) + 20
        HStack{
            
            Button {
                
                navigationController?.popViewController(animated: true)

            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text(title).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:ht).background()
        //+ 44.0
        
        VStack{
            
//            let keyWindow = UIApplication.shared.connectedScenes
//                 .filter({$0.activationState == .foregroundActive})
//                 .compactMap({$0 as? UIWindowScene})
//                 .first?.windows
//                 .filter({$0.isKeyWindow}).first
             
           
           
            
            if let url = URL(string:getUrlTYpe(type: type)){
                Webview(url: url).navigationBarBackButtonHidden(true)
            }
        }.navigationBarTitleDisplayMode(.inline).navigationBarHidden(true)
    }
    
    
    func getUrlTYpe(type:ViewType) ->String{
       var url:String = ""

       if type == .privacy{
           url = "https://getkart.com/privacy-polic"
       }else if type == .faq{
           url = "https://getkart.com/privacy-polic"
       }else if type == .termsAndConditions{
           url = "https://getkart.com/privacy-polic"
       }else if type == .blogs{
           url = "https://getkart.com/privacy-polic"
       }else if type == .aboutUs{
           url = "https://getkart.com/privacy-polic"
       }else if type == .refundAndCancellationPolicy{
           url = "https://getkart.com/privacy-polic"
       }
        
        
       
        
       return url
   }
}

#Preview {
    PrivacyView(navigationController: nil, title: "Privacy", type: .privacy)
}
