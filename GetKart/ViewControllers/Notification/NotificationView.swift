//
//  NotificationView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import SwiftUI



struct NotificationView: View {
    var  navigation:UINavigationController?
  
    let notifications: [NotificationModel] = [
        NotificationModel(image: "getkartplaceholder", title: "New Listing in Your Neighborhood!", message: "A new item has just been listed near you. Take a look and make an offer."),
        NotificationModel(image: "getkartplaceholder", title: "🚨 Hurry! New Listings Won’t Last!", message: "Hot new products have just been added. Don’t miss out—explore now! 🔥"),
        NotificationModel(image: "getkartplaceholder", title: "New Listings in Your Favorite Category!", message: "Discover the latest items in Mobiles. Start browsing!"),
        NotificationModel(image: "getkartplaceholder", title: "📢 New to the Market!", message: "Fresh used items have just been listed. Find your next bargain today! 🛍"),
        NotificationModel(image: "getkartplaceholder", title: "🔥 New Listings Just Dropped!", message: "Check out the latest items and get them before they’re gone! 🛒"),
        NotificationModel(image: "getkartplaceholder", title: "Check Out the Latest Listings!", message: "New items have just been listed. Explore the latest deals now.")
    ]

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
            
            
            ScrollView {
                
                HStack{  }.frame(height: 5)
                VStack(spacing: 10) {
                    ForEach(notifications) { notification in
                        NotificationRow(notification: notification).onTapGesture{
                            
                            let hostingVC = UIHostingController(rootView: NotificationDetailView(navigation: self.navigation, notification: notification))
                            self.navigation?.pushViewController(hostingVC, animated: true)
                            print("horizontal list item tapped \n \(notification.title)")
                            
                            
                        }
                    }
                }
                .padding(.horizontal, 10)
            }

                
            
        }.background(Color(.systemGray6))
        
    }
}

#Preview {
    NotificationView()
}

struct NotificationRow: View {
    let notification: NotificationModel

    var body: some View {
        HStack(spacing: 10) {
            Image(notification.image)
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(notification.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white).cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        
    }
}

