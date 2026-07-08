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

    @State private var addAmount: String = "2000"
    @State private var selectedAmount: Int? = 2000

    let quickAmounts = [500, 1000, 2000, 5000]
    
    @StateObject private var walletObj = MyWalletViewModel()
    @State private var paymentGateway: PaymentGatewayCentralized?
    @State private var showSheet = false
    
    var body: some View {
        VStack(spacing: 0) {

            // Custom Header (matches your app-wide HeaderView pattern)
            HeaderView(navigation: navigation, title: "My Wallet")

            // Divider
            Divider()

            ScrollView {
                VStack(spacing: 16) {

                    // Balance Card
                    BalanceCard(availableAmt: walletObj.balance) {
                        self.pushToHistoryButtonAction()
                    }

                    // Add Amount Card
                    AddAmountCard(
                        addAmount: $addAmount,
                        selectedAmount: $selectedAmount,
                        quickAmounts: quickAmounts,
                        onSumbitToAddAmount: {
                            print("selected Amount == \(addAmount) to add")
                            paymentGatewayOpen()
                        }
                    )

                    // Promo Banner
                    PromoBanner()

                    // Ad Banner
                    AdBanner()

                    // How It Works
                    HowItWorksRow(onClickOfRow: {
                        showSheet = true
                    })
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showSheet) {

            WalletInfoSheetView()
                .presentationDetents([.fraction(0.72)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
        }
    }
    
    
    func paymentGatewayOpen() {
        
        paymentGateway = PaymentGatewayCentralized()   //  STRONG REFERENCE
        paymentGateway?.planObj = nil
        paymentGateway?.paymentFor = .wallet
        paymentGateway?.amount = Int(addAmount) ?? 0
        paymentGateway?.callbackPaymentSuccess = { (isSuccess) in
            
            if isSuccess {
                addAmount = ""
                selectedAmount = 0
                self.walletObj.getMyWalletBalance()
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
    let availableAmt:String
    let clickOnHistor:()->Void
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.brandOrangeLight, lineWidth: 1.5)
                )

            VStack(spacing: 6) {
                Text("Available Balance")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .padding(.top, 20)

                Text("₹\(availableAmt)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)

            // History button
            Button(action: {
                clickOnHistor()
                
            }) {
                HStack(spacing: 4) {
                    Text("History")
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                }
                .foregroundColor(.textSecondary)
                .padding(.top, 14)
                .padding(.trailing, 16)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    
}

// MARK: - Add Amount Card
struct AddAmountCard: View {
    @Binding var addAmount: String
    @Binding var selectedAmount: Int?
    let quickAmounts: [Int]
    let onSumbitToAddAmount:()->Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Amount Input
            VStack(alignment: .leading, spacing: 4) {
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
            }

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
                    onSumbitToAddAmount()
                }
              
            }) {
                Text("Add Balance")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background( addAmount.isEmpty ? Color.gray : Color.brandOrange)
                    .cornerRadius(12)
                    .disabled(addAmount.isEmpty)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
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
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .brandOrange : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white)
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
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("🎁")
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 3) {
                Text("Add ₹2,000 and above to get")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black)

                Text("Double Wallet Balance instantly!")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.purpleAccent)

                Text("Enjoy 100% bonus credit on every eligible top-up.")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.promoBackground)
        .cornerRadius(14)
    }
}

// MARK: - Ad Banner
struct AdBanner: View {
    var body: some View {
        ZStack(alignment: .leading) {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.88, blue: 1.0),
                    Color(red: 0.75, green: 0.65, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(16)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Small or big,")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.35))
                    Text("every business")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.35))
                    HStack(spacing: 4) {
                        Text("can ")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.35))
                        Text("grow")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.purpleAccent)
                            .underline()
                        Text(" with us.")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.35))
                    }

                    Spacer().frame(height: 8)

                    HStack(spacing: 12) {
                        AdFeaturePill(icon: "rocket", label: "Grow Faster")
                        AdFeaturePill(icon: "person.2", label: "Reach More")
                    }
                    HStack(spacing: 12) {
                        AdFeaturePill(icon: "chart.bar", label: "Boost Sales")
                        AdFeaturePill(icon: "hand.thumbsup", label: "Trusted Support")
                    }
                }
                .padding(.leading, 16)
                .padding(.vertical, 18)

                Spacer()
            }
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
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        }
    }
}

// MARK: - Preview
struct MyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        MyWalletView()
    }
}
