//
//  FavoritesView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI

struct FavoritesView: View {
    
    var  navigation:UINavigationController?
    @StateObject var objVM = FavoriteViewModel()
    
    var body: some View {
        HStack {
            
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding()
            }
            Text("Favorites").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            
            Spacer()
        }.frame(height: 44)
        
        
        VStack{
            
            if objVM.listArray.count == 0 {
                
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
                HStack{Spacer()}
                
                ScrollView {
                    
                    HStack{  }.frame(height: 5)
                    LazyVStack(spacing: 10) {
                        ForEach(objVM.listArray) { item in
                            
                            FavoritesCell(itemObj: item)
                                .onTapGesture {
                                    
                                    let destView = ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId:item.id ?? 0,itemObj: item)
                                    let hostingController = UIHostingController(rootView:destView )
                                    AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                                }
                                .onAppear{
                                    
                                    if let obj = objVM.listArray.last {
                                        
                                        if obj.id == item.id {
                                            if !objVM.isDataLoading {
                                                objVM.getFavoriteHistory()
                                            }
                                        }
                                    }
                                }
                        }
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
}


#Preview {
    FavoritesView()
}


struct FavoritesCell:View {
    
    @State var itemObj:ItemModel
    var body: some View {
        
        HStack{
            
            if  let img = itemObj.image {
                AsyncImage(url: URL(string: img)) { image in
                    image
                        .resizable()
                        .frame(width: 110)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10, corners: [.topRight, .bottomRight])                      
                    
                }placeholder: {
                    
                    Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit).frame(width: 110)
                    
                }
            }
            
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text("\(Local.shared.currencySymbol) \(itemObj.price ?? 0)").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(Color(hex: "#FF9900"))
                    Spacer()
                    Button {
                        addToFavourite()
                    } label: {
                        let isLike = (itemObj.isLiked ?? false)

                        Image(isLike ? "like_fill" : "like").frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(.gray)
                        .foregroundColor(isLike ? .red : .gray)
                            .padding(5)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .padding(.trailing)
                    }
                    
                    
                }
                Text(itemObj.name ?? "").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(.black).padding(.bottom,10).padding(.trailing)
                
                HStack{
                    Image("location_icon").resizable().frame(width: 15, height: 15).foregroundColor(.gray)
                    Text(itemObj.address ?? "").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 12)).foregroundColor(.gray).padding(.trailing)
                    Spacer()
                }
                
            }
            
        }.frame(height: 110)
           // .padding()
            .background(Color.white).cornerRadius(15)
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
