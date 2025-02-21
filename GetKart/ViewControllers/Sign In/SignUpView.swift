//
//  SignUpView.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 17/02/25.
//

import SwiftUI

struct SignUpView: View {
    var navigationController: UINavigationController?


    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
   // @Binding var navigateToSignUp: Bool

    var body: some View {
        
        VStack{
            
             
            ScrollView{
                HStack{
                    Spacer()
//                    NavigationLink(destination: BaseView() .environmentObject(authManager).navigationBarBackButtonHidden(true)) {
//                        
//                        Text("Skip")
//                            .font(Font.manrope(.medium, size: 18.0))
//                            .frame(width: 90,height: 32)
//                            .foregroundColor(Color(hex: " #fa7860"))
//                        
//                    }.background(Color(hex: "#f6e7e9")).cornerRadius(16.0)
                    Button {
                        if let destvC:HomeBaseVC = StoryBoard.main.instantiateViewController(withIdentifier: "HomeBaseVC") as? HomeBaseVC {
                            navigationController?.pushViewController(destvC, animated: true)
                        }
                    } label: {
                        
                        Text("Skip")
                            .font(.custom("Manrope-Medium", size: 18.0))
                            .frame(width: 90,height: 32)
                            .foregroundColor(Color(hex: " #fa7860"))
                        
                    }.background(Color(hex: "#f6e7e9")).cornerRadius(16.0)
                    
                    
                }
                VStack (alignment: .leading) {
                    HStack{
                        Text("Welcome").multilineTextAlignment(.leading) .font(.custom("Manrope-ExtraBold", size: 28.0)).padding(.trailing,10)
                        Spacer()
                    }.padding(0)
                    HStack{
                        
                        Text("Sign up").multilineTextAlignment(.leading).font(.custom("Manrope-Regular", size: 18.0)).padding(.trailing,10)
                        Spacer()
                    }.padding(3)
                }.padding(.top,25)
                
                
                VStack (alignment: .leading,spacing: 5) {
                    TextField("Email Address", text: $email).font(.custom("Manrope-Regular", size: 16.0))
                      .frame(height: 55)
                        .padding([.leading, .trailing])
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke((email.isEmpty && showError)  ? Color(hex: "#a60404") : Color.gray, lineWidth: 1))
                    
                    if (email.isEmpty || !Validator.validateEmail(email)) && showError {
                        Text("Please enter valid email").font(.custom("Manrope-Regular", size: 14.0)).multilineTextAlignment(.leading)
                            .foregroundColor(Color(hex: "#a60404"))
                            .font(.caption)
                            .padding(.leading, 5)
                    }
                }.padding(.top,25)
                
                VStack (alignment: .leading,spacing: 5) {
                    TextField("User Name", text: $username).font(.custom("Manrope-Regular", size: 16.0))
                    .frame(height: 55)
                        .padding([.leading, .trailing])
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke((username.isEmpty && showError) ? Color(hex: "#a60404") : Color.gray, lineWidth: 1))
                    
                    
                    if username.isEmpty && showError {
                        Text("Field must not be empty").font(.custom("Manrope-Regular", size: 14.0)).multilineTextAlignment(.leading)
                            .foregroundColor(Color(hex: "#a60404"))
                            .font(.caption)
                            .padding(.leading, 5)
                    }
                }.padding(.top,15)
                
                VStack (alignment: .leading,spacing: 5) {
                    
                    HStack{
                        SecureField("Password", text: $password).font(.custom("Manrope-Regular", size: 16.0))
                          .frame(height: 55)
                            .padding([.leading, .trailing])
                        // .overlay(RoundedRectangle(cornerRadius: 8).stroke(password.isEmpty ? Color.red : Color.gray, lineWidth: 1))
                        Button {
                            
                        } label: {
                            Image(systemName: "eye.slash.fill")
                        }.padding(.trailing,10)
                        
                    }.overlay(RoundedRectangle(cornerRadius: 8).stroke((password.isEmpty && showError) ? Color(hex: "#a60404") : Color.gray, lineWidth: 1))
                   
                    if password.isEmpty && showError {
                        let msg = password.isEmpty ? "Field must not be empty" : "Password must be 6 character long."
                        Text(msg).font(.custom("Manrope-Regular", size: 14.0)).multilineTextAlignment(.leading)
                            .foregroundColor(Color(hex: "#a60404"))
                            .font(.caption)
                            .padding(.leading, 5)
                    }
                }.padding(.top,15)
                
                
                Button(action: {
                    
                    if email.isEmpty || !Validator.validateEmail(email){
                        showError = true
                    }else if  username.isEmpty {
                        showError = true
                        
                    }else if password.isEmpty || password.count < 6{
                        showError = true
                        
                    }else{
                        showError = false
                    }
                    
                }) {
                    Text("Verify Email Address").font(.custom("Manrope-Regular", size: 16.0))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity).frame(minHeight:50, maxHeight: 50)
                        .background(Color(hex: "#ffad33"))
                        .cornerRadius(8)
                }.padding([.top,.bottom],25)
                
                   // .disabled(email.isEmpty || username.isEmpty || password.isEmpty)
                
                HStack {
                    Text("Already have an account?").font(.custom("Manrope-Regular", size: 16.0))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                       
                        navigationController?.popViewController(animated: true)

                    }) {
                        Text("Log in").foregroundColor(Color(hex: " #fa7860")).underline().font(.custom("Manrope-Regular", size: 16.0))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 8)
                
                Text("Or sign in with").font(.custom("Manrope-Regular", size: 14.0))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                
                    Button(action:{
                        
                    }) {
                        HStack{
                            Spacer()
                            Image("login_Google").resizable().frame(width: 30,height: 30)
                               
                            Text("Continue with Google")
                                .font(.custom("Manrope-Regular", size: 16.0))
                                .foregroundColor(.black)
                                .frame(height: 50)
                            
                       Spacer()
                            
                        }
                            .frame(maxWidth: .infinity).frame(minHeight:50, maxHeight: 50) .padding([.leading, .trailing]).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1))
                        
                    }.padding(.top,25)
                    

                
                Text("By Signing Up /Logging in, You agree to our").font(.custom("Manrope-Regular", size: 14.0))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 15)
                
                HStack{
                    
                     NavigationLink(destination: PrivacyView(title: "Terms of Service", type: .termsAndConditions).navigationBarBackButtonHidden(true)) {

                            Text("Terms of Service").underline().foregroundColor(Color(hex: " #fa7860")).font(.custom("Manrope-Medium", size: 14.0))
                        
                    }
                    Text("and").font(.custom("Manrope-Regular", size: 14.0)).foregroundColor(.gray)
                    
                    
                    
                    NavigationLink(destination: PrivacyView(title: "Privacy Policy", type: .privacy).navigationBarBackButtonHidden(true)) {

                        Text("Privacy Policy").underline().foregroundColor(Color(hex: " #fa7860")).font(.custom("Manrope-Regular", size: 14.0))
                    }
                    
                }.padding(.top,1)
            }
            .padding()
            Spacer()
        }
        
    }
        }
    

    

#Preview {
//    SignUpView(navigateToSignUp: .constant(false))
    SignUpView()

}






class Validator{
    
    class func validateEmail(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        //let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    
    class  func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        // Define the regex pattern for a valid phone number (10 digits)
        let phoneRegex = "^[0-9]{10}$"
        
        // Use NSPredicate to match the phone number with the regex pattern
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        // Check if the phone number matches the pattern
        let isValidFormat = phoneTest.evaluate(with: phoneNumber)
        
        // Additional check to ensure that all digits are not the same (e.g., 9999999999)
        let allCharactersAreSame = Set(phoneNumber).count == 1
        
        // Return true if the phone number is valid and not a repeated digit
        return isValidFormat && !allCharactersAreSame
    }

}


extension Color {
    
   init(hex: String) {
       let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
       var int: UInt64 = 0
       Scanner(string: hex).scanHexInt64(&int)
       let a, r, g, b: UInt64
       switch hex.count {
       case 3: // RGB (12-bit)
           (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
       case 6: // RGB (24-bit)
           (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
       case 8: // ARGB (32-bit)
           (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
       default:
           (a, r, g, b) = (1, 1, 1, 0)
       }

       self.init(
           .sRGB,
           red: Double(r) / 255,
           green: Double(g) / 255,
           blue:  Double(b) / 255,
           opacity: Double(a) / 255
       )
   }
}
