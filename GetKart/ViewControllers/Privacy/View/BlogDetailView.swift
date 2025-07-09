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
    var navigationController:UINavigationController?

    var body: some View {
     
        VStack{
        HStack{
            Button {
                
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text(title).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
        }.frame(height:44).background(Color(UIColor.systemBackground))
        
            ScrollView{
               
                HStack{ Spacer() }.frame(height: 10)

                
                if (obj?.image ?? "").count > 0{
                    AsyncImage(url: URL(string: obj?.image ?? "")) { image in
                        image.resizable()//.aspectRatio(contentMode: .fill)
                            .frame(width:  UIScreen.main.bounds.width-20, height: 160).clipped()
                        
                    }placeholder: {
                        
                        Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fill)
                            .frame(width:  UIScreen.main.bounds.width-20, height: 160).clipped()
                        
                    }
                }
               /* if (obj?.title ?? "").count > 0{
                    
                    Text(obj?.title ?? "").multilineTextAlignment(.leading).font(.manrope(.medium, size: 18)).padding([.leading,.trailing],8).padding(.top,10)
                }*/
                
                if (obj?.title ?? "").count > 0 {
                    HStack {
                        Text(obj?.title ?? "")
                            .multilineTextAlignment(.leading)
                            .font(.manrope(.medium, size: 18))
                            .padding([.leading, .trailing], 8)
                            .padding(.top, 10)
                        Spacer()
                    }
                }

                
                let metaTag = """
                   <meta name="viewport" content="width=device-width, initial-scale=3.0, maximum-scale=5.0, minimum-scale=3.0, user-scalable=yes">
                   """
                
                if (obj?.description ?? "").contains("<head>") {
                    let txt = ((obj?.description ?? "").replacingOccurrences(of: "<head>", with: "<head>\(metaTag)"))
                    
                    let cleanedHTML = stripColorStyles(from: txt)

                    Text(convertHtmlToAttributedString(cleanedHTML)).font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom).foregroundColor(Color(UIColor.label))
                } else {
                    let txt   = ("<html><head>\(metaTag)</head><body>\(obj?.description ?? "")</body></html>")
                    Text(convertHtmlToAttributedString(txt)).font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom).foregroundColor(Color(UIColor.label))
                }
            }.background(Color(UIColor.systemGroupedBackground))
            
            Spacer()
            
        }.navigationBarHidden(true)
        
    }
    
    func convertHtmlToAttributedString(_ txtHtml: String) -> AttributedString {
        guard let data = txtHtml.data(using: .utf8) else { return AttributedString("Failed to load") }

    /*    // Convert HTML to NSAttributedString
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
        */
        
        
        if let nsAttrStr = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        ) {
            // Remove hardcoded text colors to support light/dark mode
            nsAttrStr.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: nsAttrStr.length)) { _, range, _ in
                nsAttrStr.removeAttribute(.foregroundColor, range: range)
            }

            // Convert to AttributedString
            if var attrStr = try? AttributedString(nsAttrStr, including: \.uiKit) {
                attrStr.font = .system(size: 15)
                return attrStr
            }
        }

        return AttributedString("Failed to convert HTML")
    }
    
    func stripColorStyles(from html: String) -> String {
        let pattern = "color\\s*:\\s*[^;\"']+;?"
        return html.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
   
}

#Preview {
    BlogDetailView()
}


