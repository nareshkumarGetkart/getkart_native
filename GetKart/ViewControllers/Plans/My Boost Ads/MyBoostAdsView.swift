//
//  MyBoostAdsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 02/04/25.
//

import SwiftUI

struct MyBoostAdsView: View {
    var navigation:UINavigationController?
    @StateObject var obj = MyAdsViewModel()
   
    var body: some View {
        HStack {
            
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding()
            }
            Text("My Boost Ads").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            
            Spacer()
        }.frame(height: 44)
        
        ScrollView{
            LazyVStack{
                ForEach(obj.listArray) { item in
                    BoostAdsCell(itemObj:item).onTapGesture {
                        
                        let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId: item.id ?? 0,isMyProduct:true))
                        AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                    }
                }
            }
        }.background(Color(.systemGray6))
        
        Spacer()
    }
}

#Preview {
    MyBoostAdsView()
}


struct BoostAdsCell: View {
    var itemObj:ItemModel?
    
    var body: some View {
        
        HStack{
            
            ZStack{
                AsyncImage(url: URL(string: itemObj?.image ?? "")) { img in
                    img.frame(width: 120,height: 140).aspectRatio(contentMode: .fit).cornerRadius(5)
                    
                } placeholder: {
                    Image("getkartplaceholder").frame(width: 120,height: 140).cornerRadius(5)
                    
                }
                
                VStack(alignment:.leading){
                    HStack{
                        Text("Boost").frame(width:70,height:25).background(.orange).cornerRadius(5).foregroundColor(.white)
                    }.padding(.top,5)
                    Spacer()
                }
            }
            
            VStack(alignment:.leading){
                HStack{
                    Text("₹ \(itemObj?.price ?? 0)").font(.custom("Manrope-Regular", size: 16.0)).foregroundColor(.orange)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image("heart")
                    }.padding()
                }
                
                Text("Residential floor").font(.custom("Manrope-Regular", size: 14.0)).multilineTextAlignment(.leading)
                HStack{
                    Image("location_icon").renderingMode(.template)
                        .foregroundColor(Color.gray)
                    Text(itemObj?.address ?? "" ).font(.custom("Manrope-Regular", size: 12.0)).foregroundColor(Color.gray)
                }.padding(.bottom,15)
            }
        }.background(Color.white).cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(8)
    }
}
