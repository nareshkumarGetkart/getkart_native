//
//  DeleteAccountView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI
import FirebaseAuth
import Kingfisher

struct DeleteAccountView: View {
    
    @Environment(\.presentationMode) var presentationMode

    @State private var showAlert = true
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image("delete_illustrator") // Replace with actual asset name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150).padding(.top,20)
                
                Text("Deleting Account?").font(Font.manrope(.semiBold, size: 16))
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack{
                        Text("\u{2022}").font(Font.manrope(.extraBold, size: 16)).foregroundColor(.black)
                        Text("Your ads and transactions history will be deleted.").font(Font.manrope(.regular, size: 16)).foregroundColor(.black)
                    }
                    HStack{
                        Text("\u{2022}").font(Font.manrope(.extraBold, size: 16)).foregroundColor(.black)
                        Text("Account details can’t be recovered.").font(Font.manrope(.regular, size: 16)).foregroundColor(.black)
                    }
                    HStack{
                        Text("\u{2022}").font(Font.manrope(.extraBold, size: 16)).foregroundColor(.black)
                        Text("Subscriptions will be cancelled.").font(Font.manrope(.regular, size: 16)).foregroundColor(.black)
                    }
                    HStack{
                        Text("\u{2022}").font(Font.manrope(.extraBold, size: 16)).foregroundColor(.black)
                        Text("Saved preferences and messages will be lost.").font(Font.manrope(.regular, size: 15)).foregroundColor(.black)
                    }
                }
                .font(.body)
                .foregroundColor(.gray)
                .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        showAlert = false
                        presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        Text("No").font(Font.manrope(.regular, size: 16))
                            .foregroundColor(.black).padding()
                            .frame(maxWidth: .infinity,idealHeight:40,maxHeight:40)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        /* Delete account action */
                        
                       // presentationMode.wrappedValue.dismiss()
                        self.deleteApi()

                    }) {
                        Text("Delete").font(Font.manrope(.regular, size: 16)).foregroundColor(.white).padding()
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
            .padding(.horizontal, 20)
        }
    }
    
    func deleteApi(){
        URLhandler.sharedinstance.makeCall(url: Constant.shared.deleteUser, param: Dictionary(), methodType: .delete,showLoader:true) {  responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    self.deleteUser()
                    
                    AppDelegate.sharedInstance.sharedProfileID = ""
                    AppDelegate.sharedInstance.notificationType = ""
                    AppDelegate.sharedInstance.roomId = 0
                    AppDelegate.sharedInstance.userId = 0
                    
                    RealmManager.shared.deleteUserInfoObjects()
                    RealmManager.shared.clearDB()
                    ImageCache.default.clearDiskCache()
                    ImageCache.default.clearMemoryCache()
                    SocketIOManager.sharedInstance.socket?.disconnect()
                    SocketIOManager.sharedInstance.socket = nil
                    SocketIOManager.sharedInstance.manager = nil
                    
                    showAlert = false
                    presentationMode.wrappedValue.dismiss()
                    
                    AppDelegate.sharedInstance.showLoginScreen()
                    
                    
                    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                           
                    }))
                    
                    AppDelegate.sharedInstance.navigationController?.present(alert, animated: true, completion: nil)
                    
                   
                    
                }else{
                    //self?.delegate?.showError(message: message)
                }
                
            }
        }
    }
    

    func deleteUser() {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    print("Failed to delete user: \(error.localizedDescription)")
                } else {
                    print("User account deleted successfully.")
                }
            }
        } else {
            print("No user is signed in.")
        }
    }
    
}

#Preview {
    DeleteAccountView()
}
