//
//  EditBanerPromotionView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 03/11/25.
//

import SwiftUI

struct EditBanerPromotionView: View {
    
    var navigationController:UINavigationController?
    @State private var selectedImage: UIImage? = nil
    @State private var strUrl:String = ""
    @State private var showImagePicker = false
    @State private var showCropper = false
    @State private var showSheetpackages = false
    @State private var isSettingCalled:Bool = false
    @State private var settingObj:PromotionSettingModel = PromotionSettingModel(crop_height: 100, crop_width: 100, default_radius: 50, min_radius: 25, max_radius: 100)

    var objBanner:AnalyticsModel?
    @State private var selectedMedia: PromotionMediaType?
    
    
    
    @State private var showMediaPicker = false

    @State private var isCompressing = false
    
    


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
            
        

         }.frame(height:44).background(Color(UIColor.systemBackground))
            .onAppear{
                
                if !isSettingCalled{
                    strUrl = objBanner?.url ?? ""
                    getCmpaignSettingsApi()
                    isSettingCalled = true
                }
            }
         VStack(alignment:.leading,spacing: 25){
            VStack(alignment:.leading,spacing: 5){
                Text("Banner image & video")
                    .font(.manrope(.semiBold, size: 16.0))
                
                Text("For the best results on all devices, use an image & video that's at least 800 x 350 pixels and 12 MB or less.")
                    .font(.manrope(.regular, size: 12.0))
            }
            
            VStack(alignment:.leading){
                
                
                Button {
                    showMediaPicker = true
                } label: {
                   
                            ZStack {
                                
                                
                                if (((objBanner?.thumbnail?.count ?? 0) > 0) || ((objBanner?.image?.count ?? 0) > 0)) && selectedMedia == nil{
                                    
                                    GeometryReader { geo in
                                        
                                        if let img = objBanner?.thumbnail, img.count > 0{
                                            AsyncImage(url: URL(string: img)) { img in
                                                img.image?.resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: geo.size.width, height: geo.size.height)
                                                    .clipped() //  Important to crop overflowing area
                                                    .cornerRadius(8)
                                            }

                                        }else{
                                            AsyncImage(url: URL(string: objBanner?.image ?? "")) { img in
                                                img.image?.resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: geo.size.width, height: geo.size.height)
                                                    .clipped() //  Important to crop overflowing area
                                                    .cornerRadius(8)
                                            }

                                        }
                                        
                                    }
                                    VStack{
                                        
                                        Image("gallery")
                                        Text("Upload Banner/Video").font(.manrope(.regular, size: 15.0)).foregroundColor(Color(hexString: "#888888"))
                                    }
                                }else{
                                    
                                    
                                    // MARK: Selected Media
                                    
                                    switch selectedMedia {
                                        
                                        // MARK: Image
                                        
                                    case .image(let img):
                                        
                                        GeometryReader { geo in
                                            
                                            Image(uiImage: img)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(
                                                    width: geo.size.width,
                                                    height: geo.size.height
                                                )
                                                .clipped()
                                                .cornerRadius(8)
                                        }
                                        
                                        // MARK: Video
                                        
                                    case .video(let url):
                                        
                                        VideoBannerThumbnailView(
                                            videoURL: url
                                        )
                                        
                                        // MARK: Empty
                                        
                                    case .none:
                                        
                                        VStack(spacing: 12) {
                                            
                                            Image("gallery")
                                            
                                            Text("Select file")
                                                .font(.manrope(.regular, size: 15.0))
                                                .foregroundColor(
                                                    Color(hexString: "#888888")
                                                )
                                            
                                            Text("Upload file")
                                                .font(.manrope(.medium, size: 14))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(Color.orange)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                                // MARK: Compression Loader
                                
                                if isCompressing {
                                    
                                    ZStack {
                                        
                                        Color.black.opacity(0.45)
                                        
                                        VStack(spacing: 14) {
                                            
                                            ProgressView()
                                                .progressViewStyle(
                                                    CircularProgressViewStyle(
                                                        tint: .white
                                                    )
                                                )
                                                .scaleEffect(1.2)
                                            
                                            Text("Compressing video...")
                                                .font(
                                                    .manrope(
                                                        .medium,
                                                        size: 14
                                                    )
                                                )
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .cornerRadius(8)
                                }
                            }
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 170,
                                maxHeight: 170
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay {
                                
                                RoundedRectangle(cornerRadius: 8.0)
                                    .stroke(
                                        Color(hexString: "#DADADA"),
                                        lineWidth: 1.0
                                    )
                            }
                            .cornerRadius(8)
                        }
                        
                        Text("Allowed file types: PNG, JPG, JPEG, MP4, MOV")
                            .font(.manrope(.regular, size: 12.0))
                            .foregroundColor(.red)
                    
                    /*
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
                        }else{
                            
                            GeometryReader { geo in
                                
                                if let img = objBanner?.thumbnail, img.count > 0{
                                    AsyncImage(url: URL(string: img)) { img in
                                        img.image?.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .clipped() //  Important to crop overflowing area
                                            .cornerRadius(8)
                                    }

                                }else{
                                    AsyncImage(url: URL(string: objBanner?.image ?? "")) { img in
                                        img.image?.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .clipped() //  Important to crop overflowing area
                                            .cornerRadius(8)
                                    }

                                }
                                
                            }
                           
                        }
                        VStack{
                            
                            Image("gallery")
                            Text("Upload Banner").font(.manrope(.regular, size: 15.0)).foregroundColor(Color(hexString: "#888888"))
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
              
                Text("Allowed file types: PNG, JPG, JPEG").font(.manrope(.regular, size: 14.0)).foregroundColor(Color.red)*/
            }
          
            
            VStack(alignment:.leading,spacing: 8){
                Text("Add URL").font(.manrope(.semiBold, size: 16.0))
                
                TextField("Website", text: $strUrl).padding(.horizontal).frame(maxWidth: .infinity,minHeight:55, maxHeight: 55).background(
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                    
                ).keyboardType(.URL).tint(Color(.systemOrange)).autocapitalization(.none)
              
                Text("Add your business page link and let users discover you in just one click.").font(.manrope(.regular, size: 12.0))

            }
            Spacer()
            
             let isFilled = true // (selectedImage != nil)
            Button {
                
                if isFilled{
                    validateField()
//                    showSheetpackages = true
                }
            } label: {
                
                Text("Update").font(.manrope(.medium, size: 16.0)).foregroundColor(isFilled ? .white : .gray)
                  
            }.frame(maxWidth: .infinity,minHeight:55, maxHeight: 55)
                 .background(isFilled ? Color(hexString: "#FF9900") : Color(hexString: "#DFDFDF")) .cornerRadius(27.5)
            
        }.padding()
            .background(Color(UIColor.systemGray6))
        
            .sheet(isPresented: $showImagePicker) {
                ImagePickerPromotion(image: $selectedImage) {
                           showCropper = true
                       }
                   }
                
          /*  .fullScreenCover(isPresented: $showCropper) {
                       if let img = selectedImage {
                           ImageCropperView(
                               image: img,
                              // cropAspectRatio: CGSize(width: 1180, height: 500) // 354)
                               
                               cropAspectRatio: CGSize(width: settingObj.crop_width, height: settingObj.crop_height) // 354)

                           ) { croppedImage in
                               self.selectedImage = croppedImage
                               self.showCropper = false
                           }
                       }
                   }*/
               
        
        
        
        // MARK: Media Picker
        
        .sheet(isPresented: $showMediaPicker) {
            
            MediaPickerPromotion(selectedMedia:
                                    $selectedMedia,
                                 onImagePicked: {
                
                if case .image = selectedMedia {
                    showCropper = true
                }
            }, isCompressing:$isCompressing)
        }
           
        // MARK: Cropper
        
        .fullScreenCover(isPresented: $showCropper) {
            
            if case .image(let img) = selectedMedia {
                
                ImageCropperView(
                    image: img,
                    cropAspectRatio: CGSize(
                        width: settingObj.crop_width,
                        height: settingObj.crop_height
                    )
                ) { croppedImage in
                    
                    self.selectedMedia = .image(croppedImage)
                    self.showCropper = false
                }
            }
        }
        
    }
    
    
    func validateField(){
        
        if ( selectedMedia == nil) && objBanner?.url?.trim() == strUrl.trim(){
           // AlertView.sharedManager.showToast(message: "Please ")

        }else if strUrl.count > 0 && !strUrl.isValidWebsiteURL() {
            AlertView.sharedManager.showToast(message: "Please enter valid url")

        }else{
            uploadFileAndDataApi()
        }
    }
    
    func pushToPreviewScreen(){
        if let img = selectedImage{
            let destVC = UIHostingController(rootView: PreviewAdView(navigationController: self.navigationController, image: img))
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
    
/*
    func uploadFileAndDataApi(){
    
        let params = ["url":strUrl,"banner_id":(objBanner?.id ?? 0)] as [String : Any]
     
         let img = selectedImage?.wxCompress()

        URLhandler.sharedinstance.uploadImageWithParameters(profileImg: img, imageName: "image", url: Constant.shared.update_campaign_banner, params: params) { responseObject, error in
            
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
    */
    
    func uploadFileAndDataApi(){
        
            let params = ["url":strUrl,"banner_id":(objBanner?.id ?? 0)] as [String : Any]

                var selImg:UIImage?
                var videoUrl:URL?

                if case .image(let image) = selectedMedia {
                    selImg = image.wxCompress()
                }
                
                if case .video(let video) = selectedMedia {
                    videoUrl = video
                }
                
                
                URLhandler.sharedinstance.uploadMediaWithParameters(profileImg: selImg, imageKey: "image", videoURL: videoUrl, videoKey: "image", url: Constant.shared.update_campaign_banner, params: params) { responseObject, error in
                    
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
    
    
    func getCmpaignSettingsApi(){
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.campaign_settings, param: nil,methodType: .get) { responseObject, error in
            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
            
                
                if code == 200{
                    if let data = result["data"] as? Dictionary<String,Any>{
                        
                        self.settingObj.crop_height = data["crop_height"] as? Int ?? 0
                        self.settingObj.crop_width = data["crop_width"] as? Int ?? 0
                        self.settingObj.default_radius = data["default_radius"] as? Int ?? 0
                        self.settingObj.min_radius = data["min_radius"] as? Int ?? 0
                        self.settingObj.max_radius = data["max_radius"] as? Int ?? 0

                    }
                }else{
                    
                }
            }
        }
    }
 
    
}

#Preview {
    EditBanerPromotionView()
}
