//
//  BannerPromotionsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/25.
//

import SwiftUI

struct BannerPromotionsView: View {
    var navigationController:UINavigationController?
    @State private var selectedImage: UIImage? = nil
    @State private var strUrl:String = ""
    @State private var showImagePicker = false
    @State private var showCropper = false
    @State private var showSheetpackages = false
    @State private var showBuySheetpackages = false
    @State private var strAddress:String = ""
    @State private var latitude:Double = 0
    @State private var longitude:Double = 0
    @State private var radius:Int = 0


    var body: some View {
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text("Banner Promotions").font(.manrope(.bold, size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            
            if (selectedImage != nil){
                Button {
                    pushToPreviewScreen()
                } label: {
                    Text("Preview Add").font(.manrope(.semiBold, size: 18.0)).foregroundColor(Color(hexString: "#FF9900")).padding(.trailing)
                }
            }

         }.frame(height:44).background(Color(UIColor.systemBackground))
        
         VStack(alignment:.leading,spacing: 25){
            VStack(alignment:.leading,spacing: 5){
                Text("Banner image").font(.manrope(.semiBold, size: 16.0))
                Text("For the best results on all devices, use an image that's at least 1080 x 354 pixels and 4 MB or less.").font(.manrope(.regular, size: 12.0))
            }
            
            VStack(alignment:.leading){
                
                
                Button {
                    showImagePicker = true

                } label: {
                    ZStack{
                        if let img = selectedImage{
                            
                            GeometryReader { geo in
                                
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped() //  Important to crop overflowing area
                                    .cornerRadius(8)
                            }
                        }
                        VStack{
                            
                            Image("gallery")
                            Text("Select file").font(.manrope(.regular, size: 15.0)).foregroundColor(Color(hexString: "#888888"))
                        }.opacity(selectedImage == nil ? 1 : 0) // hide label over image
                    }.frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150)
                        .background(
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                        
                    )
                    .overlay{
                        RoundedRectangle(cornerRadius: 8.0).stroke(Color(hexString: "#DADADA"), lineWidth: 1.0)
                    }
                }
              
                Text("Allowed file types: PNG, JPG, JPEG, SVG, PDF").font(.manrope(.regular, size: 14.0)).foregroundColor(Color.red)
            }
            
            HStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)  // Square with rounded corners
                        .fill(Color.yellow.opacity(0.1))
                        .frame(width: 50, height: 50) // Background size
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image("location_icon_orange").renderingMode(.template)
                        .foregroundColor(.orange)
                }.padding(.leading)
                
                VStack(alignment:.leading){
                    Text("Location & Radius").font(.manrope(.semiBold, size: 15.0)).foregroundColor(Color(.label))
                    if (strAddress.count > 0){
                        Text("\(strAddress)/ \(radius)km").font(.manrope(.regular, size: 14.0)).foregroundColor(Color(.label))
                    }
                }.padding([.top,.bottom],5)
                
                Spacer()
                
                ZStack{
                    RoundedRectangle(cornerRadius: 10) // Square with rounded corners
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40) // Background size
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image("arrow_right").renderingMode(.template)
                        .foregroundColor(.black)
                }.padding(.trailing)
                
                
            }.frame(height:65)
                .background(
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                
            )
            
            .overlay {
                RoundedRectangle(cornerRadius: 8.0).stroke(Color(hexString: "#DADADA"), lineWidth: 1.0)
            }
            .onTapGesture {
                pushToLocationcreen()
            }
            
            
            VStack(alignment:.leading,spacing: 8){
                Text("Add URL").font(.manrope(.semiBold, size: 16.0))
                
                TextField("Website", text: $strUrl).padding(.horizontal).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55).background(
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                    
                ).keyboardType(.URL).tint(Color(.systemOrange))
            Text("For the best results on all devices, use an image that's at least 1080 x 354 pixels and 4 MB or less.").font(.manrope(.regular, size: 12.0))
            }
            Spacer()
            
             let isFilled = (selectedImage != nil)
            Button {
                
                if isFilled{
                    showSheetpackages = true
                }
            } label: {
                
                Text("Show packages").font(.manrope(.medium, size: 16.0)).foregroundColor(isFilled ? .white : .gray)
                  
            }.frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                 .background(isFilled ? Color(hexString: "#FF9900") : Color(hexString: "#DFDFDF")) .cornerRadius(8)
            
        }.padding()
            .background(Color(UIColor.systemGray6))
        
            .sheet(isPresented: $showImagePicker) {
                ImagePickerPromotion(image: $selectedImage) {
                           showCropper = true
                       }
                   }
                
            .fullScreenCover(isPresented: $showCropper) {
                       if let img = selectedImage {
                           ImageCropperView(
                               image: img,
                               cropAspectRatio: CGSize(width: 1180, height: 500) // 354)
                           ) { croppedImage in
                               self.selectedImage = croppedImage
                               self.showCropper = false
                           }
                       }
                   }
               
        
            .sheet(isPresented: $showSheetpackages) {
                if #available(iOS 16.0, *) {
                    PromotionPackagesView(navigationController: self.navigationController, packageSelectedPressed: {
                        
                        showBuySheetpackages = true
                        
                        
                    })
                    .presentationDetents([.fraction(0.5)]) // 📏 50% screen height
                    .presentationDragIndicator(.visible)
                } else {
                    // Fallback on earlier versions
                }   // ⬆️ Optional drag handle
            }
        
            .sheet(isPresented: $showBuySheetpackages) {
                
                if #available(iOS 16.0, *) {
                    BuyPromotionPackageView(navigationController: self.navigationController) {
                        
                    }
                    .presentationDetents([.fraction(0.25)]) // 📏 50% screen height
                    .presentationDragIndicator(.visible)
                } else {
                    // Fallback on earlier versions
                }
            }
        
    }
    
    
    func pushToPreviewScreen(){
        if let img = selectedImage{
            let destVC = UIHostingController(rootView: PreviewAdView(navigationController: self.navigationController, image: img))
            self.navigationController?.pushViewController(destVC, animated: true)
            
        }
        
    }
    
    
    func pushToLocationcreen(){
        let destVC = UIHostingController(rootView: ChooseLocationBannerView(navigationController: self.navigationController, selectedLocation: { (lat, long, address, locality, radius) in
            
            self.strAddress = address
            self.latitude = lat
            self.longitude = long
            self.radius = radius

        }))
      self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    
}

#Preview {
    BannerPromotionsView()
}




import PhotosUI
import SwiftUI

struct ImagePickerPromotion: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onPicked: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerPromotion

        init(_ parent: ImagePickerPromotion) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let itemProvider = results.first?.itemProvider else { return }

            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                        self.parent.onPicked()
                    }
                }
            }
        }
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
