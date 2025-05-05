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
    
    var body: some View {
        
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
                            .padding(.bottom, 10)
                    }
                    .setProcessor(
                        DownsamplingImageProcessor(size: CGSize(width: widthScreen / 2.0 - 15,
                                                                height: widthScreen / 2.0 - 15))
                    )
                    .fade(duration: 0.25)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: widthScreen / 2.0 - 15, height: widthScreen / 2.0 - 15)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding(.bottom, 10)

                
              /*  AsyncImage(url: URL(string: objItem.image ?? "")) { image in
                    image
                        .resizable()
                        .frame(width: widthScreen/2.0 - 15 , height: widthScreen/2.0 - 15)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10).padding(.bottom,10)
                    
                }placeholder: {
                    
                    Image("getkartplaceholder")
                        .resizable().aspectRatio(contentMode: .fill)
                        .frame(width: widthScreen/2.0 - 15 , height: widthScreen/2.0 - 15)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10).padding(.bottom,10)
                }
                */
                
                Button( action: {
                    
            
                        
                }) {
                    VStack{
                        Spacer()
                        
                        let islike = ((objItem.isLiked ?? false) == true)
                        Image( islike ? "like_fill" : "like")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3).simultaneousGesture(TapGesture().onEnded {
                                if AppDelegate.sharedInstance.isUserLoggedInRequest(){
                                    var obj = objItem
                                    obj.isLiked = !(obj.isLiked ?? false)
                                    objItem = obj
                                    addToFavourite(itemId: objItem.id ?? 0)
                                }
                           
                            })
                    }
                }
                .padding([.trailing], 15)
                .simultaneousGesture(TapGesture().onEnded {
               
                })
            }
           
            VStack(alignment: .leading){
                Text("\(Local.shared.currencySymbol) \(objItem.price ?? 0)").multilineTextAlignment(.leading).lineLimit(1)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#FF9900"))
                Text(objItem.name ?? "").multilineTextAlignment(.leading).lineLimit(1)
                    .font(.subheadline)
                Text(objItem.address ?? "").multilineTextAlignment(.leading).lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }.padding([.trailing,.leading,.bottom],10).frame(maxWidth: widthScreen/2.0 - 20)
            
        
    }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    func addToFavourite(itemId:Int){
        
        let params = ["item_id":"\(itemId)"]
        URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_favourite, param: params) { responseObject, error in
            
            if error == nil {
                
            }
        }
    }

}
