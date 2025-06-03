//
//  NotificationView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 24/02/25.
//

import SwiftUI



struct NotificationView: View {
    var  navigation:UINavigationController?
    @State var isDataLoading = true
    @State private var page = 1
    @State var  listArray = [NotificationModel]()


    var body: some View {
        HStack {
            
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
                    .padding()
            }
            Text("Notifications").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
        }.frame(height: 44).background(Color(UIColor.systemBackground))
        
        
        
        VStack{
            HStack{Spacer()}
            
            ScrollView {
                
                HStack{  }.frame(height: 5)
                VStack(spacing: 10) {
                    ForEach(listArray) { notification in
                        NotificationRow(notification: notification)
                            .onTapGesture{
                                
                                let hostingVC = UIHostingController(rootView: NotificationDetailView(navigation: self.navigation, notification: notification))
                                self.navigation?.pushViewController(hostingVC, animated: true)
                            }
                            .onAppear{
                                
                                if let lastItem = listArray.last, lastItem.id == notification.id, !isDataLoading {
                                    getNoticiationlistApi()
                                }
                            }
                        
                    }
                    
                    
                    if listArray.count == 0 && !isDataLoading{
                        
                        HStack{
                            Spacer()
                            
                            VStack(spacing: 30){
                                Spacer()
                                Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                                Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding()
                                Spacer()
                            }
                            Spacer()
                        }
                    }else{
                        Spacer()
                    }
                }
                .padding(.horizontal, 10)
            }
            
        }.navigationBarHidden(true).background(Color(.systemGray6))
            .onAppear{
                if listArray.count == 0 {
                    getNoticiationlistApi()
                }
            }
        
    }
    
    func getNoticiationlistApi(){
        let strURl = Constant.shared.get_notification_list + "?page=\(page)"
        self.isDataLoading = true

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strURl) { (obj:NotificationParse) in
            
       
            if obj.code == 200{
                
                if self.page == 1{
                    self.listArray.removeAll()
                }
                
                if obj.data != nil {
                    self.listArray.append(contentsOf: obj.data?.data ?? [])
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.page += 1
                    self.isDataLoading = false
                })
            }else{
                self.isDataLoading = false

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
                    .font(.manrope(.medium, size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.label))

                Text(notification.message ?? "")
                    .font(.manrope(.regular, size: 15))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground)).cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        
    }
}

