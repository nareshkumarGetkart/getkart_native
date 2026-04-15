//
//  AmountFormatter.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/04/26.
//

import Foundation


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
