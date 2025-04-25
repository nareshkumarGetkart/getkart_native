//
//  TakeBackDocumentView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 17/04/25.
//

import SwiftUI
import Foundation

struct TakeBackDocumentView: View {
    @State private var showCapturedImage = false
    @State private var capturedBackImage: UIImage?
    var navigation:UINavigationController?
  // @State private var coordinator: CameraView.CameraCoordinator?
    var frontImage: UIImage?
    var selfieImage: UIImage?
    var businessName:String?

    var body: some View {
        
        // Top Navigation Bar
        HStack {
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding()
            }
            Spacer()
        }.frame(height: 44)
        
        VStack {
            
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Submit the back of your ID Proof")
                        .font(.manrope(.bold, size: 18))
                    Spacer()
                    Text("Step 3 of 3")
                        .foregroundColor(.gray)
                }
                
                // Progress Bar
                ProgressView(value: 0.9)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
                
                Text("Secure verification, no data sharing")
                    .font(.manrope(.medium, size: 18))
                    .padding(.top)
           
            }.padding(.top,15)
            .padding(.horizontal, 20)
            

            Text("Take a clear photo of the front side of your ID. Only Aadhaar Card, Driving License, Voter ID, or Passport will be accepted")
                .font(.manrope(.regular, size: 14))
                .multilineTextAlignment(.leading)
                .padding()

            Spacer()
            
            if let image = capturedBackImage {
               /* Image(uiImage: image)
                    .resizable()
                
                    .scaledToFit()
                    .frame(height: 350)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .frame(width: widthScreen-40)
                */
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity) // allows it to stretch to full width
                    .frame(height: 350)
                    .cornerRadius(12)
                    .padding(.horizontal)
                Spacer()
                HStack {
                    Button("Re-take") {
                        capturedBackImage = nil
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .foregroundColor(.orange)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 1)
                    }
                    
                    Button("Next") {
                        
                        if let img1 = frontImage{
                            
                            if let img2 = capturedBackImage{
                                if  let topView = AppDelegate.sharedInstance.navigationController?.topViewController?.view  {
                                    Themes.sharedInstance.activityView(uiView:  topView)
                                }
                                if let mergeimg = mergeImages(img1, img2){
                                    
                                    if let selfie = selfieImage{
                                        self.uploadData(selfieImg: selfie, mergedImg: mergeimg)
                                    }
                                }
                            }
                        }
                      
                  
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    //.padding(.horizontal)
                }
                .padding()
                
            } else {
                ZStack {
                    CameraView(capturedImage: $capturedBackImage, onImageCaptured: {
                        
                    }, isFrontCamera: false) .frame(height: 350)
                        .cornerRadius(12)
                    VStack{
                        Spacer()
                        Text("Place the back side of the ID Proof inside this box")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#FFB546"))
                            .foregroundColor(.white)
                            .font(.manrope(.regular, size: 14))
                            .clipShape(
                                RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight])
                            )
                    }
                    
                }.frame(height: 350).padding(.horizontal)

                Spacer()
                
                Button("Capture") {
                    // Trigger photo capture and set capturedImage
                    
                    //coordinator?.capturePhoto()
                    NotificationCenter.default.post(name: .init("capturePhoto"), object: nil)


                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
            }

        }
        .navigationBarHidden(true)
        .background(Color(UIColor.systemGray6))
    }
    
    func mergeImages(_ firstImage: UIImage, _ secondImage: UIImage) -> UIImage? {
//        
//         let view =  self.navigation?.topViewController?.view ?? UIView()
//        Themes.sharedInstance.activityView(uiView: view)
        
        let size = CGSize(
            width: max(firstImage.size.width, secondImage.size.width),
            height: firstImage.size.height + secondImage.size.height
        )
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        firstImage.draw(in: CGRect(origin: .zero, size: firstImage.size))
        secondImage.draw(in: CGRect(
            x: 0,
            y: firstImage.size.height,
            width: secondImage.size.width,
            height: secondImage.size.height
        ))

        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
     //   Themes.sharedInstance.removeActivityView(uiView: view)
        return mergedImage
    }

    
    func uploadData(selfieImg:UIImage,mergedImg:UIImage){
        
        let valDict = ["2":businessName ?? ""]
        
        let paramDict = ["verification_field":valDict,]
        let arrKey = ["1","4"]
        URLhandler.sharedinstance.uploadArrayOfImagesWithParameters(mediaArray: [selfieImg,mergedImg], mediaKeyArray: arrKey, mediaName: "verification_field_files", url: Constant.shared.send_verification_request, params: paramDict) { responseObject, error in
      
            if error != nil {
                
            }else{
                
                    let result = responseObject! as NSDictionary
                    let status = result["code"] as? Int ?? 0
                    let message = result["message"] as? String ?? ""
                    
                    if status == 200{
                        // Navigate to next screen
                        let hostVC = UIHostingController(rootView: SuccessVerifyStepView(navigation:navigation))
                        self.navigation?.pushViewController(hostVC, animated: true)

                    }
                
           
            }
        }
    }
    /*

    func uploadVerificationData(
        image1: UIImage,
        image2: UIImage,
        text: String,
        url: URL
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = createMultipartBody(image1: image1, image2: image2, text: text, boundary: boundary)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload failed: \(error)")
                return
            }

            if let data = data, let response = response as? HTTPURLResponse {
                print("Status: \(response.statusCode)")
                print("Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }.resume()
    }
    
    func createMultipartBody(image1: UIImage, image2: UIImage, text: String, boundary: String) -> Data {
        var body = Data()

        // Add text field: verification_field[2]
        body.append(convertFormField(named: "verification_field[2]", value: text, using: boundary))

        // Add file1: verification_field_files[1]
        if let imageData1 = image1.jpegData(compressionQuality: 0.8) {
            body.append(convertFileData(
                fieldName: "verification_field_files[1]",
                fileName: "image1.jpg",
                mimeType: "image/jpeg",
                fileData: imageData1,
                using: boundary
            ))
        }

        // Add file2: verification_field_files[4]
        if let imageData2 = image2.jpegData(compressionQuality: 0.8) {
            body.append(convertFileData(
                fieldName: "verification_field_files[4]",
                fileName: "image2.jpg",
                mimeType: "image/jpeg",
                fileData: imageData2,
                using: boundary
            ))
        }

        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }

    func convertFormField(named name: String, value: String, using boundary: String) -> Data {
        var fieldData = Data()
        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        fieldData.append("\(value)\r\n")
        return fieldData
    }

    func convertFileData(fieldName: String,
                         fileName: String,
                         mimeType: String,
                         fileData: Data,
                         using boundary: String) -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.append("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.append("\r\n")
        return data
    }


     VStack(spacing: 20) {
                 if let mergedImage = mergedImage {
                     Image(uiImage: mergedImage)
                         .resizable()
                         .scaledToFit()
                         .frame(height: 400)
                 }

                 Button("Merge Images") {
                     mergedImage = mergeImages(image1, image2)
                 }
     */
}

#Preview {
    TakeBackDocumentView()
}
