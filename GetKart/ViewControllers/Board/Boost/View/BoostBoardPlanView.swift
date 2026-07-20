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
    var packageSelectedPressed: ((_ selPkgObj: PlanModel, _ selPaymentMethod: SelPaymentMethod) -> Void)?
    let boardType:Int
    @State private var currentStep: BoostStep = .selectPlan
    @State private var selectedPlan: PlanModel?
    @State private var selectedPayment: SelPaymentMethod = .wallet
    
    @StateObject private var walletVM = MyWalletViewModel()
    @State private var showInsufficientBalanceAlert = false
    @State private var alertMessage = ""
    
    init(
        categoryId: Int,
        packageSelectedPressed: ((_ selPkgObj: PlanModel, _ selPaymentMethod: SelPaymentMethod) -> Void)? = nil,
        boardType: Int
    ) {

        self.categoryId = categoryId
        self.packageSelectedPressed = packageSelectedPressed
        self.boardType = boardType

        print("INIT BOARD TYPE =", boardType)
        print(" self INIT BOARD TYPE =",  self.boardType)

    }
    var body: some View {
        VStack(spacing: 16) {
            VStack{
                HStack {
                    Spacer()
                    
                    if boardType == 0{
                        Text("Boost your board")
                            .font(.inter(.semiBold, size: 18))
                    }else  if boardType == 1{
                        Text("Boost your Promotional Ad")
                            .font(.inter(.semiBold, size: 18))
                    }else  if boardType == 2{
                        Text("Boost your Promotional Ad")
                            .font(.inter(.semiBold, size: 18))
                    }else  if boardType == 3{
                        
                        Text("Boost your idea")
                            .font(.inter(.semiBold, size: 18))
                    }
                    //                Text(getTitle())
                    //                    .font(.inter(.semiBold, size: 18))
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark").renderingMode(.template)
                            .foregroundColor(Color(.label))
                            .padding(8)
                    }
                }
                StepIndicatorView(step: currentStep)
            }
            if currentStep == .selectPlan {
                Spacer()
                planSelectionView
                
            } else {
                
                paymentView
            }

            /*ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    
                    ForEach(planListArray ?? [], id: \.id) { pkgObj in
                        PlanCardView(planObj: pkgObj)
                            
                        .onTapGesture {
                           /* dismiss()
                            packageSelectedPressed?(pkgObj)*/
                            
                            selectedPlan = pkgObj
                        }
                    }
                    
                    if currentStep == .selectPlan {

                        Button {

                            guard selectedPlan != nil else { return }

                            currentStep = .payment

                        } label: {

                            Text("Continue to Payment")
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
            }*/
        }
        //.padding(.horizontal)
        .padding(.top, 10)
        .background(Color(.systemBackground))
       // .cornerRadius(20, corners: [.topLeft, .topRight])
        //.clipped()
        .onAppear {
            if (planListArray ?? []).isEmpty{
                getPackagesApi()
            }
        }
        .alert("Insufficient Wallet Balance",
               isPresented: $showInsufficientBalanceAlert) {

          
            Button("Ok", role: .cancel) { }

//            Button("Add Money") {
//
//                // Navigate to Add Money screen
//
//            }

        } message: {

            Text(alertMessage)
        }
    }

   
    private var planSelectionView: some View {

        VStack(spacing: 0) {
        

            ScrollView(showsIndicators: false) {

                LazyVStack(spacing: 18) {

                    ForEach(planListArray ?? [], id:\.id) { plan in

                        PlanCardView(
                            planObj: plan,
                            isSelected: selectedPlan?.id == plan.id
                        )
                        .onTapGesture {

                            withAnimation {

                                selectedPlan = plan
                            }
                        }
                    }

                    Button {

                        guard selectedPlan != nil else {

                            return
                        }

                        withAnimation {

                            currentStep = .payment
                        }

                    } label: {

                        HStack {

                            Spacer()

                            Text("Continue to Payment")
                                .font(.inter(.semiBold, size: 18))

                            Image(systemName: "arrow.right")

                            Spacer()
                        }
                        .foregroundColor(.white)
                        .frame(height: 54)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    .padding(.top,5)

                    Button {
                        dismiss()

                       // if let url = URL(string: Constant.shared.BOARDBOOST_DEMO){
                            let vc = UIHostingController(rootView:  PreviewURL(fileURLString:Constant.shared.BOARDBOOST_DEMO))
                            AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)

                        //}
                    } label: {

                        Text("How It Benefits You")
                            .underline()
                            .font(.inter(.medium, size: 15))
                            .foregroundColor(Color(hex:"#192E73"))
                    }
                    .padding(.bottom,25)

                }
                .padding([.horizontal])
            }
        }
    }
    
    private var paymentView: some View {

        ScrollView(showsIndicators: false) {

            VStack(spacing: 14) {

                if let plan = selectedPlan {

                    SelectedPlanCard(planObj: plan)
                }

                Text("Select payment method")
                    .font(.inter(.medium, size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
        
                WalletPaymentCard(
                    isSelected: selectedPayment == .wallet,
                    plan: selectedPlan,
                    walletBalance: Double(walletVM.walletObj?.balance ?? 0)
                )
                .onTapGesture {
                    selectedPayment = .wallet
                }

                
                OtherPaymentCard(
                    isSelected: selectedPayment == .other
                )
                .onTapGesture {
                    selectedPayment = .other
                }

                VStack(spacing:0){
                    Divider().padding([.top],8)
                    TotalAmountView(plan: selectedPlan)
                }

                Button {
                    if let selPlan = selectedPlan{
                        if selectedPayment == .wallet {
                            
                            let planAmount = Double(selPlan.finalPrice ?? "0") ?? 0
                            let walletBalance = Double(walletVM.walletObj?.balance ?? 0)
                            
                            if walletBalance < planAmount {
                                
                                alertMessage = "Your wallet balance is insufficient to purchase this plan. Please add \(Local.shared.currencySymbol)\(Int(planAmount-walletBalance)) to your wallet and try again."
                                showInsufficientBalanceAlert = true
                                return
                            }
                        }
                        dismiss()
                        packageSelectedPressed?(selPlan,selectedPayment)
                    }

                } label: {

                    HStack {

                        Image(systemName: "lock")

                        Text("Pay \(Local.shared.currencySymbol)\(selectedPlan?.finalPrice ?? "0") & Boost Now")
                            .font(.inter(.semiBold, size: 18))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(12)
                }

                Button {
                    dismiss()

                    //if let url = URL(string: Constant.shared.BOARDBOOST_DEMO){
                        let vc = UIHostingController(rootView:  PreviewURL(fileURLString:Constant.shared.BOARDBOOST_DEMO))
                        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true)

                   // }
                } label: {

                    Text("How It Benefits You").font(.inter(.medium, size: 14))
                        .underline()
                        .foregroundColor(Color(hex:"#192E73"))
                }.padding(.bottom,5)

            }
            .padding([.horizontal])
        }
    }
    
    
    func getTitle() ->String{
        if boardType == 0{
            return "Boost your board"
        }else  if boardType == 1{
            return "Boost your Promotional Ad"

        }else  if boardType == 2{
            return "Boost your Promotional Ad"

        }else  if boardType == 3{
            return "Boost your idea"
        }
        return "Boost your board"
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


struct TotalAmountView: View {

    let plan: PlanModel?

    var body: some View {

        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 5) {

                Text("Total Amount")
                    .font(.inter(.medium, size: 16))

                Text("(inclusive of all taxes)")
                    .font(.inter(.regular, size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("\(Local.shared.currencySymbol)\(plan?.finalPrice ?? "0")")
                .font(.inter(.bold, size: 20))
        }
        .padding(.vertical,10)
    }
}

struct SelectedPlanCard: View {

    let planObj: PlanModel

    var body: some View {

        PlanCardView(
            planObj: planObj,
            isSelected: false
        )
    }
}



struct StepIndicatorView: View {

    let step: BoostStep

    var body: some View {

        HStack(spacing:12){

            step(number: 1,
                 title: "Select Plan",
                 active: true)

            Rectangle()
                .fill(Color.gray.opacity(0.35))
                .frame(width:45,height:1)

            step(number: 2,
                 title: "Select Payment",
                 active: step == .payment)

        }
    }

    func step(
        number:Int,
        title:String,
        active:Bool
    ) -> some View {

        HStack(spacing:8){

            Circle()
                .fill(active ? Color.orange : Color.gray)
                .frame(width:28,height:28)
                .overlay{

                    Text("\(number)")
                        .foregroundColor(.white)
                        .font(.inter(.semiBold, size: 14))
                }

            Text(title)
                .font(.inter(.medium, size: 16))
                .foregroundColor(
                    active
                    ? .orange
                    : .gray
                )
        }
    }
}

struct PlanCardView: View {

    let planObj: PlanModel
    let isSelected: Bool
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
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)

        .background(

            isSelected
            ? Color.orange.opacity(0.05)
            : Color(.systemBackground)
        )
    .overlay(

            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Color.orange : Color.gray.opacity(0.35),
                    lineWidth: isSelected ? 2 : 1
                )
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


struct WalletPaymentCard: View {

//    @Binding var isSelected: Bool
    let isSelected: Bool

    let plan: PlanModel?

    var walletBalance: Double = 0

    var body: some View {

        VStack(alignment:.leading, spacing:10){

            HStack {

                Image("wallet")

                VStack(alignment:.leading){

                    Text("Getkart Wallet")
                        .font(.inter(.semiBold, size: 18))

                    Text("Available Balance: ₹\(Int(walletBalance))").font(.inter(.regular, size: 12))
                        .foregroundColor(.orange)
                }

                Spacer()

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .orange : .gray.opacity(0.5))
                
            }

            let amount = Double(plan?.finalPrice ?? "0") ?? 0

            if walletBalance >= amount{
                HStack{
                    VStack(alignment:.leading, spacing:8){
                        
                        Text("₹\(Int(amount)) will be deducted from your wallet balance.").font(.inter(.regular, size: 12))
                        
                        Text("Remaining balance after payment: ₹\(Int(walletBalance - amount))").font(.inter(.regular, size: 12))
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.08))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange.opacity(0.25))
                )
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke( isSelected ? Color.orange : Color.gray.opacity(0.25))
        )
    }
}

struct OtherPaymentCard: View {

    let isSelected: Bool

    var body: some View {


            HStack {

                Image(systemName: "creditcard.fill")

                VStack(alignment: .leading) {

                    Text("Other Payment").font(.inter(.semiBold, size: 18))

                    Text("UPI • Card • NetBanking")
                        .font(.inter(.regular, size: 10))
                        .foregroundColor(.gray)
                }

                Spacer()
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .orange : .gray.opacity(0.5))

            }
            .padding()
            .background(Color(.systemBackground))
            .overlay {

                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.orange : Color.gray.opacity(0.25),
                        lineWidth: 1
                    )
            }
    }
}
