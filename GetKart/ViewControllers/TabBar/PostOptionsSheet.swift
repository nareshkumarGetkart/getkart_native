//
//  PostOptionsSheet.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/12/25.
//

import SwiftUI

struct PostOptionsSheet: View {

    var onBoardTap: () -> Void = {}
    var onAdsTap: () -> Void = {}
    var onBannerTap: () -> Void = {}
    var onIdeaTap: () -> Void = {}
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {

            // Drag handle
            Capsule()
                .fill(Color.clear.opacity(0.25))
                .frame(width: 38, height: 5)
                .padding(.top, 5)
                .padding(.bottom, 5)

            // Header
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(.label))
                        .frame(width: 32, height: 32)
                }.hidden()
               
                Spacer()
                
                Text("Start Posting Now")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(.label))

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(.label))
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)

//            Divider()
//                .background(Color.dividerGray)

            VStack(spacing: 8) {

                PostingOptionRow(
                    icon: "add-circle",
                    title: "Ads",
                    subtitle: "Classified Used Items"
                )
                .onTapGesture { onAdsTap() }

                PostingOptionRow(
                    icon: "gridOpaque",
                    title: "Board",
                    subtitle: "Sell Products with image and video Ads"
                )
                .onTapGesture { onBoardTap() }
                
                
                PostingOptionRow(
                    icon: "hugeicons_ai-idea",
                    title: "Ideas",
                    subtitle: "Discover & Share New Ideas"
                )
                .onTapGesture { onIdeaTap() }

                PostingOptionRow(
                    icon: "megaphone",
                    title: "Banner",
                    subtitle: "Promote Your Business and Grow"
                )
                .onTapGesture { onBannerTap() }
            }
            .padding(.horizontal, 20)
            .padding([.top,.bottom], 10)

            Spacer(minLength: 15)
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
}


struct PostingOptionRow: View {
    
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            
            //            ZStack {
            //                Circle()
            //                    .fill(Color.getkartOrange.opacity(0.15))
            //                    .frame(width: 44, height: 44)
            
            Image(icon)
            //  .foregroundColor(.getkartOrange)
                .font(.system(size: 20, weight: .semibold))
            // }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.inter(.medium, size: 22))
                    .foregroundColor(Color(.label))
                
                Text(subtitle)
                    .font(.inter(.medium, size: 12))
                    .foregroundColor(Color(.gray))
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            
            RoundedRectangle(cornerRadius: 14)
                .fill(getColor()) // ✅ #F0F0F0
        )
    }
    
    func getColor() ->Color{
        
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        
        if theme == .dark{
            return Color(.systemGray6)
        }else{
            return  Color(red: 240/255, green: 240/255, blue: 240/255)
        }
    }
}

