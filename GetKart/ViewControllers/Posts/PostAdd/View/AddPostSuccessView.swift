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
        ZStack{
            Image("backgroundAdPost")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image("success")
                    .resizable()
                    .frame(width: 130, height: 130)
                    .foregroundColor(.green)
                    .scaleEffect(animateCheck ? 1 : 0.5)
                    .opacity(animateCheck ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateCheck)
                VStack{
                    Text("Successful")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Your ad will be live soon")
                        .font(.body)
                        .foregroundColor(.black)
                }
                
                if (itemObj?.usedPackage ?? "").count > 0{
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.3))
                        .overlay(
                            //itemObj?.usedPackage ?? ""
                            //                        Text("Getkart offers 1 free ad every 30 days for mobiles")
                            Text(itemObj?.usedPackage ?? "")
                                .font(.body)
                                .foregroundColor(Color(red: 0.58, green: 0.29, blue: 0.00)) // Dark orange-ish brown
                                .multilineTextAlignment(.center)
                                .padding()
                            
                        )
                        .frame(height: 80)
                        .padding(.horizontal)
                }
                
                Image("tag")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.orange)
                VStack{
                    Text("Reach more buyers")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.58, green: 0.29, blue: 0.00)) // Dark orange-ish brown
                    
                    Text("Upgrade your ad to reach more buyers")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.58, green: 0.29, blue: 0.00).opacity(0.8)) // Slightly lighter
                }
                
                Button(action: {
                    
//                    var isNotFound  = true
//                    for vc in self.navigationController?.viewControllers ?? [] {
//                        if let vc1 = vc as? ConfirmLocationHostingController {
//                            self.navigationController?.popToViewController(vc, animated: false)
//                            isNotFound = false
//                            break
//                        }
//                    }
//                    
                    self.navigationController?.popToRootViewController(animated: false)
                    let hostingController = UIHostingController(rootView: ItemDetailView(navController:  self.navigationController, itemId:itemObj?.id ?? 0, itemObj: itemObj, slug: itemObj?.slug))
                    hostingController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(hostingController, animated: false)
                })  {
                    Text("Preview Ad")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 1.0, green: 0.58, blue: 0.0)) // Bright orange
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.58, green: 0.29, blue: 0.00), lineWidth: 0.5)
                        )
                        .padding(.horizontal)
                }
                
                Button(action: {
                    // Action for back to home
                    
                    for vc in self.navigationController?.viewControllers ?? [] {
                        if vc is HomeVC  || vc is ChatListVC  || vc is MyAdsVC  || vc is ProfileVC{
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                    
                }) {
                    Text("Back to home")
                        .foregroundColor(Color(red: 0.58, green: 0.29, blue: 0.00)) // Same dark orange-brown
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 1.0, green: 0.91, blue: 0.80)) // Light peach background
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.58, green: 0.29, blue: 0.00), lineWidth: 0.5)
                        ).padding(.horizontal)
                }
                
                Spacer()
            }.onAppear {
                animateCheck = true
            }
        }.navigationBarHidden(true)
        
    }
}




#Preview {
    AddPostSuccessView()
}


/*
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
                 
                 Text(itemObj?.usedPackage ?? "")
                     .multilineTextAlignment(.center)
                     .font(.manrope(.regular, size: 14))
             }
             
             // Preview Ad Button
             // NavigationLink(destination: PreviewAdView(), isActive: $navigateToPreview) {
             Button(action: {
                 let hostingController = UIHostingController(rootView: ItemDetailView(navController:  self.navigationController, itemId:itemObj?.id ?? 0, itemObj: itemObj, slug: itemObj?.slug))
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
                     if vc is HomeVC  || vc is ChatListVC  || vc is MyAdsVC  || vc is ProfileVC{
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
         }.navigationBarHidden(true)
         .padding()
         .background(Color(.systemBackground))
         .onAppear {
             animateCheck = true
         }
         
     }
 }

 */
