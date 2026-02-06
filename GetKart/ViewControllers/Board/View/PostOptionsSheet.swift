//
//  PostOptionsSheet.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/12/25.
//

import SwiftUI
/*
struct PostOptionsSheet: View {
    
    var onBoardTap: () -> Void = {}
    var onAdsTap: () -> Void = {}
    var onBannerTap: () -> Void = {}
    var onClose: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onClose() }
            
            VStack(spacing: 25) {
                // Close button
                HStack {
                    //THis is hidden to maintain balance
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(.label))
                            .padding(.top, 5)
                    }.hidden()
                    
                    Spacer()
                    // Title
                    Text("Start Posting Now")
                        .font(.inter(.medium, size: 18))
                        .foregroundColor(Color(.label))
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(.label))
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal)
                
              
                
                // 3 Options
                HStack(spacing: 25) {
                    optionButton(icon: "add-circle", title: "Ads", action: onAdsTap)
                    optionButton(icon: "gridOpaque", title: "Board", action: onBoardTap)
                    optionButton(icon: "megaphone", title: "Banner", action: onBannerTap)
                }
                .padding(.vertical, 10)
                
                Spacer(minLength: 20)
            }
            .padding(.top, 15)
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(radius: 5)
            .clipped()
           // .padding(.horizontal, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(), value: UUID())
        }
    }
    
    @ViewBuilder
    func optionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Rectangle()
                    .fill(Color.orange.opacity(0.17))
                    .frame(width: 65, height: 65).cornerRadius(15)
                Image(icon)
                    .font(.system(size: 26))
                    .foregroundColor(.orange)
            }
            Text(title)
                .font(.inter(.medium, size: 15))
                .foregroundColor(Color(.label))
        }
        .onTapGesture { action() }
    }
}

#Preview {
    PostOptionsSheet()
}
*/

struct PostOptionsSheet: View {

    var onBoardTap: () -> Void = {}
    var onAdsTap: () -> Void = {}
    var onBannerTap: () -> Void = {}
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
                    subtitle: "For Sale New Products"
                )
                .onTapGesture { onBoardTap() }

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

//
//extension Color {
//
//    static let titleBlack = Color(red: 20/255, green: 20/255, blue: 20/255)
//    static let subtitleGray = Color(red: 130/255, green: 130/255, blue: 130/255)
//    static let dividerGray = Color(red: 220/255, green: 220/255, blue: 220/255)
//}
