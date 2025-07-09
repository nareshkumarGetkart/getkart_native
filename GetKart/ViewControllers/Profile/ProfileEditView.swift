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
    @State private var isMobileVerified = false
    @State private var isEmailVerified = false
    @State private var isEmailOtpVerifyClicked = false
    @State var isDataLoading = false
    var navigationController:UINavigationController?
    
    var body: some View {
        HStack{
            
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Edit Profile").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
        }.frame(height:44).background(Color(UIColor.systemBackground))
       
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
//                        Circle()
//                            .fill(Color.gray.opacity(0.3))
//                            .frame(width: 100, height: 100).padding(5)
//                            .overlay(Circle().stroke(Color.orange, lineWidth: 3))
//                        
                        Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image("user-circle") // <-- Replace with your placeholder asset name
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    )
                                    //.padding(5)
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
                    .disabled(isEmailVerified)
                if !isEmailVerified && email.count > 0{
                    HStack{
                        Spacer()
                        Button(action: {
                            if email.isValidEmail(){
                                isEmailOtpVerifyClicked = true

                                UIApplication.shared.endEditing()
                                sendEmailOtp(emailId: email)
                            }
                        }) {
                            Text("Verify")
                                .underline() .foregroundColor(Color.orange).padding(.horizontal)
                        }
                    }.frame(height:15)
                    
                }
                CustomTextField(title: "Phone Number", text: $phoneNumber, keyboardType: .phonePad)
                    .disabled(isMobileVerified)
                
                if !isMobileVerified && phoneNumber.count > 0{
                    HStack{
                        Spacer()
                        Button(action: {
                            if phoneNumber.count > 5{
                                isEmailOtpVerifyClicked = false
                                UIApplication.shared.endEditing()
                                sendOTPApi(countryCode: "+91")
                            }
                        }) {
                            Text("Verify")
                                .underline() .foregroundColor(Color.orange).padding(.horizontal)
                        }
                    }.frame(height:15)
                    
                }
                
                CustomTextField(title: "Address", text: $address)
                
                // Toggle Switches
              /*  ToggleField(title: "Notification", isOn: $isNotificationsEnabled)
                ToggleField(title: "Show Contact Info", isOn: $isContactInfoVisible)
               
                */
                // Update Button
                Button(action: {
                    UIApplication.shared.endEditing()

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
                .contentShape(Rectangle())
                
                if isDataLoading{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .tint(.orange)
                        .padding(.bottom)
                }
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
                    otp: "",
                    onVerify: {code in
                        if isEmailOtpVerifyClicked{
                            verifyEmailOTPApi(otp: code)
                        }else{
                            verifyMobileOTPApi(otp: code)
                        }
                        print("OTP Entered: \(code)")
                        // Call your verification logic here
                    }
                ).presentationDetents([.large, .large]) // Optional for different heights
                    .background(.clear) // Remove default background
                    .presentationBackground(.clear)
            } else {
                // Fallback on earlier versions
                
                OTPPopup(
                    showOTPPopup: $showOTPPopup,
                    otp: "",
                    onVerify: {code in
                         print("OTP Entered: \(code)")
                        if isEmailOtpVerifyClicked{
                            verifyEmailOTPApi(otp: code)
                        }else{
                            verifyMobileOTPApi(otp: code)
                        }

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
           
            AlertView.sharedManager.showToast(message: "Please fill all the fields.")

        }else if !fullName.isValidName() || fullName.lowercased() == "guest user" {
            AlertView.sharedManager.showToast(message: "Please enter valid name")
            
        }else if !email.isValidEmail(){
            AlertView.sharedManager.showToast(message: "Please enter valid email")

        }else if isMobileVerified == false{
            AlertView.sharedManager.showToast(message: "Please verify mobile number")

        } else if isEmailVerified == false{
            AlertView.sharedManager.showToast(message: "Please verify email id")

        }else {
            updateProfile()
        }
    }
    
    
    func verifyMobileOTPApi(otp:String){
        
        let params = ["mobile": phoneNumber, "countryCode":"+91", "otp":otp] as [String : Any]
        
        
      
        URLhandler.sharedinstance.makeCall(url: Constant.shared.mobile_verify_update, param: params, methodType: .post,showLoader:true) {  responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    isMobileVerified = true
                }else{
                    isMobileVerified = false

                }
                
            }
        }
    }
    
   
    func getUserProfileApi(){
        
       // let objLoggedInUser = RealmManager.shared.fetchLoggedInUserInfo()
        
        let strUrl = Constant.shared.get_seller + "?id=\(Local.shared.getUserId())"
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:SellerParse) in
            
            if obj.data != nil {
                
                self.fullName = obj.data?.seller?.name ?? ""
                self.email = obj.data?.seller?.email ?? ""
                self.phoneNumber = obj.data?.seller?.mobile ?? ""
                self.address = obj.data?.seller?.address ?? ""
                self.isNotificationsEnabled = ((obj.data?.seller?.notification ?? 0) == 0) ? false : true
                self.isContactInfoVisible = ((obj.data?.seller?.mobileVisibility ?? 0) == 0) ? false : true
                
                if  let url = URL(string:obj.data?.seller?.profile ?? ""){
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url)
                        {
                            self.selectedImage = UIImage(data: data)
                        }
                    }
                }
                self.isMobileVerified = (self.phoneNumber.count > 0) ? true : false
                self.isEmailVerified = (self.email.count > 0) ? true : false

                
            }
        }
    }
    
    
    
    
    func sendEmailOtp(emailId:String){
      //  let timestamp = Date.timeStamp
        let params: Dictionary<String,String> =  ["email":emailId,"type":"update"]
        
       
      
        URLhandler.sharedinstance.makeCall(url: Constant.shared.send_email_otp, param: params, methodType: .post,showLoader:true) { responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    
                    AlertView.sharedManager.showToast(message: message)
                    self.showOTPPopup = true

                  
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    
    
    func verifyEmailOTPApi(otp:String){
        
        let params = ["email": email,"otp":otp,"type":"update"] as [String : Any]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.verify_email_otp, param: params, methodType: .post,showLoader:true) { responseObject, error in
            
            
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if status == 200{
                 
                    self.isEmailVerified = true
                    
                
                }else{
                    self.isEmailVerified = false

                    AlertView.sharedManager.showToast(message: message)
                }
                
            }
        }
    }
    func updateProfile(){
        
        self.isDataLoading = true
        
//        let isNotification =  isNotificationsEnabled == false ? 0 : 1
//        let isContact =  isContactInfoVisible == false ? 0 : 1

//        let params = ["name":fullName,"email":email,"address":address,"mobile":phoneNumber,"countryCode":"91","notification":isNotification,"personalDetail":isContact] as [String : Any]
        
        
        let params = ["name":fullName,"email":email,"address":address,"mobile":phoneNumber,"countryCode":"91"] as [String : Any]

        
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: selectedImage?.wxCompress() ?? UIImage(), imageName: "profile", url: Constant.shared.update_profile, params: params) { responseObject, error in
            
            self.isDataLoading = false
            
            if error == nil{
                
                
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                if code == 200{
                    
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        RealmManager.shared.updateUserData(dict: data)
                        AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["OK"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
                            navigationController?.popViewController(animated: true)
                        }
                        
                    }
                    
                }else{
                    AlertView.sharedManager.showToast(message: message)
                }
            }
        }
    }
    
    
    func sendOTPApi(countryCode:String){
        
        let params = ["mobile": Int(phoneNumber.trim()) ?? 0, "countryCode":"\(countryCode)"] as [String : Any]
              
        URLhandler.sharedinstance.makeCall(url: Constant.shared.sendMobileOtpUrl, param: params, methodType: .post,showLoader:true) { responseObject, error in
            
        
            if(error != nil)
            {
                //self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                
            }else{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""

                if status == 200{
                    self.showOTPPopup = true

                }else{
                    AlertView.sharedManager.showToast(message: message)

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
        
        VStack(alignment: .leading) {
            Text(title)
                .font(.body)
                .foregroundColor(Color(UIColor.label))
            
        HStack {
            let str = isOn ? "Enabled" : "Disabled"
            Text(str)
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
            Toggle("", isOn: $isOn).tint(.orange)
                .labelsHidden()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
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
    var onVerify: (_ otp:String) -> Void

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

                    TextField("Enter OTP", text: $otp).tint(.orange)
                        .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                            .frame(height: 40) // Set your desired height here
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.horizontal)
                

                    Button(action: {
                        onVerify(otp)
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


import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
