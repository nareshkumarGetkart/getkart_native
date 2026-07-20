//
//  WalletView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 23/06/26.
//


import SwiftUI

// MARK: - Color Extensions
extension Color {
    
    static let brandOrange = Color(red: 230/255, green: 150/255, blue: 30/255)
    static let brandOrangeLight = Color(red: 253/255, green: 235/255, blue: 200/255)
    static let promoBackground = Color(red: 235/255, green: 230/255, blue: 255/255)
    static let cardBackground = Color(red: 252/255, green: 248/255, blue: 240/255)
    static let borderGray = Color(red: 220/255, green: 220/255, blue: 220/255)
    static let textSecondary = Color(red: 120/255, green: 120/255, blue: 120/255)
    static let purpleAccent = Color(red: 100/255, green: 60/255, blue: 200/255)
}

// MARK: - Main View
struct MyWalletView: View {
    var navigation: UINavigationController?

    @State private var addAmount: String = ""
    @State private var selectedAmount: Int? = 0
    @State private var quickAmounts = [500, 1000, 2000, 5000]
    
    @StateObject private var walletVM = MyWalletViewModel()
    @State private var paymentGateway: PaymentGatewayCentralized?
    @State private var showSheet = false
    @State private var termsSheet = false
    
    
    var body: some View {
        VStack(spacing: 0) {

            // Custom Header (matches your app-wide HeaderView pattern)
            HeaderView(navigation: navigation, title: "My Wallet")
            .onDisappear{
                    termsSheet = false
            }

            // Divider
            Divider()

            ScrollView {
                VStack(spacing: 16) {

                    // Balance Card
                    BalanceCard(availableAmt: walletVM.walletObj?.balance ?? 0) {
                        self.pushToHistoryButtonAction()
                    }

                    // Add Amount Card
                    AddAmountCard(
                        addAmount: $addAmount,
                        selectedAmount: $selectedAmount,
                        quickAmounts: quickAmounts,
                        onSumbitToAddAmount: {
                            print("selected Amount == \(addAmount) to add")
                            if let amt = Int(addAmount),amt > 0 {
                                paymentGatewayOpen()

                            }
                        }
                    )

                    // Promo Banner
                    if (walletVM.walletObj?.bonusAmount ?? 0) > 0{
                        PromoBanner(bonusAmount: walletVM.walletObj?.bonusAmount ?? 0)
                    }

                    // Ad Banner
                    AdBanner(bannerImg: walletVM.walletObj?.banner ?? "")

                    // How It Works
                    HowItWorksRow(onClickOfRow: {
                        showSheet = true
                    })
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background((getThemeSelected() == .light) ? Color(UIColor.systemGroupedBackground) : Color(.systemGray5))
        }
        .navigationBarHidden(true)
       
        .sheet(isPresented: $showSheet) {
            
            WalletInfoSheetView(points:walletVM.walletObj?.howItWorks ?? [],
                                termsClick: {
                showSheet = false
                termsSheet = true
            })
            .presentationDetents([.fraction(0.67)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(20)
            .presentationBackground(Color(.systemBackground)) //sheet background
        }
        
        .sheet(isPresented: $termsSheet) {
            
            WalletInfoSheetView(points:walletVM.walletObj?.bonusAmountTermsCondition ?? [],
                                termsClick: {
                
            },isTerms: true)
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(20)
            .presentationBackground(Color(.systemBackground)) //sheet background
        }
        
        .onChange(of: walletVM.walletObj?.bonusAmount) { bonus in
            if selectedAmount == 0 && (bonus ?? 0) > 0 {
                updateArrayWithCheck()
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    
    func getThemeSelected() ->AppTheme{
        
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        return theme
    }
    
    func updateArrayWithCheck() {
        
        guard let bonus = walletVM.walletObj?.bonusAmount, bonus > 0 else { return }

        selectedAmount = bonus
        addAmount = "\(bonus)"

        if !quickAmounts.contains(bonus) {
            let index = quickAmounts.firstIndex(where: { $0 > bonus }) ?? quickAmounts.endIndex
            quickAmounts.insert(bonus, at: index)
        }
    }
    
   
    func paymentGatewayOpen() {
        
        paymentGateway = PaymentGatewayCentralized()
        paymentGateway?.planObj = nil
        paymentGateway?.paymentFor = .wallet
        paymentGateway?.amount = Int(addAmount) ?? 0
        paymentGateway?.callbackPaymentSuccess = { (isSuccess) in
            
            if isSuccess {
                addAmount = ""
                selectedAmount = 0
                
                self.walletVM.getMyWalletBalance()
                let vc = UIHostingController(
                    rootView: PlanBoughtSuccessView(
                        navigationController: self.navigation,paymentType:.wallet
                    )
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigation?.present(vc, animated: true)
            }
            
            //  RELEASE
            self.paymentGateway = nil
        }
        
        paymentGateway?.initializeDefaults()
    }
    
    func pushToHistoryButtonAction(){
        let vc = UIHostingController(rootView: WalletTransactionsView(navigation: self.navigation))
        self.navigation?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - Balance Card
struct BalanceCard: View {

    let availableAmt: Int
    let clickOnHistor: () -> Void

    var body: some View {

        VStack(spacing: 0) {

            // Header
            ZStack {

                LinearGradient(
                    stops: [
                        .init(color: Color(red: 255/255, green: 248/255, blue: 238/255), location: 0),
                        .init(color: Color(red: 255/255, green: 236/255, blue: 205/255), location: 0.45),
                        .init(color: Color(red: 255/255, green: 220/255, blue: 170/255), location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                // Center title
                Text("Available Balance")
                    .font(.inter(.semiBold,size: 18.0))
                    .foregroundColor(.black)

                // Top-right History
                VStack {
                    HStack {

                        Spacer()

                        Button(action: clickOnHistor) {
                            HStack(spacing: 3) {
                                Text("History")
                                    .font(.inter(.medium,size: 13.0))
                                Image(systemName: "clock.arrow.circlepath")
                                .font(.inter(.medium,size: 12.0))                            }
                            .foregroundColor(.black)
                        }
                    }

                    Spacer()
                }
                .padding(.top, 12)
                .padding(.trailing, 14)
            }
            .frame(height: 68)

            Divider()

            // Balance
            VStack {

                Text("₹\(availableAmt)")
                    .font(.inter(.bold,size: 42.0))
                    .foregroundColor(.primary)
                    .padding(.vertical, 22)

            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))

        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                //.stroke(Color.gray.opacity(0.22), lineWidth: 1)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
}

// MARK: - Add Amount Card
struct AddAmountCard: View {
    @Binding var addAmount: String
    @Binding var selectedAmount: Int?
    let quickAmounts: [Int]
    let onSumbitToAddAmount:()->Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            // Amount Input
           /* VStack(alignment: .leading, spacing: 4) {
                Text("Add amount *")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.textSecondary)
                    .padding(.leading, 4)

                HStack(spacing: 6) {
                    Text("₹")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black)
                    TextField("", text: $addAmount)
                        .font(.system(size: 17, weight: .regular))
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.borderGray, lineWidth: 1)
                )
                */
                
                ZStack(alignment: .topLeading) {

                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.borderGray)

                    Text("Add amount *")
                        .font(.inter(.regular,size: 13.0))
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, 8)
                        .background(Color(.systemBackground))
                        .offset(x: 18, y: -8)

                    HStack(spacing:8){

                        Text("₹")
                            .font(.inter(.medium,size: 15.0))
                        TextField("", text: $addAmount)
                            .keyboardType(.numberPad)
                            .font(.title3)
                            .onChange(of: addAmount) { newValue in

                                    // Allow only digits
                                    let filtered = newValue.filter { $0.isNumber }

                                    // Limit to 6 digits (100000)
                                    let limited = String(filtered.prefix(6))

                                    if let amount = Int(limited) {
                                        if amount > 100000 {
                                            addAmount = "100000"
                                        } else {
                                            addAmount = limited
                                        }
                                    } else {
                                        addAmount = limited
                                    }
                                }

                    }
                    .padding(.horizontal,18)
                    .padding(.top,18)
                }
                .frame(height:55)
                
                
           // }

            // Quick Select Amounts
            HStack(spacing: 10) {
                ForEach(quickAmounts, id: \.self) { amount in
                    QuickAmountButton(
                        amount: amount,
                        isSelected: selectedAmount == amount,
                        action: {
                            selectedAmount = amount
                            addAmount = "\(amount)"
                        }
                    )
                }
            }

            // Add Balance Button
            Button(action: {
                
                if addAmount.trim().count > 0{
                    UIApplication.shared.endEditing()
                    onSumbitToAddAmount()
                }
              
            }) {
                Text("Add Balance")
                    .font(.inter(.semiBold,size: 16.0))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background((addAmount.isEmpty || addAmount.hasPrefix("0")) ? Color.gray : Color.brandOrange)
                    .cornerRadius(8)
                    .disabled(addAmount.isEmpty || addAmount.hasPrefix("0"))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.04), radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                //.stroke(Color.gray.opacity(0.22), lineWidth: 1)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
    
    func getThemeSelected() ->AppTheme{
        
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        return theme
    }
}

// MARK: - Quick Amount Button
struct QuickAmountButton: View {
    let amount: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(amount)")
                .font(.inter(.medium,size: 14.0))
                .foregroundColor(isSelected ? .brandOrange : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                //.background(Color.white)
                .background(
                    isSelected
                    ? Color(red:255/255, green:247/255, blue:236/255)
                    : Color(.systemBackground)
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color.brandOrange : Color.borderGray,
                            lineWidth: isSelected ? 1.5 : 1
                        )
                )
        }
    }
}

// MARK: - Promo Banner
struct PromoBanner: View {
    
    let bonusAmount:Int
    var body: some View {
        HStack(spacing: 12) {
            Text("🎁")
                .font(.system(size: 30))

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading,spacing:1){
                    Text("Add ₹\(bonusAmount) and above to get")
                        .font(.inter(.medium,size: 13.0))
                        .foregroundColor(.black)
                    
                    Text("Double Wallet Balance instantly!")
                        .font(.inter(.semiBold,size: 13.0))
                    // .foregroundColor(.black)
                        .foregroundColor(Color(hex:"#6d1797"))
                        .foregroundColor(.purpleAccent)
                }

                Text("Enjoy 100% bonus credit on every eligible top-up.")
                    .font(.inter(.regular,size: 12.0))
                    .foregroundColor(.black)
                    .foregroundColor(.textSecondary)//.padding(.top,8)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.promoBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                //.stroke(Color.gray.opacity(0.22), lineWidth: 1)
                .stroke(Color.borderGray, lineWidth: 1)
        )
        
    }
}

import Kingfisher

// MARK: - Ad Banner
struct AdBanner: View {
    let bannerImg:String
    var body: some View {
        HStack {
            KFImage(URL(string: bannerImg)).onSuccess { result in
                
            }
            .resizable()
            .scaledToFill()
            .clipped()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
    }
}

struct AdFeaturePill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.purpleAccent)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.35))
        }
    }
}

// MARK: - How It Works Row
struct HowItWorksRow: View {
    
    let onClickOfRow:()->Void
    var body: some View {
        Button(action: {
            
            onClickOfRow()
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.brandOrange)
                    .padding(.leading, 4)

                Text("How it works")
                    .font(.inter(.medium,size: 15.0))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: Color.primary.opacity(0.04), radius: 4, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    //.stroke(Color.gray.opacity(0.22), lineWidth: 1)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }
    
    
    func getThemeSelected() ->AppTheme{
        
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        return theme
    }
}

// MARK: - Preview
struct MyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        MyWalletView()
    }
}
