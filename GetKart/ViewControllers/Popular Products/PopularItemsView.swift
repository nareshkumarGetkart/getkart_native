//
//  PopularItemsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import SwiftUI
import Kingfisher


struct ProductCard: View {

    @Binding var objItem:ItemModel
    
    var onItemLikeDislike: (ItemModel) -> Void

    var body: some View {
        
        ZStack{
        VStack(alignment: .leading) {
            
            ZStack(alignment: .topTrailing) {
                
                KFImage(URL(string: objItem.image ?? ""))
                    .placeholder {
                        Image("getkartplaceholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: widthScreen / 2.0 - 15, height: widthScreen / 2.0 - 15)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .setProcessor(
//                        DownsamplingImageProcessor(size: CGSize(width: widthScreen / 2.0 - 15,
//                                                                height: widthScreen / 2.0 - 15))
                        
                        DownsamplingImageProcessor(size: CGSize(width: widthScreen,
                                                                height: widthScreen))
                    )
                    .fade(duration: 0.25)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: widthScreen / 2.0 - 15, height: widthScreen / 2.0 - 15)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                
                
                HStack{
                    
                    if (objItem.isFeature ?? false) == true{
                        Text("Featured").frame(width:75,height:20)
                            .background(.orange)
                            .cornerRadius(5)
                            .foregroundColor(Color(UIColor.white))
                            .padding(.horizontal).padding(.top)
                            .font(.manrope(.regular, size: 13))

                    }
                    
                    Spacer()
                }

            }
            
            
            VStack(alignment: .leading){
                Text("\(Local.shared.currencySymbol) \((objItem.price ?? 0.0).formatNumber())").multilineTextAlignment(.leading).lineLimit(1)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#FF9900"))
                Text(objItem.name ?? "").foregroundColor(Color(UIColor.label)).multilineTextAlignment(.leading).lineLimit(1)
                    .font(.subheadline)
                HStack{
                    Image("location-outline")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                    Text(objItem.address ?? "").foregroundColor(Color(UIColor.label)).multilineTextAlignment(.leading).lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }.padding([.trailing,.leading,.bottom],10).frame(maxWidth: widthScreen/2.0 - 20)
            
            
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .contentShape(Rectangle())
           // VStack{
              //  Spacer()
                
                HStack{
                    Spacer()
                    Button {
                        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                            var obj = objItem
                            obj.isLiked = !(obj.isLiked ?? false)
                            objItem = obj
                            addToFavourite(itemId: objItem.id ?? 0)
                            onItemLikeDislike(objItem)
                        }
                    } label: {
                        let islike = ((objItem.isLiked ?? false) == true)
                        Image( islike ? "like_fill" : "like")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                        
                    }
                        .frame(width: 55,height: 50)
                        .padding([.trailing], 15)
                        .allowsHitTesting(true)
                    
                }.padding(.top,widthScreen / 2.0 - 108)
              
               // Spacer()

           // }
    }
    }
    
    func addToFavourite(itemId:Int){
        
        let params = ["item_id":"\(itemId)"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
            
            if error == nil {
                
            }
        }
    }

}
