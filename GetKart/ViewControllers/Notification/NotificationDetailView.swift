//
//  NotificationDetailView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import SwiftUI

struct NotificationDetailView: View {
    var navigation:UINavigationController?
    var notification: NotificationModel?

    var body: some View {
        HStack {
         
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding()
            }
            Text("Notifications").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            
            Spacer()
        }.frame(height: 44)
       
        VStack{
            Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fill).frame(width: UIScreen.main.bounds.width ,height: 150)
            
            VStack(alignment: .leading,spacing: 5){
                Text("\(notification?.title ?? "")").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 16)).foregroundColor(.black)
                Text("\(notification?.message ?? "")").multilineTextAlignment(.leading).font(Font.manrope(.regular, size: 13)).foregroundColor(.gray)
            }.padding()

            Spacer()
            
        }
    }
}

#Preview {
    NotificationDetailView(navigation:nil, notification:nil)
}
