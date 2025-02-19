//
//  Extension.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 12/08/24.
//

import Foundation
import UIKit
import SwiftUI


extension UIDevice {
    
    open  var hasNotch: Bool {
        var bottom:CGFloat = 0.0
        if #available(iOS 13.0, *) {
            bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        }else{
            bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        
        return bottom > 0
    }
    
    

        static let modelName: String = {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }

            func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
                #if os(iOS)
                switch identifier {
                case "iPod5,1":                                       return "iPod touch (5th generation)"
                case "iPod7,1":                                       return "iPod touch (6th generation)"
                case "iPod9,1":                                       return "iPod touch (7th generation)"
                case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
                case "iPhone4,1":                                     return "iPhone 4s"
                case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
                case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
                case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
                case "iPhone7,2":                                     return "iPhone 6"
                case "iPhone7,1":                                     return "iPhone 6 Plus"
                case "iPhone8,1":                                     return "iPhone 6s"
                case "iPhone8,2":                                     return "iPhone 6s Plus"
                case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
                case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
                case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
                case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
                case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
                case "iPhone11,2":                                    return "iPhone XS"
                case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
                case "iPhone11,8":                                    return "iPhone XR"
                case "iPhone12,1":                                    return "iPhone 11"
                case "iPhone12,3":                                    return "iPhone 11 Pro"
                case "iPhone12,5":                                    return "iPhone 11 Pro Max"
                case "iPhone13,1":                                    return "iPhone 12 mini"
                case "iPhone13,2":                                    return "iPhone 12"
                case "iPhone13,3":                                    return "iPhone 12 Pro"
                case "iPhone13,4":                                    return "iPhone 12 Pro Max"
                case "iPhone14,4":                                    return "iPhone 13 mini"
                case "iPhone14,5":                                    return "iPhone 13"
                case "iPhone14,2":                                    return "iPhone 13 Pro"
                case "iPhone14,3":                                    return "iPhone 13 Pro Max"
                case "iPhone14,7":                                    return "iPhone 14"
                case "iPhone14,8":                                    return "iPhone 14 Plus"
                case "iPhone15,2":                                    return "iPhone 14 Pro"
                case "iPhone15,3":                                    return "iPhone 14 Pro Max"
                case "iPhone15,4":                                    return "iPhone 15"
                case "iPhone15,5":                                    return "iPhone 15 Plus"
                case "iPhone16,1":                                    return "iPhone 15 Pro"
                case "iPhone16,2":                                    return "iPhone 15 Pro Max"
                case "iPhone8,4":                                     return "iPhone SE"
                case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
                case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
                case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
                case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
                case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
                case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
                case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
                case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
                case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
                case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
                case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
                case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
                case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
                case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
                case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
                case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
                case "iPad14,8", "iPad14,9":                          return "iPad Air (11-inch) (M2)"
                case "iPad14,10", "iPad14,11":                        return "iPad Air (13-inch) (M2)"
                case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
                case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
                case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
                case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
                case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
                case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
                case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
                case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
                case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
                case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
                case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
                case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
                case "iPad16,3", "iPad16,4":                          return "iPad Pro (11-inch) (M4)"
                case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
                case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
                case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
                case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
                case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
                case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
                case "iPad16,5", "iPad16,6":                          return "iPad Pro (13-inch) (M4)"
                case "AppleTV5,3":                                    return "Apple TV"
                case "AppleTV6,2":                                    return "Apple TV 4K"
                case "AudioAccessory1,1":                             return "HomePod"
                case "AudioAccessory5,1":                             return "HomePod mini"
                case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
                default:                                              return identifier
                }
                #elseif os(tvOS)
                switch identifier {
                case "AppleTV5,3": return "Apple TV 4"
                case "AppleTV6,2", "AppleTV11,1", "AppleTV14,1": return "Apple TV 4K"
                case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
                default: return identifier
                }
                #elseif os(visionOS)
                switch identifier {
                case "RealityDevice14,1": return "Apple Vision Pro"
                default: return identifier
                }
                #endif
            }

            return mapToDevice(identifier: identifier)
        }()

    
    
}



//MARK: UIImageview

extension UIImageView{
    
    func setImageTintColor(color:UIColor){
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
    
 
}
//MARK: UICOlor
extension UIColor {
    
    
        
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

//MARK: UIButton
extension UIButton {
    
    func setImageTintColor(color:UIColor){
        self.imageView?.image = self.imageView?.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.tintColor = color
    }

    
func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }
    
    func applyGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.frame.height/2

        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
        self.contentVerticalAlignment = .center
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        self.titleLabel?.textColor = UIColor.white
    }
    
    
 
    
}

//MARK: UITextfield

extension UITextField {
func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }
}

//MARK: UIView
extension UIView {
    
    func applyGradientBackground(colors: [CGColor]) {
      /*  self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 0

        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
        */
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0,0.1]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.insertSublayer(gradientLayer, at: 0)
       
 
    }
    
    
    func setGradientColor(colorOne: UIColor, colorTwo: UIColor) {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
            gradientLayer.locations = [0.0,0.1]
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
            layer.insertSublayer(gradientLayer, at: 0)
       }
    
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }


    func addShadow(shadowColor: CGColor = UIColor.black.cgColor, shadowOpacity: Float = 0.4, shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset  = CGSize(width: 1.0, height: 2.0)
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }
    
     static let kLayerNameGradientBorder = "GradientBorderLayer"

    func gradientBorder(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = .init(x: 0.5, y: 0),
        endPoint: CGPoint = .init(x: 0.5, y: 1),
        andRoundCornersWithRadius cornerRadius: CGFloat = 0,maskName:String = "") {
        let existingBorder = gradientBorderLayer()
        let border = existingBorder ?? .init()
        border.frame = CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y,
            width: bounds.size.width + width,
            height: bounds.size.height + width
        )
        border.colors = colors.map { $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint

        let mask = CAShapeLayer()
        let maskRect = CGRect(
            x: bounds.origin.x + width/2,
            y: bounds.origin.y + width/2,
            width: bounds.size.width - width,
            height: bounds.size.height - width
        )
        mask.path = UIBezierPath(
            roundedRect: maskRect,
            cornerRadius: cornerRadius
        ).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width
        border.mask = mask
        self.layer.name = maskName
        
        let isAlreadyAdded = (existingBorder != nil)
        if !isAlreadyAdded {
            layer.addSublayer(border)
        }
    }

    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter {
            $0.name == UIView.kLayerNameGradientBorder
        }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
    
    func removeSubLayerFromView(){
        for layers in  layer.sublayers ?? []{
            if layers.name == UIView.kLayerNameGradientBorder{
                layers.removeFromSuperlayer()
                break
            }
        }
    }

    
        func asImage() -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        }

}




extension  UITextField {
        
    func addLeftPadding() -> Void {

        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.leftView = leftPaddingVw
        self.leftViewMode = .always
    }

    func addRightPadding() -> Void {

        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.rightView = leftPaddingVw
        self.leftViewMode = .always
    }
    
    func addRightPaddingWithValue(paddingValue:Int = 50) -> Void {

        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: paddingValue, height: paddingValue)
        self.rightView = leftPaddingVw
        self.rightViewMode = .always
    }
    
    func addRightIconToTextFieldWithImg(iconName:NSString,rightXAxisVal:Int = 0,iconXAxis:Int = 10) -> Void {

        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.leftView = leftPaddingVw
        self.leftViewMode = .always

        let rightPaddingVw = UIView()
        rightPaddingVw.frame = CGRect(x: rightXAxisVal, y: 0, width: 40, height: 50)
        self.rightView = rightPaddingVw
        self.rightViewMode = .always

        let rightIconImg = UIImageView()
        rightIconImg.frame = CGRect(x:iconXAxis,y:15,width:20,height:20)
        if iconName.length > 0{
        rightIconImg.image = UIImage(imageLiteralResourceName: iconName as String)
        }
        rightIconImg.contentMode = .scaleAspectFit
        rightPaddingVw.addSubview(rightIconImg)
    }
    
    func addLeftIconToTextFieldWithImg(iconName:NSString) -> Void {
        
        let leftPaddingVw = UIView()
        leftPaddingVw.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        self.leftView = leftPaddingVw
        self.leftViewMode = .always
        
        let rightPaddingVw = UIView()
        rightPaddingVw.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.rightView = rightPaddingVw
        self.rightViewMode = .always
        
        let rightIconImg = UIImageView()
        rightIconImg.frame = CGRect(x:10,y:15,width:20,height:20)
        if iconName.length > 0{
            rightIconImg.image = UIImage(imageLiteralResourceName: iconName as String)
        }
        rightIconImg.contentMode = .scaleAspectFit
        leftPaddingVw.addSubview(rightIconImg)
    }
    
    func setAttributedPlaceHolder(text:String,color:UIColor) -> Void {
       
        self.attributedPlaceholder = NSAttributedString(string: text,
                                                                       attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func setAttributedPlaceHolder(frstText:String,color:UIColor,secondText:String,secondColor:UIColor) -> Void {

        // Initialize with a string only
        let attrStar = NSAttributedString(string: secondText, attributes: [NSAttributedString.Key.foregroundColor: secondColor])
        
        // Initialize with a string and inline attribute(s)
        let attrString2 = NSAttributedString(string: frstText, attributes: [NSAttributedString.Key.foregroundColor: color])
        
        
        let attr1: NSMutableAttributedString = NSMutableAttributedString()
        attr1.append(attrString2)
        attr1.append(attrStar)
        self.attributedPlaceholder = attr1
        
    }
    
    
}


extension UILabel{
    
    func setAttributedString(frstText:String,color:UIColor,firstFont:UIFont,secondText:String,secondColor:UIColor,secondFont:UIFont) {

        // Initialize with a string only
        let attrStar1 = NSAttributedString(string: frstText, attributes: [NSAttributedString.Key.foregroundColor: color,NSAttributedString.Key.font: firstFont])
        
        let attrStar2 = NSAttributedString(string: secondText, attributes: [NSAttributedString.Key.foregroundColor: secondColor,NSAttributedString.Key.font: secondFont])
        
        
        let attr1: NSMutableAttributedString = NSMutableAttributedString()
        attr1.append(attrStar1)
        attr1.append(attrStar2)
        self.attributedText = attr1
        
    }
}

extension String
{
    func trim() -> String
   {
    return self.trimmingCharacters(in: CharacterSet.whitespaces)
   }
}


extension UIApplication {
    static var release: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.x"
    }
    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String? ?? "x"
    }
    static var version: String {
        return "\(release)"
    }
}



extension Color {
    init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue)
    }
   
}



extension Double {
    func rounded(toPlaces places:Int) -> Double {
           let divisor = pow(10.0, Double(places))
           return (self * divisor).rounded() / divisor
       }
}


//MARK: UItableview
extension UITableView {
    
    func reloadAnimately(_ completion: @escaping ()->()) {
        
        UIView.transition(with: self,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations:
                            { () -> Void in
            self.reloadData()
        }, completion: nil);
    }
}



//MARK: UICollectionview
extension UICollectionView {
    
    func reloadAnimately(_ completion: @escaping ()->()) {
        
        UIView.transition(with: self,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations:
                            { () -> Void in
            self.reloadData()
        }, completion: nil);
    }
}


extension UILabel {

    func setTextWithShadow(_ string: String,font:UIFont,color:UIColor) {

        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = CGSize(width: 3, height: 3)
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)

        let attributes = [ NSAttributedString.Key.shadow: shadow,NSAttributedString.Key.font:font,NSAttributedString.Key.foregroundColor:color]
        let attributedString = NSAttributedString(string: string, attributes: attributes)

        self.attributedText = attributedString
    }

}
