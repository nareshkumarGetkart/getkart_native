//
//  Utility.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 17/02/25.
//

import Foundation
import SwiftUI
import UIKit


let scenes = UIApplication.shared.connectedScenes
let windowScene = scenes.first as? UIWindowScene
let window = windowScene?.windows.first
let heightScreen = window?.screen.bounds.height ?? 0
let widthScreen = window?.screen.bounds.width ?? 0

extension Font {
    enum ManropeFont {
        
        case semiBold
        case bold
        case medium
        case regular
        case extraBold
        
        case custom(String)
        
        var value: String {
            
            switch self {
                
            case .semiBold:
                return "Manrope-SemiBold"
                
            case .custom(let name):
                return name
            case .bold:
                return "Manrope-Bold"
            case .medium:
                return "Manrope-Medium"
            case .regular:
                return "Manrope-Regular"
            case .extraBold:
                return "Manrope-ExtraBold"
            }
        }
        
    }
    static func manrope(_ type: ManropeFont, size: CGFloat = 16) -> Font {
        return .custom(type.value, size: size)
    }
}







extension UIFont {
    enum ManropeFont {
        
        case semiBold
        case bold
        case medium
        case regular
        case extraBold
        
        case custom(String)
        
        var value: String {
            
            switch self {
                
            case .semiBold:
                return "Manrope-SemiBold"
                
            case .custom(let name):
                return name
            case .bold:
                return "Manrope-Bold"
            case .medium:
                return "Manrope-Medium"
            case .regular:
                return "Manrope-Regular"
            case .extraBold:
                return "Manrope-ExtraBold"
            }
        }
        
    }
    static func manrope(_ type: ManropeFont, size: CGFloat = 16) -> Font {
        return .custom(type.value, size: size)
    }
}




extension Font {
    enum InterFont {
        
        case semiBold
        case bold
        case medium
        case regular
        case extraBold
        
        case custom(String)
        
        var value: String {
            
            switch self {
                
            case .semiBold:
                return "Inter-SemiBold"
                
            case .custom(let name):
                return name
            case .bold:
                return "Inter-Bold"
            case .medium:
                return "Inter-Medium"
            case .regular:
                return "Inter-Regular"
            case .extraBold:
                return "Manrope-Black"
            }
        }
        
    }
    static func inter(_ type: InterFont, size: CGFloat = 16) -> Font {
        return .custom(type.value, size: size)
    }
}
