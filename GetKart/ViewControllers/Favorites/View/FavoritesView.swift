//
//  FavoritesView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI
import Kingfisher

struct FavoritesView: View {
    
    var navigation:UINavigationController?
    @StateObject var objVM = FavoriteViewModel()
    
    var body: some View {
        
        HeaderView(navigation:navigation).frame(height: 44)
        
        VStack{
            
            if objVM.listArray.count == 0 {
            
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
            objVM.listArray.remove(at: index)
        }
    }

}


#Preview {
    FavoritesView()
}


struct FavoritesCell:View {
    
    @Binding var itemObj:ItemModel
    var body: some View {
        
        HStack{
                
                ZStack{
                   // if  let img = itemObj.image {
                    KFImage(URL(string: itemObj.image ?? ""))
                        .placeholder {
                            Image("getkartplaceholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 110,height:widthScreen / 2.0 - 15)
                                .padding(.vertical,0)
                                .frame(maxHeight: .infinity)
                               // .background(Color.gray.opacity(0.3))
                               // .cornerRadius(10, corners: [.topRight, .bottomRight])
                                
                        }
                        .setProcessor(
                            DownsamplingImageProcessor(size: CGSize(width: widthScreen / 2.0 - 15,
                                                                    height: widthScreen / 2.0 - 15))
                        )
                        .resizable()
                        .frame(width: 110)
                        .padding(.vertical,0)
                        .aspectRatio(contentMode: .fit)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10, corners: [.topRight, .bottomRight])
                        .frame(maxHeight: .infinity)
                    
                    if (itemObj.isFeature ?? false) == true {
                        VStack(alignment:.leading){
                            HStack{
                                Text("Featured")
                                    .frame(width:75,height:20)
                                    .background(.orange)
                                    .cornerRadius(5)
                                    .foregroundColor(Color(UIColor.label))
                                    .font(.manrope(.regular, size: 13))

                            }.padding(.top,5)
                            Spacer()
                        }
                    }

               // }
                
             

            }
            
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text("\(Local.shared.currencySymbol) \((itemObj.price ?? 0.0).formatNumber())").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(Color(hex: "#FF9900"))
                    Spacer()
                    Button {
                        addToFavourite()
                    } label: {
                        let isLike = (itemObj.isLiked ?? false)

                        Image(isLike ? "like_fill" : "like").frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(.gray)
                        .foregroundColor(isLike ? .red : .gray)
                            .padding(5)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .padding(.trailing)
                    }
                    
                    
                }
                Text(itemObj.name ?? "").lineLimit(1).multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(Color(UIColor.label))
                    .padding(.bottom,10).padding(.trailing)
                
                HStack{
                    Image("location-outline").resizable().frame(width: 10, height: 10).foregroundColor(.gray)
                    Text(itemObj.address ?? "").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 12)).foregroundColor(.gray).padding(.trailing)
                    Spacer()
                }
                
            }.padding([.top,.bottom],10)
            
        }.frame(height: 115)
           // .padding()
            .background(Color(UIColor.systemBackground)).cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        
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

struct HeaderView: View {
   var navigation:UINavigationController?
    var body: some View {
        HStack{
            
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
                    .padding()
            }
            Text("Favorites").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}
