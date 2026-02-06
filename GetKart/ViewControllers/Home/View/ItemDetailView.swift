//
//  ItemDetailView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 05/03/25.
//

import SwiftUI
import MapKit
import Foundation
import SVGKit
import MessageUI
import CoreImage
import CoreImage.CIFilterBuiltins
import AVKit
import AVFoundation
import _AVKit_SwiftUI

struct ItemDetailView: View {
    
    @State private var backgroundColor: Color = .secondary
    var navController:UINavigationController?
    var itemId = 0
    var slug = ""
    @State private var selectedIndex:Int?
    @StateObject  var objVM:ItemDetailViewModel
    @State private var showSheet = false
    @State private var showOfferPopup = false
    @State private var showShareSheet = false
    @State private var showMoreOptionSheet = false
    @State private var showConfirmDeactvatePopup = false
    @State private var videoPlayer: AVPlayer? = nil
    @State private var isVideoVisible = false
    @State var isMyProduct = false
    @State private var showConfirmDialog = false
    // Declare callback function variable
    
    @State private  var isCreateRoomSafetyTips = false

    var returnValue: ((_ value: ItemModel?)->())?
    
    
    init(navController: UINavigationController? = nil, itemId: Int = 0, itemObj: ItemModel?,isMyProduct: Bool = false,slug:String?) {
        

        self.navController = navController
        self.itemId = itemId
        self.slug = slug ?? ""
        
        let viewModel = ItemDetailViewModel()
        viewModel.itemObj = itemObj
        
        viewModel.galleryImgArray = itemObj?.galleryImages ?? []
        
        if let img = itemObj?.image {
            let new = GalleryImage(id:10, image: img, itemID: itemObj?.id)
            viewModel.galleryImgArray.insert(new, at: 0)
            selectedIndex = 0
        }
                
        if (itemObj?.videoLink?.count ?? 0) > 0{
            
            let new = GalleryImage(id:10, image: itemObj?.videoLink, itemID: 400)
            viewModel.galleryImgArray.append(new)
            
        }
        
        self.isMyProduct = isMyProduct
        _objVM = StateObject(wrappedValue: viewModel)
        
        // Enable interactive pop gesture

    }
    
    var body: some View {
   
        VStack(spacing:0){
            headerBar
            Divider()
            
            ScrollView(.vertical, showsIndicators: false) {
                
                LazyVStack(alignment: .leading,spacing: 5) {
                    
                    let isFeatured = objVM.itemObj?.isFeature ?? false
                    let itemUserId = objVM.itemObj?.userID ?? 0
                    
                    ZStack (alignment: .topTrailing) {
                        
                        if  (objVM.galleryImgArray.count) > 0 {
                            
                            VStack(spacing: 10) {
                                TabView(selection: $selectedIndex) {
                                    ForEach(objVM.galleryImgArray.indices, id: \.self) { index in
                                        if let img = objVM.galleryImgArray[index].image {
                                            
                                            let isLast = (index + 1) == objVM.galleryImgArray.count
                                            let isVideoAvailable = (objVM.itemObj?.videoLink?.count ?? 0) > 0
                                            let bothConditionTrue = isLast && isVideoAvailable
                                            if  bothConditionTrue {
                                                
                                                if img.contains("youtube.com") || img.contains("youtu"){
                                                    
                                                    YouTubeFallbackView(videoID: extractYouTubeID(from: img)).frame(height: 200).cornerRadius(10).tag(index)
                                                    
                                                   /* YouTubeWebView(videoID:extractYouTubeID(from: img), isVisible: $isVideoVisible).frame(height: 200)
                                                        .cornerRadius(10)
                                                        //.padding(.horizontal, 5)
                                                        .onAppear {
                                                            // When the video is on screen, make sure it's playing
                                                            self.isVideoVisible = true
                                                        }
                                                        .onDisappear {
                                                            // When the video disappears, pause it
                                                            self.isVideoVisible = false
                                                        } .tag(index)*/
                                                }else{
                                                    
                                                    WebVideoView(videoURL:img)
                                                        .frame(height: 200)
                                                        .cornerRadius(10)
                                                        //.padding(.horizontal, 5)
                                                        .tag(index)
                                                }
                                                
                                            } else {
                                                
                                                AsyncImage(url: URL(string: img)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(height: 200)
                                                        //.padding(.horizontal, 5)
                                                        .onAppear {
//                                                            extractDominantColor(from: image)
                                                        }
                                                } placeholder: {
                                                    Image("getkartplaceholder")
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(height: 200)
                                                       // .padding(.horizontal, 5)
                                                }
                                                .tag(index)
                                                
                                            }
                                        }
                                    }
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                .frame(width: widthScreen - 20, height: 200)
                                .background(backgroundColor.opacity(0.4))
                                .cornerRadius(10)
                                .onTapGesture {
                                    
                                    if  (objVM.galleryImgArray.count) > 0 {
                                        
                                        if selectedIndex == nil{ selectedIndex = 0}
                                        if let index = selectedIndex{
                                            
                                            if objVM.galleryImgArray[index].image != nil {
                                                
                                                let isLast = (index + 1) == objVM.galleryImgArray.count
                                                let isVideoAvailable = (objVM.itemObj?.videoLink?.count ?? 0) > 0
                                                let bothConditionTrue = isLast && isVideoAvailable
                                                if  bothConditionTrue {
                                                    
                                                }else{
                                                    navigateToPager()
                                                    
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                
                                
                                if objVM.galleryImgArray.count > 1{
                                    
                                    // Custom Dot Indicator
                                    HStack(spacing: 6) {
                                        
                                        ForEach(objVM.galleryImgArray.indices, id: \.self) { index in
                                            Circle()
                                                .fill(selectedIndex == index ? Color.orange : Color.gray.opacity(0.4))
                                                .frame(width: 6, height: 6)
                                                .onTapGesture {
                                                    selectedIndex = index // manually change page
                                                }
                                        }
                                    }
                                }
                            }
                            
                        }else{
                            Image("getkartplaceholder").frame(width:widthScreen-20,height: 200)
                                .cornerRadius(10)
                        }
                        
                        HStack{
                            
                            if (objVM.itemObj?.isFeature ?? false) == true{
                                Text("Featured").frame(width:75,height:20)
                                    .background(.orange)
                                    .cornerRadius(5)
                                    .foregroundColor(Color(UIColor.white))
                                    .padding(.horizontal).padding(.top,5)
                                    .font(.manrope(.regular, size: 13))
                                
                            }
                            
                            Spacer()
                            
                            if itemUserId != Local.shared.getUserId(){
                                Button(action: {
                                    if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                                        
                                        objVM.addToFavourite()
                                    }
                                }) {
                                    
                                    let isLike = (objVM.itemObj?.isLiked ?? false)
                                    Image( isLike ? "like_fill" : "like")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                       // .foregroundColor(isLike ? .red : .gray)
                                        .padding()
                                }
                                
                            }
                        }
                        
                    }
                    
                    if Local.shared.getUserId() == itemUserId {
                        
                        HStack {
                            HStack {
                                Image(systemName: "eye")
                                Text("Views: \(objVM.itemObj?.clicks ?? 0)")
                            }.padding()
                                .frame(maxWidth: .infinity,maxHeight:40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            Spacer(minLength: 20)
                            HStack {
                                Image(systemName: "heart")
                                Text("Like: \(objVM.itemObj?.totalLikes ?? 0)")
                            }
                            .padding()
                            .frame(maxWidth: .infinity,maxHeight:40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        .padding([.horizontal,.top],5)
                        .foregroundColor(.gray)
                    }
                    
                    if Local.shared.getUserId() == itemUserId && (objVM.itemObj?.rejectedReason?.count  ?? 0) > 0 {
                        
                        
                        if ((objVM.itemObj?.status ?? "") == "rejected"){
                            RejectedReasonView(rejectedReason: objVM.itemObj?.rejectedReason ?? "")
                        }
                    }
                    
                    
                    Text(objVM.itemObj?.name ?? "")
                        .font(Font.manrope(.semiBold, size: 16))
                        .padding(.top, 10)
                        .padding(5)
                    
                    HStack{
                        
                        Text("\(Local.shared.currencySymbol) \((objVM.itemObj?.price ?? 0.0).formatNumber())")
                            .font(Font.manrope(.bold, size: 16))
                            .foregroundColor(Color(CustomColor.sharedInstance.priceColor))
                            .padding(5)
                           // .padding(.bottom,5)
                        
                        Spacer()
                        if Local.shared.getUserId() == itemUserId {
                            
                            
                            let status = objVM.itemObj?.status ?? ""
                            let (bgColor, titleColor, displayStatus) = statusColors(for: status)
                            
                            Text(displayStatus.capitalized)
                                .font(Font.manrope(.medium, size: 14))
                                .foregroundColor(titleColor)
                                .padding(.horizontal,5)
                                .frame(height: 26)
                                .background(bgColor)
                                .cornerRadius(13)
                        }
                    }
                    
                    HStack{
                        HStack{
                            Image("location_icon").renderingMode(.template).foregroundColor(.orange)
                            Text(objVM.itemObj?.address ?? "")
                                .lineLimit(1)
                                .font(Font.manrope(.medium, size: 16))
                            Spacer()
                        }
                        
                        Text(getFormattedCreatedDate())
                            .font(Font.manrope(.medium, size: 15))
                    }.padding(5)
                    //.padding(.bottom,5)
                    
                    if (Local.shared.getUserId() == itemUserId) && objVM.itemObj?.status?.lowercased() == "draft" {
                        
                        HStack{
                            Spacer()
                            Image("create_add").padding(5)
                            VStack{
                                Spacer()
                                Text("Post your ad, attract more clients and sell faster")
                                    .font(.manrope(.regular, size: 16.0))
                                    .padding(.top,10)
                                
                                HStack{
                                    Button(action: {
                                        self.objVM.postNowApi(nav: self.navController)
                                    }) {
                                        Text("Post Now").font(.manrope(.semiBold, size: 16.0)).frame(width: 145, height: 40, alignment: .center)
                                            .foregroundColor(.white)
                                            .background(Color.orange)
                                            .cornerRadius(8)
                                    }.padding([.bottom,.leading],10)
                                    Spacer()
                                    
                                }
                                Spacer()
                                
                            }
                            Spacer()
                            
                        }
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom)
                    }
                    if !isFeatured && (Local.shared.getUserId() == itemUserId) && objVM.itemObj?.status == "approved"{
                        
                        HStack{
                            Spacer()
                            Image("create_add").padding(5)
                            VStack{
                                Spacer()
                                Text("Boost your ad, attract more clients and sell faster")
                                    .font(.manrope(.regular, size: 16.0))
                                    .padding(.top,10)
                                
                                HStack{
                                    Button(action: {
                                        //                                    self.objVM.getLimitsApi(nav: self.navController)
                                        self.objVM.makeItemFeaturd(nav: self.navController)
                                        
                                    }) {
                                        Text("Create Boost Ad").font(.manrope(.semiBold, size: 16.0)).frame(width: 145, height: 40, alignment: .center)
                                            .foregroundColor(.white)
                                            .background(Color.orange)
                                            .cornerRadius(8)
                                    }.padding([.bottom,.leading],10)
                                    Spacer()
                                    
                                }
                                Spacer()
                                
                            }
                            Spacer()
                            
                        }
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom)
                    }
                    
                    if (objVM.itemObj?.customFields ?? []).count > 0 {
                        
                        let columns = [
                            GridItem(.adaptive(minimum: 100, maximum: widthScreen/2.0-10)),
                            GridItem(.adaptive(minimum: 100, maximum: widthScreen/2.0-10)),
                        ]
                        
                        LazyVGrid(columns: columns, alignment:.leading, spacing: 5) {
                        if let arr = objVM.itemObj?.customFields{
                            ForEach(arr){obj in
                                
                                if (obj.value?.count ?? 0) > 0 {
                                    InfoView(icon: obj.image ?? "",
                                             text: obj.name ?? "",
                                             value:(((obj.value?.count ?? 0) > 0 ? obj.value?.first ?? "" : "") ?? ""),
                                             navController: self.navController)
                                }
                            }
                        }
                    }
                }
                    
                    VStack(alignment:.leading) {
                        Divider().padding(.top)
                        Text("About this item").font(Font.manrope(.semiBold, size: 16))
                        /*Text(objVM.itemObj?.description ?? "")
                         .font(Font.manrope(.regular, size: 15))
                         .foregroundColor(.gray)*/
                        
                        ExpandableTextView(
                            text: objVM.itemObj?.description ?? "",
                            lineLimit: 5
                        )
                        
                        Divider()
                        
                        let sellerName = objVM.itemObj?.user?.name ?? ""
                        let sellerPic = objVM.itemObj?.user?.profile ?? ""
                        let sellerMob = objVM.itemObj?.user?.mobile ?? ""
                        let sellerIsVerified = objVM.itemObj?.user?.isVerified ?? 0
                        let sellerId = objVM.itemObj?.user?.id ?? 0
                        
                        
                        SellerInfoView(name: sellerName, email: "", image:sellerPic,mobile: sellerMob,mobileVisibility:isVisibleContact,isverified:sellerIsVerified)
                            .onTapGesture {
                                
                                let hostingController = UIHostingController(rootView: SellerProfileView(navController: self.navController, userId: sellerId))
                                self.navController?.pushViewController(hostingController, animated: true)
                            }
                        
                        Text("Location").font(Font.manrope(.semiBold, size: 16))
                    }
                    
                    HStack{
                        Image("location_icon").renderingMode(.template)
                            .foregroundColor(.orange)
                        Text(objVM.itemObj?.address ?? "").font(Font.manrope(.medium, size: 16))
                        
                        Spacer()
                    }
                    
                    if let lat = objVM.itemObj?.latitude, let lon = objVM.itemObj?.longitude {
                        
                        PinnedMapView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                            let swiftUIview = MapLocationView(latitude: objVM.itemObj?.latitude ?? 0.0, longitude: objVM.itemObj?.longitude ?? 0.0, address: objVM.itemObj?.address ?? "", navController: self.navController)
                            let hostingController = UIHostingController(rootView: swiftUIview)
                            self.navController?.pushViewController(hostingController, animated: true)
                        } .frame(height: 160)
                            .cornerRadius(10)
                            .id("static-map-\(lat)-\(lon)")
                    }
                    
                    
                    if (Local.shared.getUserId() != itemUserId) {
                        
                        let isReported = objVM.itemObj?.isAlreadyReported ?? false
                        if isReported == false {
                            //Reporting ads
                            reportingAdsView
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .clipped()
                                .background(Color(.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.2)
                                )
                                .cornerRadius(10.0)
                                .clipped()
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .padding(.top, 5)
                        }
                    }
                    
                    
                    LazyVStack(alignment: .leading, spacing: 10) {
                        
                        if objVM.relatedDataItemArray.count > 0 {
                            HStack{
                                Text("Related Ads").foregroundColor(Color(UIColor.label)).font(Font.manrope(.semiBold, size: 16))
                                Spacer()
                            }
                        }
                        
                        if !objVM.bannerAdsArray.isEmpty {
                            AutoScrollBannerAdsView(sliderArray: objVM.bannerAdsArray, currentIndex: 0,navController:self.navController)
                            //.frame(height: 180)
                        }
                        
                        
                        RelatedItemsRow(
                            items:  $objVM.relatedDataItemArray,
                            onItemTapped: { item in
                                var swiftUIview = ItemDetailView(
                                    navController: self.navController,
                                    itemId: item.id ?? 0,
                                    itemObj: item,
                                    slug: item.slug
                                )
                                swiftUIview.returnValue = { value in
                                    if let obj = value {
                                        updateItemInList(obj)
                                    }
                                }
                                let hostingController = UIHostingController(rootView: swiftUIview)
                                self.navController?.pushViewController(hostingController, animated: true)
                            }) { likedObj in
                                updateItemInList(likedObj)
                                
                            }
                    }
                }//.padding(.vertical)
                .padding(.horizontal,8)
                .padding(.top,5)
                
            }
            .navigationBarHidden(true)
        }.padding(0)
        .onAppear{
            
            if objVM.itemObj == nil{
                objVM.getItemDetail(id: self.itemId,slug:self.slug,nav: self.navController)
                
                objVM.updateSelectedIndex = {
                    if objVM.galleryImgArray.count > 1{
                        selectedIndex = 0
                    }
               }
            }else{
              //  if objVM.sellerObj == nil {
                if objVM.itemObj?.user == nil || objVM.relatedDataItemArray.count == 0 {
                  //  self.objVM.getSeller(sellerId:objVM.itemObj?.userID ?? 0)
                    self.objVM.getProductListApi(categoryId: objVM.itemObj?.categoryID ?? 0,excludeId:  objVM.itemObj?.id ?? 0)
                    self.objVM.setItemTotalApi()
                }
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(SocketEvents.itemOffer.rawValue))) { notification in
            
            guard let data = notification.userInfo else{
                return
            }
            
            if let dataDict = data["data"] as? Dictionary<String,Any>{
                
                let id = dataDict["id"] as? Int ?? 0
                let buyer_id = dataDict["buyer_id"] as? Int ?? 0
                let seller_id = dataDict["seller_id"] as? Int ?? 0
                let item_id = dataDict["item_id"] as? Int ?? 0
                
                if (item_id == objVM.itemObj?.id ){
                    var userId = 0
                    if Local.shared.getUserId() == buyer_id{
                        userId = seller_id
                    }else if Local.shared.getUserId() == seller_id{
                        userId = buyer_id
                    }
                    objVM.itemObj?.isAlreadyOffered = true
                    objVM.itemObj?.itemOffers = [ItemOffers(amount: Int(objVM.itemObj?.price ?? 0.0), buyerID: buyer_id, createdAt: nil, id: id, itemId: objVM.itemObj?.id, sellerID: seller_id, updatedAt: nil)]
                                      
                    let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                    destVC.item_offer_id = id
                    destVC.userId = userId
                    self.navController?.pushViewController(destVC, animated: true)
                }
            }
        }
        
        
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(SocketEvents.createRoom.rawValue))) { notification in
                
                guard let data = notification.userInfo else{
                    return
                }
                
                if let dataDict = data["data"] as? Dictionary<String,Any>{
                    
                    let id = dataDict["id"] as? Int ?? 0
                    let buyer_id = dataDict["buyer_id"] as? Int ?? 0
                    let seller_id = dataDict["seller_id"] as? Int ?? 0
                    let item_id = dataDict["item_id"] as? Int ?? 0
                    
                    if (item_id == objVM.itemObj?.id ){
                        var userId = 0
                        if Local.shared.getUserId() == buyer_id{
                            userId = seller_id
                        }else if Local.shared.getUserId() == seller_id{
                            userId = buyer_id
                        }
                        objVM.itemObj?.isAlreadyOffered = true
                        objVM.itemObj?.itemOffers = [ItemOffers(amount: Int(objVM.itemObj?.price ?? 0.0), buyerID: buyer_id, createdAt: nil, id: id, itemId: objVM.itemObj?.id, sellerID: seller_id, updatedAt: nil)]
                                          
                        let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                        destVC.item_offer_id = id
                        destVC.userId = userId
                        self.navController?.pushViewController(destVC, animated: true)
                        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
                    }
                }
            }
        
        .sheet(isPresented: $showSheet) {
            // Always present the same view
            SafetyTipsView(onContinueOfferTap: {
                self.showOfferPopup = true
            })
            // Apply detents and drag indicator only if iOS 16+
            .modifier(PresentationModifier())            
        }
        
        
        .fullScreenCover(isPresented: $showOfferPopup) {
            if #available(iOS 16.4, *) {
                MakeAnOfferView(
                    isPresented: $showOfferPopup,
                    sellerPrice: objVM.itemObj?.price ?? 0.0,
                    onOfferSubmit: { offer in
                        // submittedOffer = offer
                       // print("User submitted offer: ₹\(offer)")
                        callOfferSocket(amount: offer)
                        
                    }
                ).presentationDetents([.large, .large]) // Optional for different heights
                    .background(.clear) // Remove default background
                    .presentationBackground(.clear)
            } else {
                // Fallback on earlier versions
                
                MakeAnOfferView(
                    isPresented: $showOfferPopup,
                    sellerPrice: objVM.itemObj?.price ?? 0.0,
                    onOfferSubmit: { offer in
                        // submittedOffer = offer
                        callOfferSocket(amount: offer)
                       // print("User submitted offer: ₹\(offer)")
                    }
                )
            } // Works in iOS 16+
        }


        
        let itemUserId = objVM.itemObj?.userID ?? 0
        
        if Local.shared.getUserId() == itemUserId {
            
            if ((objVM.itemObj?.status ?? "") == "review") || ((objVM.itemObj?.status ?? "") == "draft") || ((objVM.itemObj?.status ?? "") == "expired"){
             
                HStack {
                    Button(action: {
                        
                        if ((objVM.itemObj?.status ?? "") == "expired"){
                            self.objVM.renewAdsApi(nav: self.navController)
                       
                        }else{
                            
                           if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddDetailVC") as? CreateAddDetailVC {
                                vc.itemObj = objVM.itemObj
                                vc.popType = .editPost
                                self.navController?.pushViewController(vc, animated: true)
                            }
                           
                            /*
                            let swiftuIview = CreateAdFirstView(navigationController: self.navController,popType: .editPost, itemObj: objVM.itemObj)
                            
                            let hostingVC = UIHostingController(rootView: swiftuIview)
                            
                            self.navController?.pushViewController(hostingVC, animated: true)
                             */
                            
                        }
                    }) {
                        
                        if ((objVM.itemObj?.status ?? "") == "expired"){
                            Text("Renew").font(.manrope(.semiBold, size: 16.0))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(Color.orange)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange, lineWidth: 1)
                                )
                        }else{
                            Text("Edit").font(.manrope(.semiBold, size: 16.0))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }.frame(height: 40)
                   
                    
                    Button(action: {
                        showConfirmDialog = true
                        
                    }) {
                        Text("Remove")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.frame(height: 40)
                   // .padding([.leading,.trailing])
                    
                    .confirmationDialog("Confirm Remove",
                                        isPresented: $showConfirmDialog,
                                        titleVisibility: .visible) {
                        Button("Confirm", role: .destructive) {
                            // Confirm logic
                            self.objVM.deleteItemApi(nav: navController)
                            
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("After removing, ads will be deleted.")
                    }
                }
                .padding(.horizontal).padding(.bottom)
                
            }else  if ((objVM.itemObj?.status ?? "") == "sold out")  ||   ((objVM.itemObj?.status ?? "") == "inactive"){
                
                Button(action: {
                    showConfirmDialog = true
                    
                }) {
                    Text("Remove")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.frame(height: 40)
                .padding([.leading,.trailing])
                
                .confirmationDialog("Confirm Remove",
                                    isPresented: $showConfirmDialog,
                                    titleVisibility: .visible) {
                    Button("Confirm", role: .destructive) {
                        // Confirm logic
                        self.objVM.deleteItemApi(nav: navController)
                        
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("After removing, ads will be deleted.")
                }
                
            }else if ((objVM.itemObj?.status ?? "") == "rejected"){
                
                HStack{
                    
                    Button(action: {
                        showConfirmDialog = true
                        
                    }) {
                        Text("Remove").font(.manrope(.semiBold, size: 16.0))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.frame(height: 40)
                    //.padding([.leading,.trailing])
                    
                    .confirmationDialog("Confirm Remove",
                                        isPresented: $showConfirmDialog,
                                        titleVisibility: .visible) {
                        Button("Confirm", role: .destructive) {
                            // Confirm logic
                            self.objVM.deleteItemApi(nav: navController)
                            
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("After removing, ads will be deleted.")
                    }
                    
                    Button(action: {

                        if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddDetailVC") as? CreateAddDetailVC {
                             vc.itemObj = objVM.itemObj
                             vc.popType = .editPost
                             self.navController?.pushViewController(vc, animated: true)
                         }
                        
                    }) {
                        Text("Edit").font(.manrope(.semiBold, size: 16.0))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(Color(.label))
                            .cornerRadius(10)
                    }.frame(height: 40)
                    //.padding([.leading,.trailing])
                    
                    
                   }
                .padding(.horizontal).padding(.bottom)
           
                
            } else{
                
                HStack {
                    Button(action: {
                        if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddDetailVC") as? CreateAddDetailVC {
                            vc.itemObj = objVM.itemObj
                            vc.popType = .editPost
                            self.navController?.pushViewController(vc, animated: true)
                        }
                    }) {
                 
                        Text("Edit").font(.manrope(.semiBold, size: 16.0))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.orange)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 1.5)
                            )
                            .cornerRadius(10)
                    }.frame(height: 40)
                    
                    Button(action: {
                        
                        
                        if (objVM.itemObj?.status ?? "") == "approved"  || (objVM.itemObj?.status ?? "") == "sold out" {
                            
                            var markAsSold = MarkAsSoldView(navController: self.navController)
                            markAsSold.productTitle = objVM.itemObj?.name ?? ""
                            markAsSold.price = Int(objVM.itemObj?.price ?? 0.0)
                            markAsSold.productImg = objVM.itemObj?.image ?? ""
                            markAsSold.itemId = objVM.itemObj?.id ?? 0
                            let hostingController = UIHostingController(rootView: markAsSold)
                            self.navController?.pushViewController(hostingController, animated: true)
                            
                        }else{
                            
                        }
                        
                    }) {
                        
                        if "Sold Out" == getButtonTitle(){
                            
                            Text(getButtonTitle()).font(.manrope(.semiBold, size: 16.0))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                           
                        }else{
                            Text(getButtonTitle()).font(.manrope(.semiBold, size: 16.0))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }.frame(height: 40)
                }
                .padding(.horizontal)
            }
        }else{
            //Offer and chat button both
            if (objVM.itemObj?.isAlreadyOffered ?? false) == true{
                
                Button(action: {
                    
                    if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                        
                        Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
                        if (objVM.itemObj?.isAlreadyOffered ?? false) == true{
                                                    
                            let offerId =
                            objVM.itemObj?.itemOffers?.first?.id ?? 0
                            let sellerId =
                            objVM.itemObj?.itemOffers?.first?.sellerID ?? 0
                            let buyerId =
                            objVM.itemObj?.itemOffers?.first?.buyerID ?? 0
                            var userId = 0
                            if sellerId == Local.shared.getUserId(){
                                userId = buyerId
                            }else{
                                userId = sellerId
                            }
                            
                            //Already pushed same chat screen
                            for controller in self.navController?.viewControllers ?? []{
                                
                                if let destController = controller as? ChatVC{
                                    if destController.userId == userId , destController.item_offer_id == offerId {
                                        self.navController?.popToViewController(destController, animated: true)
                                        return
                                    }
                                }
                            }
                            
                            //Push new chat screen
                            let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                            destVC.item_offer_id = offerId
                            destVC.userId = userId
                            self.navController?.pushViewController(destVC, animated: true)
                            
                        }else{
                            showSheet = true
                            
                        }
                    }
                    
                }) {
                    
                    Text("Chat").font(.manrope(.semiBold, size: 16.0))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.frame(height: 40)
                .padding([.leading,.trailing])
                
            }else{
                
                HStack{
              
                    Button(action: {
                        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                            
                            //Call create offer Id sockeet
                            isCreateRoomSafetyTips = true
                            
                        }
                        
                    
                    }) {
                        
                        Text("Chat").font(.manrope(.semiBold, size: 16.0))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.frame(height: 40)
                  //  .padding([.leading,.trailing])
                    
                    .sheet(isPresented: $isCreateRoomSafetyTips) {
                        // Always present the same view
                        SafetyTipsView(btnTitle:"Continue to chat", onContinueOfferTap: {
                            createRoom()
                            
                        })
                        // Apply detents and drag indicator only if iOS 16+
                        .modifier(PresentationModifier())
                        
                    }

                    
                    Spacer(minLength: 10)
                 
                    Button(action: {
                        
                        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                            
                            Themes.sharedInstance.is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true
                                
                            showSheet = true
                            
                        }
                        
                    }) {
                        
                        Text("Make an Offer").font(.manrope(.semiBold, size: 16.0))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.frame(height: 40)
                }.padding([.leading,.trailing])
            }
        }
    }
    
    
    
    func getButtonTitle() -> String{
        
        var strTitle = ""
        //enum('review', 'approved', 'rejected', 'sold out','inactive')
        if (objVM.itemObj?.status ?? "") == "approved" {
            strTitle = "Sold Out"
            
        }else if (objVM.itemObj?.status ?? "") == "sold out" {
            
            strTitle = "Remove"
            
        }else if (objVM.itemObj?.status ?? "") == "review"{
            
            strTitle = "Remove"
        }else if (objVM.itemObj?.status ?? "") == "rejected"{
            
            strTitle = "Remove"
        }else if (objVM.itemObj?.status ?? "") == "inactive"{
            
            strTitle = "Remove"
        } else if (objVM.itemObj?.status ?? "") == "draft"{
            
            strTitle = "Draft"
        }else if (objVM.itemObj?.status ?? "") == "expired"{
            
            strTitle = "Expired"
        }
        
        return strTitle
    }
    
    
    func callOfferSocket(amount:String){
        let params = ["item_id":(objVM.itemObj?.id ?? 0), "amount":amount] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.itemOffer.rawValue, params)
    }
    
    func navigateToPager(){
        
        let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "ZoomImageViewController") as! ZoomImageViewController
        vc.currentTag = selectedIndex ?? 0
        
        if (objVM.itemObj?.videoLink?.count ?? 0) > 0
        {
            vc.imageArrayUrl = objVM.galleryImgArray.dropLast()
        }else{
            vc.imageArrayUrl = objVM.galleryImgArray
        }
        self.navController?.pushViewController(vc, animated: true )
    }
    
    func openPlayerAndPlay(strUrl:String){
        
    }
    
    
    func createRoom(){
        
        let params = ["item_id":(objVM.itemObj?.id ?? 0)] as [String : Any]
        SocketIOManager.sharedInstance.emitEvent(SocketEvents.createRoom.rawValue, params)
    }
    
    func statusColors(for status: String) -> (Color, Color, String) {
        switch status {
        case "approved":
            return (Color(hexString: "#e5f7e7"), Color(hexString: "#32b983"), status)
        case "rejected", "inactive":
            return (Color(hexString: "#ffe5e6"), Color(hexString: "#fe0002"), status)
        case "review":
            return (Color(hexString: "#e6eef5"), Color(hexString: "#3e4c63"), "Under review")
        case "sold out":
            return (Color(hexString: "#fff8eb"), Color(hexString: "#ffbb34"), status)
        case "draft":
            return (Color(hexString: "#e6eef5"), Color(hexString: "#3e4c63"), "Draft")
        case "expired":
            return (Color(hexString: "#ffe5e6"), Color(hexString: "#fe0002"), status)
        default:
            return (.clear, .black, status)
        }
    }
    
    func getFormattedCreatedDate() -> String{
       
        
        let isoDateString = objVM.itemObj?.createdAt ?? ""

        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

        if let date = isoFormatter.date(from: isoDateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMM yyyy"
            let formattedDate = outputFormatter.string(from: date)
            return formattedDate
        } else {
            print("Invalid date string")
            return ""
        }
    }
    
    
    @ViewBuilder
    private var reportingAdsView: some View {
        
        HStack(spacing:5) {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.red)
                Text("Did you find any problem?").font(Font.manrope(.medium, size: 14))
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
                Text("Report this Ad")
                    .font(Font.manrope(.semiBold, size: 15))
                    .foregroundColor(.red).frame(width: 127, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 0.5)
                    ) .background(Color.red.opacity(0.1)).cornerRadius(15.0)
                    .onTapGesture {
                        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                            let reportAds =  ReportAdsView(itemId:(objVM.itemObj?.id ?? 0)) {bool in
                                objVM.itemObj?.isAlreadyReported = bool
                            }
                            let destVC = UIHostingController(rootView:reportAds)
                            destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
                            destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
                            destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                            self.navController?.present(destVC, animated: true, completion: nil)
                        }
                        
                    }

            }
    }
    
    @ViewBuilder
    private var headerBar: some View {
        HStack {
            Button {
                returnValue?(objVM.itemObj)
                self.navController?.popViewController(animated: true)
            } label: {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
            }.padding(.leading, 10)

            Spacer()

            if (objVM.itemObj?.status ?? "") == "approved"{
                
                Button {
                    showShareSheet = true
                } label: {
                    Image("share").renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }.padding(.trailing, 10)
                
                    .actionSheet(isPresented: $showShareSheet) {
                        ActionSheet(
                            title: Text(""),
                            message: nil,
                            buttons: [
                                .default(Text("Copy Link"), action: {
                                    UIPasteboard.general.string = ShareMedia.itemUrl + "\(objVM.itemObj?.slug ?? "")?share=true"
                                    AlertView.sharedManager.showToast(message: "Copied successfully.")
                                }),
                                .default(Text("Share"), action: {
                                    ShareMedia.shareMediafrom(type: .item, mediaId: "\(objVM.itemObj?.slug ?? "")", controller: (self.navController?.topViewController)!)
                                }),
                                .cancel()
                            ]
                        )
                    }
            }
                            


            let sellerId = (objVM.itemObj?.user?.id ?? 0)

            if sellerId == Local.shared.getUserId()  && objVM.itemObj?.status == "approved"{
                
                Button {
                    showMoreOptionSheet = true
                } label: {
                    Image("more").renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }.padding(.trailing, 10)
                    .actionSheet(isPresented: $showMoreOptionSheet) {
                        ActionSheet(
                            title: Text(""),
                            message: nil,
                            buttons: [
                                .default(Text("Deactivate"), action: {
                                    showConfirmDeactvatePopup = true
                                }),
                                .default(Text("Remove"), action: {
                                    showConfirmDialog = true

                                }),
                                .cancel()
                            ]
                        )
                    }
                    .confirmationDialog("Confirm Remove",
                                        isPresented: $showConfirmDialog,
                                        titleVisibility: .visible) {
                        Button("Confirm", role: .destructive) {
                            // Confirm logic
                            self.objVM.deleteItemApi(nav: navController)
                            
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("After removing, ads will be deleted.")
                    }
                
                
                    .confirmationDialog("Confirm Deactivate",
                                        isPresented: $showConfirmDeactvatePopup,
                                        titleVisibility: .visible) {
                        Button("Confirm", role: .destructive) {
                            // Confirm logic
                            self.objVM.updateItemStatus(nav: navController)
                            
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("After deactivate, ads will be inactive.")
                    }
            }
            
        }
        .background(
            PopGestureDetector {
                returnValue?(objVM.itemObj) // Called on swipe back too!
                
            }
        )
        .frame(height: 44)
        .background(Color(UIColor.systemBackground))

    }

    private func updateItemInList(_ value: ItemModel) {
        if let index = $objVM.relatedDataItemArray.firstIndex(where: { $0.id == value.id }) {
            objVM.relatedDataItemArray[index] = value
        }
    }
    
    func extractDominantColor(from image: Image) {
        // Convert SwiftUI Image to UIImage
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: image)
            if let uiImage = renderer.uiImage {
                if let averageUIColor = uiImage.averageColor{
                    self.backgroundColor = Color(averageUIColor).opacity(0.4)
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func extractYouTubeID(from url: String) -> String {
        let patterns = [
            "youtu.be/([^?&]+)",
            "youtube.com/watch\\?v=([^?&]+)",
            "youtube.com/embed/([^?&]+)"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        return ""
    }


   /* func extractYouTubeID(from urlString: String) -> String {
        let patterns = [
            "youtube\\.com/watch\\?v=([\\w-]{11})",
            "m\\.youtube\\.com/watch\\?v=([\\w-]{11})",
            "youtu\\.be/([\\w-]{11})",
            "youtube\\.com/embed/([\\w-]{11})"
        ]

        for pattern in patterns {
            
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: urlString, options: [], range: NSRange(urlString.startIndex..., in: urlString)),
               let range = Range(match.range(at: 1), in: urlString) {
                return String(urlString[range])
            }
        }

        return ""
    }
*/
    var isVisibleContact: Int {
     
        let itemUserId = objVM.itemObj?.userID ?? 0
        
        if Local.shared.getUserId() == itemUserId {
            return 0
        } else {
            return objVM.itemObj?.user?.mobileVisibility ?? 0
        }
    }
}


#Preview {
    ItemDetailView(navController:nil,itemId:0, itemObj: nil,isMyProduct:false, slug: "")
}


struct InfoView: View {
    let icon: String
    let text: String
    let value:String
    var navController:UINavigationController?

    var body: some View {
        HStack {
            
            if icon.lowercased().contains(".svg"), let iconURL = URL(string: icon) {

                RemoteSVGWebView(svgURL: iconURL)
                      .frame(width: 30, height: 30)
                      .cornerRadius(7.0)
                      .clipped()
            } else {
                
                AsyncImage(url: URL(string: icon)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width:30, height: 30)
                        .cornerRadius(7.0)
                    
                }placeholder: {
                    
                    Image("getkartplaceholder")
                        .resizable()
                        .scaledToFit()
                        .frame(width:30, height: 30)
                        .cornerRadius(7.0)
                }
            }
       
            VStack(alignment: .leading,spacing: 0){
               // Spacer()
                Text(text.trimmingCharacters(in: .whitespaces))
                    .font(.manrope(.regular, size: 12)).foregroundColor(.gray).lineLimit(2)
                
                if value.contains("http"){
                    Button(action: {
                        if let url = URL(string: value){
                           
                            let vc = UIHostingController(rootView:  PreviewURL(fileURLString:value))
                            
                            navController?.pushViewController(vc, animated: true)

                        }
                    }) {
                         AsyncImage(url: URL(string: value)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width:30, height: 30)
                            
                        }placeholder: {
                            
                            Image("getkartplaceholder").resizable()
                                .scaledToFit()
                                .frame(width:30, height: 30)
                        }
                    }
                }else{
                    Text(value.trimmingCharacters(in: .whitespaces))
                        .font(.manrope(.medium, size: 12)).foregroundColor(Color(UIColor.label)).lineLimit(3)
                }

            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}



struct RejectedReasonView:View {
    let rejectedReason:String
    var body: some View {
        // MARK: - Rejected Banner
        HStack{
            Rectangle()
                .fill(Color.red)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("REJECTED REASON")
                    .font(.manrope(.bold, size: 14.0))
                    .foregroundColor(.red)
                
                Text(rejectedReason)
                    .font(.manrope(.regular, size: 13.0))
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}


struct SellerInfoView: View {
    let name: String
    let email: String
    let image: String
    let mobile: String
    var mobileVisibility:Int = 1
    var isverified:Int = 0
    @State private var showMessageView = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack{

                 /*   AsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width:55, height: 55)
                            .cornerRadius(27.5)
                        
                    }placeholder: {
                        
                        Image("user-circle").resizable()
                            .scaledToFit()
                            .frame(width:55, height: 55)
                            .cornerRadius(27.5)
                    }
                */
                
                ContactImageSwiftUIView(name: name, imageUrl: image, fallbackImageName: "user-circle", imgWidth: 55, imgHeight: 55)

             
                HStack{
                    Text("\(name)")
                        .font(.headline)
                    if isverified == 1{
                        Image("verifiedIcon")
                            .resizable()
                   
                            .scaledToFit()
                            .frame(width:20, height: 20)
                    }
                    
                    Spacer()
                }.contentShape(Rectangle())

 
                    Spacer(minLength: 0)
              
                if mobileVisibility == 1  && mobile.count > 0 {
                    Button {
                        showMessageView = true
                        
                    } label: {
                        Image("message").renderingMode(.template).foregroundColor(.orange)
                    }.frame(width: 40,height: 40).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    Button {
                        callToSellerMobileNumber()
                    } label: {
                        Image("call").renderingMode(.template)
                            .foregroundColor(.orange)
                    }.frame(width: 40,height: 40).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
             
                Image("arrow_right").renderingMode(.template).foregroundColor(.orange).frame(width: 20,height: 20)

            }
        }.sheet(isPresented: $showMessageView) {
            if MFMessageComposeViewController.canSendText() {
                MessageView(recipients: [mobile], body: "")
            } else {
                Text("This device can't send SMS.")
            }
        }
    }

    
    
     
    func callToSellerMobileNumber(){
        if let url = URL(string: "tel://\(mobile)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

struct RelatedItemsRow: View {
    @Binding var items: [ItemModel]
    var onItemTapped: (ItemModel) -> Void
    var onItemLikedTapped: (ItemModel) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach($items, id: \.id) { $item in
                    ProductCard(objItem: $item,onItemLikeDislike: { likedObj in })
                    .onTapGesture {  onItemTapped(item) }
                }
            }.padding([.bottom])
        }
    }
}




struct PinnedMapView: View {
    var coordinate: CLLocationCoordinate2D
    var onTap: (() -> Void)? = nil

    @State private var region: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D, onTap: (() -> Void)? = nil) {
        self.coordinate = coordinate
        self.onTap = onTap
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region,
            interactionModes: [],
            annotationItems: [MapPinItem(coordinate: coordinate)]
        ) { item in
            MapMarker(coordinate: item.coordinate, tint: .red)
        }
        .frame(height: 160)
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

struct PresentationModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.fraction(0.80)])
                .presentationDragIndicator(.visible)
        } else {
            content // No special presentation on iOS 15
        }
    }
}


struct MapPinItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}




struct MessageView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    var recipients: [String]
    var body: String

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageView

        init(_ parent: MessageView) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) {
                self.parent.presentation.wrappedValue.dismiss()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.messageComposeDelegate = context.coordinator
        vc.recipients = recipients
        vc.body = body
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}


extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extent = inputImage.extent
        let filter = CIFilter.areaAverage()
        filter.inputImage = inputImage
        filter.extent = extent

        let context = CIContext()
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: 1)
    }
}



import SwiftUI
import WebKit

import SwiftUI
import WebKit

struct WebVideoView: UIViewRepresentable {
    let videoURL: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.configuration.allowsInlineMediaPlayback = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {

        let html: String

        if videoURL.contains("facebook.com") || videoURL.contains("fb.watch") {
            // -------- FACEBOOK EMBED --------
            let encoded = videoURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            html = """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body style="margin:0;padding:0;">
                <iframe 
                    src="https://www.facebook.com/plugins/video.php?href=\(encoded)&show_text=false&width=560"
                    width="100%" 
                    height="100%" 
                    style="border:none;overflow:hidden" 
                    scrolling="no" 
                    frameborder="0"
                    allowfullscreen="true" 
                    allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share">
                </iframe>
            </body>
            </html>
            """
        } else {
            // -------- NORMAL MP4 VIDEO --------
            html = """
            <html>
            <head>
            <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
            </head>
            <body style="margin:0; padding:0; background:black;">
                <video width="100%" height="100%" controls playsinline autoplay>
                    <source src="\(videoURL)" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            </body>
            </html>
            """
        }

        webView.loadHTMLString(html, baseURL: nil)
    }
}

struct YouTubeFallbackView: View {
    let videoID: String

    var body: some View {
        Button {
            openYouTube()
        } label: {
            ZStack {
                AsyncImage(
                    url: URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
                ) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.black
                }

                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
            .frame(height: 200)
            .cornerRadius(10)
        }
    }

    private func openYouTube() {
        let appURL = URL(string: "youtube://\(videoID)")!
        let webURL = URL(string: "https://www.youtube.com/watch?v=\(videoID)")!

        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }
}


struct YouTubeWebView: UIViewRepresentable {
    let videoID: String
    @Binding var isVisible: Bool  // To track visibility

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedURL = "https://www.youtube.com/embed/\(videoID)?autoplay=1&mute=0&playsinline=1"
        let html = """
        <html>
        <body style="margin:0;padding:0;">
            <iframe width="100%" height="100%" src="\(embedURL)"
                frameborder="0"
                allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen>
            </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
        
        // Pause the video if it is not visible
               if !isVisible {
                   pauseVideo(webView: webView)
               }
    }
    
    func pauseVideo(webView: WKWebView) {
           let pauseScript = """
           var iframe = document.getElementById('youtube-video');
           var player = new YT.Player(iframe);
           player.pauseVideo();
           """
           webView.evaluateJavaScript(pauseScript, completionHandler: nil)
       }
}





import SwiftUI

struct PopGestureDetector: UIViewControllerRepresentable {
    var onPop: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPop: onPop)
    }

    class Coordinator: UIViewController {
        var onPop: () -> Void

        init(onPop: @escaping () -> Void) {
            self.onPop = onPop
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toParent parent: UIViewController?) {
            if parent == nil {
                onPop()
            }
        }
    }
}



struct ExpandableTextView: View {
    let text: String
    let lineLimit: Int
    @State private var isExpanded = false
    @State private var truncated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                Text(text)
                    .font(.manrope(.regular, size: 15))
                    .foregroundColor(.gray)
                    .lineLimit(isExpanded ? nil : lineLimit)
                    .background(
                        TextSizeReader(text: text, font: .manrope(.regular, size: 15), lineLimit: lineLimit) { isTruncated in
                            self.truncated = isTruncated
                        }
                    )
            }

            if truncated {
                Button(action: {
                    isExpanded.toggle()
                }) {
                    HStack{
                        Spacer()
                        Text(isExpanded ? "Read less" : "Read more")
                            .font(.manrope(.semiBold, size: 16))
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
            }
        }
    }
}


struct TextSizeReader: View {
    let text: String
    let font: Font
    let lineLimit: Int
    let onChange: (Bool) -> Void

    var body: some View {
        ZStack {
            Text(text)
                .font(font)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { fullGeometry in
                        Color.clear
                            .onAppear {
                                let fullHeight = fullGeometry.size.height
                                DispatchQueue.main.async {
                                    onChange(fullHeight > lineHeight * CGFloat(lineLimit))
                                }
                            }
                    }
                )
        }
        .hidden()
    }

    var lineHeight: CGFloat {
        // Estimated height per line for 15pt font
        18
    }
}








struct AutoScrollBannerAdsView: View {
    @State var sliderArray: [SliderModel]
    @State var currentIndex = 0
    let navController: UINavigationController?
    
    // Timer that fires every 3 seconds
    private let timer = Timer.publish(every: TimeInterval(Local.shared.bannerScrollInterval), on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(sliderArray.indices, id: \.self) { index in
                    let slider = sliderArray[index]
                    
                    ZStack {
                        AsyncImage(url: URL(string: slider.image ?? "")) { image in
                            image
                                .resizable()
                                .cornerRadius(10)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                        .onTapGesture {
                            BannerNavigation.navigateToScreen(
                                index: index,
                                sliderObj: slider,
                                navigationController: navController,
                                viewType: "AD_DETAIL"
                            )
                        }
                    }
                    .frame(height: 170)
                    .background(Color.clear)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 170)
            .onReceive(timer) { _ in
                // Auto-scroll every 3 seconds
                withAnimation {
                    if currentIndex < sliderArray.count - 1 {
                        currentIndex += 1
                    } else {
                        currentIndex = 0
                    }
                }
            }
            
            if sliderArray.count > 1{
                // Page Indicator
                HStack(spacing: 5) {
                    ForEach(sliderArray.indices, id: \.self) { index in
                        Capsule()
                            .fill(currentIndex == index ? Color.orange : Color.gray.opacity(0.4))
                            .frame(width: currentIndex == index ? 18 : 8, height: 6)
                            .animation(.easeInOut, value: currentIndex)
                    }
                }
                .padding(.top, -3)
            }
        }
    }
}


