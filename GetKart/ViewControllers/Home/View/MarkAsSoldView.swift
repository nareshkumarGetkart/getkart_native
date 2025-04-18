//
//  MarkAsSoldView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/04/25.
//

import SwiftUI

struct MarkAsSoldView: View {
    
    @State private var selectedUserId: String? = nil
    @State private var showConfirmDialog = false
    @State var users = [Users]()
    let productTitle = "Motorola C 55"
    let price = "₹2000.0"
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
                self.users.append(Users(id: "", name: "Rahul", image: nil))
            }

            // Product Info
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "photo")) // Replace with actual image
                Text(productTitle)
                    .font(.body)
                Spacer()
                Text(price)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)

            Divider()

            // User List
            List(users) { user in
                HStack {
                    if let image = user.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 36, height: 36)
                            .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                    }

                    Text(user.name)
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
}

#Preview {
    MarkAsSoldView(navController: nil)
}





// MARK: - User Model
struct Users: Identifiable {
    let id: String
    let name: String
    let image: UIImage? // Optional image
}
