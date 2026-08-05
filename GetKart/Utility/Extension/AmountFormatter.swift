//
//  AmountFormatter.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/04/26.
//

import Foundation

/*
extension Double {

    func indianPriceFormat() -> String {

        let absValue = abs(self)

        switch absValue {

        case 1_00_00_000...:
            let value = self / 1_00_00_000
            return format(value, suffix: "Cr")

        case 1_00_000...:
            let value = self / 1_00_000
            return format(value, suffix: "Lac")

        default:
            return NumberFormatter.indianComma.string(from: NSNumber(value: self)) ?? "\(self)"
        }
    }

    private func format(_ value: Double, suffix: String) -> String {
        let isWhole = value.truncatingRemainder(dividingBy: 1) == 0
        let formatted = String(format: isWhole ? "%.0f" : "%.1f", value)
        return "\(formatted) \(suffix)"
    }
}

extension NumberFormatter {

    static let indianComma: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Int {
    func formatViews() -> String {
        let num = Double(self)

        if num < 1000 {
            return "\(self)"
        } else if num < 1_000_000 {
            return format(num / 1000) + "K"
        } else if num < 1_000_000_000 {
            return format(num / 1_000_000) + "M"
        } else {
            return format(num / 1_000_000_000) + "B"
        }
    }

    private func format(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10   // round to 1 decimal

        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", rounded)
        } else {
            return String(format: "%.1f", rounded)
        }
    }
}
*/



import Foundation

enum CurrencySystem {
    case indian
    case western
    
    static func system(forSymbol symbol: String) -> CurrencySystem {
        let cleanSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch cleanSymbol {
        case "₹", "Rs", "Rs.", "INR":
            return .indian
        default:
            return .western
        }
    }
}

extension Double {

    /// Formats prices dynamically. Fallback defaults automatically to the system's current currency symbol.
    func priceFormat(forSymbol symbol: String? = Local.shared.currencySymbol) -> String {
        let activeSymbol = symbol ?? ""
        let system = CurrencySystem.system(forSymbol: activeSymbol)
        let formattedValue = self.priceFormat(for: system)
        
//        return "\(activeSymbol)\(formattedValue)"
        return "\(formattedValue)"

    }

    func priceFormat(for system: CurrencySystem) -> String {
        let absValue = abs(self)

        switch system {
        case .indian:
            switch absValue {
            case 1_00_00_000...:
                return format(self / 1_00_00_000) + " Cr"
            case 1_00_000...:
                return format(self / 1_00_000) + " Lac" // Fixed divisor back to 1 Lakh
            default:
                return NumberFormatter.indianComma.string(from: NSNumber(value: self)) ?? "\(self)"
            }

        case .western:
            switch absValue {
            case 1_000_000_000...:
                return format(self / 1_000_000_000) + "B"
                
            case 1_000_000...:
                return format(self / 1_000_000) + "M"
                
            case 10_000...: // 👈 Abbreviates to K only for 5-digit and 6-digit numbers (10,000 to 999,999)
                return format(self / 1_000) + "K"
                
            default: // 👈 Catches 4-digit numbers and lower (anything under 10,000, like 4,449)
                return NumberFormatter.westernComma.string(from: NSNumber(value: self)) ?? "\(self)"
            }


        }
    }

    /// Restored exact rounding logic from your snippet
    private func format(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10   // round to 1 decimal

        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", rounded)
        } else {
            return String(format: "%.1f", rounded)
        }
    }
}

extension NumberFormatter {
    static let indianComma: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let westernComma: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Int {
    /// Formats prices dynamically. Fallback defaults automatically to the system's current currency symbol.
    func priceFormat(forSymbol symbol: String? = Local.shared.currencySymbol) -> String {
        return Double(self).priceFormat(forSymbol: symbol)
    }
}
