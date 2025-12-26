//
//  AdNotPostedView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 07/05/25.
//

import SwiftUI

struct AdNotPostedView: View {
    var navigationController: UINavigationController?
    var itemObj:ItemModel?
    var message:String = ""
    var body: some View {
        
        ZStack{
          //  Image("backgroundAdPost")
            Image("backgroundAdPost")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
               // .frame(width: widthScreen,height: heightScreen)
            
            VStack(spacing: 20) {
                Spacer()
                
                HStack {
                    Button(action: {
                        // back action
                        navigationController?.popToRootViewController(animated: true)
                    }) {
                        Image("Cross").renderingMode(.template).foregroundColor(.black)
                    }
                    Spacer()
                    
                }
                .padding(.leading)
                .padding(.top,20)
                Spacer()
                
                Image("draft")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .foregroundColor(.green)
                
                let msg = (message.count > 0) ? message : "Ad not posted, saved in draft"
                Text(msg)
                    .font(.manrope(.bold, size: 20.0)).foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()

                VStack(alignment:.leading,spacing:10){
                    Text("The category or location you've selected for this ad doesn't match the package you purchased.")
                        .font(.manrope(.regular, size: 16.0)).foregroundColor(.black)
                        .padding(.horizontal)
                    
                    Text("What you can do:")
                        .font(.manrope(.regular, size: 16.0)).foregroundColor(.black)
                        .padding(.horizontal)
                    
                    HStack{
                        Text("•").font(.manrope(.bold, size: 20.0)).foregroundColor(.black)
                        Text("Use the same category and location as the package you purchased")
                            .font(.manrope(.regular, size: 16.0)).foregroundColor(.black)
                    }.padding(.horizontal)
                    
                    
                    
                    HStack{
                        Text("•").font(.manrope(.bold, size: 20.0)).foregroundColor(.black)
                        Text("Or buy a new package that matches your desired category and location").foregroundColor(.black)
                            .font(.manrope(.regular, size: 16.0))
                    }.padding(.horizontal)
     
                }
                Spacer()
                
                Button(action: {
                    // Show plans action
                    pushToPlanScreen()
                }) {
                    Text("Show Plans")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.58, green: 0.29, blue: 0.00), lineWidth: 0.5)
                        )
                        .padding(.horizontal)
                        .font(.manrope(.medium, size: 16.0))

                }.padding(.bottom)
                
                Spacer()
            }.padding([.top,.bottom])
        }.navigationBarHidden(true)
        
    }
    
    
    func pushToPlanScreen(){
        if  let destvc = StoryBoard.chat.instantiateViewController(identifier: "CategoryPackageVC") as? CategoryPackageVC{
            destvc.hidesBottomBarWhenPushed = true
            destvc.categoryId = self.itemObj?.categoryID ?? 0
            destvc.categoryName = self.itemObj?.category?.name ?? ""
            destvc.city = self.itemObj?.city ?? ""
            destvc.country =  self.itemObj?.country ?? ""
            destvc.state =  self.itemObj?.state ?? ""
            destvc.latitude = "\(self.itemObj?.latitude ?? 0.0)"
            destvc.longitude = "\(self.itemObj?.longitude ?? 0.0)"
            destvc.itemId =  self.itemObj?.id ?? 0

            navigationController?.pushViewController(destvc, animated: true)
        }
    }
}



#Preview {
    AdNotPostedView()
}



/*

 
 
 
 
 var body: some View {
     
     
     VStack(spacing: 20) {
         HStack {
             Button(action: {
                 // back action
                 navigationController?.popToRootViewController(animated: true)
             }) {
                 Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
             }
             Spacer()

         }
         .padding()
         Spacer()

         VStack(spacing: 10) {
             Image(systemName: "exclamationmark.triangle.fill")
                 .resizable()
                 .frame(width: 100, height: 100)
                 .foregroundColor(.red)
             
             Text("Ad Not posted, Free Limit Reached")
                 .font(.headline)
                 .padding(.bottom)
             
             Text("Your ad is saved as a draft. Buy a plan to post it.")
                 .font(.subheadline)
                 .frame(maxWidth: .infinity, alignment: .leading)
                 .padding(.horizontal)
             
         }
         .padding(.top)
         
        
      
         
         Spacer()
         
         Button(action: {
             // Pay action
             pushToPlanScreen()
         }) {
             Text("Show Plans")
                 .font(.headline)
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color.orange)
                 .foregroundColor(.white)
                 .cornerRadius(12)
         }
         .padding(.horizontal)
         .padding(.bottom)
     } .background(Color(UIColor.systemBackground))
         .navigationBarHidden(true)

 }
 

*/
