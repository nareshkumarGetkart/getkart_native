//
//  BottomSheetPopupView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/08/25.
//

import SwiftUI
import FittedSheets

struct BottomSheetPopupView: View {
    var objPopup:PopupModel
    var pushToScreenFromPopup: (_ obj:PopupModel,_ dismissOnly:Bool) -> Void
   
    var body: some View {

        VStack{
            
            if (objPopup.image ?? "").count == 0{
                HStack{
                    Spacer()
                    Button(action: {
                        pushToScreenFromPopup(objPopup,true)
                    }) {
                        Image("Cross")
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25).padding(8)
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 10)
                }
            }else{
                ZStack(alignment: .topTrailing) {
                    
                    AsyncImage(url: URL(string: objPopup.image ?? "")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        Image("getkartplaceholder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    }
                    
                    if !(objPopup.mandatoryClick ?? false){
                        
                        Button(action: {
                            pushToScreenFromPopup(objPopup,true)
                        }) {
                            Image("Cross")
                                .resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25).padding(8)
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                        
                    }
                    
                    
                }.frame(height:175).padding(.bottom)
            }
            
            VStack(spacing:10){
                VStack(alignment: .center, spacing: 5){
                    Text(objPopup.title ?? "").font(.manrope(.semiBold, size: 17.0)).foregroundColor(.black).multilineTextAlignment(.center)
                    Text(objPopup.subtitle ?? "").font(.manrope(.regular, size: 16.0)).foregroundColor(.black).multilineTextAlignment(.center)
                }
                              
                
                if (objPopup.description ?? "").count > 0{
                    
                        HTMLTextView(htmlContent: objPopup.description ?? "")

                }
                
                Spacer(minLength: 0)

                Button {
                    pushToScreenFromPopup(objPopup,false)
                    
                } label: {
                    Text(objPopup.buttonTitle ?? "").foregroundColor(.white).font(.manrope(.semiBold, size: 17.0))
                    
                }.frame(maxWidth:.infinity,minHeight:50, maxHeight: 50).background(Color(hexString: "#FF9900")).cornerRadius(10.0).padding([.leading,.trailing]).padding(.bottom)
                
            }.padding(5)
        }.background(Color(.white))//.padding()
    }
    
    var cleanedAttributedString: AttributedString? {
        
        
        guard let data = (objPopup.description ?? "").data(using: .utf8) else {
            return nil
        }

        return try? AttributedString( NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ), including: \.uiKit)
        
    }
  
}

#Preview {
    BottomSheetPopupView(objPopup: PopupModel(userID:639, title: "items saved as draft that",
                                              subtitle: "items saved as draft that",
                                              description: "<ul><li>You have items saved as draft that are not visible to others.</li>  <li>Complete the required details to make your item live.</li>    <li>Publishing your item increases visibility and chances of response.</li>   <li>Make sure the images and description are clear and accurate.</li>        <li>Click 'Publish Now' to make your draft item available to others.</li>     </ul>", image:"https://d25frd65ud7bv8.cloudfront.net/getkart/chat/2025/07/687dcf6b83e234.645584041753075563.png", mandatoryClick: true,
                                              buttonTitle: "Okay",
                                              type: 1, itemID: 49625), pushToScreenFromPopup: {(obj,dismissOnly) in
        
    })
}



import UIKit

struct HTMLTextView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = UIFont.Manrope.regular(size: 13.0).font

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if let data = htmlContent.data(using: .utf8),
           let attributedString = try? NSMutableAttributedString(data: data,
                       options: [.documentType: NSAttributedString.DocumentType.html,
                                 .characterEncoding: String.Encoding.utf8.rawValue],
                       documentAttributes: nil) {
            
            

            // Remove inline text colors (for dark mode support)
//            attributedString.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: attributedString.length)) { _, range, _ in
//                attributedString.removeAttribute(.foregroundColor, range: range)
//            }
            
            
            attributedString.applyFont(UIFont.Manrope.regular(size: 13).font) // Your custom base font

            uiView.attributedText = attributedString
        }
    }
}


import UIKit

extension NSMutableAttributedString {
    func applyFont(_ font: UIFont) {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, range, _ in
            guard let oldFont = value as? UIFont else { return }
            
            var newDescriptor = font.fontDescriptor
            
            // Preserve traits (bold, italic) from old font
            if oldFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
                newDescriptor = newDescriptor.withSymbolicTraits(.traitBold) ?? newDescriptor
            }
            if oldFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                newDescriptor = newDescriptor.withSymbolicTraits(.traitItalic) ?? newDescriptor
            }
            
            let newFont = UIFont(descriptor: newDescriptor, size: font.pointSize)
            addAttribute(.font, value: newFont, range: range)
        }
    }
}
