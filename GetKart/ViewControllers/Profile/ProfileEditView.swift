//
//  ProfileEditView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/03/25.
//

import SwiftUI

struct ProfileEditView: View {
    
        @State private var fullName: String = ""
        @State private var email: String = ""
        @State private var phoneNumber: String = ""
        @State private var address: String = ""
        @State private var isNotificationsEnabled: Bool = true
        @State private var isContactInfoVisible: Bool = false
        @State private var selectedImage: UIImage? = nil
        @State private var showingImagePicker: Bool = false
        @State private var showOTPPopup = false

    
    var body: some View {
        HStack{
            
            Button {
                AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text("Profile Edit").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background()
        
        
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image Section
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle()).padding(5)
                            .overlay(Circle().stroke(Color.orange, lineWidth: 3))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100).padding(5)
                            .overlay(Circle().stroke(Color.orange, lineWidth: 3))
                    }
                    
                    Button(action: { showingImagePicker.toggle() }) {
                        Image("edit").resizable().frame(width: 15, height: 15).aspectRatio(contentMode: .fit)
                          
                    }.frame(width: 30,height: 30).background(Color.orange).cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 3)
                        )
                    
                        .offset(x: 35, y: 38)
                      //  .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                
                // Form Fields
                CustomTextField(title: "Full Name", text: $fullName)
                CustomTextField(title: "Email Address", text: $email, keyboardType: .emailAddress)
                CustomTextField(title: "Phone Number", text: $phoneNumber, keyboardType: .phonePad)
                HStack{
                    Spacer()
                    Button(action: {
                        showOTPPopup = true
                    }) {
                        Text("Verify")
                            .underline() .foregroundColor(Color.orange).padding(.horizontal)
                    }
                }.frame(height:15)
                
                
                
                CustomTextField(title: "Address", text: $address)
                
                // Toggle Switches
                ToggleField(title: "Notification", isOn: $isNotificationsEnabled)
                ToggleField(title: "Show Contact Info", isOn: $isContactInfoVisible)
                
                
                // Update Button
                Button(action: {
                    validateForm()
                }) {
                    Text("Update Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding()
        }.background(Color(UIColor.systemGroupedBackground)).sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }.navigationBarHidden(true).onAppear{
            getUserProfileApi()
        }
        .fullScreenCover(isPresented: $showOTPPopup) {
            if #available(iOS 16.4, *) {
                OTPPopup(
                    showOTPPopup: $showOTPPopup,
                    otp: "44334",
                    onVerify: {
                        // print("OTP Entered: \(otp)")
                        // Call your verification logic here
                    }
                ).presentationDetents([.large, .large]) // Optional for different heights
                    .background(.clear) // Remove default background
                    .presentationBackground(.clear)
            } else {
                // Fallback on earlier versions
                
                
                OTPPopup(
                    showOTPPopup: $showOTPPopup,
                    otp: "44334",
                    onVerify: {
                        // print("OTP Entered: \(otp)")
                        // Call your verification logic here
                    }
                ).background(Color.clear)
            } // Works in iOS 16+
        }
        
        
        /*.sheet(isPresented: $showOTPPopup) {
            // Centered OTP Popup
                      OTPPopup(
                        showOTPPopup: $showOTPPopup,
                          otp: "44334",
                          onVerify: {
                             // print("OTP Entered: \(otp)")
                              // Call your verification logic here
                          }
                      )
        }
        */
        
    }
    
    // Form Validation
        private func validateForm() {
            if fullName.isEmpty || email.isEmpty || phoneNumber.isEmpty || address.isEmpty {
                print("Please fill all the fields.")
            } else {
                print("Form Submitted!")
                updateProfile()
            }
        }
    
    func getUserProfileApi(){
            
        let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()

        let strUrl = Constant.shared.get_seller + "?id=\(objLoggedInUser.id ?? 0)"
            
            ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:SellerParse) in
                
                if obj.data != nil {
                    
                    self.fullName = obj.data?.seller?.name ?? ""
                    self.email = obj.data?.seller?.email ?? ""
                    self.phoneNumber = obj.data?.seller?.mobile ?? ""
                    self.address = obj.data?.seller?.address ?? ""
                    self.isNotificationsEnabled = ((obj.data?.seller?.notification) != nil)
                    self.isContactInfoVisible = ((obj.data?.seller?.mobileVisibility) != 0)
                    if  let url = URL(string:obj.data?.seller?.profile ?? ""){
                        if let data = try? Data(contentsOf: url)
                        {
                            self.selectedImage = UIImage(data: data)
                        }
                    }
                }
            }
        }
    
    
    
    func updateProfile(){
        
        
        let params = ["name":fullName,"email":email,"address":address,"mobile":phoneNumber,"countryCode":"91","notification":isNotificationsEnabled,"personalDetail":isContactInfoVisible] as [String : Any]
        
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: selectedImage ?? UIImage(), imageName: "profile", url: Constant.shared.update_profile, params: params) { responseObject, error in
            
            if error == nil{
                
                
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200{
                    
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        RealmManager.shared.updateUserData(dict: data)
                        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["OK"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                            AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                    
                }
            }
        }
    }
}


#Preview {
    ProfileEditView()
}


// Custom TextField with Background and Border
struct CustomTxtField: View {
    var title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
            
            TextField("", text: $text)
                .padding()
                .background(Color.white)
                .tint(.orange)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .keyboardType(keyboardType)
        }
    }
}

struct ToggleField: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
            Toggle("", isOn: $isOn).tint(.orange)
                .labelsHidden()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
    }
}




struct OTPPopup: View {
    @Binding var showOTPPopup: Bool
    @State var otp: String
    var onVerify: () -> Void

    var body: some View {
        if showOTPPopup {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Enter OTP")
                        .font(.title2)
                        .bold()

                    TextField("6-digit code", text: $otp).multilineTextAlignment(.center).frame(minHeight: 45)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: {
                        onVerify()
                        showOTPPopup = false
                    }) {
                        Text("Verify")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)//.frame(minHeight: 40)
                    }
                    .padding(.horizontal)

                    Button("Cancel") {
                        showOTPPopup = false
                    }
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .padding(.horizontal, 30)
                .shadow(radius: 20)
            }
            .transition(.opacity)
           // .animation(.easeInOut, value: isVisible)
        }
    }
}
