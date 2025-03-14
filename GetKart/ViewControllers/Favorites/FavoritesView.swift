//
//  FavoritesView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI

struct FavoritesView: View {
   
    var  navigation:UINavigationController?
    @State var page = 1
   @State var listArray = [ItemModel]()

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
            
            
            ScrollView {
                
                HStack{  }.frame(height: 5)
                VStack(spacing: 10) {
                    ForEach(listArray) { item in
                        
                        FavoritesCell(itemObj: item).onTapGesture {
                            let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemObj:item ))
                            AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                        }
                        
                    }
                }
                .padding(.horizontal, 10)
            }

                
            
        }.background(Color(.systemGray6)).onAppear{
            
            getFavoriteHistory()
        }
        
    }
    
    func getFavoriteHistory(){
        let strUrl = Constant.shared.get_favourite_item + "?page=\(page)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) { (obj:FavoriteParse) in
            if obj.code == 200 {
                self.listArray = obj.data?.data ?? []
            }
        }
    }
}

#Preview {
    FavoritesView()
}


struct FavoritesCell:View {
    
    let itemObj:ItemModel
    var body: some View {
        
        HStack{
            
            if  let img = itemObj.image {
                AsyncImage(url: URL(string: img)) { image in
                    image
                        .resizable()
                        .frame(width: 90)
                        .aspectRatio(contentMode: .fit)
                    
                }placeholder: { ProgressView().progressViewStyle(.circular) }
            }
            
           // Image("getkartplaceholder").resizable().frame(width:90).aspectRatio(contentMode: .fit)
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text("₹ \(itemObj.price ?? 0)").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(.orange)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image("like").frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(.gray)
                        //.foregroundColor(likedItems.contains(id) ? .red : .gray)
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
}
