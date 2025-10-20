//
//  BannerPromotionsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/25.
//

import SwiftUI
import FittedSheets

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
    @State private var selectedPkgObj:PlanModel?

    @State private var country:String = ""
    @State private var city:String = ""
    @State private var state:String = ""
    @State private var area:String = ""
    @State private var pincode:String = ""

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
              
                Text("Allowed file types: PNG, JPG, JPEG").font(.manrope(.regular, size: 14.0)).foregroundColor(Color.red)
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
                    
                ).keyboardType(.URL).tint(Color(.systemOrange)).autocapitalization(.none)
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
                    PromotionPackagesView(navigationController: self.navigationController, packageSelectedPressed: {selPkgObj in
                        selectedPkgObj = selPkgObj
                        self.presentPayView(planObj: selPkgObj)
                        //showBuySheetpackages = true
                        
                        
                    })
                    .presentationDetents([.fraction(0.6)]) // 📏 50% screen height
                    .presentationDragIndicator(.visible)
                } else {
                    // Fallback on earlier versions
                }   // ⬆️ Optional drag handle
            }
            
//            .onChange(of: selectedPkgObj) { newValue in
//                if newValue != nil {
//                    showBuySheetpackages = true
//                }
//            }
        
            .sheet(isPresented: $showBuySheetpackages) {
                
                if #available(iOS 16.0, *) {
                    
                    BuyPromotionPackageView(navigationController: self.navigationController, buyButtonPressed: {
                        
                        //Call upload pic api
                        
                    }, selPkgObj: selectedPkgObj)
                   
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
        let destVC = UIHostingController(rootView: ChooseLocationBannerView(navigationController: self.navigationController, selectedLocation: { (lat, long, address, locality, radius,city,state,country)  in
            
            self.strAddress = address
            self.latitude = lat
            self.longitude = long
            self.radius = radius
            self.area = locality
            self.city = city
            self.state = state
            self.country = country


        }))
      self.navigationController?.pushViewController(destVC, animated: true)
    }
    
  


    func uploadFileAndDataApi(){
    
        let params = ["radius":radius,"country":country,"city":city,"state":state,"area":area,"pincode":pincode,"latitude":latitude,"longitude":longitude,"payment_method":"PhonePe","package_id":(selectedPkgObj?.id ?? ""),"status":"active","type":"redirect","url":"https://example.com/job-promotions"] as [String : Any]
        
        guard let img = selectedImage?.wxCompress() else{ return }
        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: img, imageName: "image", url: Constant.shared.campaign_payment_intent, params: params) { responseObject, error in
            
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    AlertView.sharedManager.presentAlertWith(title: "", msg: message as NSString, buttonTitles: ["Ok"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { str, index in
                        
                        self.navigationController?.popViewController(animated: true)
                    }
               
                }else{
                    
                    AlertView.sharedManager.showToast(message: message)

                }
            }
        }
    }
    
    
  /*  curl --location 'https://admin.gupsup.com/api/v1/campaign-payment-intent' \
    --header 'Authorization: Bearer 36916|d4AUyGpAiRXqMeXmFI1Y2MxDMs3uWTqVFPoYbWfn5cbd09d4' \
    --header 'Accept: application/json' \
    --form 'image=@"/home/khusyal/Desktop/error_17382998.png"' \
    --form 'country="India"' \
    --form 'state="Maharashtra"' \
    --form 'city="Mumbai"' \
    --form 'area="Andheri East"' \
    --form 'pincode="400059"' \
    --form 'latitude="19.1136"' \
    --form 'longitude="72.8697"' \
    --form 'radius="15"' \
    --form 'type="redirect"' \
    --form 'url="https://example.com/job-promotions"' \
    --form 'status="active"' \
    --form 'city="Delhi"' \
    --form 'package_id="516"' \
    --form 'payment_method="PhonePe"'
     
    */
    
    func presentPayView(planObj:PlanModel){
        
        let controller = StoryBoard.chat.instantiateViewController(identifier: "PayPlanVC")
        as! PayPlanVC
        controller.planObj = planObj
        controller.isBannerPromotionPay = true
        controller.categoryId = 0
        controller.categoryName = ""
        controller.radius = radius
        controller.area = area
        controller.selectedImage = selectedImage
        controller.city = city
        controller.country = country
        controller.state = state
        controller.latitude = "\(latitude)"
        controller.longitude = "\(longitude)"
        
        controller.callbackPaymentSuccess = { (isSuccess) -> Void in
            
            if controller.sheetViewController?.options.useInlineMode == true {
                controller.sheetViewController?.attemptDismiss(animated: true)
            } else {
                controller.dismiss(animated: true, completion: nil)
            }
            
            if isSuccess == true {
                let vc = UIHostingController(rootView: PlanBoughtSuccessView(navigationController: self.navigationController))
                vc.modalPresentationStyle = .overFullScreen // Full-screen modal
                vc.modalTransitionStyle = .crossDissolve   // Fade-in effect
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
        
        let useInlineMode = (self.navigationController?.topViewController?.view)! != nil
        controller.title = ""
        controller.navigationController?.navigationBar.isHidden = true
        let nav = UINavigationController(rootViewController: controller)
        var fixedSize = 0.3
        if UIDevice().hasNotch{
            fixedSize = 0.27
        }else{
            if UIScreen.main.bounds.size.height <= 700 {
                fixedSize = 0.37
            }
        }
        nav.navigationBar.isHidden = true
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.percent(Float(fixedSize)),.intrinsic],
            options: SheetOptions(presentingViewCornerRadius : 0 , useInlineMode: useInlineMode))
        sheet.allowGestureThroughOverlay = false
        // sheet.dismissOnOverlayTap = false
        sheet.cornerRadius = 15
        if let view = (AppDelegate.sharedInstance.navigationController?.topViewController)?.view {
            sheet.animateIn(to: view, in: (AppDelegate.sharedInstance.navigationController?.topViewController)!)
        } else {
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
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
