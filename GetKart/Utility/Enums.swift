//
//  Enums.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/03/26.
//

import Foundation


enum PaymentMethod: Int {
    case phonePe = 3
    case applePay = 1
    case payUPay = 4

    var title: String {
        switch self {
        case .phonePe:
            return "PhonePe"
        case .applePay:
            return "apple"
        case .payUPay:
            return "Payu"
        }
    }
}

enum PaymentForEnum{
    
    case adsPlan
    case bannerPromotion
    case bannerPromotionDraft
    case boostBoard
    
}
