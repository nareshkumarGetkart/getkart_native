//
//  FollowerListView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 22/04/25.
//


import SwiftUI

struct FollowerListView: View {
    let navController: UINavigationController?
    var isFollower = true
    let userId: Int?
    var showHeader: Bool = true

    @StateObject private var followerVM:FollowerViewModal
    @State private var isRommCreated: Bool = false
    
    init(navController: UINavigationController?,
            isFollower: Bool = true,
            userId: Int?,
         showHeader: Bool = true) {
        
        self.navController = navController
        self.isFollower = isFollower
        self.userId = userId
        self.showHeader = showHeader
        _followerVM = StateObject(wrappedValue: FollowerViewModal(userId: userId ?? 0, isFollower: isFollower))
    }

    var body: some View {
        VStack(spacing: 0) {
            
            if showHeader {
                HStack {
                    Button {
                        navController?.popViewController(animated: true)
                    } label: {
                        Image("arrow_left")
                            .renderingMode(.template)
                            .foregroundColor(Color(UIColor.label))
                    }
                    .frame(width: 40, height: 40)
                    
                    Text(isFollower ? "Followers" : "Follow")
                        .font(.inter(.medium, size: 18))
                        .foregroundColor(Color(UIColor.label))
                    
                    Spacer()
                }
                .frame(height: 44)
                .padding(.horizontal, 8)
                .background(Color(UIColor.systemBackground))
                
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(followerVM.usersArray) { user in
                        FollowerRowView(
                            user: user,
                            isFollower: isFollower,
                            onActionTap: {
                                if isFollower {
                                    // Message action
                                    navigateToMessage(user: user)
                                } else {
                                    // Follow / Unfollow action
                                    toggleFollow(user: user)
                                }
                            }
                        ).onAppear{
                           
                            if let userLast = followerVM.usersArray.last{
                                if user.id == userLast.id {
                                    followerVM.getUserList()
                                }
                            }
                        }
                        .onTapGesture {
                            let vc = UIHostingController(
                                rootView: SellerProfileView(
                                    navController: navController,
                                    userId: user.id ?? 0
                                )
                            )
                            navController?.pushViewController(vc, animated: true)
                        }
                        
                        Divider()
                            .padding(.leading, 76)
                    }
                    
                    if followerVM.usersArray.count == 0 {
                        
                        HStack{
                            Spacer()
                            
                            VStack(spacing: 30){
                                Spacer(minLength: 100)
                                Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                                Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding()
                                Spacer()
                            }
                            Spacer()
                        }
                    }else{
                        Spacer()
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarHidden(true)
//        .onAppear {
//            if followerVM.usersArray.count == 0{
//                followerVM.getUserList()
//            }
//        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(SocketEvents.createRoom.rawValue))) { notification in
            
            if isRommCreated == true{
                return
            }
            
            if navController?.topViewController is ChatVC {
                return
            }
            
            guard let data = notification.userInfo else{
                return
            }
            
            if let dataDict = data["data"] as? Dictionary<String,Any>{
                
                let id = dataDict["id"] as? Int ?? 0
                let sender_id = dataDict["sender_id"] as? Int ?? 0
                let receiver_id = dataDict["receiver_id"] as? Int ?? 0
                
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = id
                destVC.userId = receiver_id
                self.navController?.pushViewController(destVC, animated: true)
                Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
            }
            else{
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = 0
                destVC.userId = userId ?? 0
                self.navController?.pushViewController(destVC, animated: true)
            }
            isRommCreated = true
        }
    }

    
   
    // MARK: - Actions

    func toggleFollow(user: UserModel) {
        // Call your follow/unfollow API here
        // After success, refresh the list
        if AppDelegate.sharedInstance.isUserLoggedInRequest() {
            
            self.followerVM.followUnfollowUserApi(userObj: user)
        }
 
    }

    func navigateToMessage(user: UserModel) {
        // Navigate to message/chat screen
        // let vc = UIHostingController(rootView: ChatView(userId: user.id ?? 0))
        // navController?.pushViewController(vc, animated: true)
        
        // TODO: Open chat screen
        if AppDelegate.sharedInstance.isUserLoggedInRequest() {
            isRommCreated = false
            FaceBookAppEvents.facebookEvents(type: .createOffer, categoryName: user.name ?? "")
            let params = ["user_id":user.id ?? 0] as [String : Any]
            SocketIOManager.sharedInstance.emitEvent(SocketEvents.createRoom.rawValue, params)
        }
    }

}

#Preview {
    FollowerListView(navController:nil ,isFollower: true, userId:nil)
}

// MARK: - Row View

struct FollowerRowView: View {
    let user: UserModel
    var isFollower: Bool
    var onActionTap: () -> Void

    /// Local toggle state for follow/unfollow (followings tab only)
    @State private var isFollowing: Bool = true   // already following since it's in the followings list

    var body: some View {
        HStack(spacing: 12) {

            // Avatar
            ContactImageSwiftUIView(
                name: user.name ?? "",
                imageUrl: user.profile ?? "",
                fallbackImageName: "user-circle",
                imgWidth: 50,
                imgHeight: 50,
                selectedImage: nil
            )

            // Name + verified badge
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(user.name ?? "")
                        .font(.custom("Manrope-SemiBold", size: 15))
                        .foregroundColor(Color(UIColor.label))

                    if (user.isVerified ?? 0) != 0 {
                        Image("verifiedIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                }
            }

            Spacer()

            // ── Action button ──────────────────────────────────────
            if isFollower {
                // Followers tab → Message button
                actionButton(title: "Message", filled: true)

            } else {
                // Followings tab → Follow / Unfollow button
                actionButton(
                    title: (user.isFollowing == true) ? "Unfollow" : "Follow",
                    filled: true
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }

    @ViewBuilder
    private func actionButton(title: String, filled: Bool) -> some View {
        Button {
            if !isFollower {
                // Animate the local state toggle immediately for snappy UX
                withAnimation(.easeInOut(duration: 0.15)) {
                    isFollowing.toggle()
                }
            }
            onActionTap()
        } label: {
            Text(title)
                .font(.inter(.medium, size: 13))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.init(hexString: "#FFBC55"))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)   // prevents row tap gesture interference
    }
}
