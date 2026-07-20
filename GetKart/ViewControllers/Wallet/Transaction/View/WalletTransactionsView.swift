//
//  WalletTransactionsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/06/26.
//

import SwiftUI

struct WalletTransactionsView: View {

    var navigation: UINavigationController?
    @State private var selectedFilter: WalletFilterTab = .all
    @StateObject private var transactionObj = WalletTransactionViewModel()
    
    var body: some View {
        VStack(spacing: 0) {

            HeaderView(navigation: navigation, title: "Wallet History")

            // ── Page content ──
            ZStack {
                if getThemeSelected() == .light{
                    Color(hex: "#F5F6FA").ignoresSafeArea()
                }else{
                    Color(.systemGray5).ignoresSafeArea()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Balance card
                        WalletBalanceCardView(
                            balance:    transactionObj.currentBalance,
                            totalAdded: transactionObj.totalAdded
                        )
                        .padding(.horizontal, 10)

                        // Filter tabs
                        if #available(iOS 17.0, *) {
                            WalletFilterTabsView(selected: $selectedFilter)
                                .onChange(of: selectedFilter) {
                                    if transactionObj.listType != selectedFilter{
                                        transactionObj.listType = selectedFilter
                                        transactionObj.callInitialLoading()
                                    }
                                }
                        } else {
                            // Fallback on earlier versions
                        }

                        // Transaction list
                        VStack(spacing: 10) {
                            if transactionObj.transacrions.isEmpty {
                                VStack(spacing: 12) {
                                    Image("no_data_found_illustrator")
                                        .font(.system(size: 70))
                                        .foregroundColor(Color(hex: "#D1D5DB"))
                                    Text("No transactions found")
                                        .font(.inter(.regular,size: 15))
                                        .foregroundColor(Color(hex: "#9CA3AF"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                ForEach(transactionObj.transacrions,id: \.id) { txn in
                                    WalletTransactionRowView(transaction: txn)
                                        .onAppear{
                                            if txn.id == transactionObj.transacrions.last?.id {
                                                loadNextPageIfAllowed()
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 16)
                }
            }
        }
        // Hides the system navigation bar so HeaderView is the only header
        .navigationBarHidden(true)
    }
    
    func loadNextPageIfAllowed() {
        guard
            !transactionObj.isDataLoading,
            transactionObj.hasMoreData
        else { return }
        
        transactionObj.getWalletHistory()
    }
    
    func getThemeSelected() ->AppTheme{
        
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        return theme
    }
}

#Preview {
    WalletTransactionsView()
}



struct WalletBalanceCardView: View {
    let balance: Int
    let totalAdded: Int

    var body: some View {
        ZStack(alignment: .leading) {
            // Gradient background
            LinearGradient(
                colors: [Color(hex: "#FDDCAA"), Color(hex: "#FDF0D5")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative grid (right side only)
            GeometryReader { geo in
                let startX = geo.size.width * 0.55
                let colSpacing: CGFloat = 38
                let colCount = 5
                let rowCount = 4

                ForEach(0..<colCount, id: \.self) { col in
                    Path { path in
                        let x = startX + CGFloat(col) * colSpacing
                        path.move(to: .init(x: x, y: 0))
                        path.addLine(to: .init(x: x, y: geo.size.height))
                    }
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                }
              
                ForEach(0..<rowCount, id: \.self) { row in
                    Path { path in
                        let y = CGFloat(row) * (geo.size.height / CGFloat(rowCount - 1))
                        path.move(to: .init(x: startX, y: y))
                        path.addLine(to: .init(x: geo.size.width, y: y))
                    }
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                }
            }

            // Text content
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Balance")
                    .font(.inter(.regular,size: 15))
                    .foregroundColor(Color(hex: "#8A7560"))

                Text("₹\(balance)")
                    .font(.inter(.bold,size: 36))
                    .foregroundColor(Color(hex: "#1A1206"))

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "#8A7560"))
                        .frame(width: 7, height: 7)
                    Text("Total Added: ₹\(totalAdded)")
                        .font(.inter(.regular,size: 14))
                        .foregroundColor(Color(hex: "#5C4A30"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Filter Tabs

struct WalletFilterTabsView: View {
    @Binding var selected: WalletFilterTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(WalletFilterTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                           // .font(.system(size: 14, weight: selected == tab ? .semibold : .regular))
                        
                            .font(.inter(((selected == tab) ? .semiBold : .regular),size: 14))
                            .foregroundColor(selected == tab ? .primary : Color(hex: "#6B7280"))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(selected == tab ? Color(hex: "#F4A623") : Color(.systemBackground))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(
                                    selected == tab ? Color.clear : Color(hex: "#E5E7EB"),
                                    lineWidth: 1.2
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

// MARK: - Transaction Row

struct WalletTransactionRowView: View {
    let transaction: WalletTransaction
    
    private var amountColor: Color {
        transaction.type == "credit" ? Color(hex: "#2DB87A") : Color(hex: "#E84646")
    }
    private var amountText: String {
        let prefix = transaction.type == "credit" ? "+" : "-"
        //        return "\(prefix)₹\(String(format: "%.2f", transaction.amount))"
        
        return "\(prefix)₹\(transaction.amount)"
        
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon circle
            ZStack {
                let type = ((transaction.type == "credit") ? TransactionType.credit : TransactionType.debit)
                
                let icon = ((transaction.type == "credit") ? "plus" : "minus")
                
                Circle()
                    .fill(type.iconBackground)
                    .frame(width: 46, height: 46)
                
                Image(systemName: icon)
                    .font(.inter(.medium,size: 18))
                    .foregroundColor(type.iconColor)
            }
            
            // Title + TxnID
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.inter(.medium,size: 15))
                //.foregroundColor(Color(hex: "#111827"))
                if (self.transaction.paymentTransactionID != nil){
                    Text("Txn ID: \(transaction.txnID)")
                        .font(.inter(.regular,size: 12))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                }else{
                    Text("Credited on")
                        .font(.inter(.regular,size: 12))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                }
            }
            
            Spacer()
            
            // Amount + date + badge
            VStack(alignment: .trailing, spacing: 4) {
                Text(amountText)
                    .font(.inter(.bold,size: 15))
                    .foregroundColor(amountColor)
                
                Text("\(transaction.createdAt.formattedDate) • \(transaction.createdAt.formattedTime)")
                    .font(.inter(.regular,size: 11))
                    .foregroundColor(Color(hex: "#9CA3AF"))
                
                if (self.transaction.paymentTransactionID != nil){
                    
                    Text(transaction.status)
                    //.font(.system(size: 10, weight: .semibold))
                        .font(.inter(.semiBold,size: 10))
                        .foregroundColor(getStatusColor(status: transaction.status))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(getStatusColor(status: transaction.status).opacity(0.12))
                    //.clipShape(Capsule())
                        .cornerRadius(5)
                }
                
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.primary.opacity(0.04), radius: 6, x: 0, y: 2)
    }
    
    func getStatusColor(status:String) -> Color{
        
        if status == "success"{
            return Color(hex: "#2DB87A")
        }else if status == "pending"{
            return Color(hex: "#F4A623")
        }else if status == "failed"{
            return Color(hex: "#E84646")
        }
        return Color.black
    }
}


import Foundation

extension String {

    private var isoDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter.date(from: self)
    }

    var formattedDate: String {
        guard let date = isoDate else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        return formatter.string(from: date)
    }

    var formattedTime: String {
        guard let date = isoDate else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        return formatter.string(from: date).lowercased()
    }
}



//    private let transactions: [WalletTransaction] = [
//        WalletTransaction(
//            title: "Money Added",   txnID: "TXN2026061801",
//            amount: 500,            date: "18 Jun 2026", time: "10:30 AM",
//            status: .success,       type: .credit,       iconSystemName: "plus"
//        ),
//        WalletTransaction(
//            title: "Money Added",   txnID: "TXN2026061701",
//            amount: 1000,           date: "17 Jun 2026", time: "05:15 PM",
//            status: .success,       type: .credit,       iconSystemName: "plus"
//        ),
//        WalletTransaction(
//            title: "Money Added",   txnID: "TXN2026061501",
//            amount: 250,            date: "15 Jun 2026", time: "08:45 PM",
//            status: .pending,       type: .credit,       iconSystemName: "plus"
//        ),
//        WalletTransaction(
//            title: "Product Boost", txnID: "TXN2026061401",
//            amount: 525,            date: "14 Jun 2026", time: "12:00 PM",
//            status: .success,       type: .debit,        iconSystemName: "rocket.fill"
//        )
//    ]

//    private var filteredTransactions: [WalletTransaction] {
//        switch selectedFilter {
//        case .all:        return transactions
//        case .successful: return transactions.filter { $0.status == .success }
//        case .pending:    return transactions.filter { $0.status == .pending }
//        case .failed:     return transactions.filter { $0.status == .failed }
//        }
//    }
