//
//  FavoriteAdsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/12/25.
//

import SwiftUI
import Kingfisher

struct FavoriteAdsView: View {
    
    var navigation:UINavigationController?
    @StateObject var objVM = FavoriteViewModel()
    
    var body: some View {
        
      //  HeaderView(navigation:navigation).frame(height: 44)
        
        VStack{
            
            if objVM.listArray.count == 0 && !objVM.isDataLoading{
            
                NoDataView()
                
            }else{
                
                ScrollView {
                    
                    HStack{ Spacer() }.frame(height: 10)
                    
                    LazyVStack(spacing: 10) {
                        ForEach($objVM.listArray) { $item in

                            FavoritesCell(itemObj: $item)
                                .onTapGesture {
                                    
                                   var destView = ItemDetailView(navController:  self.navigation, itemId:item.id ?? 0,itemObj: item,slug: item.slug)
                                    destView.returnValue = { value in
                                        if let obj = value {
                                            
                                            updateItemInList(obj)
                                        }
                                    }
                                    
                                    let hostingController = UIHostingController(rootView:destView )
                                    self.navigation?.pushViewController(hostingController, animated: true)
                                }
                                .onAppear{
                                    
                                    if let lastItem = objVM.listArray.last, lastItem.id == item.id, !objVM.isDataLoading {
                                        objVM.getFavoriteHistory()
                                    }
                                }
                        }
                    }
                }.refreshable {
                    if objVM.isDataLoading == false {
                        self.objVM.page = 1
                        objVM.getFavoriteHistory()
                    }
                }
                .scrollIndicators(.hidden, axes: .vertical)
                .padding(.horizontal, 10)
            }
                        
        }.navigationBarHidden(true).background(Color(.systemGray6))
            .onAppear{
                
                if objVM.listArray.count == 0 {
                    objVM.getFavoriteHistory()
                }
            }
    }
    
    private func updateItemInList(_ value: ItemModel) {
        if let index = objVM.listArray.firstIndex(where: { $0.id == value.id }) {
          
            if value.isLiked == false{
                objVM.listArray.remove(at: index)

            }else{
                
            }
        }
    }

}

#Preview {
    FavoriteAdsView()
}




struct FavoritesCell:View {
    
    @Binding var itemObj:ItemModel
    var body: some View {
        
        HStack{
                
            ZStack{
             
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                 .frame(width: 120,height: 115)
                    .cornerRadius(10, corners: [.topRight, .bottomRight])
                
                
                KFImage(URL(string:  itemObj.image ?? ""))
                    .placeholder {
                        Image("getkartplaceholder")
                        .frame(width: 120,height: 115).aspectRatio(contentMode: .fit).cornerRadius(5)
                    }
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: widthScreen / 2.0 - 15,
                                                                height: widthScreen / 2.0 - 15))
                    )
                    //.resizable().frame(width: 120,height: 115).cornerRadius(5)
                
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120,height: 115).cornerRadius(5)
                    .padding(1)
                
                if (itemObj.isFeature ?? false) == true{
                    VStack(alignment:.leading){
                        HStack{
                            Text("Featured")
                                .frame(width:75,height:20)
                                .background(.orange)
                                .cornerRadius(5)
                                .foregroundColor(Color(UIColor.white))
                                .font(.manrope(.regular, size: 13))
                        }.padding(.top,5)
                        Spacer()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text("\(Local.shared.currencySymbol) \((itemObj.price ?? 0.0).formatNumber())").multilineTextAlignment(.leading).font(Font.manrope(.bold, size: 15)).foregroundColor(Color(CustomColor.sharedInstance.priceColor))
                        
                        //.foregroundColor(Color(hex: "#FF9900"))
                    Spacer()
                    Button {
                        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                            addToFavourite()
                        }
                    } label: {
                        let isLike = (itemObj.isLiked ?? false)

                        Image(isLike ? "like_fill" : "like").renderingMode(.template).frame(width: 20, height: 20, alignment: .center)
                            //.foregroundColor(.gray)
                            .foregroundColor(isLike ? Color(.systemOrange) : .gray)
                            .padding(5)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 1)
                            .padding(.trailing)
                    }
                }
                
                Text(itemObj.name ?? "").lineLimit(1).multilineTextAlignment(.leading).font(Font.manrope(.semiBold, size: 15)).foregroundColor(Color(UIColor.label))
                    .padding(.bottom,10).padding(.trailing)
                
                HStack(spacing:5){
                    Image("location-outline").resizable().renderingMode(.template).frame(width: 13, height: 13).foregroundColor(.gray)
                    Text(itemObj.address ?? "").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 12)).foregroundColor(.gray).padding(.trailing)
                    Spacer()
                    
                    if (itemObj.user?.isVerified ?? 0) == 1{
                        Button {
                            AppDelegate.sharedInstance.presentVerifiedInfoView()
                        } label: {
                            Image( "verifiedIcon").resizable().aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                                .padding(3)
                                .background(Color(UIColor.systemBackground))
                                .clipShape(Circle())
                                .shadow(radius: 1)
                            
                        }
                        .frame(width: 30,height: 30)
                        .padding([.trailing], 15)
                        .allowsHitTesting(true)
                        
                    }

                }
                
            }.padding([.top,.bottom],10)
            
        }.frame(height: 115)
           
            .background(Color(UIColor.systemBackground)).cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 2)
        
    }
    
    
    func addToFavourite(){
        
        let params = ["item_id":"\(itemObj.id ?? 0)"]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
            
            if error == nil {
                self.itemObj.isLiked?.toggle()
            }
        }
    }
  
   

}



extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct NoDataView: View {
    var body: some View {
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
    }
}

