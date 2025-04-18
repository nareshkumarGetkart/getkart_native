//
//  AddPostSuccessView.swift
//  GetKart
//
//  Created by gurmukh singh on 4/18/25.
//

import SwiftUI





struct AddPostSuccessView: View {
    var navigationController: UINavigationController?
    @State private var animateCheck = false
    @State private var navigateToPreview = false
    @State private var navigateToHome = false
    var itemObj:ItemModel?
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated Checkmark Badge
            Image("success")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .padding()
                //.background(Color.cyan)
                //.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                //.shadow(radius: 4)
                .scaleEffect(animateCheck ? 1 : 0.5)
                .opacity(animateCheck ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateCheck)
            
            // Congrats Text
            VStack(spacing: 8) {
                Text("Congratulations!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                VStack {
                    Text("Your Item")
                    Text("Submitted Successfully")
                }
                .font(.body)
                .multilineTextAlignment(.center)
            }
            
            // Preview Ad Button
            // NavigationLink(destination: PreviewAdView(), isActive: $navigateToPreview) {
            Button(action: {
                let hostingController = UIHostingController(rootView: ItemDetailView(navController:  self.navigationController, itemId:itemObj?.id ?? 0, itemObj: itemObj))
                self.navigationController?.pushViewController(hostingController, animated: true)
            }) {
                Text("Preview Ad")
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
            }
            // }
            .padding(.horizontal, 32)
            
            // Back to Home
            // NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
            Button(action: {
                for vc in self.navigationController?.viewControllers ?? [] {
                    if vc is HomeVC {
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }) {
                Text("Back to home")
                    .foregroundColor(.black)
                    .underline()
            }
            //}
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .onAppear {
            animateCheck = true
        }
        
    }
}





#Preview {
    AddPostSuccessView()
}
