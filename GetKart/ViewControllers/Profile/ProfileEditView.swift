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
        }
        
        
    }
    
    // Form Validation
        private func validateForm() {
            if fullName.isEmpty || email.isEmpty || phoneNumber.isEmpty || address.isEmpty {
                print("Please fill all the fields.")
            } else {
                print("Form Submitted!")
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
