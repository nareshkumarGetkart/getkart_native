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

struct ItemDetailView: View {
    
    var navController:UINavigationController?
    
     var itemId = 0
    @State private var selectedIndex:Int?
    @StateObject  var objVM:ItemDetailViewModel
    @State private var showSheet = false
    @State private var showOfferPopup = false
    @State private var showShareSheet = false
    @State var isMyProduct = false
    @State private var showConfirmDialog = false
    
 
    
    init(navController: UINavigationController? = nil, itemId: Int = 0, itemObj: ItemModel?,isMyProduct: Bool = false) {
        self.navController = navController
        self.itemId = itemId
       // self.selectedIndex = selectedIndex
        
        let viewModel = ItemDetailViewModel()
        viewModel.itemObj = itemObj

        /*if let img = itemObj?.image {
            let new = GalleryImage(id:10, image: img, itemID: itemObj?.id)
            viewModel.itemObj?.galleryImages?.insert(new, at: 0)
        }*/
        
        _objVM = StateObject(wrappedValue: viewModel)
        
        
        
        //self.objVM.itemObj = itemObj
      //  self.showSheet = showSheet
//        self.showOfferPopup = showOfferPopup
//        self.showShareSheet = showShareSheet
        self.isMyProduct = isMyProduct
    }

    var body: some View {
        
        HStack{
            Button {
                self.navController?.popViewController(animated: true)
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                
            }.padding(.leading,10)
            
            Spacer()
            
            Button {
                showShareSheet = true
            } label: {
                Image("share").renderingMode(.template).foregroundColor(.black)
            }.padding(.trailing,10)
                .actionSheet(isPresented: $showShareSheet) {
                    
                    ActionSheet(title: Text(""), message: nil, buttons: [
                        
                        .default(Text("Copy Link"), action: {
                            
                        }),
                        
                            .default(Text("Share"), action: {
                                
                            }),
                        
                            .cancel()
                    ])
                }
            
        }.frame(height: 44)
        Divider()
        Spacer()
        VStack{
            ScrollView{
                VStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                    
                        if  (objVM.itemObj?.galleryImages?.count ?? 0) > 0 {
                            TabView(selection: $selectedIndex) {
                                
                                if let arr = objVM.itemObj?.galleryImages as? [GalleryImage], arr.count > 0{
                                    
                                    ForEach(0..<arr.count){ index in
                                        
                                        if  let img = arr[index].image {
                                            AsyncImage(url: URL(string: img)) { image in
                                                image
                                                    .resizable()
                                                    //.aspectRatio(contentMode: .fit)
                                                    .frame(height: 200)
                                                    .cornerRadius(10).padding(.horizontal,5)
                                                    .tag(index).onTapGesture {
                                                        navigateToPager()
                                                    }
                                                
                                            }placeholder: { ProgressView().progressViewStyle(.circular) }
                                        }
                                    }
                                }
                                
                            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)).tint(.orange).cornerRadius(10)
                                .frame(width:widthScreen-20, height: 200)
                            
                        }else{
                            Image("getkartplaceholder").frame(width:widthScreen-20,height: 200)
                                .cornerRadius(10)
                        }
                        
                        HStack{
                           
                            if (objVM.itemObj?.isFeature ?? false) == true{
                                Text("Boost").frame(width:70,height:25).background(.orange).cornerRadius(5).foregroundColor(.white).padding(.horizontal)
                            }
                            
                            Spacer()
                            
                            
                            Button(action: {
                                objVM.addToFavourite()
                            }) {
                                
                                let isLike = (objVM.itemObj?.isLiked ?? false)
                                Image( isLike ? "like_fill" : "like")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(isLike ? .red : .gray)
                                    .padding()
                            }
                        }
                       
                    }


                    let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                    let isFeatured = objVM.itemObj?.isFeature ?? false
                    let loggedInUserId = objLoggedInUser.id ?? 0
                    let itemUserId = objVM.itemObj?.userID ?? 0

                    if loggedInUserId == itemUserId {

                        HStack {
                            HStack {
                                Image(systemName: "eye")
                                Text("\(objVM.itemObj?.clicks ?? 0)")
                            }.padding()
                            .frame(maxWidth: .infinity,maxHeight:40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            Spacer(minLength: 20)
                            HStack {
                                Image(systemName: "heart")
                                Text("\(objVM.itemObj?.totalLikes ?? 0)")
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
                    
                    Text(objVM.itemObj?.name ?? "").font(Font.manrope(.medium, size: 16))
                        .font(Font.manrope(.medium, size: 16))
                        .padding(.top, 10).padding(5)
                    
                    HStack{
                        
                        Text("\(Local.shared.currencySymbol) \(objVM.itemObj?.price ?? 0)")
                            .font(Font.manrope(.medium, size: 16))
                            .foregroundColor(Color(hex: "#FF9900")).padding(5).padding(.bottom,10)
                        
                        Spacer()
                        if loggedInUserId == itemUserId {

                            
                            let status = objVM.itemObj?.status ?? ""
                            let (bgColor, titleColor, displayStatus) = statusColors(for: status)

                            Text(displayStatus)
                                .font(Font.manrope(.medium, size: 15))
                                .foregroundColor(titleColor)
                                .padding(.horizontal)
                                .frame(height: 30)
                                .background(bgColor)
                                .cornerRadius(15)
                        }
                    }
                    
                    HStack{
                        HStack{
                            Image("location_icon").renderingMode(.template).foregroundColor(.orange)
                            Text(objVM.itemObj?.address ?? "").lineLimit(1)
                        }
                        Spacer()
                        Text(objVM.itemObj?.expiryDate ?? "")
                    }.padding(5).padding(.bottom,10)

                    if !isFeatured && (loggedInUserId == itemUserId) && objVM.itemObj?.status == "approved"{

                        HStack{
                            Spacer()
                            Image("create_add").padding(5)
                            VStack{
                                Spacer()
                                Text("Boost your ad, attract more clients and sell faster")
                                    .font(.subheadline)
                                    .padding(.top,10)
                            
                                HStack{
                                    Button(action: {
                                        self.objVM.getLimitsApi(nav: self.navController)
                                    }) {
                                        Text("Create Boost Ad").frame(width: 140, height: 40, alignment: .center)
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
                    }
                    
                    
                    let columns = [
                        GridItem(.adaptive(minimum: 100, maximum: widthScreen/2.0-10)),
                        GridItem(.adaptive(minimum: 100, maximum: widthScreen/2.0-10)),
                    ]
                    
                    LazyVGrid(columns: columns, alignment:.leading, spacing: 5) {
                        if let arr = objVM.itemObj?.customFields{
                            ForEach(arr){obj in
                                                                
                            InfoView(icon: obj.image ?? "", text: obj.name ?? "",value:(((obj.value?.count ?? 0) > 0 ? obj.value?.first ?? "" : "") ?? ""))
                            }
                        }
                    }
                    
                    Divider()
                    VStack(alignment: .leading) {
                        Text("About this item").font(Font.manrope(.semiBold, size: 16))
                        Text(objVM.itemObj?.description ?? "").font(Font.manrope(.regular, size: 15)).foregroundColor(.gray)
                    }.padding(.vertical,1)
                    
                    Divider()
                    SellerInfoView(name: objVM.sellerObj?.name ?? "", email: objVM.sellerObj?.email ?? "", image: objVM.sellerObj?.profile ?? "").onTapGesture {
                        
                        let hostingController = UIHostingController(rootView: SellerProfileView(navController: self.navController, userId: objVM.sellerObj?.id ?? 0))
                        self.navController?.pushViewController(hostingController, animated: true)
                    }
                    
                    Text("Location").font(Font.manrope(.semiBold, size: 16))
                     
                    HStack{
                        Image("location_icon").renderingMode(.template).foregroundColor(.orange)
                        Text(objVM.itemObj?.address ?? "")
                        Spacer()
                    }
                
                    MapView(latitude: objVM.itemObj?.latitude ?? 0.0, longitude: objVM.itemObj?.longitude ?? 0.0,address: objVM.itemObj?.address ?? "")
                       .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.bottom).onTapGesture {
                            
                            let swiftUIview = MapLocationView(latitude: objVM.itemObj?.latitude ?? 0.0, longitude: objVM.itemObj?.longitude ?? 0.0, address: objVM.itemObj?.address ?? "", navController: self.navController)
                            let hostingController = UIHostingController(rootView: swiftUIview)
                            self.navController?.pushViewController(hostingController, animated: true)
                        }
                    
                    
                        
                    if (loggedInUserId != itemUserId) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.red)
                                Text("Did you find any problem?").font(Font.manrope(.semiBold, size: 16))
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            
                            
                            Text("Report this Ad")
                                .font(.subheadline)
                                .foregroundColor(.orange).frame(width: 130, height: 30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                ) .background(.yellow.opacity(0.1)).cornerRadius(15.0)
                                .onTapGesture {
                                  
                                    let isReported = objVM.itemObj?.isAlreadyReported ?? false
                                   
                                    if isReported {
                                     
                                    }else{
                                        print("Already Reported")
                                        
                                        let destVC = UIHostingController(rootView: ReportAdsView())
                                        destVC.modalPresentationStyle = .overFullScreen // Full-screen modal
                                        destVC.modalTransitionStyle = .crossDissolve   // Fade-in effect
                                        destVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                                        self.navController?.present(destVC, animated: true, completion: nil)
                                        
                                    }
                                }
                        }.padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.top, 5)
                        
                    }
                    
                }.padding(.horizontal)
                Spacer()
                
                HStack{
                    Text("Related Ads").foregroundColor(.black).font(Font.manrope(.semiBold, size: 16))
                    Spacer()
                }.padding()
        
                
              ScrollView(.horizontal, showsIndicators: false) {
                    
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: 150))], spacing: 10){
                        
                        ForEach(objVM.relatedDataItemArray){ item in
                            ProductCard(objItem: item)
                           
                                .onTapGesture {
                                    let hostingController = UIHostingController(rootView: ItemDetailView(navController: self.navController, itemId:item.id ?? 0,itemObj: item))
                                    self.navController?.pushViewController(hostingController, animated: true)
                                }
                        }
                    }
                    .padding([.leading,.trailing,.bottom])
                }
            }
            
        }
        
        .navigationBarHidden(true).onAppear{
            
            
            if objVM.itemObj == nil{
                objVM.getItemDetail(id: self.itemId)

            }else{
                if objVM.sellerObj == nil {
                    self.objVM.getSeller(sellerId:objVM.itemObj?.userID ?? 0)
                    self.objVM.getProductListApi(categoryId: objVM.itemObj?.categoryID ?? 0)
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
                
                let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                var userId = 0
                if (objLoggedInUser.id ?? 0) == buyer_id{
                    userId = seller_id
                }else if (objLoggedInUser.id ?? 0) == seller_id{
                    userId = buyer_id
                }
                
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = id
                destVC.userId = userId
                AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
                
            }
        }
        
        
        .sheet(isPresented: $showSheet ) {
            if #available(iOS 16.0, *) {
                SafetyTipsView(onContinueOfferTap: {
                    print("offer tap")
                    
                    self.showOfferPopup = true
                    
                    
                }).transition(.move(edge: .bottom))
                    .presentationDetents([.medium, .medium]) // Customizable sizes
                    .presentationDragIndicator(.visible)
                
                
            } else {
                // Fallback on earlier versions
                
                if showSheet {
                    SafetyTipsView(onContinueOfferTap: {
                        
                        self.showOfferPopup = true
                        
                        
                        print("offer tap")
                    }).transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            } // Shows the drag indicator
        }
        
        Spacer()
        
        
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        let loggedInUserId = objLoggedInUser.id ?? 0
        let itemUserId = objVM.itemObj?.userID ?? 0
        
        if loggedInUserId == itemUserId {
            
                if ((objVM.itemObj?.status ?? "") == "sold out")  ||  ((objVM.itemObj?.status ?? "") == "rejected") ||  ((objVM.itemObj?.status ?? "") == "review"){
                    
                    Button(action: {
                        showConfirmDialog = true
                          
                    }) {
                        Text("Remove")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
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
               
                }else{
                    
                    HStack {
                        Button(action: {
                            if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "CreateAddDetailVC") as? CreateAddDetailVC {
                                vc.itemObj = objVM.itemObj
                                vc.popType = .editPost
                                self.navController?.pushViewController(vc, animated: true)
                            }
                        }) {
                            Text("Edit")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            
                            
                            if (objVM.itemObj?.status ?? "") == "approved"  || (objVM.itemObj?.status ?? "") == "sold out" {
                                
                                var markAsSold = MarkAsSoldView(navController: self.navController)
                                markAsSold.productTitle = objVM.itemObj?.name ?? ""
                                markAsSold.price = objVM.itemObj?.price ?? 0
                                markAsSold.productImg = objVM.itemObj?.image ?? ""
                                markAsSold.itemId = objVM.itemObj?.id ?? 0
                                let hostingController = UIHostingController(rootView: markAsSold)
                                self.navController?.pushViewController(hostingController, animated: true)
                                
                            }else{
                                
                            }
                            
                        }) {
                            
                            Text(getButtonTitle())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
        }else{
        Button(action: {
            print("Make an Offer")
            
            if (objVM.itemObj?.isAlreadyOffered ?? false) == true{
                
                let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
                
                let offerId =
                objVM.itemObj?.itemOffers?.first?.id ?? 0
                let sellerId =
                objVM.itemObj?.itemOffers?.first?.sellerID ?? 0
                let buyerId =
                objVM.itemObj?.itemOffers?.first?.buyerID ?? 0
                var userId = 0
                if sellerId == objLoggedInUser.id{
                    userId = buyerId
                }else{
                    userId = sellerId
                }
                
                let destVC = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                destVC.item_offer_id = offerId
                destVC.userId = userId
                AppDelegate.sharedInstance.navigationController?.pushViewController(destVC, animated: true)
                
            }else{
                showSheet = true
                
            }
            
        }) {
            
            let str = (objVM.itemObj?.isAlreadyOffered ?? false) == true ? "Chat" : "Make an Offer"
            Text(str)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding([.leading,.trailing])
  
        
        .fullScreenCover(isPresented: $showOfferPopup) {
            if #available(iOS 16.4, *) {
                MakeAnOfferView(
                    isPresented: $showOfferPopup,
                    sellerPrice: "\(objVM.itemObj?.price ?? 0)",
                    onOfferSubmit: { offer in
                        // submittedOffer = offer
                        print("User submitted offer: ₹\(offer)")
                        callOfferSocket(amount: offer)
                        
                    }
                ).presentationDetents([.large, .large]) // Optional for different heights
                    .background(.clear) // Remove default background
                    .presentationBackground(.clear)
            } else {
                // Fallback on earlier versions
                
                MakeAnOfferView(
                    isPresented: $showOfferPopup,
                    sellerPrice: "\(objVM.itemObj?.price ?? 0)",
                    onOfferSubmit: { offer in
                        // submittedOffer = offer
                        callOfferSocket(amount: offer)

                        print("User submitted offer: ₹\(offer)")
                    }
                )
            } // Works in iOS 16+
        }
        }
    }
    
    
    
    func getButtonTitle() -> String{
       
        var strTitle = ""
       //enum('review', 'approved', 'rejected', 'sold out')
        if (objVM.itemObj?.status ?? "") == "approved" {
            strTitle = "Sold Out"
            
        }else if (objVM.itemObj?.status ?? "") == "sold out" {
            
            strTitle = "Remove"
            
        }else if (objVM.itemObj?.status ?? "") == "review"{
            
            strTitle = "Remove"
        }else if (objVM.itemObj?.status ?? "") == "rejected"{
            
            strTitle = "Remove"
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
        vc.imageArrayUrl = objVM.itemObj?.galleryImages ?? []
        AppDelegate.sharedInstance.navigationController?.pushViewController(vc, animated: true )
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
        default:
            return (.clear, .black, status)
        }
    }
    
}


#Preview {
    ItemDetailView(navController:nil,itemId:0, itemObj: nil,isMyProduct:false)
}


struct InfoView: View {
    let icon: String
    let text: String
    let value:String
    
    var body: some View {
        HStack {
            if icon.lowercased().contains(".svg"){
            SVGImageView(url: URL(string: icon)).frame(width:30, height: 30)
            }else{
               
                AsyncImage(url: URL(string: icon)) { image in
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
       
            VStack(alignment: .leading){
                Spacer()
                Text(text)
                    .font(.manrope(.regular, size: 10)).foregroundColor(.gray)
                Text(value)
                    .font(.manrope(.medium, size: 14)).foregroundColor(.black)
                Spacer()

            }
        }
        .padding(.horizontal)
    }
}

struct SellerInfoView: View {
    let name: String
    let email: String
    let image: String
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack{
                Button {
                    
                } label: {

                    AsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width:60, height: 60)
                            .cornerRadius(30)
                        
                    }placeholder: {
                        
                        Image("getkartplaceholder").resizable()
                            .scaledToFit()
                            .frame(width:60, height: 60)
                            .cornerRadius(30)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("\(name)")
                        .font(.headline)
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                
                HStack{
                    Button {
                        
                    } label: {
                        Image("message").renderingMode(.template).foregroundColor(.orange)
                    }.frame(width: 40,height: 40).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                    Button {
                        
                    } label: {
                        Image("call").renderingMode(.template).foregroundColor(.orange)
                    }.frame(width: 40,height: 40).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                    Button {
                        
                    } label: {
                        Image("arrow_right").renderingMode(.template).foregroundColor(.orange)
                  
                    }.frame(width: 20,height: 20)

                }.padding(.leading)
            }
        }
    }
}







import MapKit

struct MapView: UIViewRepresentable {
    
    let latitude: Double
    let longitude: Double
    let address: String

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = address
        mapView.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {}
}




