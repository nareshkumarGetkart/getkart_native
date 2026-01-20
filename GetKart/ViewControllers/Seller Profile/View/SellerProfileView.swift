//
//  SellerProfileView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/03/25.
//

import SwiftUI

struct SellerProfileView: View {
    
    var navController:UINavigationController?
    var userId:Int = 0
//    @ObservedObject private var objVM = ProfileViewModel()
    @StateObject private var objVM = ProfileViewModel()

    @State var showShareSheet = false
    @State var showOptionSheet = false
    
    var body: some View {
        VStack(spacing:0) {
            // Header Section
            HStack {
                Button(action: {
                    // Handle back action
                    navController?.popViewController(animated: true)
                }) {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    
                }
                
                Text("Seller Profile")
                    .font(.manrope(.bold, size: 18))
                    .foregroundColor(Color(.label))
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {
                        // Handle share action
                        showShareSheet = true
                    }) {
                        Image("share").renderingMode(.template)
                            .font(.title2)
                            .foregroundColor(Color(UIColor.label))
                    } .actionSheet(isPresented: $showShareSheet) {
                        
                        ActionSheet(title: Text(""), message: nil, buttons: [
                            
                            .default(Text("Copy Link"), action: {
                                
                                UIPasteboard.general.string = ShareMedia.profileUrl + "\(userId)"
                                AlertView.sharedManager.showToast(message: "Copied successfully.")
                                
                            }),
                            
                                .default(Text("Share"), action: {
                                    ShareMedia.shareMediafrom(type: .profile, mediaId: "\(userId)", controller: (navController?.topViewController!)!)
                                }),
                            
                                .cancel()
                        ])
                    }
                    if Local.shared.getUserId() > 0  && Local.shared.getUserId() != (objVM.sellerObj?.id ?? 0) {
                        Button(action: {
                            // Handle more options
                            showOptionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                                .foregroundColor(Color(UIColor.label))
                        } .actionSheet(isPresented: $showOptionSheet) {
                            
                            
                            ActionSheet(title: Text(""), message: nil, buttons: [
                                
                                
                                .default(Text((((objVM.sellerObj?.isBlock ?? 0) == 1) ? "Unblock" : "Block")), action: {
                                    
                                    if (objVM.sellerObj?.isBlock ?? 0) == 1{
                                        self.objVM.unblockUser()
                                    }else{
                                        self.objVM.blockUser()
                                    }
                                }),
                                
                                    .default(Text(("Report user")), action: {
                                        reportUserPush()
                                        
                                        
                                    }),
                                
                                    .cancel()
                            ])
                        }
                    }
                }
            }.frame(height: 44).padding(.horizontal, 10)
            
            HStack {
                
                
                ContactImageSwiftUIView(name: objVM.sellerObj?.name ?? "", imageUrl: objVM.sellerObj?.profile ?? "", fallbackImageName: "user-circle", imgWidth: 80, imgHeight: 80)
                
                HStack{
                    Text(objVM.sellerObj?.name ?? "")
                        .font(.manrope(.medium, size: 15))
                    if(objVM.sellerObj?.isVerified ?? 0) == 1{
                        Image("verifiedIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width:20, height: 20).onTapGesture {
                                AppDelegate.sharedInstance.presentVerifiedInfoView()
                            }
                        
                    }
                    Spacer()
                }
                Spacer()
                
                if Local.shared.getUserId() > 0 && Local.shared.getUserId() != (objVM.sellerObj?.id ?? 0) {
                    Button(action: {
                        // Handle follow action
                        let follow = (objVM.sellerObj?.isFollowing ?? false) ? false : true
                        
                        objVM.followUnfollowUserApi(isFollow: follow)
                        
                        objVM.sellerObj?.followersCount =    (objVM.sellerObj?.followersCount ?? 0)  + ((follow) ? 1 : -1)
                        
                    }) {
                        
                        let strText = (objVM.sellerObj?.isFollowing ?? false) ? "Unfollow" : "Follow"
                        Text(strText).font(.manrope(.medium, size: 15))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .foregroundColor(Color(.white))
                            .cornerRadius(20)
                            .font(Font.manrope(.semiBold, size: 15.0))
                    }
                }
            }
            .padding(.horizontal, 10)
            
            // Stats Section
            HStack {
                
                statView(value: "\(objVM.sellerObj?.items ?? 0)", label: "Products")
                
                Divider().frame(width: 1,height: 30).background(.gray)
                
                statView(value: "\(objVM.sellerObj?.followersCount ?? 0)", label: "Followers")
                    .onTapGesture {
                        
                        if (objVM.sellerObj?.followersCount ?? 0) > 0{
                            if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                                let hostVC = UIHostingController(rootView: FollowerListView(navController: navController,isFollower: true,userId: userId))
                                self.navController?.pushViewController(hostVC, animated: true)
                            }
                        }
                    }
                
                Divider().frame(width: 1,height: 30).background(.gray)
                
                statView(value: "\(objVM.sellerObj?.followingCount ?? 0)", label: "Following")
                    .onTapGesture {
                        
                        if (objVM.sellerObj?.followingCount ?? 0) > 0{
                            if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                                
                                let hostVC = UIHostingController(rootView: FollowerListView(navController: navController,isFollower: false,userId: userId))
                                self.navController?.pushViewController(hostVC, animated: true)
                            }
                        }
                    }
                
            }.padding(.vertical, 8)
            
            
            if objVM.itemArray.count == 0  && objVM.isDataLoading == false{
                
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
                // Products Section
                ScrollView {

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        
                        ForEach($objVM.itemArray) { $item in
                            
                            ProductCard(objItem: $item, onItemLikeDislike: {likedObj in
                                updateItemInList(likedObj)
                                
                            })
                            .onAppear {
                                
                                if let lastItem = objVM.itemArray.last, lastItem.id == item.id, !objVM.isDataLoading {
                                    objVM.getItemListApi(sellerId: userId)
                                }
                            }
                            .onTapGesture {
                                var detailView =  ItemDetailView(navController:   self.navController, itemId: item.id ?? 0, itemObj: item,isMyProduct:true, slug: item.slug)
                                
                                detailView.returnValue = { value in
                                    if let obj = value{
                                        self.updateItemInList(obj)
                                    }
                                }
                                let hostingController = UIHostingController(rootView:detailView)
                                
                                self.navController?.pushViewController(hostingController, animated: true)
                            }
                        }
                    }.padding(.horizontal,8).padding(.top,5)
                    
                    if objVM.isDataLoading {
                        ProgressView()
                            .padding()
                    }
                    
                }.background(Color(.systemGray6))
            }
            
        }.navigationBarHidden(true)
        
            .onAppear{
                if objVM.itemArray.count == 0{
                    objVM.getSellerProfile(sellerId: userId,nav: navController)
                    objVM.getItemListApi(sellerId: userId)
                }
            }
    }
   
    private func updateItemInList(_ value: ItemModel) {
        if let index = $objVM.itemArray.firstIndex(where: { $0.id == value.id }) {
            objVM.itemArray[index] = value
            
        }
    }
    
    // Function to create stats view
    private func statView(value: String, label: String) -> some View {
        VStack {
            Text(value)
                .font(.manrope(.bold, size: 16))

            Text(label)
                .font(.manrope(.regular, size: 15))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    
    func reportUserPush(){
        
        let hostingController = UIHostingController(rootView:ReportUserView(roportUserId:userId))
        self.navController?.pushViewController(hostingController, animated: true)
    }
}

#Preview {
    SellerProfileView()
}

