//
//  BannerPromotionsView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/25.
//

import SwiftUI
import FittedSheets
import PhotosUI
import AVKit
import UniformTypeIdentifiers

// MARK: - Media Type

enum PromotionMediaType {
    case image(UIImage)
    case video(URL)
}

// MARK: - Main View

struct BannerPromotionsView: View {
    
    var navigationController: UINavigationController?
    
    @State private var selectedMedia: PromotionMediaType?

    @State private var showMediaPicker = false

    @State private var isCompressing = false
    
    @State private var strUrl: String = ""
    
    @State private var showCropper = false
    
    @State private var showSheetpackages = false
    @State private var showBuySheetpackages = false
    

   // @State private var selectedPkgObj: PlanModel?
    
    @State private var country: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var area: String = ""
    @State private var pincode: String = ""
    
    @State private var isSettingCalled: Bool = false
    
    @State private var settingObj = PromotionSettingModel(
        crop_height: 350,
        crop_width: 830,
        default_radius: 50,
        min_radius: 25,
        max_radius: 100
    )
    
    @State private var paymentGateway: PaymentGatewayCentralized?

    var body: some View {
        
        VStack(spacing: 0) {
            
            // MARK: Header
            
            HStack(spacing: 3) {
                
                Button {
                    navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.label))
                }
                .frame(width: 40, height: 40)
                
                Text("Banner Promotions")
                    .font(.manrope(.bold, size: 18.0))
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
                
                if selectedMedia != nil {
                    
                    Button {
                        pushToPreviewScreen()
                    } label: {
//                        Text("Preview Add")
                        
                        Text("How it works")

                            .font(.manrope(.semiBold, size: 18.0))
                            .foregroundColor(Color(hexString: "#FF9900"))
                            .padding(.trailing)
                    }
                }
            }
            .frame(height: 44)
            .padding(.horizontal)
            .background(Color(UIColor.systemBackground))
            
            Divider()
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 25) {
                    
                    // MARK: Title
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text("Banner image & video")
                            .font(.manrope(.semiBold, size: 16.0))
                        
                        Text("For the best results on all devices, use an image & video that's at least 800 x 350 pixels and 12 MB or less.")
                            .font(.manrope(.regular, size: 12.0))
                    }
                    
                    // MARK: Media Picker
                    
                    VStack(alignment: .leading) {
                        
                        Button {
                            showMediaPicker = true
                            
                        } label: {
                            
                            ZStack {
                                
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
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("Add URL")
                            .font(.manrope(.semiBold, size: 16.0))
                        
                        TextField("Website", text: $strUrl)
                            .padding(.horizontal)
                            .frame(height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                            )
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                        
                        Text("Add your business page link and let users discover you in just one click.")
                            .font(.manrope(.regular, size: 12.0))
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            
            // MARK: Bottom Button
            
            let isFilled = (selectedMedia != nil)
            
            Button {
                
                if isFilled {
                    validateField()
                }
                
            } label: {
                
                Text("Show Packages")
                    .font(.manrope(.medium, size: 16.0))
                    .foregroundColor(isFilled ? .white : .gray)
            }
            .frame(maxWidth: .infinity, minHeight: 55)
            .background(
                isFilled
                ? Color(hexString: "#FF9900")
                : Color(hexString: "#DFDFDF")
            )
            .cornerRadius(8)
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color(UIColor.systemGray6))
        
        // MARK: onAppear
        
        .onAppear {
            
            if !isSettingCalled {
                getCmpaignSettingsApi()
                isSettingCalled = true
            }
        }
        
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
        
        // MARK: Package Sheet
        
        .sheet(isPresented: $showSheetpackages) {
            
            if #available(iOS 16.0, *) {
                
                BannerPackageView(packageSelectedPressed: { selPkgObj, pymntMethod in
                    //selectedPkgObj = selPkgObj
                    self.paymentGatewayOpen(selPlan: selPkgObj, selPaymentMethod: pymntMethod)
                })
               /* PromotionPackagesView(
                    navigationController: self.navigationController
                ) { selPkgObj in
                    
                    selectedPkgObj = selPkgObj
                    
                    self.presentPayView(planObj: selPkgObj)
                }*/
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.hidden)
            }
        }
    }
}
import SwiftUI
import AVFoundation

struct VideoBannerThumbnailView: View {
    
    let videoURL: URL
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        
        ZStack {
            
            if let thumbnail = thumbnail {
                
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 170) // Banner Height
                    .clipped()
                    .cornerRadius(8)
                
            } else {
                
                Color.black.opacity(0.2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 170)
                    .cornerRadius(8)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            // Play Icon Overlay
            Image(systemName: "play.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 600)
        
        DispatchQueue.global(qos: .background).async {
            
            do {
                
                let cgImage = try generator.copyCGImage(
                    at: time,
                    actualTime: nil
                )
                
                let uiImage = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
                
            } catch {
                print("Thumbnail Error: \(error.localizedDescription)")
            }
        }
    }
}
// MARK: - Functions

extension BannerPromotionsView {
    
    func validateField() {
        UIApplication.shared.endEditing()
        if selectedMedia == nil {
            
            AlertView.sharedManager.showToast(
                message: "Please upload banner media"
            )
            
        }
//        else if city.count == 0 {
//            
//            AlertView.sharedManager.showToast(
//                message: "Please select location"
//            )
//
        
//        }
        else if strUrl.count <= 4 {
            
            AlertView.sharedManager.showToast(
                message: "Please enter valid url"
            )
            
        } else if strUrl.count > 0 &&
                    !strUrl.isValidWebsiteURL() {
            
            AlertView.sharedManager.showToast(
                message: "Please enter valid url"
            )
            
        } else {
            
            showSheetpackages = true
        }
    }
    
    func pushToPreviewScreen() {
        
        
       // if let url = URL(string: Constant.shared.BANNER_DEMO){
            let vc = UIHostingController(rootView:  PreviewURL(fileURLString:Constant.shared.BANNER_DEMO))
            self.navigationController?.pushViewController(vc, animated: true)

       // }
//        switch selectedMedia {
//            
//        case .image(let img):
//            
//            
//            do{
//                
//        
//                let zoomCtrl = VKImageZoom()
//                zoomCtrl.image = img
//                zoomCtrl.modalPresentationStyle = .fullScreen
//                navigationController?.present(zoomCtrl, animated: true, completion: nil)
//            }
//            
//           /* let vc = UIHostingController(
//                rootView: PreviewAdView(
//                    navigationController: navigationController,
//                    image: img
//                )
//            )
//            
//            navigationController?.pushViewController(
//                vc,
//                animated: true
//            )
//            */
//        case .video(let url):
//            
//            let vc = UIHostingController(
//                rootView: VideoPreviewScreen(videoURL: url)
//            )
//            
//            navigationController?.pushViewController(
//                vc,
//                animated: true
//            )
//            
//        case .none:
//            break
//        }
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
    
    
    
    func presentPayView(planObj:PlanModel){
        
        let controller = StoryBoard.chat.instantiateViewController(identifier: "PayPlanVC")
        as! PayPlanVC
        controller.planObj = planObj
        // controller.isBannerPromotionPay = true
        controller.categoryId = 0
        controller.categoryName = ""
        // controller.radius = radius
        // controller.area = area
        //controller.selectedImage = selectedImage
        
        controller.selectedMedia = selectedMedia
        //controller.city = city
        //controller.country = country
        //controller.state = state
        // controller.latitude = "\(latitude)"
        // controller.longitude = "\(longitude)"
        controller.strUrl = strUrl
        controller.paymentFor = .bannerPromotion
        
        
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
    
    
    
    func paymentGatewayOpen(selPlan: PlanModel,selPaymentMethod:SelPaymentMethod) {
                
        paymentGateway = PaymentGatewayCentralized()   //  STRONG REFERENCE
        paymentGateway?.planObj = selPlan
        paymentGateway?.paymentFor = .bannerPromotion
        paymentGateway?.strUrl = strUrl
        paymentGateway?.selectedMedia = selectedMedia
    
        paymentGateway?.callbackPaymentSuccess = { (isSuccess) in
           
            if isSuccess {
                let vc = UIHostingController(
                    rootView: PlanBoughtSuccessView(
                        navigationController: self.navigationController
                    )
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigationController?.present(vc, animated: true)
            }
            
            //  RELEASE
            self.paymentGateway = nil
        }
        paymentGateway?.initializeDefaults(selpaymentMethod: selPaymentMethod)
        
    }
}

// MARK: - Video Thumbnail

struct VideoThumbnailView: View {
    
    let videoURL: URL
    
    var body: some View {
        
        ZStack {
            
            VideoPlayer(
                player: AVPlayer(url: videoURL)
            )
            .disabled(true)
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 45))
                .foregroundColor(.white)
        }
        .cornerRadius(8)
    }
}

// MARK: - Video Preview

struct VideoPreviewScreen: View {
    
    let videoURL: URL
    
    var body: some View {
        
        VideoPlayer(
            player: AVPlayer(url: videoURL)
        )
        .ignoresSafeArea()
    }
}

// MARK: - Picker

struct MediaPickerPromotion: UIViewControllerRepresentable {
    
    @Binding var selectedMedia: PromotionMediaType?
    
    var onImagePicked: () -> Void
    @Binding var isCompressing: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(
        context: Context
    ) -> PHPickerViewController {
        
        var config = PHPickerConfiguration()
        
        config.selectionLimit = 1
        
        config.filter = .any(
            of: [.images, .videos]
        )
        
        let picker = PHPickerViewController(
            configuration: config
        )
        
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    ) {}
    
    // MARK: Coordinator
    
    class Coordinator: NSObject,
                       PHPickerViewControllerDelegate {
        
        let parent: MediaPickerPromotion
        
        init(_ parent: MediaPickerPromotion) {
            self.parent = parent
        }
        
        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else {
                return
            }
            
            // MARK: IMAGE
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                
                provider.loadObject(
                    ofClass: UIImage.self
                ) { image, error in
                    
                    DispatchQueue.main.async {
                        
                        if let img = image as? UIImage {
                            
                            self.parent.selectedMedia = .image(img)
                            
                            self.parent.onImagePicked()
                        }
                    }
                }
                
                return
            }
            
            // MARK: VIDEO
            
            if provider.hasItemConformingToTypeIdentifier(
                UTType.movie.identifier
            ) {
                
            self.parent.isCompressing = true
                
                provider.loadFileRepresentation(
                    forTypeIdentifier: UTType.movie.identifier
                ) { url, error in
                    
                    guard let url else {
                        
                        DispatchQueue.main.async {
                            self.parent.isCompressing = false
                        }
                        
                        return
                    }
                    
                    let tempURL = FileManager.default
                        .temporaryDirectory
                        .appendingPathComponent(
                            UUID().uuidString + ".mov"
                        )
                    
                    try? FileManager.default.removeItem(at: tempURL)
                    
                    do {
                        
                        try FileManager.default.copyItem(
                            at: url,
                            to: tempURL
                        )
                        
                        // MARK: Validate Landscape Video
                        
                      /*  let asset = AVAsset(url: tempURL)
                        
                        guard asset.isLandscapeVideo else {
                            
                            DispatchQueue.main.async {
                                
                            self.parent.isCompressing = false
                                
                                AlertView.sharedManager.showToast(
                                    message: "Please select horizontal banner video"
                                )
                            }
                            
                            return
                        }*/
                        
                        // MARK: Compress
                        
                        VideoCompressor.compressVideo(
                            inputURL: tempURL
                        ) { compressedURL in
                            
                            self.parent.isCompressing = false
                            
                            guard let compressedURL else {
                                return
                            }
                            
                            // MARK: Validate Size
                            
                            do {
                                
                                let data = try Data(
                                    contentsOf: compressedURL
                                )
                                
                                let sizeMB = Double(data.count)
                                / 1024.0
                                / 1024.0
                                
                                print("Compressed Size:", sizeMB)
                                
                                if sizeMB > 12 {
                                    
                                    AlertView.sharedManager.showToast(
                                        message: "Video size must be less than 12 MB"
                                    )
                                    
                                    return
                                }
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            DispatchQueue.main.async {
                                
                                self.parent.selectedMedia = .video(
                                    compressedURL
                                )
                            }
                        }
                        
                    } catch {
                        
                        DispatchQueue.main.async {
                            self.parent.isCompressing = false
                        }
                        
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

import AVFoundation

extension AVAsset {
    
    var isLandscapeVideo: Bool {
        
        guard let track = tracks(
            withMediaType: .video
        ).first else {
            return false
        }
        
        let size = track.naturalSize
            .applying(track.preferredTransform)
        
        let width = abs(size.width)
        let height = abs(size.height)
        
        return width > height
    }
}

import AVFoundation

final class VideoCompressor {
    
    static func compressVideo(
        inputURL: URL,
        completion: @escaping (URL?) -> Void
    ) {
        
        let asset = AVURLAsset(url: inputURL)
        
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetMediumQuality
        ) else {
            completion(nil)
            return
        }
        
        let compressedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                UUID().uuidString + ".mp4"
            )
        
        // Remove existing
        try? FileManager.default.removeItem(at: compressedURL)
        
        exportSession.outputURL = compressedURL
        exportSession.outputFileType = .mp4
        
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            
            DispatchQueue.main.async {
                
                switch exportSession.status {
                    
                case .completed:
                    completion(compressedURL)
                    
                case .failed:
                    print(exportSession.error ?? "")
                    completion(nil)
                    
                case .cancelled:
                    completion(nil)
                    
                default:
                    break
                }
            }
        }
    }
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





import Foundation

extension String {
    /// Valid only if starts with http://, https://, or www.
    func isValidWebsiteURL() -> Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Must start with one of these
        guard trimmed.lowercased().hasPrefix("http://") ||
              trimmed.lowercased().hasPrefix("https://") ||
              trimmed.lowercased().hasPrefix("www.") else {
            return false
        }

        // Try to create a URL (auto-add https:// if only www. present)
        var testURL = trimmed
        if testURL.lowercased().hasPrefix("www.") {
            testURL = "https://" + testURL
        }

        guard let url = URL(string: testURL),
              let host = url.host,
              host.contains(".") else {
            return false
        }

        return true
    }

//not checking prefix will pass go.in like
    func isValidURLFormat() -> Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return false }

        // Add scheme ONLY for parsing (not validation requirement)
        let testString: String
        if trimmed.contains("://") {
            testString = trimmed
        } else {
            testString = "https://" + trimmed
        }

        guard let url = URL(string: testString),
              let host = url.host else {
            return false
        }

        // Host must contain at least one dot and valid characters
        let hostRegex = #"^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", hostRegex)

        return predicate.evaluate(with: host)
    }
}
