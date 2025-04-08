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
                                
                            }),
                            
                                .default(Text("Share"), action: {
                                    
                            }),
                            
                           .cancel()
                        ])
                    }
                    
                    Button(action: {
                        // Handle more options
                        showOptionSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(.black)
                    } .actionSheet(isPresented: $showOptionSheet) {
                        
                        ActionSheet(title: Text(""), message: nil, buttons: [

                            .default(Text("Block"), action: {
                                
                            }),
                           
                            .cancel()
                        ])
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
                Button(action: {
                    // Handle follow action
                }) {
                    Text("Follow").font(.custom("Manrope-Medium", size: 16.0))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .font(.headline)
                }
            }
            .padding(.horizontal, 10)
            
            // Stats Section
            HStack {
                
                statView(value: "\(objVM.sellerObj?.items ?? 0)", label: "Products")
                
                Divider().frame(width: 1,height: 40).background(.gray)

                statView(value: "\(objVM.sellerObj?.followersCount ?? 0)", label: "Followers")
                
                Divider().frame(width: 1,height: 40).background(.gray)
                
                statView(value: "\(objVM.sellerObj?.followingCount ?? 0)", label: "Following")
           
            }.padding(.vertical, 10)
            
            // Products Section
            ScrollView {
                HStack{Spacer()}.frame(height: 5)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    
                    ForEach(objVM.itemArray) { item in
                        
                        ProductCard(objItem: item)
                       // ProductCard(id: item.id ?? 0, imageName: item.image ?? "", price: "₹\(item.price ?? 0)", title:item.name ?? "", location: item.address ?? "").frame(width: widthScreen/2.0 - 10,item.isLiked)
                            .onTapGesture {
                                
                                let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId: item.id ?? 0,isMyProduct:true))
                                AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                            }
                    }
                }.padding(.horizontal,10)
               
            }.background(Color(.systemGray6))
            
        }.navigationBarHidden(true)
        .onAppear{
            objVM.getSellerProfile(sellerId: userId)
            objVM.getItemListApi(sellerId: userId)
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

