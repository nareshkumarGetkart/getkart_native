//
//  FavoritesView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI

struct FavoritesView: View {
   
    var  navigation:UINavigationController?
  
   

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
                   // ForEach(notifications) { notification in
                        
                        ForEach(0..<3){ index in

                            FavoritesCell()
                       /* NotificationRow(notification: notification).onTapGesture{
                            
                            let hostingVC = UIHostingController(rootView: NotificationDetailView(navigation: self.navigation, notification: notification))
                            self.navigation?.pushViewController(hostingVC, animated: true)
                            print("horizontal list item tapped \n \(notification.title)")
                            
                            
                        }*/
                    }
                }
                .padding(.horizontal, 10)
            }

                
            
        }.background(Color(.systemGray6))
        
    }
}

#Preview {
    FavoritesView()
}


struct FavoritesCell:View {
    
    
    var body: some View {
        
        HStack{
            Image("getkartplaceholder").resizable().frame(width:90).aspectRatio(contentMode: .fit)
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    Text("₹ 6000.0").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(.orange)
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
                Text("Mi A2 mobile").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(.black).padding(.bottom,10)
                
                HStack{
                    Image("location_icon").resizable().frame(width: 15, height: 15).foregroundColor(.gray)
                    Text("Vikaspuri, New Delhi 110034").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 12)).foregroundColor(.gray)
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
