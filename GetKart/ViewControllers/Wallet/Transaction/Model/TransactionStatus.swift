//
//  TransactionStatus.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/06/26.
//

import Foundation
import UIKit
import SwiftUI

enum TransactionStatus {
    case success, pending, failed

    var label: String {
        switch self {
        case .success: return "SUCCESS"
        case .pending: return "PENDING"
        case .failed:  return "FAILED"
        }
    }

    var color: Color {
        switch self {
        case .success: return Color(hex: "#2DB87A")
        case .pending: return Color(hex: "#F4A623")
        case .failed:  return Color(hex: "#E84646")
        }
    }

    var backgroundColor: Color {
        color.opacity(0.12)
    }
}


enum TransactionType {
    case credit, debit

    var iconColor: Color {
        switch self {
        case .credit: return Color(hex: "#2DB87A")
        case .debit:  return Color(hex: "#E84646")
        }
    }

    var iconBackground: Color {
        iconColor.opacity(0.12)
    }
}

// MARK: - Filter Tab

enum WalletFilterTab: String, CaseIterable {
    case all        = "All"
    case successful = "Successfull"
    case pending    = "Pending"
    case failed     = "Failed"
}
