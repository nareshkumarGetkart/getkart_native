//
//  Constant.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 08/08/24.
//

import UIKit
import Foundation
import CryptoKit
import CommonCrypto

enum DevEnvironment{
    case live
    case staging
    case development
}

var devEnvironment: DevEnvironment = .staging
var ISDEBUG = true

final class Constant: NSObject {
    
    static let shared = Constant()
    let ErrorMessage = "No Network Connection. Please check your internet connection."
    var userActiveStatus = 0 //0-> account Unapproved ,1 - account Approved
    var isLaunchFirstTime = 1
    
    private override init(){ }
    
    var baseURL:String {
        get {
            if devEnvironment == .live {
                return "https://adminweb.getkart.com/api"
            }else if devEnvironment == .staging {
                return "https://admin.gupsup.com/api"
            }else {
                return "https://admin.gupsup.com/api"
            }
        }
    }
    
    var socketUrl:String{
        //https://chat.getkart.com/chat
        get{
            if devEnvironment == .live {
                return  "https://chat.getkart.com"// "https://chat.getkart.com" //https://getkartchat.getkart.ca"
            }else if devEnvironment == .staging {
                return   "https://chat.gupsup.com" //"https://getkartchat.getkart.ca"
            }else{
                return  "https://chat.gupsup.com" //"https://getkartchat.getkart.ca"
            }
        }
    }
    
    
    
    
    var salt_handler:String {
        get {
            return "\(baseURL)/v1/salt-handler"
        }
    }
    
    var send_mobile_otp_handler:String {
        get {
            return "\(baseURL)/v1/send-mobile-otp-handler"
        }
    }
    
    var verify_mobile_otp_handler:String {
        get {
            return "\(baseURL)/v1/verify-mobile-otp-handler"
        }
    }
    
    
    
    var user_Insights:String {
        get {
            return "\(baseURL)/v1/user-Insights"
        }
    }
    
    
    var verify_email_otp:String {
        get {
            return "\(baseURL)/v1/verify-email-otp"
        }
    }
    
    var sendMobileOtpUrl:String {
        get {
            return"\(Constant.shared.baseURL)/v1/send-mobile-otp"
        }
    }
    var verifyMobileOtpUrl:String{
        get {
            return  "\(Constant.shared.baseURL)/v1/verify-mobile-otp"
        }
    }
    
    
    var update_mobile_visibility:String{
        get {
            return  "\(Constant.shared.baseURL)/update-mobile-visibility"
        }
    }
    
    
    var update_notification:String{
        get {
            return  "\(Constant.shared.baseURL)/v1/update-notification"
        }
    }
    
    
    
    var mobile_verify_update:String{
        get {
            return  "\(Constant.shared.baseURL)/mobile-verify-update"
        }
    }
    
    var userSignupUrl:String{
        get {
            return "\(Constant.shared.baseURL)/v2/user-signup"

        }
    }
    
    
    var alert_popup:String{
        get {
            return "\(Constant.shared.baseURL)/v1/alert-popup"

        }
    }
    
    var get_slider:String{
        get {
            return "\(Constant.shared.baseURL)/v1/get-slider"
        }
    }
    
    var get_item:String{
        get {
            return "\(Constant.shared.baseURL)/v1/get-item"
        }
    }
    
    
    var get_categories:String{
        get {
            return "\(Constant.shared.baseURL)/get-categories"
        }
    }
    
    var send_email_otp:String{
        get{
            return "\(Constant.shared.baseURL)/v1/send-email-otp"
        }
    }
    
    var get_featured_section:String{
        get{
            return "\(Constant.shared.baseURL)/v1/get-featured-section"
            
        }
    }
    
    var get_Countries:String{
        get{
            return "\(Constant.shared.baseURL)/countries"
            
        }
    }
    var get_States:String{
        get{
            return "\(Constant.shared.baseURL)/states"
            
        }
    }
    
    var get_Cities:String{
        get{
            return "\(Constant.shared.baseURL)/cities"
            
        }
    }
    var get_seller:String{
        get{
            return "\(Constant.shared.baseURL)/v1/get-seller"
            
        }
    }
    
    
    var tips:String{
        get{
            return "\(Constant.shared.baseURL)/tips"
            
        }
    }
    
    
    var getLimits:String{
        get{
            return "\(Constant.shared.baseURL)/v1/get-limits"
        }
    }
  
    var get_report_reasons:String{
        get{
            return "\(Constant.shared.baseURL)/get-report-reasons"
            
        }
    }
    
    
    var getCustomfields:String{
        get{
            return "\(Constant.shared.baseURL)/get-customfields"
            
        }
    }
    
    
    var getFilterCustomfields:String{
        get{
            return "\(Constant.shared.baseURL)/v1/get-filterfields"
            
        }
    }
    
    
    var search_suggestions:String{
        
        get{
            return "\(Constant.shared.baseURL)/v1/search-suggestion"
        }
    }
    
    var set_item_total_click:String{
        get{
            return "\(Constant.shared.baseURL)/set-item-total-click"
            
        }
    }
    
    var get_notification_list:String{
        get{
            return "\(Constant.shared.baseURL)/get-notification-list"
            
        }
    }
    
    
    var blogs:String{
        get{
            return "\(Constant.shared.baseURL)/blogs"
            
        }
        
    }
    
   
    var renew_item:String{
        get{
            return "\(Constant.shared.baseURL)/v1/renew-item"
            
        }
        
    }
    
    var cancellation_refund_policy:String{
        get{
            return "\(Constant.shared.baseURL)/get-system-settings?type=cancellation_refund_policy"
            
        }
        
    }
    var about_us:String{
        get{
            return "\(Constant.shared.baseURL)/get-system-settings?type=about_us"
            
        }
        
    }
    
    
    
    var terms_conditions:String{
        get{
            return "\(Constant.shared.baseURL)/get-system-settings?type=terms_conditions"
            
        }
        
    }
    
    
    var privacy_policy:String{
        get{
            return "\(Constant.shared.baseURL)/get-system-settings?type=privacy_policy"
            
        }
        
    }
    
    var faq:String{
        get{
            return "\(Constant.shared.baseURL)/faq"
            
        }
        
    }
    
    
    var payment_transactions:String{
        get{
            return "\(Constant.shared.baseURL)/v1/payment-transactions"
            
        }
    }
    
    
    var get_favourite_item:String{
        get{
            return "\(Constant.shared.baseURL)/get-favourite-item"
            
        }
    }
   
    
    var add_itemURL:String{
        get{
            return "\(Constant.shared.baseURL)/v1/add-item"
        }
    }

    var update_itemURL:String{
        get{
            return "\(Constant.shared.baseURL)/v1/update-item"
            
        }
        
    }
    
    var my_items:String{
        get{
            return "\(Constant.shared.baseURL)/my-items"
        }
        
    }
    
    
    var upload_chat_files:String{
        get{
            return "\(Constant.shared.baseURL)/v1/upload-chat-files"
            
        }
    }
    
    
    var chat_suggestions:String{
        get{
            return "\(Constant.shared.baseURL)/v1/chat-suggestions"
            
        }
    }
    
    
    var manage_favourite:String{
        get{
            return "\(Constant.shared.baseURL)/manage-favourite"
        }
    }
    
    
    var blocked_users:String{
        get {
            return "\(Constant.shared.baseURL)/blocked-users"
        }
    }
    
    
    var item_buyer_list:String{
        get {
            return "\(Constant.shared.baseURL)/item-buyer-list"
        }
    }
    
    var block_user:String{
        get {
            return "\(Constant.shared.baseURL)/block-user"
        }
    }
    
    var unblock_user:String{
        get {
            return "\(Constant.shared.baseURL)/unblock-user"
        }
    }

    
    var update_item_status:String{
        get {
            return "\(Constant.shared.baseURL)/update-item-status"
        }
    }
    
    var delete_item:String{
        get {
            return "\(Constant.shared.baseURL)/delete-item"
        }
    }
    
    var logout:String{
        get {
            return "\(Constant.shared.baseURL)/v1/logout"
        }
    }
    
    
    var get_system_settings:String{
        get {
            return "\(Constant.shared.baseURL)/get-system-settings"
        }
    }
    
    var deleteUser:String{
        get {
            return "\(Constant.shared.baseURL)/delete-user"
        }
    }
    
    
    var get_package:String{
        get {
            return "\(Constant.shared.baseURL)/v1/get-package"
        }
    }
    
    
    var paymentIntent:String{
        get {
            return "\(Constant.shared.baseURL)/v1/payment-intent"
        }
    }
    
    
    var getPaymentSettings:String{
        get {
            return "\(Constant.shared.baseURL)/get-payment-settings"
        }
    }
    
    var update_profile:String{
        get {
            return "\(Constant.shared.baseURL)/update-profile"
        }
    }
    
    var get_package_banner:String{
        get {
            return "\(Constant.shared.baseURL)/v1/get-package-banner"
        }
    }
    
    
    var order_update:String{
        get {
            return "\(Constant.shared.baseURL)/v1/order-update"
        }
    }
    
    var in_app_purchase:String{
        get {
            return "\(Constant.shared.baseURL)/v1/in-app-purchase"
        }
    }
    
    var get_following:String{
        get {
            return "\(Constant.shared.baseURL)/get-following"
        }
    }
    
    var add_reports:String{
        get {
            return "\(Constant.shared.baseURL)/add-reports"
        }
    }
    
    var get_followers:String{
        get {
            return "\(Constant.shared.baseURL)/get-followers"
        }
    }
    
    var follow_unfollow:String{
        get{
            return "\(Constant.shared.baseURL)/follow-unfollow"
        }
    }
    
    var make_item_featured:String{
        get{
            return "\(Constant.shared.baseURL)/v1/make-item-featured"
        }
    }
    
    var send_verification_request:String{
        get{
            return "\(Constant.shared.baseURL)/send-verification-request"
        }
    }
    
    var verification_request:String{
        get{
            return "\(Constant.shared.baseURL)/verification-request"
        }
    }
    
    
    var post_draft_item:String{
        get{
            return "\(Constant.shared.baseURL)/v1/post-draft-item"
        }
    }
    
}


enum StoryBoard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static let preLogin = UIStoryboard(name: "PreLogin", bundle: nil)
    static let postAdd = UIStoryboard(name: "PostAdd", bundle: nil)
    static let chat = UIStoryboard(name: "Chats", bundle: nil)

}


enum Images{
   
//    static let checkCircle = UIImage(named: "checkCircle")
//    static let roundUnSel = UIImage(named: "roundUnSel")
//    static let uncheckPink = UIImage(named: "uncheckPink")
//    static let checkPink = UIImage(named: "checkPink")
//    static let blackCheck = UIImage(named: "blackCheck")
//    static  let dummyCover = UIImage(named: "dummy")
//    static  let notFound = UIImage(named: "notFound")
//    static  let govtId = UIImage(named: "govtId")
//    static  let verify = UIImage(named: "verify")
}










extension UIFont{
    
    enum Manrope{
        
        case regular(size: CGFloat)
        case medium(size: CGFloat)
        case semiBold(size: CGFloat)
        case bold(size: CGFloat)
        case extraBold(size: CGFloat)
        
        var font:UIFont!{
            switch self{
                
            case .regular(size: let size):
                return UIFont(name: "Manrope-Regular", size: size)
                
            case .medium(size: let size):
                return UIFont(name: "Manrope-Medium", size: size)
                
            case .semiBold(size: let size):
                return UIFont(name: "Manrope-SemiBold", size: size)
                
            case .bold(size: let size):
                return UIFont(name: "Manrope-Bold", size: size)
                
            case .extraBold(size: let size):
                return UIFont(name: "Manrope-ExtraBold", size: size)
            }
            
        }
    }
}
    







enum MediaShareType{
    
    case item
    case profile
    case appShare
   
}


class ShareMedia{
    
    static var profileUrl = "https://getkart.com/seller/"
    static var itemUrl = "https://getkart.com/product-details/"

    
    
  
    
    static func shareMediafrom(type:MediaShareType,mediaId:String,controller:UIViewController){
        
        var baseUrl =  "https://getkart.com"
      
        if type == .profile{
            
            baseUrl = "\(baseUrl)/seller/\(mediaId)"
            print("Deep link ==\(baseUrl)")
            let activityController = UIActivityViewController(activityItems: [baseUrl, ActionExtensionBlockerItem()], applicationActivities: nil)
            let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
            activityController.excludedActivityTypes = excludedActivities
            controller.present(activityController, animated: true)
            
        }else if type == .item{
            
            baseUrl = "\(baseUrl)/product-details/\(mediaId)?share=true"
            

            
            print("Deep link ==\(baseUrl)")
            let activityController = UIActivityViewController(activityItems: [baseUrl, ActionExtensionBlockerItem()], applicationActivities: nil)
            let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
            activityController.excludedActivityTypes = excludedActivities
            controller.present(activityController, animated: true)
            
        }else if type == .appShare{
            
            baseUrl = "Getkart \n https://apps.apple.com/in/app/getkart-buy-sell/id1488570846 \n\n Buy and Sell Easily."
            let activityController = UIActivityViewController(activityItems: [baseUrl, ActionExtensionBlockerItem()], applicationActivities: nil)
            let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
            activityController.excludedActivityTypes = excludedActivities
            controller.present(activityController, animated: true)
        }
    }
}
    class ActionExtensionBlockerItem: NSObject, UIActivityItemSource {
        func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
            return "group.NHBQDLLJN4.com.PickZonGroup"
        }

        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            return NSObject()
        }

        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            return String()
        }

        func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
            return nil
        }

        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return String()
        }
    }





enum NotificationKeys:String,CaseIterable{
    
    case reconnectInternet = "reconnectInternet"
    case noInternet = "noInternet"
    case refreshAdsScreen = "refreshAdsScreen"
    
    case refreshChatTblViewScreen = "refreshChatTblViewScreen"

    
}



enum NotiKeysLocSelected:String,CaseIterable{
    case homeNewLocation = "homeNewLocation"
    case filterNewLocation = "filterNewLocation"
    case createPostNewLocation = "createPostNewLocation"
    case buyPackageNewLocation = "buyPackageNewLocation"
    case bannerPromotionNewLocation = "bannerPromotionNewLocation"

    
}


enum ImageName {
    static let userPlaceHolder = UIImage(named: "user-circle")
    static let getKartplaceHolder = UIImage(named: "getkartplaceholder")
}





extension UIDevice{
    

    static  var appVersion : String{
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
   
   static func getDeviceUIDid() ->String{
        

        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    
    static func getDeviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let identifier = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(cString: ptr)
            }
        }

        let deviceList: [String: String] = [
            // iPhone
            "iPhone6,1": "iPhone 5s", "iPhone6,2": "iPhone 5s",
            "iPhone7,2": "iPhone 6", "iPhone7,1": "iPhone 6 Plus",
            "iPhone8,1": "iPhone 6s", "iPhone8,2": "iPhone 6s Plus",
            "iPhone8,4": "iPhone SE (1st generation)",
            "iPhone9,1": "iPhone 7", "iPhone9,3": "iPhone 7",
            "iPhone9,2": "iPhone 7 Plus", "iPhone9,4": "iPhone 7 Plus",
            "iPhone10,1": "iPhone 8", "iPhone10,4": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus", "iPhone10,5": "iPhone 8 Plus",
            "iPhone10,3": "iPhone X", "iPhone10,6": "iPhone X",
            "iPhone11,2": "iPhone XS", "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max", "iPhone11,8": "iPhone XR",
            "iPhone12,1": "iPhone 11", "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone12,8": "iPhone SE (2nd generation)",
            "iPhone13,1": "iPhone 12 mini", "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro", "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,4": "iPhone 13 mini", "iPhone14,5": "iPhone 13",
            "iPhone14,2": "iPhone 13 Pro", "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,6": "iPhone SE (3rd generation)",
            "iPhone15,2": "iPhone 14 Pro", "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone14,7": "iPhone 14", "iPhone14,8": "iPhone 14 Plus",
            "iPhone16,1": "iPhone 15 Pro", "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone15,4": "iPhone 15", "iPhone15,5": "iPhone 15 Plus",

            // Simulators
            "i386": "Simulator", "x86_64": "Simulator", "arm64": "Simulator"
        ]

        return deviceList[identifier] ?? identifier
    }
    
    
    static let  MY_CUSTOM_KEY = "Gr8@98qwmlx"
    static  let  MY_CUSTOM_SALT = "GetkartIndia"
    
    static  func generateShortKeyWithSalt(customValue: String, salt: String, keyLength: Int = 8) -> String {
        // Combine: custom value + salt
        let combinedData = (customValue + salt).data(using: .utf8)!
     
        // SHA-256 hash
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        combinedData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(combinedData.count), &hash)
        }
        let hashedData = Data(hash)
     
        // Base64 URL-safe encoding (no padding, no wrap)
        var encoded = hashedData.base64EncodedString()
        encoded = encoded
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
     
        // Return only the first N characters
        if encoded.count > keyLength {
            let index = encoded.index(encoded.startIndex, offsetBy: keyLength)
            return String(encoded[..<index])
        } else {
            return encoded
        }
    }

}



