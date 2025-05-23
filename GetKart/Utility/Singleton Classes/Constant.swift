//
//  Constant.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 08/08/24.
//

import UIKit

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
                return  "https://chat.gupsup.com"// "https://chat.getkart.com" //https://getkartchat.getkart.ca"
            }else if devEnvironment == .staging {
                return   "https://chat.gupsup.com" //"https://getkartchat.getkart.ca"
            }else{
                return  "https://chat.gupsup.com" //"https://getkartchat.getkart.ca"
            }
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
            return"\(Constant.shared.baseURL)/send-mobile-otp"
        }
    }
    var verifyMobileOtpUrl:String{
        get {
            return  "\(Constant.shared.baseURL)/verify-mobile-otp"
        }
    }
    
    
    var mobile_verify_update:String{
        get {
            return  "\(Constant.shared.baseURL)/mobile-verify-update"
        }
    }
    
    var userSignupUrl:String{
        get {
            return "\(Constant.shared.baseURL)/v1/user-signup"

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
    
    case deeplinkProfile = "deeplinkProfile"
    case reconnectInternet = "reconnectInternet"
    case noInternet = "noInternet"
    case refreshAdsScreen = "refreshAdsScreen"

}




enum ImageName {
    static let userPlaceHolder = UIImage(named: "user-circle")
    static let getKartplaceHolder = UIImage(named: "getkartplaceholder")
}

