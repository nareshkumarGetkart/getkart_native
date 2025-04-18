//
//  MarkAsSoldView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/04/25.
//

import SwiftUI

struct MarkAsSoldView: View {
    
    @State private var selectedUserId: Int? = nil
    @State private var showConfirmDialog = false
    @State var listArray = [UserModel]()
    var productTitle:String?
    var price:Int?
    var productImg:String?
    var navController:UINavigationController?
    
    
    var body: some View {
        
        VStack {
            // Header
            HStack {
                Button(action: {
                    // Back action
                    navController?.popViewController(animated: true)
                }) {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)

                }

                Text("Who bought?")
                    .font(.headline)
                    .padding(.leading, 4)

                Spacer()
            }
            .padding()
            .onAppear{
                self.getUsers()
            }

            // Product Info
            HStack {
                
                if let image = productImg {
                    AsyncImage(url: URL(string: image)) { img in
                        img.resizable()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } placeholder: {
                        
                    }

                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Image("getkartplaceholder")) // Replace with actual image
                }
                Text(productTitle ?? "")
                    .font(.body)
                Spacer()
                Text("\(Local.shared.currencySymbol) \(price ?? 0)")
                    .fontWeight(.bold)
            }
            .padding(.horizontal)

            Divider()

            // User List
            List(listArray) { user in
                HStack {
                    
                    
                    if let image = user.profile {
                        AsyncImage(url: URL(string: image)) { img in
                            img.resizable()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        } placeholder: {
                            
                        }

                    } else {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 36, height: 36)
                            .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                    }

                    Text(user.name ?? "")
                        .padding(.leading, 8)

                    Spacer()

                    Image(systemName: selectedUserId == user.id ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedUserId = user.id
                }
            }

            Spacer()

            // None of above
            Button("None of above") {
                selectedUserId = nil
            }
            .padding()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5))
            )
            .padding(.horizontal)

            // Mark As Sold Out
            Button("Mark As Sold Out") {
                showConfirmDialog = true
            }
            .disabled(selectedUserId == nil)
            .padding()
            .frame(maxWidth: .infinity)
            .background(selectedUserId == nil ? Color.gray : Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }.navigationBarHidden(true)
        .confirmationDialog("Confirm Sold Out",
                            isPresented: $showConfirmDialog,
                            titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                // Confirm logic
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("After marking this ad as sold out, you can’t undo or change its status.")
        }
    }
    
    
    func getUsers(){
        
        ApiHandler.sharedInstance.makePostGenericData(url: Constant.shared.blocked_users, param: nil,httpMethod: .get) { (obj:UserParse) in
            
            if obj.code == 200{
                self.listArray = obj.data ?? []
            }
        }
    }

}

#Preview {
    MarkAsSoldView(navController: nil)
}





