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
        VStack(spacing: 15) {
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
                        HTMLOrTextView(htmlContent: title, defaultFont:UIFont(name: "Manrope-SemiBold", size: 20.0) ?? UIFont.systemFont(ofSize: 20, weight: .medium))
                            .fixedSize(horizontal: false, vertical: true)
                    }else{
                        
                        Text(title).foregroundColor(.black)
                            .font(.manrope(.semiBold, size: 18))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    
                    
                }
                
                if let subtitle = objPopup.subtitle {
                    
                    if subtitle.isHTML{
                        HTMLOrTextView(htmlContent: subtitle, defaultFont:UIFont(name: "Manrope-Medium", size: 17.0) ?? UIFont.systemFont(ofSize: 16, weight: .medium))
                            .fixedSize(horizontal: false, vertical: true)
                    }else{
                        Text(subtitle).foregroundColor(.black)
                            .font(.manrope(.medium, size: 17))
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
                    .font(.manrope(.semiBold, size: 17))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(hexString: "#FF9900"))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 25)
        }
    }
    
    private var popupImage: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: objPopup.image ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 170, maxHeight: 250)
                    .padding(.top,1)
            } placeholder: {
                Image("getkartplaceholder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity).padding(.top,1)
            }
            
            if !(objPopup.mandatoryClick ?? false) {
                closeButton
                    .padding(.top, 15)
                    .padding(.trailing, 10)
            }
        }
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

// MARK: - HostingController that reports SwiftUI content size dynamically
class IntrinsicHostingController<Content: View>: UIHostingController<Content> {
    
    private var lastReportedSize: CGSize = .zero
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }
    
    private func updatePreferredContentSize() {
        let targetSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        guard lastReportedSize != targetSize else { return }
        lastReportedSize = targetSize
        preferredContentSize = targetSize
        view.invalidateIntrinsicContentSize()
    }
}


struct HTMLTextView: UIViewRepresentable {
    let htmlContent: String
    var defaultFont: UIFont = .Manrope.regular(size: 15).font
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
    var defaultFont: UIFont //= .Manrope.regular(size: 17).font
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



// MARK: - Presenting function
/*func presentHostingController(objPopup: PopupModel, from vc: UIViewController) {
    
    let hostingController = IntrinsicHostingController(
        rootView: BottomSheetPopupView(objPopup: objPopup, pushToScreenFromPopup: { obj, dismissOnly in
            vc.dismiss(animated: true)
            // handle your navigation here
        })
    )
    
    hostingController.view.backgroundColor = .clear
    hostingController.view.layoutIfNeeded()
    
    // Present FittedSheet with intrinsic height
    let sheet = SheetViewController(
        controller: hostingController,
        sizes: [.intrinsic],
        options: SheetOptions(presentingViewCornerRadius: 20)
    )
    
    sheet.cornerRadius = 20
    sheet.dismissOnOverlayTap = !(objPopup.mandatoryClick ?? false)
    sheet.dismissOnPull = false
    sheet.allowGestureThroughOverlay = false
    sheet.gripColor = .clear
    
    vc.present(sheet, animated: true, completion: nil)
}
*/

/*
struct BottomSheetPopupView: View {
    var objPopup: PopupModel
    var pushToScreenFromPopup: (_ obj: PopupModel, _ dismissOnly: Bool) -> Void

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 10)   // ✅ horizontal padding applied
            .padding(.bottom, 5)
            .background(Color.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: UIScreen.main.bounds.width - 20) // constrain width
   // ❤️ CRITICAL
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }

    private var content: some View {
        VStack(spacing: 0) {

            // Banner — full width, ignores horizontal padding
            if let imageUrl = objPopup.image, !imageUrl.isEmpty {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 150, maxHeight: 220)// ✅ full screen width
                    } placeholder: {
                        Image("getkartplaceholder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(minHeight: 150, maxHeight: 220)

                    if !(objPopup.mandatoryClick ?? false) {
                        closeButton
                            .padding(.top)
                    }
                } .frame(maxWidth: .infinity)
            }

            // Content — padded text/buttons
            VStack(spacing: 15) {
                Text(objPopup.title ?? "")
                    .font(.manrope(.semiBold, size: 17))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(objPopup.subtitle ?? "")
                    .font(.manrope(.regular, size: 16))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if let html = objPopup.description, !html.isEmpty {
                    HTMLTextView(htmlContent: html)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    pushToScreenFromPopup(objPopup, false)
                } label: {
                    Text(objPopup.buttonTitle ?? "Okay")
                        .foregroundColor(.white)
                        .font(.manrope(.semiBold, size: 17))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color(hexString: "#FF9900"))
                        .cornerRadius(10)
                }
            }.padding(.top,10)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .fixedSize(horizontal: false, vertical: true)

    }

    // MARK: - Subviews

    private var popupImage: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: objPopup.image ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 170, maxHeight: 250)

            } placeholder: {
                Image("getkartplaceholder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }

            if !(objPopup.mandatoryClick ?? false) {
                closeButton
            }
        }
        .padding(.bottom, 10)
    }

    private var closeButton: some View {
        Button {
            pushToScreenFromPopup(objPopup, true)
        } label: {
           
                Image("Cross")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                 //   .padding(8)
            
          
        }
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



import SwiftUI

struct HTMLTextView: UIViewRepresentable {
    let htmlContent: String
    var defaultFont: UIFont = .systemFont(ofSize: 15)
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
    }
}




import UIKit

extension NSMutableAttributedString {
    func applyFont(_ font: UIFont) {
        beginEditing()
        enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, range, _ in
            guard let oldFont = value as? UIFont else { return }
            let newFont = UIFont(descriptor: font.fontDescriptor, size: oldFont.pointSize)
            addAttribute(.font, value: newFont, range: range)
        }
        endEditing()
    }
}





class AutoSizingTextView: UITextView {
    override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
*/
