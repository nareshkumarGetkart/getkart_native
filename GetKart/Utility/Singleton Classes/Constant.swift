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
                return "https://adminweb.getkart.com/api/"
            }else if devEnvironment == .staging {
                return "https://admin.gupsup.com/api/"
            }else {
                return "https://admin.gupsup.com/api/"
            }
        }
    }
    
    var socketUrl:String{
        get{
            if devEnvironment == .live {
                return "https://chat.pickzon.io/chat"
            }else if devEnvironment == .staging {
                return "https://chatter.getkart.ca"
            }else{
                return "https://chatter.getkart.ca"
            }
        }
    }
    
    var user_Insights:String {
        get {
            return "\(baseURL)/v1/user-Insights"
        }
    }
    
   
    
}


enum StoryBoard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static let preLogin = UIStoryboard(name: "PreLogin", bundle: nil)
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
    
   
    case profile
    case appShare
   
}


class ShareMedia{
    
    static func shareMediafrom(type:MediaShareType,mediaId:String,controller:UIViewController){
        
        //var baseUrl = "https://www.pickzon.com"
        var baseUrl = "https://pzdl.pickzon.com"
        
        if type == .profile{
            baseUrl = "\(baseUrl)/profile/\(mediaId)"
            
            
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
}


let sendMobileOtpUrl = "send-mobile-otp"
let verifyMobileOtpUrl = "verify-mobile-otp"
let userSignupUrl = "user-signup"
