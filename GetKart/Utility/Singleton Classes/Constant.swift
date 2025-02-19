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
                return "https://pickzon.io"
            }else if devEnvironment == .staging {
                return "https://backend.getkart.ca"
            }else {
                return "https://backend.getkart.ca"
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
    
    
    var  user_Insights_info:String {
        get {
            return "\(baseURL)/v1/user-Insights-info"
        }
    }
    
    var generateHashToken:String {
        get {
            return "\(baseURL)/v1/hash"
        }
    }
    
    var user_setting:String{
        get {
            return "\(baseURL)/v1/user-setting"
        }
    }
    
    
    var signup_screen_content:String{
        get {
            return "\(baseURL)/v1/signup-screen-content"
        }
    }
    
    var register:String{
        get {
            return "\(baseURL)/v1/register"
        }
    }
    
    var sendOTP:String{
        get {
            return "\(baseURL)/v1/sotp"
        }
    }
    
    var verifyOTP:String{
        get {
            return "\(baseURL)/v1/votp"
        }
    }
    
    var upload_user_images:String{
        get {
            return "\(baseURL)/v1/upload-user-images"
        }
    }
        
    var social_signup:String{
        get {
            return "\(baseURL)/v1/social-signup"
        }
    }
    
    
    var delete_user_image:String{
        get {
            return "\(baseURL)/v1/delete-user-image"
        }
    }
    
    
    var get_all_user_images:String{
        get {
            return "\(baseURL)/v1/get-all-user-images"
        }
    }
    
  
    var change_image_position:String{
        get {
            return "\(baseURL)/v1/change-image-position"
        }
    }
    
    var premium_type:String{
        get {
            return "\(baseURL)/v1/premium-type"
        }
    }
    
    var user_profile:String{
        get{
            return "\(baseURL)/v1/user-profile"
        }
    }
    
    var nearby_users:String{
        get{
            return "\(baseURL)/v1/nearby-users"
        }
    }
    
    var complete_profile:String{
        get{
            return "\(baseURL)/v1/complete-profile"
        }
    }
    
    var pop_up:String{
        get{
            return "\(baseURL)/v1/pop-up"
        }
    }
    
    var get_match_user_list:String {
        get {
            return "\(baseURL)/v1/get-match-user-list"
        }
    }
    
    var edit_screen_content:String {
        get {
            return "\(baseURL)/v1/edit-screen-content"
        }
    }
    
    var update_profile:String{
        get {
            return "\(baseURL)/v1/update-profile"
        }
    }
    
    
    var swipe_userURL:String{
        get {
            return "\(baseURL)/v1/swipe-user"
        }
    }
    
    var visitorsAPIURL:String{
        get {
            return "\(baseURL)/v1/visitors"
        }
    }
    
    var get_user_info_by_id:String{
        get {
            return "\(baseURL)/v1/get-user-info-by-id"
        }
    }
    
    var premium_planURL:String{
        get {
            return "\(baseURL)/v1/premium-plan"
        }
    }
    
    var  initiate_orderURL:String{
        get {
            return "\(baseURL)/v1/initiate-order"
        }
    }
    
    var  verify_orderURL:String{
        get {
            return "\(baseURL)/v1/verify-order"
        }
    }
    
    
    var get_notifications:String{
        get {
            return "\(baseURL)/v1/get-notifications"
        }
    }
    
    var update_notifications:String{
        get {
            return "\(baseURL)/v1/update-notifications"
        }
    }
    
    var get_block_user:String{
        get {
            return "\(baseURL)/v1/get-block-user"
        }
    }
    
    var user_block:String{
        get {
            return "\(baseURL)/v1/user-block"
        }
    }
    
    var report_reason:String{
        get {
            return "\(baseURL)/v1/report-reason"
        }
    }
    
    var report:String{
        get {
            return "\(baseURL)/v1/report"
        }
    }
    
    var get_like_list:String{
        get {
            return "\(baseURL)/v1/get-like-list"
        }
    }
    
    var user_gifts:String{
        get {
            return "\(baseURL)/v1/user-gifts"
        }
    }
    
    var audio_upload:String{
        get {
            return "\(baseURL)/v1/audio-upload"
        }
    }
    
    var user_notifications:String{
        get {
            return "\(baseURL)/v1/user-notifications"
        }
    }
    
    
    var update_contact_send_otp:String{
        get {
            return "\(baseURL)/v1/update-contact-send-otp"
        }
    }
    
    var update_contact_verify_otp:String{
        get {
            return "\(baseURL)/v1/update-contact-verify-otp"
        }
    }
    
    var order_history:String{
        get {
            return "\(baseURL)/v1/order-history"
        }
    }
    
    
    var secret_mode:String{
        get {
            return "\(baseURL)/v1/secret-mode"
        }
    }
    
    
    var update_location:String{
        get {
            return "\(baseURL)/v1/update-location"
        }
    }
    
    var delete_user_account:String{
        get {
            return "\(baseURL)/v1/delete-user-account"
        }
    }
    
    var get_verification_gesture:String{
        get {
            return "\(baseURL)/v1/get-verification-gesture"
        }
    }
    
    var user_verify_gesture:String{
        get {
            return "\(baseURL)/v1/user-verify-gesture"
        }
    }
    
    var contactus:String{
        get {
            return "\(baseURL)/v1/contactus"
        }
    }
    
    var setting:String{
        get {
            return "\(baseURL)/v1/setting"
        }
    }
    
    var dis_like:String{
        get {
            return "\(baseURL)/v1/dis-like"
        }
    }
    
    var premium_benefits:String{
        get {
            return "\(baseURL)/v1/premium-benefits"
        }
    }
    
    var boost_user_profile:String{
        get {
            return "\(baseURL)/v1/boost-user-profile"
        }
    }
    
    var verification_request:String{
        get {
            return "\(baseURL)/v1/verification-request"
        }
    }
    
    var document_type:String{
        get {
            return "\(baseURL)/v1/document-type"
        }
    }
    
    var logout:String{
        get {
            return "\(baseURL)/v1/logout"
        }
    }
    
    
    var for_you_list:String{
        get {
            return "\(baseURL)/v1/for-you-list"
        }
    }
    
    var disableTravelMode:String{
        get{
            return "\(baseURL)/v1/travel-mode"
        }
    }
    
}


enum StoryBoard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static let preLogin = UIStoryboard(name: "PreLoginStoryboard", bundle: nil)
    static let chat = UIStoryboard(name: "Chat", bundle: nil)
    static let settings = UIStoryboard(name: "Settings", bundle: nil)
}


enum Images{
   
    static let checkCircle = UIImage(named: "checkCircle")
    static let roundUnSel = UIImage(named: "roundUnSel")
    static let uncheckPink = UIImage(named: "uncheckPink")
    static let checkPink = UIImage(named: "checkPink")
    static let blackCheck = UIImage(named: "blackCheck")
    static  let dummyCover = UIImage(named: "dummy")
    static  let notFound = UIImage(named: "notFound")
    static  let govtId = UIImage(named: "govtId")
    static  let verify = UIImage(named: "verify")
}




enum SignUpScreen:Int{
    //Dont change ordering otherwise you will get wrong value
   
    case landingScreen = 0
    case enterMobile
    case introdcution
    case enterEmail
    case enableNotification
    case gender
    case sexualOrientation
    case whatBringsYou
    case whomWouldYouLikeToSee
    case typeOfRelationShip
    case yourHeight
    case haveKids
    case talkAboutLifeStyle
    case religiousAndPoliticalBelief
    case moreAboutYou
    case highestLevelYouAttained
    case likeInterests
    case whereDoYouPutUp
    case addYourPhotos
    case youAreAllSet
}


extension UIViewController{
   
    func navigateToScreen(redirectStep:Int) {
        
        switch redirectStep{
            
        case 0:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "LandingVC") as? LandingVC{
                self.navigationController?.pushViewController(destVC, animated: false)
            }
            break
        case 1:
            
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "IntroductionVC") as? IntroductionVC{
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
            break
        case 2:
            let socialId = UserDefaults.standard.value(forKey: LocalKeys.socialId.rawValue)  as? String ?? ""
            if  socialId.count > 0 {
                if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "LoginPhoneVC") as? LoginPhoneVC{
                    destVC.isToHideBackButton = true
                    destVC.viewModel.type = 1
                    self.navigationController?.pushViewController(destVC, animated: true)
                }
            }else{
                
                /*if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "EnterEmailVC") as? EnterEmailVC{
                    self.navigationController?.pushViewController(destVC, animated: true)
                }*/
                
                if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "GenderVC") as? GenderVC{
                    destVC.isHideBack = true
                    self.navigationController?.pushViewController(destVC, animated: true)
                }
            }
                        
        case 3:
            /*if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "EnableNotificationVC") as? EnableNotificationVC{
                self.navigationController?.pushViewController(destVC, animated: true)
            }*/
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "GenderVC") as? GenderVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
        case 4:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "GenderVC") as? GenderVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        case 5:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "SexualOrientationVC") as? SexualOrientationVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
        case 6:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "WhatBringsYouVC") as? WhatBringsYouVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
        case 7:
            /*if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "WhomYouLikeToSeeVC") as? WhomYouLikeToSeeVC{
                destVC.btnBack.isHidden = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }*/
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "RelationshipLookingVC") as? RelationshipLookingVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
        case 8:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "RelationshipLookingVC") as? RelationshipLookingVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        case 9:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "WhatYourHeightVC") as? WhatYourHeightVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
        case 10:
            /*if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "HaveKidsVC") as? HaveKidsVC{
                destVC.btnBack.isHidden = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }*/
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "TalkAboutLifestyleVC") as? TalkAboutLifestyleVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        case 11:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "TalkAboutLifestyleVC") as? TalkAboutLifestyleVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
        case 12:
            /*if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "TalkLifestyleHabitsVC") as? TalkLifestyleHabitsVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }*/
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "MoreAboutYouVC") as? MoreAboutYouVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        case 13:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "MoreAboutYouVC") as? MoreAboutYouVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            break
        
        case 14:
            /*if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "HighestLevelAttainedVC") as? HighestLevelAttainedVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            break
             */
            
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikesInterestsVC") as? LikesInterestsVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            break
            
        case 15:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "LikesInterestsVC") as? LikesInterestsVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            break
        case 16:
            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "LocationVC") as? LocationVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            break
        case 17:
            if let destVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "AddPhotosVC") as? AddPhotosVC{
                destVC.isHideBack = true
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            break
        case 18:

            if let destVC = StoryBoard.main.instantiateViewController(withIdentifier: "HomeBaseVC") as? HomeBaseVC{
                
                self.navigationController?.pushViewController(destVC, animated: true)
            }
            
            break
            
        default:
            //Home screen user is already login
            
            break
        }
    }
    
    func embed(_ viewController: UIViewController, inView view: UIView) {
            addChild(viewController)
            viewController.willMove(toParent: self)
            viewController.view.frame = view.bounds
            view.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
        
        func removeController(from view: UIView) {
            willMove(toParent: nil)
            view.removeFromSuperview()
            removeFromParent()
        }
    
}



extension UIFont{
    
    enum Inter{
       
        case regular(size: CGFloat)
        case medium(size: CGFloat)
        case semiBold(size: CGFloat)
        case bold(size: CGFloat)
        
        var font:UIFont!{
            switch self{

            case .regular(size: let size):
                return UIFont(name: "Inter-Regular", size: size)
                
            case .medium(size: let size):
                return UIFont(name: "Inter-Medium", size: size)
                
            case .semiBold(size: let size):
                return UIFont(name: "Inter-SemiBold", size: size)
                
            case .bold(size: let size):
                return UIFont(name: "Inter-Bold", size: size)
                
            }
        }
    }
    
}






enum MediaShareType{
    
   
    case profile
   
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
    
    case interestChanged = "interestChanged"
    case deeplinkProfile = "deeplinkProfile"
    case hideWhenEmpty = "hideWhenEmpty"
    case hideImgRejectedPopupWhenUpdated = "hideImgRejectedPopupWhenUpdated"
    case refreshUserList = "refreshUserList"
    case refreshLikeList = "refreshLikeList"
    case PlanBaughtNotification = "PlanBaughtNotification"
    case reconnectInternet = "reconnectInternet"
    case noInternet = "noInternet"
}
