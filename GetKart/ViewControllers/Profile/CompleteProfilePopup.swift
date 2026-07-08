//
//  CompleteProfilePopup.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 22/06/26.
//

import SwiftUI


struct CompleteProfilePopup: View {

    @State private var fullName = ""
    var onClose: (() -> Void)?
    var onSave: ((String) -> Void)?
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {

            // Background Overlay
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                /*
                // Close Button
                HStack {
                    Spacer()

                    Button {
                        onClose?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
*/
                Spacer()
                    .frame(height: 5)

                // Profile Illustration
//                ZStack(alignment: .bottomTrailing) {
//
//                    Circle()
//                        .fill(Color(red: 0.95, green: 0.94, blue: 0.91))
//                        .frame(width: 135, height: 135)

                Image("avatar-illustration").resizable().aspectRatio(contentMode: .fit).frame(width: 145, height: 145)
//                        .font(.system(size: 70))
//                        .foregroundColor(.blue.opacity(0.7))
//
//                    Circle()
//                        .fill(Color.blue)
//                        .frame(width: 30, height: 30)
//                        .overlay(
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 16, weight: .bold))
//                                .foregroundColor(.white)
//                        )
//                        .offset(x: 0, y: -2)
//                }

                Spacer()
                    .frame(height: 5)

                // Title
                Text("Complete Your Profile")
                    .font(.inter(.bold, size: 24.0))                    .foregroundColor(Color(red: 0.05, green: 0.08, blue: 0.18))
                    .multilineTextAlignment(.center)

                Spacer()
                    .frame(height: 10)

                // Description
                Text("Add your name to boost trust, visibility, and buyer inquiries.")
                    .font(.inter(.regular, size: 15.0))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer()
                    .frame(height: 35)

                // Name Label
                VStack(alignment: .leading, spacing: 10) {

                    Text("Full Name")
                        .font(.inter(.semiBold, size: 15.0))
                        .foregroundColor(Color(red: 0.05, green: 0.08, blue: 0.18))

                    HStack(spacing: 15) {

                        Image(systemName: "person")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)

                        TextField(
                            "Enter your full name",
                            text: $fullName
                        )
                        .font(.inter(.regular, size: 15.0))
                        .onChange(of: fullName) { value in
                            errorMessage = ""

//                            var filtered = value.filter {
//                                $0.isLetter || $0.isWhitespace
//                            }
//                            
                            var filtered = value

                            // Remove consecutive spaces
                            filtered = filtered.replacingOccurrences(
                                of: "\\s+",
                                with: " ",
                                options: .regularExpression
                            )

                            if filtered.count > 50 {
                                filtered = String(filtered.prefix(50))
                            }

                            if filtered != fullName {
                                fullName = filtered
                            }
                        }
                    }
                    .padding()
                    .frame(height: 55)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1.5)
                    )
                    
                    if !errorMessage.isEmpty {
                            Text(errorMessage)
                            .font(.inter(.regular, size: 12.0))
                            .foregroundColor(.red)
                        }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 20)

                // Save Button
                Button {
                    if let error = validateFullName(fullName) {
                            errorMessage = error
                            
                    }else{
                        errorMessage = ""
                        onSave?(fullName)
                    }
                    
                } label: {
                    Text("Save & Continue")
                        .font(.inter(.semiBold, size: 15.0))                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            Color(
                                red: 1.0,
                                green: 0.62,
                                blue: 0.0
                            )
                        )
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                Spacer()
                    .frame(height: 30)
            }
            //.frame(maxWidth: 400)
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 20)
        }
    }
    
    func validateFullName(_ name: String) -> String? {

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return "Please enter your full name"
        }

        if trimmed.count < 2 {
            return "Name must contain at least 2 characters"
        }

     /*  // let regex = "^[A-Za-z]+(?:\\s+[A-Za-z]+)+$"
        let regex = "^[A-Za-z]+(?:\\s+[A-Za-z]+)*$"

        if NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: trimmed) == false {
            return "Please enter a valid full name"
        }*/

        return nil
    }
}

#Preview {
    CompleteProfilePopup()
}
