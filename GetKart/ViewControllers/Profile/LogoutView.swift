//
//  LogoutView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI
import Kingfisher

struct LogoutView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var navigationController: UINavigationController?
    @State private var showAlert = true
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image("logout_illustrator") // Replace with actual asset name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 170).padding(.top,20)
                
                Text("Logout Confirmation").font(Font.manrope(.semiBold, size: 16))
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Are you sure you want to logout?").font(Font.manrope(.regular, size: 16)).foregroundColor(.black)
                
                HStack {
                    Button(action: {
                        showAlert = false
                        presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        Text("Cancel").font(Font.manrope(.regular, size: 16))
                            .foregroundColor(.black).padding()
                            .frame(maxWidth: .infinity,idealHeight:40,maxHeight:40)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        self.LogoutApi()
                       
                    }) {
                        Text("OK").font(Font.manrope(.regular, size: 16)).foregroundColor(.white).padding()
                            .frame(maxWidth: .infinity,idealHeight:40,maxHeight:40)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }.padding(.bottom,10)
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 30)
        }
    }
    
    
    func LogoutApi(){
        let strUrl =  Constant.shared.logout + "?fcm_id=\(Local.shared.getFCMToken())"
        URLhandler.sharedinstance.makeCall(url:strUrl , param: Dictionary(), methodType: .post,showLoader:true) {  responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

             //   if status == 200{
                    // presentationMode.wrappedValue.dismiss()
                    ImageCache.default.clearDiskCache()
                    ImageCache.default.clearMemoryCache()
                    SocketIOManager.sharedInstance.socket?.disconnect()
                    SocketIOManager.sharedInstance.socket = nil
                    SocketIOManager.sharedInstance.manager = nil
                    
                    RealmManager.shared.deleteUserInfoObjects()
                    RealmManager.shared.clearDB()
                    showAlert = false
                    presentationMode.wrappedValue.dismiss()
                    AppDelegate.sharedInstance.showLoginScreen()
                   
//                }else{
//                    //self?.delegate?.showError(message: message)
//                }
                
            }
        }
    }
    
}

#Preview {
    LogoutView()
}
