//
//  PopularItemsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/02/25.
//

import SwiftUI

struct PopularItemsView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PopularItemsView()
}



struct ProductCard: View {
    let imageName: String
    let price: String
    let title: String
    let location: String
    
    var body: some View {
        
        VStack(alignment: .leading) {

            ZStack(alignment: .topTrailing) {
                          Image(systemName: imageName)
                              .resizable()
                              .frame(width: widthScreen/2.0 - 25 , height: widthScreen/2.0 - 25)
                              .background(Color.gray.opacity(0.3))
                              .cornerRadius(10).padding(.bottom,10)
                          
                          Button(action: {
                            //  toggleLike()
                          }) {
                              VStack{
                                  Spacer()
                                  // Image(systemName: likedItems.contains(id) ? "heart.fill" : "heart")
                                  Image(systemName: "heart")
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
                Text(price)
                    .font(.headline)
                    .foregroundColor(.orange)
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(location)
                    .font(.caption)
                    .foregroundColor(.gray)
            }.padding([.trailing,.leading,.bottom],10)
            
        }

      //  .padding(5)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
