//
//  DemoView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/02/25.
//

import SwiftUI

struct DemoView: View {
  //  @Environment(\.presentationMode) var presentationMode

    let pages = [
        
        OnboardingScreen(imageName: "onbo_a", title: "Click Photo", description: "Take a photo of the product you want to let go of.", buttonText: "Sign in"),
        OnboardingScreen(imageName: "onbo_b", title: "Publish your ad", description: "Enter a description, price and category of your ad.", buttonText: "Sign in"),
        OnboardingScreen(imageName: "onbo_c", title: "Get money", description: "Now relax and enjoy the money you made on the product you let go of.", buttonText: "Get Started")
    ]
    
    @State private var currentPage = 0
    
    var body: some View {
        VStack {

           // VStack{
                HStack{
                    
                    Button {
                        
                        let destvC = UIHostingController(rootView: LanguageView())
                        AppDelegate.sharedInstance.navigationController?.pushViewController(destvC, animated: true)
                        
                    } label: {
                        HStack{
                            Text("En").foregroundColor(.black).font(.custom("Manrope-Medium", size: 18.0))
                        }
                        Image("arrow_dd").renderingMode(.template).foregroundColor(.orange)
                    }
                    
                    Spacer()
                    Button {
                        
                        let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        AppDelegate.sharedInstance.navigationController?.pushViewController(landingVC, animated: true)
                       
                    } label: {
                        
                        Text("Skip")
                            .font(.custom("Manrope-Medium", size: 18.0))
                            .frame(width: 90,height: 32)
                            .foregroundColor(Color(hex: " #fa7860"))
                        
                    }.background(Color(hex: "#f6e7e9")).cornerRadius(16.0)
                    
                }.padding(.horizontal).padding(.top,15).frame(height:44)
           // }
            
           // Spacer()
            
            Image(pages[currentPage].imageName)
                .resizable()
                .scaledToFit()
               .padding()// .frame(height: 300)
                
            Text(pages[currentPage].title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text(pages[currentPage].description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            
            Spacer()
            
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \ .self) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(index == currentPage ? .orange : .gray.opacity(0.5))
                }
            }
            .padding(.bottom, 10)
            
            ZStack(alignment: .bottom) {
                CurvedShape()
                    .frame(height: 140)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .overlay(
                        VStack {
                            Spacer()
                            Button(action: {
                                if currentPage < pages.count - 1 {
                                    currentPage += 1
                                } else {
                                    // Handle final action (e.g., navigate to home screen)
                                   // presentationMode.wrappedValue.dismiss()
                                    
                                    let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                    AppDelegate.sharedInstance.navigationController?.pushViewController(landingVC, animated: true)

                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 85, height: 85)
                                        .shadow(radius: 4)
                                    
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 70, height: 70)
                                        .shadow(radius: 4)
                                        .overlay(
                                            Image(systemName: "arrow.right")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        )
                                }
                            }
                            .offset(y: 30)
                            
                           
                        }
                    )
            }
            
            Button(action: {
                // Handle sign-in action
                let landingVC = StoryBoard.preLogin.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                AppDelegate.sharedInstance.navigationController?.pushViewController(landingVC, animated: true)

            }) {
                Text(pages[currentPage].buttonText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity,minHeight: 50)
                    .background(Color.orange)
                    .cornerRadius(25)
                    .padding(.horizontal, 50) .padding()

                
            }.padding(.top,50)
            Spacer()

        }.navigationBarHidden(true)
    }
}

#Preview {
    DemoView()
}




struct OnboardingScreen: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let buttonText: String
}




struct CurvedShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 80))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: 80), control: CGPoint(x: rect.width / 2, y: -60))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
     
        return path
    }
}
