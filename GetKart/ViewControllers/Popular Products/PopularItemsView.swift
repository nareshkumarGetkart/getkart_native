//
//  PopularItemsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import SwiftUI



struct ProductCard: View {
   /* let imageName: String
    let price: String
    let title: String
    let location: String
    var isFavourite:Bool
    let id:Int
    
    */
    @State var objItem:ItemModel
    
    var body: some View {
        
        VStack(alignment: .leading) {

            ZStack(alignment: .topTrailing) {
//                          Image(systemName: imageName)
//                              .resizable()
//                              .frame(width: widthScreen/2.0 - 15 , height: widthScreen/2.0 - 15)
//                              .background(Color.gray.opacity(0.3))
//                              .cornerRadius(10).padding(.bottom,10)
                
                
                
                AsyncImage(url: URL(string: objItem.image ?? "")) { image in
                    image
                        .resizable()
                        .frame(width: widthScreen/2.0 - 15 , height: widthScreen/2.0 - 15)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10).padding(.bottom,10)
                    
                }placeholder: {
                    
                    Image("getkartplaceholder")
                        .resizable()
                        .frame(width: widthScreen/2.0 - 15 , height: widthScreen/2.0 - 15)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10).padding(.bottom,10)
                }
                
                          
                          Button(action: {
                            //  toggleLike()
                              objItem.isLiked?.toggle()
                              addToFavourite(itemId: objItem.id ?? 0)
                              
                          }) {
                              VStack{
                                  Spacer()
                                
                                  let islike = ((objItem.isLiked ?? false) == true)
                                  Image( islike ? "like_fill" : "like")
                                      .foregroundColor(.gray)
                                  // .foregroundColor(likedItems.contains(id) ? .red : .gray)
                                      .padding(8)
                                      .background(Color.white)
                                      .clipShape(Circle())
                                      .shadow(radius: 3)
                              }
                          }
                          .padding([.trailing], 15)
                      }
            
            VStack(alignment: .leading){
                Text("\(objItem.price ?? 0)").lineLimit(1)
                    .font(.headline)
                    .foregroundColor(.orange)
                Text(objItem.name ?? "").lineLimit(1)
                    .font(.subheadline)
                Text(objItem.address ?? "").lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }.padding([.trailing,.leading,.bottom],10)
            
        }

      //  .padding(5)
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
