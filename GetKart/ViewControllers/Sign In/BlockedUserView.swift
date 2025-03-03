//
//  BlockedUserView.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 18/02/25.
//

import SwiftUI

struct BlockedUserView: View {
    var navigationController: UINavigationController?
    
    var body: some View {
        //let ht = UIDevice().hasNotch ? (navigationController?.getNavBarHt ?? 0.0) - 20 : (navigationController?.getNavBarHt ?? 0.0) + 20
        HStack{
            
            Button {
                
                AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text("Blocked").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background(Color.white)
        
        VStack{
            Spacer()
        }.navigationBarTitleDisplayMode(.inline).navigationBarHidden(true).edgesIgnoringSafeArea(.top)
    }
}


#Preview {
    BlockedUserView(navigationController:nil)
}
