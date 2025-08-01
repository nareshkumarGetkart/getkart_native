//
//  BannerAlalyticsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 31/07/25.
//

import SwiftUI

struct BannerAlalyticsView: View {
    
    var navigationController:UINavigationController?
    
    var body: some View {
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Banner analytics").font(.manrope(.bold, size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
          

         }.frame(height:44).background(Color(UIColor.systemBackground))
        
        ScrollView{
            VStack(alignment: .leading,spacing: 10){
                Text("Banner image").font(.manrope(.bold, size: 20.0))
                Image("getkartplaceholder")
                    .frame(maxWidth:.infinity,maxHeight: 130)
                Text("17 September 2025 at 10:34 AM")
               
                Divider()
                            
                Text("Overview")
             
                VStack(spacing:15){
                    
                    BannerAnalyticCell(title: "Status", value: "", isActive: true)
                    Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .overlay(
                                    Rectangle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundColor(.gray))
                    BannerAnalyticCell(title: "No. of clicks", value: "65", isActive: false)
                    BannerAnalyticCell(title: "Impressions", value: "150", isActive: false)
                    BannerAnalyticCell(title: "Click-through rate (CTR)", value: "48%", isActive: false)
                    BannerAnalyticCell(title: "Conversions", value: "56", isActive: false)
                    BannerAnalyticCell(title: "Time on Screen", value: "18hr", isActive: false)
                    BannerAnalyticCell(title: "Radius", value: "15km", isActive: false)
                    BannerAnalyticCell(title: "Time to Click", value: "5sec.", isActive: false)
                    BannerAnalyticCell(title: "Location", value: "New Delhi,Netaji Subhash Palace", isActive: false)

                    
                }.padding()
                    .background(Color(.systemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8.0).strokeBorder(Color(.gray),lineWidth: 0.5)
                    }
                
            }
        }.padding()
        
        .background(Color(.systemGray6))
    }
}

#Preview {
    BannerAlalyticsView()
}

struct BannerAnalyticCell:View {
  
    let title:String
    let value:String
    let isActive:Bool
    
    var body: some View {
        HStack{
            Text(title)
            Spacer(minLength: 60)
            if isActive{
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Active")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }.frame(width:90, height:26)
                    .background(Color(.green).opacity(0.4).cornerRadius(13.0))
                    .overlay {
                    RoundedRectangle(cornerRadius: 13).stroke(Color(.green).opacity(0.4),lineWidth: 0.1)
                    }.clipped()

            }
            Text(value)
        }
    }
}
