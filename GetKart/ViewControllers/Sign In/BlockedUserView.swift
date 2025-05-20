//
//  BlockedUserView.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 18/02/25.
//

import SwiftUI

struct BlockedUserView: View {
    
    var navigationController: UINavigationController?
    @State var listArray = [UserModel]()
    @State private var showPopup = false
    @State private var selectedIndex: Int?

    
    var body: some View {
        HStack{
            
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Blocked Users").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
        }.frame(height:44).background(Color(UIColor.systemBackground))
        
        VStack{
            
            HStack{Spacer()}.frame(height:5)
                
            ForEach(listArray.indices, id: \.self) { index in
                let obj = listArray[index]
                
                HStack{
                    // Spacer()
                    AsyncImage(url: URL(string: obj.profile ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60,height: 60)
                            .cornerRadius(30)
                            .aspectRatio(contentMode: .fit).padding(8)
                        
                    }placeholder: { Image("getkartplaceholder")
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 60,height: 60).cornerRadius(30).padding(8)}
                    
                    Text(obj.name ?? "").foregroundColor(Color(UIColor.label))
                        .font(Font.manrope(.regular, size: 16.0))
                    Spacer()
                    
                }.background(.white).cornerRadius(6.0).padding(.horizontal).tag(index).onTapGesture {
                    self.selectedIndex = index
                    self.showPopup = true
                }
            }
            
            if listArray.count == 0 {
                
                HStack{
                    Spacer()
                    
                    VStack(spacing: 30){
                        Spacer()
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding()
                        Spacer()
                    }
                    Spacer()
                }
            }else{
                Spacer()
            }
                        
        }.background(Color(UIColor.systemGray6))
            .onAppear{
                getBlockedUsers()
            }
            .fullScreenCover(isPresented: $showPopup) {
                
                let selectedObj = listArray[selectedIndex ?? 0]
                    if #available(iOS 16.4, *) {
                        UnblockUserView(isPresented: $showPopup, bloclkUser: selectedObj, unblockUser: {
                            self.unblockUser()

                        }).presentationDetents([.large, .large]) // Optional for different heights
                            .background(.clear) // Remove default background
                            .presentationBackground(.clear)
                    }else{
                        UnblockUserView(isPresented: $showPopup, bloclkUser: selectedObj, unblockUser: {
                            self.unblockUser()
                        }).background(.clear)
                    }
            }.navigationBarHidden(true)
    }
    
    
    
    func unblockUser(){
        
        let params = ["blocked_user_id":listArray[selectedIndex ?? 0].id ?? 0]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.unblock_user, param: params) { responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                self.listArray.remove(at: self.selectedIndex ?? 0)
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: message)
            }
        }
    }
    
    func getBlockedUsers(){
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.blocked_users, param: nil,httpMethod: .get) { (obj:UserParse) in
            
            if obj.code == 200{
                self.listArray = obj.data ?? []
            }
        }
    }
}


#Preview {
    BlockedUserView(navigationController:nil)
}



