//
//  BottomSheetPopupView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/08/25.
//

import SwiftUI
import FittedSheets


// MARK: - BottomSheetPopupView
struct BottomSheetPopupView: View {
    var objPopup: PopupModel
    var pushToScreenFromPopup: (_ obj: PopupModel, _ dismissOnly: Bool) -> Void

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.white)
        .fixedSize(horizontal: false, vertical: true)  // important for intrinsic height
    }
    
    private var content: some View {
        VStack(spacing: 10) {
            // IMAGE OR CLOSE BUTTON
            if let imageUrl = objPopup.image, !imageUrl.isEmpty {
                popupImage
            } else {
                closeButton
            }
            
            // TEXT CONTENT
            VStack(spacing: 10) {
                if let title = objPopup.title {
                    
                    if title.isHTML{
                        HTMLOrTextView(htmlContent: title, defaultFont:UIFont.Inter.semiBold(size: 22.0).font ?? UIFont.systemFont(ofSize: 22, weight: .medium))
                            .fixedSize(horizontal: false, vertical: true)
                    }else{
                        
                        Text(title).foregroundColor(.black)
                            .font(.inter(.semiBold, size: 18))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    
                    
                }
                
                if let subtitle = objPopup.subtitle {
                    
                    if subtitle.isHTML{
                        HTMLOrTextView(htmlContent: subtitle, defaultFont:UIFont.Inter.medium(size: 17.0).font ?? UIFont.systemFont(ofSize: 17, weight: .medium))
                            .fixedSize(horizontal: false, vertical: true)
                    }else{
                        Text(subtitle).foregroundColor(.black)
                            .font(.inter(.medium, size: 17))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                    }
              
                }
                
                if let html = objPopup.description, !html.isEmpty {
                    HTMLTextView(htmlContent: html)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 20)
            
            // MAIN BUTTON
            Button {
                pushToScreenFromPopup(objPopup, false)
            } label: {
                let strTitle = (objPopup.buttonTitle ?? "").count > 0 ?  objPopup.buttonTitle ?? "Okay" : "Okay"
                Text(strTitle)
                    .foregroundColor(.white)
                    .font(.inter(.semiBold, size: 18))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(hexString: "#FF9900"))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 25)
        }
    }
    
//    private var popupImage: some View {
//        ZStack(alignment: .topTrailing) {
//            AsyncImage(url: URL(string: objPopup.image ?? "")) { image in
//                image.resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: .infinity)
//                    .frame(minHeight: 170, maxHeight: 250)
//                    //.padding(.top,1)
//                    .clipped()
//            } placeholder: {
//                Image("getkartplaceholder")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(minHeight: 170, maxHeight: 250)//.padding(.top,1)
//                    .clipped()
//            }
//            
//            if !(objPopup.mandatoryClick ?? false) {
//                closeButton
//                    .padding(.top, 15)
//                    .padding(.trailing, 10)
//            }
//        }
//    }
    
    private var popupImage: some View {
        ZStack(alignment: .topTrailing) {

            AsyncImage(url: URL(string: objPopup.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 160, maxHeight: 250)
                   // .padding(.top,1)
                
            } placeholder: {
                Image("getkartplaceholder")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 160, maxHeight: 250)
                  //  .padding(.top,1)
                
            }

            if !(objPopup.mandatoryClick ?? false) {
                closeButton
                    .padding(.top, 10)
                    .padding(.trailing, 12)
            }
        }    .ignoresSafeArea(.container, edges: .top)   // ✅ ONLY HERE

    }

    
    private var closeButton: some View {
        Button {
            pushToScreenFromPopup(objPopup, true)

        } label: {
            Image("Cross")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
        }
    }
}




struct HTMLTextView: UIViewRepresentable {
    let htmlContent: String
    var defaultFont: UIFont = .Inter.regular(size: 15).font
    var horizontalPadding: CGFloat = 7

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        guard let data = htmlContent.sanitizedHTML.data(using: .utf8) else { return }

        if let attributed = try? NSMutableAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            // Set default font if missing
            attributed.enumerateAttribute(.font, in: NSRange(location: 0, length: attributed.length), options: []) { value, range, _ in
                if let oldFont = value as? UIFont {
                    let newFont = oldFont.withSize(max(oldFont.pointSize, defaultFont.pointSize))
                    attributed.addAttribute(.font, value: newFont, range: range)
                } else {
                    attributed.addAttribute(.font, value: defaultFont, range: range)
                }
            }

            uiView.attributedText = attributed
        } else {
            uiView.text = htmlContent
            uiView.font = defaultFont
        }

        // Constrain UILabel width to screen width minus padding
        let screenWidth = UIScreen.main.bounds.width
        uiView.preferredMaxLayoutWidth = screenWidth - (horizontalPadding * 2)
        
        uiView.setContentHuggingPriority(.required, for: .vertical)
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}



extension String {

    /// Converts Swift newlines into HTML <br> tags and fixes broken HTML cases
    var sanitizedHTML: String {
        var html = self

        // Replace \n with <br>
        html = html.replacingOccurrences(of: "\n", with: "<br>")
     
        // Trim accidental spaces inside tags
        html = html.replacingOccurrences(of: "<strong> ", with: "<strong>")
        html = html.replacingOccurrences(of: " </strong>", with: "</strong>")
        
        // ✅ REMOVE leading/trailing whitespace & newlines
        html = html.trimmingCharacters(in: .whitespacesAndNewlines)

        // ✅ Remove whitespace between tags
        html = html.replacingOccurrences(
            of: ">\\s+<",
            with: "><",
            options: .regularExpression
        )

        // Replace \n with <br> ONLY if needed
        html = html.replacingOccurrences(of: "\n", with: "")

        // Ensure <strong> has closing tag
        let strongOpenCount = html.components(separatedBy: "<strong>").count - 1
        let strongCloseCount = html.components(separatedBy: "</strong>").count - 1
        if strongOpenCount > strongCloseCount {
            html += "</strong>"
        }

        
        
        // Escape invalid HTML characters if needed
        html = html.replacingOccurrences(of: " & ", with: " &amp; ")

        return html
    }
    
    
}




func attributedString(from html: String, defaultFont: UIFont) -> AttributedString? {
    let htmlWithFont = """
    <span style="font-family: '\(defaultFont.familyName)'; font-size: \(defaultFont.pointSize)px;">
    \(html)
    </span>
    """

    guard let data = htmlWithFont.data(using: .utf8) else { return nil }

    let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
    ]

    if let attributedString = try? NSMutableAttributedString(data: data,
                                                             options: options,
                                                             documentAttributes: nil) {

        // Force apply font to entire string (removes unwanted fonts)
        attributedString.addAttributes([
            .font: defaultFont
        ], range: NSRange(location: 0, length: attributedString.length))

        return try? AttributedString(attributedString, including: \.uiKit)
    }

    return nil
}



func extractHTMLColor(_ html: String) -> Color {
    // Example HTML: <span style="color:#FF0000">Hello</span>
    if let range = html.range(of: #"color:\s*(#[0-9A-Fa-f]{6})"#, options: .regularExpression),
       let hex = html[range].split(separator: "#").last {

        return Color(hex: String(hex))
    }
    return .black
}


 struct HTMLOrTextView: UIViewRepresentable {
    let htmlContent: String
    var defaultFont: UIFont = .Inter.regular(size: 17).font
    var horizontalPadding: CGFloat = 8

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }

     
     
    func updateUIView(_ uiView: UILabel, context: Context) {
        guard let data = htmlContent.sanitizedHTML.data(using: .utf8) else { return }

        if let attributed = try? NSMutableAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {

            // --- FONT FIX ---
            attributed.enumerateAttribute(.font, in: NSRange(location: 0, length: attributed.length)) { value, range, _ in
                if let oldFont = value as? UIFont {
                    let newFont = oldFont.withSize(max(oldFont.pointSize, defaultFont.pointSize))
                    attributed.addAttribute(.font, value: newFont, range: range)
                } else {
                    attributed.addAttribute(.font, value: defaultFont, range: range)
                }
            }

            // --- COLOR FIX ---
            attributed.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: attributed.length)) { value, range, _ in
                if value == nil {
                    // No color provided in HTML → set black
                    attributed.addAttribute(.foregroundColor, value: UIColor.black, range: range)
                }
            }
            
            // ---------- PARAGRAPH FIX (SMART) ----------
            // -------- REMOVE HTML PARAGRAPH EXTRA SPACE --------
            let fullRange = NSRange(location: 0, length: attributed.length)

            attributed.enumerateAttribute(.paragraphStyle, in: fullRange) { value, range, _ in
                let style = (value as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
                
                style.paragraphSpacing = 0
                style.paragraphSpacingBefore = 0
                style.lineSpacing = 0
                style.lineHeightMultiple = 1
                style.minimumLineHeight = 0
                style.maximumLineHeight = 0
                style.alignment = .center
                // ✅ Keep HTML alignment if present, otherwise center
                if value == nil {
                    style.alignment = .center
                }

                attributed.addAttribute(.paragraphStyle, value: style, range: range)
            }

            // 🔥 REMOVE REAL TEXT WHITESPACE (THIS FIXES EVERYTHING)
            attributed.trimNewlinesAndSpaces()
            //END
            
            
            uiView.attributedText = attributed
        } else {
            // Fallback plain text
            uiView.text = htmlContent
            uiView.font = defaultFont
            uiView.textColor = .black
        }

        // Constrain UILabel width
        let screenWidth = UIScreen.main.bounds.width
        uiView.preferredMaxLayoutWidth = screenWidth - (horizontalPadding * 2)
       
        uiView.setContentHuggingPriority(.required, for: .vertical)
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}

extension NSMutableAttributedString {

    func trimNewlinesAndSpaces() {
        let inverted = CharacterSet.whitespacesAndNewlines.inverted

        // Trim leading
        if let range = string.rangeOfCharacter(from: inverted) {
            let start = string.distance(from: string.startIndex, to: range.lowerBound)
            if start > 0 {
                deleteCharacters(in: NSRange(location: 0, length: start))
            }
        }

        // Trim trailing
        if let range = string.rangeOfCharacter(from: inverted, options: .backwards) {
            let end = string.distance(from: string.startIndex, to: range.upperBound)
            let length = string.count - end
            if length > 0 {
                deleteCharacters(in: NSRange(location: end, length: length))
            }
        }
    }
}

extension String {
    var isHTML: Bool {
        return self.range(of: "<[^>]+>", options: .regularExpression) != nil
    }
}



