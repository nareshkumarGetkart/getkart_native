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
     
        VStack{
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
               
                HStack{ Spacer() }.frame(height: 15)

                
                if (obj?.image ?? "").count > 0{
                    AsyncImage(url: URL(string: obj?.image ?? "")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                            .frame(width:  UIScreen.main.bounds.width-20, height: 150)
                        
                    }placeholder: {
                        
                        Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fill)
                            .frame(width:  UIScreen.main.bounds.width-20, height: 150)
                        //                ProgressView().progressViewStyle(.circular)
                        
                    }
                }
                if (obj?.title ?? "").count > 0{
                    
                    Text(obj?.title ?? "").font(.manrope(.medium, size: 18)).padding([.leading,.trailing]).padding(.top,10)
                    
                }
                
                let metaTag = """
                   <meta name="viewport" content="width=device-width, initial-scale=3.0, maximum-scale=5.0, minimum-scale=3.0, user-scalable=yes">
                   """
                
                if (obj?.description ?? "").contains("<head>") {
                    let txt = ((obj?.description ?? "").replacingOccurrences(of: "<head>", with: "<head>\(metaTag)"))
                    
                    Text(convertHtmlToAttributedString(txt)).font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom)
                } else {
                    let txt   = ("<html><head>\(metaTag)</head><body>\(obj?.description ?? "")</body></html>")
                    Text(convertHtmlToAttributedString(txt)).font(.manrope(.regular, size: 17)).padding([.leading,.trailing,.top],8).padding(.bottom)
                }
            }.background(Color(UIColor.systemGroupedBackground))
            
            Spacer()
            
        }//.padding()
        
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
   
}

#Preview {
    BlogDetailView()
}


