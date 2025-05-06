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
    @ObservedObject private var objVM = ProfileViewModel()
    @State var showShareSheet = false
    @State var showOptionSheet = false
    
    var body: some View {
        VStack {
            // Header Section
            HStack {
                Button(action: {
                    // Handle back action
                    navController?.popViewController(animated: true)
                }) {
                    Image("arrow_left").renderingMode(.template)
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                
                Text("Seller Profile")
                    .font(.custom("Manrope-Bold", size: 20.0))
                        .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {
                        // Handle share action
                        showShareSheet = true
                    }) {
                        Image("share").renderingMode(.template)
                            .font(.title2)
                            .foregroundColor(.black)
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
                    let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                    if objLoggedInUser.id != nil  && objLoggedInUser.id != (objVM.sellerObj?.id ?? 0) {
                    Button(action: {
                        // Handle more options
                        showOptionSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(.black)
                    } .actionSheet(isPresented: $showOptionSheet) {
                        
                        
                        ActionSheet(title: Text(""), message: nil, buttons: [
                            
                            
                            .default(Text((((objVM.sellerObj?.isBlock ?? 0) == 1) ? "Unblock" : "Block")), action: {
                                
                                if (objVM.sellerObj?.isBlock ?? 0) == 1{
                                    self.objVM.unblockUser()
                                }else{
                                    self.objVM.blockUser()
                                }
                            }),
                            
                                .cancel()
                        ])
                    }
                }
                }
            }.frame(height: 44).padding(.horizontal, 10)
          //  .padding()
            
            // Profile Info Section
            HStack {
                AsyncImage(url: URL(string: objVM.sellerObj?.profile ?? "")) { img in
                    
                    img.resizable()
                        .frame(width: 80, height: 80).cornerRadius(40)
                } placeholder: {
                    
                    Image("getkartplaceholder") // Placeholder for profile image
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(40)
                }
                
                Text(objVM.sellerObj?.name ?? "")
                    .font(.custom("Manrope-Medium", size: 16.0))
                Spacer()
                let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                if objLoggedInUser.id != nil && objLoggedInUser.id != (objVM.sellerObj?.id ?? 0) {
                Button(action: {
                    // Handle follow action
                    let follow = (objVM.sellerObj?.isFollowing ?? false) ? false : true
                    
                    objVM.followUnfollowUserApi(isFollow: follow)
                }) {
                    
                    let strText = (objVM.sellerObj?.isFollowing ?? false) ? "Unfollow" : "Follow"
                    Text(strText).font(.custom("Manrope-Medium", size: 16.0))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .font(.headline)
                }
            }
            }
            .padding(.horizontal, 10)
            
            // Stats Section
            HStack {
                
                statView(value: "\(objVM.sellerObj?.items ?? 0)", label: "Products")
                
                Divider().frame(width: 1,height: 40).background(.gray)

                statView(value: "\(objVM.sellerObj?.followersCount ?? 0)", label: "Followers").onTapGesture {
                   
                    if (objVM.sellerObj?.followersCount ?? 0) > 0{
                        let hostVC = UIHostingController(rootView: FollowerListView(navController: navController,isFollower: true,userId: userId))
                        self.navController?.pushViewController(hostVC, animated: true)
                    }
                }
                
                Divider().frame(width: 1,height: 40).background(.gray)
                
                statView(value: "\(objVM.sellerObj?.followingCount ?? 0)", label: "Following").onTapGesture {
                  
                    if (objVM.sellerObj?.followingCount ?? 0) > 0{
                        
                        let hostVC = UIHostingController(rootView: FollowerListView(navController: navController,isFollower: false,userId: userId))
                        self.navController?.pushViewController(hostVC, animated: true)
                    }
                }
           
            }.padding(.vertical, 10)
            
            // Products Section
            ScrollView {
                HStack{Spacer()}.frame(height: 5)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    
                    ForEach($objVM.itemArray) { $item in
                        
                        ProductCard(objItem: $item)
                           
                            .onAppear {
                                
                                if let lastItem = objVM.itemArray.last, lastItem.id == item.id, !objVM.isDataLoading {
                                    objVM.getItemListApi(sellerId: userId)
                                }
                            }
                            .onTapGesture {
                                var detailView =  ItemDetailView(navController:   self.navController, itemId: item.id ?? 0, itemObj: item,isMyProduct:true, slug: item.slug)
                                let hostingController = UIHostingController(rootView:detailView)
                                
                                detailView.returnValue = { value in
                                    if let obj = value{
                                        self.updateItemInList(obj)
                                    }
                                }
                                self.navController?.pushViewController(hostingController, animated: true)
                            }
                    }
                }.padding(.horizontal,10)
                
                if objVM.isDataLoading {
                    ProgressView()
                    .padding()
                }
                
            }.background(Color(.systemGray6))
           
            
        }.navigationBarHidden(true)
        .onAppear{
            if objVM.itemArray.count == 0{
                objVM.getSellerProfile(sellerId: userId)
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
                .font(.custom("Manrope-Bold", size: 16.0))

            Text(label)
                .font(.custom("Manrope-Regular", size: 15.0))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SellerProfileView()
}

