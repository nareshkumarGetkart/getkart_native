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
                    Spacer()   // Title
                    Text("Start Posting Now")
                        .font(.inter(.medium, size: 18))
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal)
                
              
                
                // 3 Options
                HStack(spacing: 35) {
                    optionButton(icon: "gridOpaque", title: "Board", action: onBoardTap)
                    optionButton(icon: "add-circle", title: "Ads", action: onAdsTap)
                    optionButton(icon: "megaphone", title: "Banner", action: onBannerTap)
                }
                .padding(.vertical, 10)
                
                Spacer(minLength: 20)
            }
            .padding(.top, 15)
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
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
                .foregroundColor(.black)
        }
        .onTapGesture { action() }
    }
}

#Preview {
    PostOptionsSheet()
}
