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

    private let currentBalance: Double = 1000.00
    private let totalAdded: Double    = 1750.00

    private let transactions: [WalletTransaction] = [
        WalletTransaction(
            title: "Money Added",   txnID: "TXN2026061801",
            amount: 500,            date: "18 Jun 2026", time: "10:30 AM",
            status: .success,       type: .credit,       iconSystemName: "plus"
        ),
        WalletTransaction(
            title: "Money Added",   txnID: "TXN2026061701",
            amount: 1000,           date: "17 Jun 2026", time: "05:15 PM",
            status: .success,       type: .credit,       iconSystemName: "plus"
        ),
        WalletTransaction(
            title: "Money Added",   txnID: "TXN2026061501",
            amount: 250,            date: "15 Jun 2026", time: "08:45 PM",
            status: .pending,       type: .credit,       iconSystemName: "plus"
        ),
        WalletTransaction(
            title: "Product Boost", txnID: "TXN2026061401",
            amount: 525,            date: "14 Jun 2026", time: "12:00 PM",
            status: .success,       type: .debit,        iconSystemName: "rocket.fill"
        )
    ]

    private var filteredTransactions: [WalletTransaction] {
        switch selectedFilter {
        case .all:        return transactions
        case .successful: return transactions.filter { $0.status == .success }
        case .pending:    return transactions.filter { $0.status == .pending }
        case .failed:     return transactions.filter { $0.status == .failed }
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Custom header (matches your app-wide HeaderView pattern) ──
            HeaderView(navigation: navigation, title: "Wallet History")

            // ── Page content ──
            ZStack {
                Color(hex: "#F5F6FA").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Balance card
                        WalletBalanceCardView(
                            balance:    currentBalance,
                            totalAdded: totalAdded
                        )
                        .padding(.horizontal, 20)

                        // Filter tabs
                        WalletFilterTabsView(selected: $selectedFilter)

                        // Transaction list
                        VStack(spacing: 10) {
                            if filteredTransactions.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color(hex: "#D1D5DB"))
                                    Text("No transactions found")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "#9CA3AF"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                ForEach(filteredTransactions) { txn in
                                    WalletTransactionRowView(transaction: txn)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 16)
                }
            }
        }
        // Hides the system navigation bar so HeaderView is the only header
        .navigationBarHidden(true)
    }
}

#Preview {
    WalletTransactionsView()
}



struct WalletBalanceCardView: View {
    let balance: Double
    let totalAdded: Double

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
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "#8A7560"))

                Text("₹\(balance, specifier: "%.2f")")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1206"))

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "#8A7560"))
                        .frame(width: 7, height: 7)
                    Text("Total Added: ₹\(totalAdded, specifier: "%.2f")")
                        .font(.system(size: 14))
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
                            .font(.system(size: 14, weight: selected == tab ? .semibold : .regular))
                            .foregroundColor(selected == tab ? .white : Color(hex: "#6B7280"))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(selected == tab ? Color(hex: "#F4A623") : Color.white)
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
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Transaction Row

struct WalletTransactionRowView: View {
    let transaction: WalletTransaction

    private var amountColor: Color {
        transaction.type == .credit ? Color(hex: "#2DB87A") : Color(hex: "#E84646")
    }
    private var amountText: String {
        let prefix = transaction.type == .credit ? "+" : "-"
        return "\(prefix)₹\(String(format: "%.2f", transaction.amount))"
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(transaction.type.iconBackground)
                    .frame(width: 46, height: 46)
                Image(systemName: transaction.iconSystemName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(transaction.type.iconColor)
            }

            // Title + TxnID
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#111827"))
                Text("Txn ID: \(transaction.txnID)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#9CA3AF"))
            }

            Spacer()

            // Amount + date + badge
            VStack(alignment: .trailing, spacing: 4) {
                Text(amountText)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(amountColor)

                Text("\(transaction.date) • \(transaction.time)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#9CA3AF"))

                Text(transaction.status.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(transaction.status.color)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(transaction.status.backgroundColor)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
