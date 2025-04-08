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
            
            HStack{Spacer()}
            
            ScrollView {
                
                HStack{  }.frame(height: 5)
                VStack(spacing: 10) {
                    ForEach(objVM.listArray) { item in
                        
                        FavoritesCell(itemObj: item).onTapGesture {
                            let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId:item.id ?? 0))
                            AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                        }
                        
                    }
                }
                .padding(.horizontal, 10)
            }
            
            
            
        }.background(Color(.systemGray6)).onAppear{
            
            objVM.getFavoriteHistory()
        }
        
        // Load More Indicator
        if objVM.isDataLoading {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else {
            // Trigger loading more when reaching the last row
            Color.clear
                .onAppear {
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
                        .frame(width: 90)
                        .aspectRatio(contentMode: .fit)
                    
                }placeholder: {
                    
                   // ProgressView().progressViewStyle(.circular)
                    
                    Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fit).frame(width: 90)
                    
                }
            }
            
           // Image("getkartplaceholder").resizable().frame(width:90).aspectRatio(contentMode: .fit)
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
                    }
                    
                    
                }
                Text(itemObj.name ?? "").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(.black).padding(.bottom,10)
                
                HStack{
                    Image("location_icon").resizable().frame(width: 15, height: 15).foregroundColor(.gray)
                    Text(itemObj.address ?? "").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 12)).foregroundColor(.gray)
                    Spacer()
                }
                
            }
            
        }.frame(height: 110)
            .padding()
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
