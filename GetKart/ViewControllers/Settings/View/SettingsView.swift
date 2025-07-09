//
//  SettingsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 09/07/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    

    @State private var isNotificationsEnabled: Bool = true
    @State private var isContactInfoVisible: Bool = false
    @State private var isMobileAvailable = false
    
    
    
    var callbackAction: ((_ action: String) -> Void)

    
    var body: some View {

        VStack(spacing: 15){
            HStack{ Spacer()}.frame(height: 25)
            // Toggle Switches
           // Spacer()
            if isMobileAvailable{
                SettingRowView(iconStr: "call", title: "Show mobile number in my Ads", isToggle:true , isOn: $isContactInfoVisible)
            }
            SettingRowView(iconStr: "notification", title: "Receive Notification", isToggle:true , isOn: $isNotificationsEnabled)
            
            SettingRowView(iconStr: "delete_account", title: "Delete Account", isToggle:false , isOn: .constant(false))
                .onTapGesture {
                    dismiss()
                    callbackAction("delete")

                }
            SettingRowView(iconStr: "logout", title: "Logout", isToggle:false , isOn: .constant(false))
                .onTapGesture {
                    dismiss()
                    callbackAction("logout")
                    
                }

//            ToggleField(title: "Show Contact Info", isOn: $isContactInfoVisible)
//            
//            ToggleField(title: "Notification", isOn: $isNotificationsEnabled)
            Spacer()
        }.padding(8)
            //.background(Color(UIColor.systemGray5))
            .onAppear {
                let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                
                isContactInfoVisible = ((objLoggedInUser.mobileVisibility ?? 0) == 1) ? true : false
                isNotificationsEnabled = ((objLoggedInUser.notification ?? 0) == 1) ? true : false
                isMobileAvailable = (objLoggedInUser.mobile?.count ?? 0) > 0 ? true : false
            }
    }
    
}

#Preview {
    SettingsView(callbackAction: {_ in })
}



struct SettingRowView:View {
   
    let iconStr:String
    let title:String
    let isToggle:Bool
    @Binding var isOn:Bool
    var body: some View {
        
        HStack{
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(iconStr)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.orange)
                    .frame(width: 25, height: 25)
                    .padding()
            }
            .frame(width: 40, height: 40)
            
            Text(title).font(.manrope(.medium, size: 16.0))
                .truncationMode(.tail)
                //.layoutPriority(1)
            
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
                        // 👉 Do your custom action here
                    }
            }else{
                
            }
       
        } .padding(8)
            .frame(height: 60)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        
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
