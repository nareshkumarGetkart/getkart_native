//
//  UnblockUserView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/03/25.
//

import SwiftUI

struct UnblockUserView: View {
    @Binding var isPresented: Bool  // Control visibility of the popup
    @State var bloclkUser:BlockedUser?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 25) {
               
                HStack{Spacer()}.frame(height: 5)
                
                Text("Unblock \(bloclkUser?.name ?? "") to send a message")
                    .font(Font.manrope(.medium, size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                

                HStack {
                    Button(action: {
                        isPresented = false  // Dismiss popup
                    }) {
                        Text("Cancel").padding().font(Font.manrope(.regular, size: 15))

                            .frame(maxWidth: .infinity,minHeight: 40,maxHeight: 40)
                            .background(Color(.systemGray5))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }

                    Button(action: {
                        // Perform unblock action
                        isPresented = false
                    }) {
                        Text("Unblock").padding().font(Font.manrope(.regular, size: 15))
                            .frame(maxWidth: .infinity,minHeight: 40,maxHeight: 40)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }

            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
        }
        .opacity(isPresented ? 1 : 0)
    }
}

#Preview {
    UnblockUserView(isPresented: .constant(true), bloclkUser: nil)
}


struct UnblockPopupView: View {
    @Binding var isPresented: Bool  // Control visibility of the popup

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                Text("Unblock X Headmaster to send a message")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    Button(action: {
                        isPresented = false  // Dismiss popup
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity, minHeight: 26)  // Set height
                            .background(Color(.systemGray5))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // Perform unblock action
                        isPresented = false
                    }) {
                        Text("Unblock")
                            .frame(maxWidth: .infinity, minHeight: 26)  // Set height
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(height: 26) // Ensure row height is consistent
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
        }
        .opacity(isPresented ? 1 : 0)
    }
}

struct ContentView: View {
    @State private var showPopup = false

    var body: some View {
        ZStack {
            Button("Show Popup") {
                showPopup = true
            }
            if showPopup {
                UnblockPopupView(isPresented: $showPopup)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
