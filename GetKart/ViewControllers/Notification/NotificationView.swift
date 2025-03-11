//
//  NotificationView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import SwiftUI



struct NotificationView: View {
    var  navigation:UINavigationController?
  
    @State private var page = 1
    @State var  listArray = [NotificationModel]()


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
                    ForEach(listArray) { notification in
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
            .onAppear{
                if listArray.count == 0{
                    getNoticiationlistApi()
                }
            }
        
    }
    
    func getNoticiationlistApi(){
        let strURl = Constant.shared.get_notification_list + "?page=\(page)"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strURl) { (obj:NotificationParse) in
            
       
            if obj.data != nil {
                self.listArray.append(contentsOf: obj.data?.data ?? [])
            }
        }
    }
}

#Preview {
    NotificationView()
}

struct NotificationRow: View {
    let notification: NotificationModel

    var body: some View {
        HStack(spacing: 10) {
            
            AsyncImage(url: URL(string: notification.image ?? "")) { image in
                image.resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
            }placeholder: {
                Image("getkartplaceholder").resizable().aspectRatio(contentMode: .fill).frame(width: 60, height: 60)
               // ProgressView().progressViewStyle(.circular)
            }
          
            VStack(alignment: .leading, spacing: 5) {
                Text(notification.title ?? "")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text(notification.message ?? "")
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

