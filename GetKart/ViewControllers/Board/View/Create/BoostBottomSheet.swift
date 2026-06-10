//
//  BoostBottomSheet.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/05/26.
//

import SwiftUI




struct BoostBottomSheet: View {

    var onBoostTap: () -> Void = {}
    var onFreePostTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 13) {

//            // Top Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 5)
                .padding(.top, 8)

            Spacer()
            ZStack(alignment: .top) {

                // Main Card
                VStack(spacing: 0) {

                    HStack(alignment:.bottom, spacing: 5) {

                        // Rocket Image
                        Image("boost_Image")
                            .resizable()
                            .scaledToFill()
                        .frame(width: 95, height: 95)
                        VStack(alignment: .leading, spacing: 6) {

                            Text("Post with Boost")
                                .font(.inter(.bold, size: 17)).padding(.top)

                            BenefitRow(text: "Get More Leads")
                            BenefitRow(text: "Reach 5x More Users")
                            BenefitRow(text: "Faster Lead Conversion")
                        }

                        Spacer()

                        Button {
                            onBoostTap()
                        } label: {
                            Circle()
                                .fill(Color(.systemOrange))
                                .frame(width: 45, height: 45)
                                .overlay(
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 24)
                }
                .background(getColor())
                
               
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.orange.opacity(0.7), lineWidth: 1.5)
                )
                .cornerRadius(15)
                .onTapGesture {
                    onBoostTap()
                }

                HStack(spacing:1){
                    Image("mdi_thunder").padding(.leading)
                    Text("Boost Recommended")
                        .foregroundColor(.black)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.trailing,18)
                        .padding(.vertical, 9)
                }
                // Recommended Badge
               
                    .background(
                        Capsule()
                            .fill(Color(hex: "#FFF4DD"))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.orange.opacity(0.7), lineWidth: 1.5)
                    )
                    .offset(y: -19)
            }
            .padding(.top, 12)
            
            // Continue Free Button
            Button {
                onFreePostTap()
            } label: {

                HStack {
                    Spacer()

                    Text("Continue with Free Post")
                        .font(.inter(.semiBold, size: 18))
                        .foregroundColor(.orange)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)

                    Spacer()
                }
                .padding(.vertical, 18)
              //  .background(Color.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.7), lineWidth: 1.5)
                ).cornerRadius(12).clipped()
            }

        }
        .padding(.horizontal, 16)
       // .padding(.bottom, 10)
//        .background(
//            RoundedRectangle(cornerRadius: 32)
//                .fill(Color.white)
//                .ignoresSafeArea()
//        )
    }
    
    func getColor() ->Color{
        
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        
        if theme == .dark{
            return Color(.systemBackground)
        }else{
            return   Color(hex: "#FFF8EF")
        }
    }
}

#Preview {
    BoostBottomSheet()
}


struct BenefitRow: View {

    let text: String

    var body: some View {
        HStack(spacing: 8) {

            Circle()
                .fill(Color.orange)
                .frame(width: 17, height: 17)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                )

            Text(text).font(.inter(.medium, size: 13))
                .foregroundColor(.gray)
        }
    }
}


// MARK: - Preview

#Preview {
    ZStack {
        Color.black.opacity(0.2)
            .ignoresSafeArea()

        VStack {
            Spacer()

            BoostBottomSheet()
        }
    }
}




