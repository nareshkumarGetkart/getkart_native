//
//  BannerAnalyticWithStatusGrayCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/07/26.
//

import SwiftUI

struct BannerAnalyticWithStatusGrayCell:View {
    
    let title:String
    let value:String
    
    var body: some View {
        HStack{
            Text(title)
            Spacer(minLength: 60)
            HStack(spacing: 6) {
                
                Text(value)
                    .padding([.leading,.trailing],7).font(.manrope(.semiBold, size: 14))
                    .foregroundColor(Color(.label))
            }.frame(height:26)
                .background(Color(.gray).opacity(0.4).cornerRadius(13.0))
                .overlay {
                    RoundedRectangle(cornerRadius: 13).stroke(Color(.gray).opacity(0.4),lineWidth: 0.1)
                }.clipped()
            
            
        }
    }
}

#Preview {
    BannerAnalyticWithStatusGrayCell(title: "", value: "")
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
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Active")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }.frame(width:100, height:26)
                    .background(Color(.systemGreen).opacity(0.4).cornerRadius(13.0))
                    .overlay {
                    RoundedRectangle(cornerRadius: 13).stroke(Color(.systemGreen).opacity(0.4),lineWidth: 0.1)
                    }.clipped()

            }else{
                Text(value)
            }
        }
    }
}


