//
//  BlockedUserView.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 18/02/25.
//

import SwiftUI

struct BlockedUserView: View {
    
    var navigationController: UINavigationController?
    @State var listArray = [BlockedUser]()
    @State private var showPopup = false
    @State var selectedObj:BlockedUser?
    
    var body: some View {
        HStack{
            
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text("Blocked Users").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background(Color.white)
        
        VStack{
            
            HStack{Spacer()}.frame(height:5)
            ForEach(listArray) { obj in
                
                HStack{
                    // Spacer()
                    AsyncImage(url: URL(string: obj.profile ?? "")) { image in
                        image
                            .resizable()
                            .frame(width: 60,height: 60).cornerRadius(30)
                            .aspectRatio(contentMode: .fit)
                        
                    }placeholder: { Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit).frame(width: 60,height: 60).cornerRadius(30)}
                    
                    Text(obj.name ?? "").foregroundColor(.black).font(Font.manrope(.regular, size: 16.0))
                    Spacer()
                    
                }.background(.white).cornerRadius(6.0).padding(.horizontal).onTapGesture {
                    showPopup = true
                    selectedObj = obj
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
                if #available(iOS 16.4, *) {
                    UnblockUserView(isPresented: $showPopup, bloclkUser: selectedObj).presentationDetents([.large, .large]) // Optional for different heights
                        .background(.clear) // Remove default background
                        .presentationBackground(.clear)
                }else{
                    UnblockUserView(isPresented: $showPopup, bloclkUser: selectedObj).background(.clear)
                }
            }
    }
    
    
    func getBlockedUsers(){
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.blocked_users, param: nil,httpMethod: .get) { (obj:BlockedParse) in
            
            if obj.code == 200{
                self.listArray = obj.data ?? []
            }
        }
    }
}


#Preview {
    BlockedUserView(navigationController:nil)
}



