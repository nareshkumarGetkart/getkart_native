//
//  BoostBoardPlanView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 22/12/25.
//

import SwiftUI

struct BoostBoardPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var planListArray:Array<PlanModel>?
    let categoryId:Int
    var packageSelectedPressed: ((_ selPkgObj:PlanModel)->Void)?

    var body: some View {
        VStack(spacing: 16) {
            
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    
                    ForEach(planListArray ?? [], id: \.id) { pkgObj in
                        PlanCardView(planObj: pkgObj).onTapGesture {
                            dismiss()
                            packageSelectedPressed?(pkgObj)
                        }
                    }
                    
                    HStack{
                        Spacer()
                        Button {
                            dismiss()

                            if let url = URL(string: Constant.shared.BOARDBOOST_DEMO){
                                let vc = UIHostingController(rootView:  PreviewURL(fileURLString:Constant.shared.BOARDBOOST_DEMO))
                                AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)

                            }
                        } label: {
                            Text("How It Benefits You").underline() .font(.inter(.medium, size: 14)).foregroundColor(Color(hex:"#192E73")).padding(.top,8)
                        }
                        
                        Spacer()

                    }
                }
                .padding(.bottom, 30)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .clipped()
        .onAppear {
            if (planListArray ?? []).isEmpty{
                getPackagesApi()
            }
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            Text("Boost your board")
                .font(.inter(.semiBold, size: 18))
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark").renderingMode(.template)
                    .foregroundColor(Color(.label))
                    .padding(8)
            }
        }
    }
    
    func getPackagesApi(){
        let strUrl = Constant.shared.get_board_package + "?category_id=\(categoryId)&type=board"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url:strUrl ) { (obj:PromotionPkg) in
            if obj.code == 200 {
                planListArray = obj.data
            }
        }
    }
}

//#Preview {
//    BoostBoardPlanView(categoryId: 0)
//}

struct PlanCardView: View {

    let planObj:PlanModel
    let clicks: String = "10"
    let impressions: String = "20"

    var body: some View {
        VStack(spacing: 12) {

            HStack {
                Text(planObj.name ?? "")
                    .font(.inter(.medium, size: 16))

                Spacer()
                    
                    if (planObj.discountInPercentage ?? "0") != "0"{

                        Text(" \(planObj.discountInPercentage ?? "0")% Savings ").frame(height:20).font(.inter(.medium, size: 13)).background(Color(hexString: "#FF9900")).foregroundColor(.white)
                        
                        
                        let originalPrice = "\(planObj.price ?? "0")".formatNumberWithComma()

                        Text("\(Local.shared.currencySymbol)\(originalPrice)")
                                       .font(.subheadline)
                                       .foregroundColor(.gray)
                                       .strikethrough(true, color: .gray)
                        
                        let amt = "\(planObj.finalPrice ?? "0")".formatNumberWithComma()
                        Text("\(Local.shared.currencySymbol) \(amt)").font(.inter(.regular, size: 16))//.padding(.trailing)
                    }else{
                        let amt = "\(planObj.price ?? "0")".formatNumberWithComma()
                        Text("\(Local.shared.currencySymbol) \(amt)").font(.inter(.regular, size: 16))//.padding(.trailing)
                    }
            }

           

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HTMLContentView(html: planObj.description ?? "")
                }
                Spacer()
                VStack(alignment:.leading) {
                    Spacer()
                    Text("For \(planObj.duration ?? "") days")
                        .font(.inter(.regular, size: 14))
                }//.padding(.trailing)
            }
        }
       // .padding(10)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange, lineWidth: 1)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )

    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
            Text(text)
        }
        .font(.inter(.regular, size: 14))
        .foregroundColor(.gray)
    }
    
}



struct HTMLContentView: View {

    let html: String
    private let parsed: (listItems: [String], plainText: String?)

    init(html: String) {
        self.html = html
        self.parsed = HTMLContentParser.parse(html)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            // Bullet list if present
            if !parsed.listItems.isEmpty {
                ForEach(parsed.listItems, id: \.self) { item in
                    BulletText(text: item)
                }
            }
            // Fallback text
            else if let text = parsed.plainText {
                Text(text)
                    .font(.inter(.regular, size: 14)).foregroundColor(Color(.systemGray))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct BulletText: View {
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Text("•")
                .font(.system(size: 16, weight: .bold))

            Text(text)
                .font(.inter(.regular, size: 14)).foregroundColor(Color(.systemGray))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}


struct HTMLListParser {

    static func parseListItems(from html: String) -> [String] {
        var result: [String] = []

        // Match <li>...</li>
        let pattern = "<li>(.*?)</li>"
        let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        )

        let range = NSRange(html.startIndex..., in: html)
        regex?.matches(in: html, range: range).forEach { match in
            if let range = Range(match.range(at: 1), in: html) {
                let item = html[range]
                    .replacingOccurrences(of: "\n", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                result.append(item)
            }
        }

        return result
    }
}


struct HTMLContentParser {

    static func parse(_ html: String) -> (listItems: [String], plainText: String?) {

        let listItems = HTMLListParser.parseListItems(from: html)

        // Remove HTML tags for plain text
        var plain = html
        plain = plain.replacingOccurrences(of: "<br>", with: "\n")
        plain = plain.replacingOccurrences(of: "<br/>", with: "\n")
        plain = plain.replacingOccurrences(of: "<p>", with: "")
        plain = plain.replacingOccurrences(of: "</p>", with: "\n")

        // Remove remaining tags
        plain = plain.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )

        plain = plain.trimmingCharacters(in: .whitespacesAndNewlines)

        return (listItems, plain.isEmpty ? nil : plain)
    }
}
