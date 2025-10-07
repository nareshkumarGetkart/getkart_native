//
//  FollowerListView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 22/04/25.
//

import SwiftUI

struct FollowerListView: View {
    let navController:UINavigationController?
    @State private var usersArray =  [UserModel]()
    var isFollower = true
    let userId:Int?
    
    var body: some View {
        HStack{
            Button {
                navController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            
            let strTitle = ((isFollower == true) ? "Followers" : "Following")
            Text(strTitle).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
        }.frame(height:44).background(Color(UIColor.systemBackground))
        
        
        VStack{
      
            ScrollView {
                VStack(spacing: 12) {
                    
                    ForEach(usersArray) { user in
                        
                        FollowerRowView(user: user).onTapGesture {
                            
                            let hostingController = UIHostingController(rootView: SellerProfileView(navController: self.navController, userId: user.id ?? 0))
                            self.navController?.pushViewController(hostingController, animated: true)
                        }

                    }
                }
                .padding(.top)
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        }.navigationBarHidden(true)
        .onAppear{
            getUserList()
        }
        
    }
    
    func getUserList(){
        var strUrl =  Constant.shared.get_following + "?user_id=\(userId ?? 0)"
        
        if isFollower{
            strUrl =  Constant.shared.get_followers + "?user_id=\(userId ?? 0)"
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url:strUrl ) { (obj:UserDataParse) in
            if (obj.code ?? 0) == 200{
                self.usersArray = obj.data?.data ?? []
            }
        }
        
    }
}

#Preview {
    FollowerListView(navController:nil ,isFollower: true, userId:nil)
}






struct FollowerRowView: View {
    let user: UserModel

    var body: some View {
        HStack(spacing: 12) {
            
            ContactImageSwiftUIView(name: user.name ?? "", imageUrl: user.profile ?? "", fallbackImageName: "user-circle", imgWidth: 50, imgHeight: 50, selectedImage: nil)
            
        /*    AsyncImage(url: URL(string: user.profile ?? "")) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                    Image(systemName: "user-circle")
                        .foregroundColor(.orange)
                    
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            */
            VStack(alignment: .leading, spacing: 4) {
                
                HStack{
                    Text(user.name ?? "")
                        .fontWeight(.semibold)
                        .foregroundColor(Color(UIColor.label))
                    
                    if (user.isVerified ?? 0) != 0 {
                       // HStack {
                            
                           // Text("Verified")
//                                .foregroundColor(.gray)
//                                .font(.subheadline)
                        Image("verifiedIcon")
                            .resizable()
                            //.renderingMode(.template)
                            //.foregroundColor(Color(UIColor.systemOrange))
                            .scaledToFit()
                            .frame(width:20, height: 20)
                        //}
                    }
                    Spacer()

                }
                
                
                
//                Text("Member Since→")
//                    .font(.caption)
//                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
