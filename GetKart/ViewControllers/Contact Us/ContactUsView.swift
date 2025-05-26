//
//  ContactUsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 28/03/25.
//

import SwiftUI
import MessageUI

struct ContactUsView: View {
    
    @State private var showEmailView = false
    var navigationController:UINavigationController?


    var body: some View {
        
        // Top Navigation Bar
        HStack {
            Button(action: {
                // Action to go back
                navigationController?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                   .padding()
                
            }
            Text("Contact us").foregroundColor(.black).font(Font.manrope(.semiBold, size: 17))
            Spacer()
        }.frame(height: 44).background(Color(UIColor.systemBackground))
        
        VStack(alignment:.leading, spacing: 20){
            Text("How can we help you?").multilineTextAlignment(.leading)
                .font(Font.manrope(.semiBold, size: 17))
                .padding(.top, 10)
            
            Text("It looks like you have problems with our systems. We are here to help you, so please get in touch with us.")
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray).font(Font.manrope(.regular, size: 13))
            
            
            VStack(spacing: 16) {
                ContactOptionView(icon: "call", title: "Call") {
                    // Implement call action here
                    makeCall(to: Local.shared.companyTelelphone1)
                }
                
                ContactOptionView(icon: "message", title: "Email") {
                    showEmailView = true
                }
            }
            .padding(.top, 5)
            
            Spacer()
        }.padding()
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showEmailView) {
                EmailSupportView()
            }
    }
    
    func makeCall(to number: String) {
            if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("📞 Cannot make a call on this device")
            }
        }
}

#Preview {
    ContactUsView(navigationController:nil)
}


struct ContactOptionView: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                
                ZStack{
                    RoundedRectangle(cornerRadius: 10)  // Square with rounded corners
                        .fill(Color.yellow.opacity(0.1))
                        .frame(width: 50, height: 50) // Background size
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image(icon).renderingMode(.template)
                        .foregroundColor(.orange)
                    
                }
              
                Text(title)
                    .font(.headline).foregroundColor(.black).padding(.leading,10)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding().frame(height: 65)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct EmailSupportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var subject: String = ""
    @State private var message: String = ""
    @State private var showMailView:Bool = false
    @State private var showMailAlert: Bool = false
    @State private var mailAlertMessage: String = ""
    
    var body: some View {
        
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black)
            }
            .padding()
                            
            Text("Send Email").font(Font.manrope(.medium, size: 15))
                .font(.headline)
            Spacer()
        }.frame(height:44).background(.white)
        
      //  VStack {
            ScrollView{
            
            VStack(alignment:.leading, spacing: 20) {
                
                HStack{Spacer()}.frame(height: 20)
                TextField("Subject", text: $subject).font(Font.manrope(.regular, size: 16))
                    .padding().tint(.orange)
                    .frame(height: 60)
                    .cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3))).padding(.horizontal,10)
                
                Text(Local.shared.companyEmail).font(Font.manrope(.regular, size: 16))
                    .foregroundColor(.black)
                    .tint(.black)
                    .padding()
                    .multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 60)
                    .cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3))).padding(.horizontal,10)
                
                // Multi-line Text Editor with Placeholder
                ZStack(alignment: .topLeading) {
                    if message.isEmpty {
                        Text("Write something here...").font(Font.manrope(.regular, size: 16))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 15).padding(.horizontal,10)
                    }
                    
                    TextEditor(text: $message).font(Font.manrope(.regular, size: 16))
                        .padding(8)
                        .frame(height: 150) // **Multi-line Input**
                        .background(.clear)
                        .cornerRadius(10).tint(.orange)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3))).padding(.horizontal,10)
                        .opacity(message.isEmpty ? 0.85 : 1) // Ensures placeholder visibility
                }
                
                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                           showMailView = true
                    } else {
                        // Show an alert to user
                        // You can use .alert modifier or a custom error state
                        mailAlertMessage = "Mail services are not available. Please set up a mail account in order to send email."
                        showMailAlert = true
                    }

                    
                }) {
                    Text("Send Email").font(Font.manrope(.medium, size: 16))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                }.padding(.horizontal,10)
                
                HStack{Spacer()}.frame(height: 20)
                
            }.background(.white)
               .cornerRadius(10).padding(8)
            
            Spacer()
        }.background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
            .alert(isPresented: $showMailAlert) {
                Alert(title: Text("Unable to Send Email"),
                      message: Text(mailAlertMessage),
                      dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showMailView) {
             
                if MFMailComposeViewController.canSendMail() {
                    MailView(subject: subject, message: message) { val in
                        if val {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    // Optional: Alert or fallback UI
                    
                    //  AlertView.sharedManager.showToast(message: "Mail services are not available. Please set up a mail account.")
                    
                }
            }
        
          
    }
}


struct MailView: UIViewControllerRepresentable {
    
    var subject: String
    var message: String
    var onMailSent: ((Bool) -> Void)? // ✅ Callback function to notify SwiftUI

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            
            if result == .sent {
                parent.onMailSent?(true) // ✅ Trigger callback when email is sent
            } else {
                parent.onMailSent?(false) // ✅ Callback with false if canceled/failed
            }
            
            controller.dismiss(animated: true)
        }
        
       
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.setSubject(subject) // Set email subject
        mailComposeVC.setMessageBody(message, isHTML: false) // Set email body
        mailComposeVC.setToRecipients([Local.shared.companyEmail]) // Set recipient email
        mailComposeVC.mailComposeDelegate = context.coordinator
        return mailComposeVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
