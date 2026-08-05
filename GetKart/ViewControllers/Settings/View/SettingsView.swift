//
//  SettingsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/07/25.
//

import SwiftUI
import FittedSheets
import StoreKit
import Kingfisher

struct SettingsView: View {
    
    var navigationController: UINavigationController?
    @State private var isNotificationsEnabled: Bool = true
    @State private var isContactInfoVisible: Bool = false
    @State private var isMobileAvailable = false
   // var callbackAction: ((_ action: String) -> Void)

    
    var body: some View {
        
        VStack{
            HeaderView(navigation: navigationController, title: "Settings")

            ScrollView{
               
                VStack(spacing: 5){
                                      
                    SettingRowView(iconStr: "article", title: "Change country/region", subTitle: "", isToggle:false , isOn: .constant(false))
                        .onTapGesture{
                            navigatToScreen(title: "Change country/region")
                        }

                    let obj = RealmManager.shared.fetchLoggedInUserInfo()
                    
                    if obj.userType == 1{
                        SettingRowView(iconStr: "buyer_icon", title: "You are in Buyer mode", subTitle: "Seller mode unlocks tools to grow your business.", isToggle:false , isOn: .constant(false))
                            .onTapGesture {
                               // navigationController?.dismiss(animated: true)
                               // callbackAction("buyerSeller")
                                showBuyerSellerPopup()
                            }

                    }else if obj.userType == 2{
                        SettingRowView(iconStr: "store_icon", title: "You are in Seller mode", subTitle: "Buyer mode unlocks tools to grow your shopping experience.", isToggle:false , isOn: .constant(false))
                            .onTapGesture {
                                showBuyerSellerPopup()
                               // navigationController?.dismiss(animated: true)
                               // callbackAction("buyerSeller")
                            }
                    }
                    
                    

                    SettingRowView(iconStr: "notification", title: "Receive Notification", subTitle: "", isToggle:true , isOn: $isNotificationsEnabled)
                        
                    SettingRowView(iconStr: "article", title: "Blogs", subTitle: "", isToggle:false , isOn: .constant(false))
                        .onTapGesture{
                            navigatToScreen(title: "Blogs")
                        }
                    SettingRowView(iconStr: "rate_us", title: "Rate us", subTitle: "", isToggle:false , isOn: .constant(false))
                        .onTapGesture{
                            navigatToScreen(title: "Rate us")
                        }
                    SettingRowView(iconStr: "contact_us", title: "Contact us", subTitle: "", isToggle:false , isOn: .constant(false))
                        .onTapGesture{
                            navigatToScreen(title: "Contact us")
                        }
                    SettingRowView(iconStr: "about_us", title: "About us", subTitle: "", isToggle:false , isOn: .constant(false))
                        .onTapGesture{
                            navigatToScreen(title: "About us")
                        }
                    SettingRowView(iconStr: "t_c", title: "Terms & Conditions", subTitle: "", isToggle:false , isOn: .constant(false))
                        .onTapGesture{
                            navigatToScreen(title: "Terms & Conditions")
                        }
                    SettingRowView(iconStr: "privacypolicy", title: "Privacy Policy", subTitle: "", isToggle:false , isOn: .constant(false))
                    .onTapGesture{
                        navigatToScreen(title: "Privacy Policy")
                    }
                    
                 
                    SettingRowView(iconStr: "delete_account", title: "Delete Account", subTitle: "", isToggle:false , isOn: .constant(false))
                        .onTapGesture {
                            //navigationController?.dismiss(animated: true)
                            //callbackAction("delete")
                            presentDeleteAccountView()
                        }
                    SettingRowView(iconStr: "logout", title: "Logout", subTitle: "", isToggle:false , isOn: .constant(false))
                        .onTapGesture {

                            presentLogoutView()
                           // callbackAction("logout")

                        }
                    
                    Spacer()
                }.padding(8)
                   
            }
        } .background(Color(UIColor.secondarySystemBackground))
            .onAppear {
                let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                
                isContactInfoVisible = ((objLoggedInUser.mobileVisibility ?? 0) == 1) ? true : false
                isNotificationsEnabled = ((objLoggedInUser.notification ?? 0) == 1) ? true : false
                isMobileAvailable = (objLoggedInUser.mobile?.count ?? 0) > 0 ? true : false
            }
    }
    
    
    
    //MARK: Navigation methods
    func navigatToScreen(title:String)->Void{
        
        
        if title == "Change country/region"{
             
             let destVC = UIHostingController(rootView: ChangeCountry(navigationController:self.navigationController))
             destVC.hidesBottomBarWhenPushed = true
             self.navigationController?.pushViewController(destVC, animated: true)
             
         } else if title == "Contact us"{
            
            let destVC = UIHostingController(rootView: ContactUsView(navigationController:self.navigationController))
            destVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(destVC, animated: true)
            
        } else if title == "FAQs"{
            
            let destVC = UIHostingController(rootView: FaqView(navigationController: self.navigationController))
            destVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(destVC, animated: true)
            
        }else if title == "Blogs"{
            
            let hostingController = UIHostingController(rootView: Blogsview(title: "Blogs",navigationController: self.navigationController)) // Wrap in UIHostingController
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
            
        }else if title == "Privacy Policy"{
            
            let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Privacy Policy", type: .privacy) // Create SwiftUI view
            let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
            
        }else if title == "Refunds & Cancellation policy"{
            
            let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Refunds & Cancellation policy", type: .refundAndCancellationPolicy,htmlString: "") // Create SwiftUI view
            let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
            
        }else if title == "About us"{
            
            let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "About us", type: .aboutUs) // Create SwiftUI view
            let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
        }else if title == "Terms & Conditions"{
            
            let swiftUIView = PrivacyView(navigationController:self.navigationController, title: "Terms & Conditions", type: .termsAndConditions) // Create SwiftUI view
            let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
            hostingController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(hostingController, animated: true)
        }else if title == "Rate us"{
            
            rateApp()
            
        }else if title == "Share this App"{
                
            ShareMedia.shareMediafrom(type: .appShare, mediaId: "", controller: UIHostingController(rootView: self))
            
        }else if title ==  "Delete Account"{
           /* let deleteAccountView = UIHostingController(rootView: DeleteAccountView())
            deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
            deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
            deleteAccountView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
            present(deleteAccountView, animated: true, completion: nil)
            */
            
        }else if title ==  "Logout"{
           /* let deleteAccountView = UIHostingController(rootView: LogoutView(navigationController: self.navigationController))
            deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
            deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
            deleteAccountView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
            present(deleteAccountView, animated: true, completion: nil)*/
        }
        
    }

    func presentLogoutView(){
        let logoutView = UIHostingController(rootView: LogoutView(navigationController: self.navigationController))
        logoutView.modalPresentationStyle = .overFullScreen // Full-screen modal
        logoutView.modalTransitionStyle = .crossDissolve   // Fade-in effect
        logoutView.view.backgroundColor = .clear
      /*  let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        
        if theme == .dark{
            logoutView.view.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5) // Semi-transparent background

        }else{
            logoutView.view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5) // Semi-transparent background
        }*/
        self.navigationController?.present(logoutView, animated: true, completion: nil)
    }
    
    func presentDeleteAccountView(){
        let deleteAccountView = UIHostingController(rootView: DeleteAccountView())
        deleteAccountView.modalPresentationStyle = .overFullScreen // Full-screen modal
        deleteAccountView.modalTransitionStyle = .crossDissolve   // Fade-in effect
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        
        if theme == .dark{
            deleteAccountView.view.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5) // Semi-transparent background
        }else{
            deleteAccountView.view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5) // Semi-transparent background
        }
        self.navigationController?.present(deleteAccountView, animated: true, completion: nil)
    }
    
    func showBuyerSellerPopup(){
        

        let selType:UserMode = (RealmManager.shared.fetchLoggedInUserInfo().userType == 1) ? .buyer : .seller
        
        let popupView = SellerBuyerPopup(selectedMode: selType, isToShowCancelButton: true) { mode in
            
            print(mode)
            
            if mode == .seller{
                self.updateUserTypeApi(type: 2)

            }else{
                self.updateUserTypeApi(type: 1)

            }
        }
        
        let hostingVC = UIHostingController(rootView: popupView)
        hostingVC.modalPresentationStyle = .overFullScreen
        hostingVC.view.backgroundColor = .clear
        self.navigationController?.present(hostingVC, animated: false)
    }
    
    
    func updateUserTypeApi(type:Int){
        
        let reqDict = ["user_type":type]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.update_user_type, param: reqDict,methodType: .post,showLoader: true) { responseObject, error in
            
            if error == nil{
                if let result = responseObject{
                    let code = result["code"] as? Int ?? 0
                    if code == 200{
                        RealmManager.shared.updateUserType(type: type)
                    }
                }
            }
            
        }
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "id1488570846") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }else{
                UIApplication.shared.openURL(url)
            }
        }
    }
}

//#Preview {
//    SettingsView(navigationController:nil, callbackAction: {_ in })
//}



struct SettingRowView:View {
   
    let iconStr:String
    let title:String
    let subTitle:String
    let isToggle:Bool
    @Binding var isOn:Bool
    var body: some View {
        
        HStack{
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                if title == "Change country/region"{
                    Text(Local.shared.emojiCountry) .font(.system(size: 30)).frame(width: 30, height: 30)
                        //.padding()
                }else{
                    Image(iconStr)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.orange)
                        .frame(width: 25, height: 25)
                        .padding()
                }
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment:.leading){
                Text(title).font(.inter(.medium, size: 16.0))
                    .truncationMode(.tail)
                //.layoutPriority(1)
                if subTitle.count > 0 {
                    Text(subTitle).font(.inter(.regular, size: 10.0))
                    // .truncationMode(.tail)
                }
            }
            
            Spacer(minLength: 0)
            
            if isToggle{
                Toggle("", isOn: $isOn).tint(.orange)
                
                    .onChange(of: isOn) { newValue in
                        
                        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                       let isContactInfoVisible = ((objLoggedInUser.mobileVisibility ?? 0) == 1) ? true : false
                       let isNotificationsEnabled = ((objLoggedInUser.notification ?? 0) == 1) ? true : false
                        if iconStr == "call"{
                            if isContactInfoVisible != newValue {
                                updateMobileVisibility(isOn: newValue)
                            }
                        }else{
                            if isNotificationsEnabled != newValue {
                                updateNotification(isOn: newValue)
                            }
                        }
                        
                        print("Toggle changed to \(newValue)")
                        //  Do your custom action here
                    }
            }else{
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemGray5).opacity(0.9))
                        .frame(width: 30, height: 30)
                    
                    Image("arrow_right")
                       // .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        //.foregroundColor(.orange)
                        .frame(width: 15, height: 15)
                        .padding()
                }
                .frame(width: 30, height: 30)
            }
       
        } .padding(8)
            .frame(height: 65)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 0.3))
        
    }
    
    
    func updateMobileVisibility(isOn:Bool){
        
        
        let isContact =  isOn == false ? 0 : 1
        
        let params = ["mobileVisibility":isContact] as [String : Any]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.update_mobile_visibility, param: params) { responseObject, error in
            
            if error == nil{
                
                
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200 {
                    RealmManager.shared.updateMobileVisibility(status: isOn)

                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
    
    func updateNotification(isOn:Bool){
        
        
        let isContact =  isOn == false ? 0 : 1
        
        let params = ["notification":isContact] as [String : Any]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.update_notification, param: params) { responseObject, error in
            
            if error == nil{
                
                
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200 {
                    RealmManager.shared.updateNotificationStatus(status: isOn)

                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
    
    
}
