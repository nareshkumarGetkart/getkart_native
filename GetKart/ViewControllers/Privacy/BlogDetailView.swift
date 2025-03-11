//
//  BlogDetailView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/03/25.
//

import SwiftUI

struct BlogDetailView: View {
    var title:String = ""
    @State var obj:BlogsModel?

    var body: some View {
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
        
     
        ScrollView{
            
            AsyncImage(url: URL(string: obj?.image ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
                    .frame(width:  UIScreen.main.bounds.width-20, height: 150)
                
            }placeholder: {
                
                Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fill)
                    .frame(width:  UIScreen.main.bounds.width-20, height: 150)
                //                ProgressView().progressViewStyle(.circular)
                
            }
            Text(obj?.title ?? "").font(.manrope(.medium, size: 18)).padding([.leading,.trailing])
            
          Webview(url: nil, htmlText: obj?.description ?? "")
           
//            if let nsAttributedString = try? NSAttributedString(data: Data((obj?.description ?? "").utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil),
//               let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) {
//                Text(attributedString).font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom)
//            } else {
//                Text(obj?.description ?? "").font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom)
//            }
            
        }.padding()
        
    }
    
   
}

#Preview {
    BlogDetailView()
}
