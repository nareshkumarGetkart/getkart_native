//
//  UploadImageVideoView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/02/26.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI
import AVKit
import AVFoundation
import SwiftUI
import PhotosUI
import AVFoundation


struct PickerConfig: Identifiable {
    let id = UUID()
    let limit: Int
}

enum ProductType:Int {
    case product
    case promoteBusiness
}


struct UploadImageVideoView: View {

    var navigationController: UINavigationController?
    @State private var showVideoSheet = false
    @State private var showSheet = false
    @State private var finalImages: [UIImage] = []
    @State private var imagesForCrop: [UIImage]? = nil
    @State private var cropWrapper: CropImageWrapper? = nil
    @State private var selectionType: ProductType = .product
    @State private var pickerConfig: PickerConfig?
    @State private var selectedVideoURL: URL?
   // @State private var isPreparingVideo = false
    @State private var isLoading = false
    
    private var currentSelectionLimit: Int {
        switch selectionType {
        case .product:
            return 5
        case .promoteBusiness:
            return 1
        }
    }

    var body: some View {

        if #available(iOS 17.0, *) {
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Button {
                        navigationController?.popViewController(animated: true)
                    } label: {
                        Image("arrow_left")
                            .renderingMode(.template)
                            .foregroundColor(Color(UIColor.label))
                    }
                    .frame(width: 40, height: 40)
                    
                    Text("Upload Image/Video")
                        .font(.system(size: 18, weight: .medium))
                    
                    Spacer()
                }
                .frame(height: 44)
                .background(Color(UIColor.systemBackground))
                
                ScrollView {
                    VStack(spacing: 15) {
                        
                        // Product
                        UploadCardView(
                            title: "Add Your Product",
                            subtitle: "Sell your items quickly!",
                            imageName: "products",
                            buttonTitle: "Sell Now"
                        ) {
                            selectionType = .product
                            pickerConfig = PickerConfig(limit: currentSelectionLimit)
                        }
                        
                        // Promote
                        UploadCardView(
                            title: "Promote Your Business",
                            subtitle: "Grow your brand & services!",
                            imageName: "promoteYourBusiness",
                            buttonTitle: "Get Started"
                        ) {
                            selectionType = .promoteBusiness
                            showSheet = true
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .background(Color(.systemGray5))
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        
                        VStack(spacing: 10) {
                            ProgressView()
                                .scaleEffect(1.4)
                            
                            Text("Preparing video...")
                                .foregroundColor(.white)
                                .font(.inter(.medium, size: 15))
                        }
                        .padding(20)
                        .background(Color(.systemOrange).opacity(0.9))
                        .cornerRadius(10)
                    }
                    .transition(.opacity)
                    .zIndex(999) //  important
                }
            }
            
            // Bottom Sheet
            .sheet(isPresented: $showSheet) {
                
                UploadBottomSheet { type in
                    
                    showSheet = false
                    
                    switch type {
                    case .video:
                        print("Video tapped")
                       // self.showVideoSheet = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                            self.pushQuick()

                        })
                    case .image:
                        print("Image tapped")
                        print("Selection type:", selectionType)
                        print("Limit:", currentSelectionLimit)
                        
                        pickerConfig = PickerConfig(limit: currentSelectionLimit)
                    }
                }
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
            }
            
            //  FIXED PICKER PRESENTATION
            .fullScreenCover(item: $pickerConfig) { config in
                
                ImagePickerViewNew(maxSelectLimit: config.limit) { images in
                    
                    pickerConfig = nil
                    cropWrapper = CropImageWrapper(images: images, type: selectionType)
                    print("selectionType==\(selectionType)")
                    
                }
            }
            
            .fullScreenCover(isPresented: $showVideoSheet) {
                VideoPickerPHPicker(
                            onVideoPicked: { url in
                                print("Video:", url)
                                showVideoSheet = false
                                selectedVideoURL = url
                            },
                            onCancel: {
                                showVideoSheet = false
                            },
                            isLoading: $isLoading   // 👈 PASS BINDING
                        )
               

//                VideoPickerPHPicker { url in
//                    showVideoSheet = false
//                    selectedVideoURL = url
//               
//                    
//                } onCancel: {
//                    showVideoSheet = false
//                }
            }
            
           
            .sheet(item: $selectedVideoURL, content: { url in
                
                ProVideoTrimmerView(url: url, maxDuration: 30) { trimmedURL in
                    
                    self.pushToPromotionalVideoView(asset: AVURLAsset(url: trimmedURL))                   //  final output after trimming
                    print("Final video:", trimmedURL)
                    selectedVideoURL = nil
                    //  push next screen (upload / preview)
                } onCancel: {
                    selectedVideoURL = nil
                }

                                
            })
            
            
            // Cropper
            .fullScreenCover(item: $cropWrapper) { wrapper in
                if wrapper.type == .promoteBusiness {
                    
                    MultiImageCropperView(images: wrapper.images) { images in
                        finalImages = images
                        cropWrapper = nil
                        
                        if let img = finalImages.first {
                            pushToPromotionalImageView(image: img)
                        }
                        
                    } onCancel: {
                        cropWrapper = nil
                        finalImages.removeAll()
                    }
                    
                } else {
                    
                    MultiImageCropperView(images: wrapper.images) { images in
                        finalImages = images
                        cropWrapper = nil
                        pushToCreateBoardScreen()
                        
                    } onCancel: {
                        cropWrapper = nil
                        finalImages.removeAll()
                        
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Navigation

    func pushToCreateBoardScreen() {
        let destVC = UIHostingController(
            rootView: CreateBoardView(
                navigationController: navigationController,
                selectedImages: finalImages
            )
        )
        navigationController?.pushViewController(destVC, animated: true)
    }

    func pushToPromotionalImageView(image: UIImage) {
        let destVC = UIHostingController(
            rootView: CreatePromotionalAdsView(
                navigationController: navigationController,
                selectedImage: image,
                isFromEdit: false
            )
        )
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func pushToPromotionalVideoView(asset: AVURLAsset) {
        let destVC = UIHostingController(
            rootView: CreatePromotionalVideoAdsView(
                navigationController: navigationController,
                videoSelected: asset,
                isFromEdit: false
            )
        )
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    func pushQuick(){
        
        let destVC = UIHostingController(
            rootView: CreatePromotionalVideoAdsView(
                navigationController: navigationController,
                videoSelected: nil,
                isFromEdit: false
            )
        )
        navigationController?.pushViewController(destVC, animated: true)
    }
}




#Preview {
    UploadImageVideoView()
}


struct UploadCardView: View {

    let title: String
    let subtitle: String
    let imageName: String
    let buttonTitle: String
    var onSelectButton: () -> Void

    var body: some View {
        VStack(spacing: 8) {

            VStack(spacing: 6) {
                Text(title)
                    .font(.inter(.inter_18pt_ExtraBoldItalic, size: 22))

                Text(subtitle)
                    .font(.inter(.inter_18pt_Italic, size: 16))
                    .foregroundColor(.gray)
            }.padding()

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 170)

            Button(action: {
                    onSelectButton()
                }) {
                    Text(buttonTitle)
                        .font(.inter(.inter_18pt_ExtraBoldItalic, size: 24))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                }
                .background(
                    LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#FDB300"),
                                Color(hex: "#FA8900")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
            
            
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}


struct UploadBottomSheet: View {

    @Environment(\.dismiss) private var dismiss
    var onSelect: (UploadType) -> Void

    var body: some View {
        VStack(spacing: 20) {

            // Header
            HStack {
                Spacer()

                Text("Select From  Gallery")
                    .font(.system(size: 18, weight: .medium))

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark").foregroundColor(Color(.label))
                        .font(.system(size: 18))
                }
            }
            .padding([.horizontal,.top])
           
            VStack(spacing: 5) {
                Spacer(minLength: 0)

                // Upload Video
                UploadRow(
                    icon: "play.circle",
                    title: "Upload Video"
                ) {
                    onSelect(.video)
                }
                
                // Upload Image
                UploadRow(
                    icon: "photo",
                    title: "Upload Image"
                ) {
                    onSelect(.image)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 10)
    }
}


struct UploadRow: View {

    let icon: String
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {

                ZStack {
                    Circle()
                        .stroke(Color.orange, lineWidth: 2)
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .foregroundColor(.orange)
                        .font(.system(size: 20))
                }

                Text(title).foregroundColor(Color(.label))
                    .font(.system(size: 18, weight: .medium))

                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
        }
        .padding(.horizontal)
    }
}


enum UploadType {
    case video
    case image
}


import SwiftUI
import PhotosUI


struct CropImageWrapper: Identifiable {
    let id = UUID()
    let images: [UIImage]
    let type: ProductType?

}


//=======


import SwiftUI
import PhotosUI

struct ImagePickerViewNew: UIViewControllerRepresentable {

    var maxSelectLimit: Int = 1
    var onFinished: ([UIImage]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {

        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = maxSelectLimit

        print("🔥 Picker created with limit:", maxSelectLimit)

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        print("uiViewController.configuration.selectionLimit == \(uiViewController.configuration.selectionLimit)")
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {

        let parent: ImagePickerViewNew

        init(_ parent: ImagePickerViewNew) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

            guard !results.isEmpty else {
                picker.dismiss(animated: true)
                return
            }

            var loadedImages: [UIImage] = []
            let group = DispatchGroup()

            for result in results {

                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {

                    group.enter()

                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage {
                            loadedImages.append(image)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                picker.dismiss(animated: true)

                let limitedImages = Array(loadedImages.prefix(self.parent.maxSelectLimit))
                self.parent.onFinished(limitedImages)
            }
        }
    }
}


struct CropFlowController: UIViewControllerRepresentable {

    var images: [UIImage]
    var onDone: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let cropVC = CropViewControllerNew(images: images)
        cropVC.onDone = onDone
        return UINavigationController(rootViewController: cropVC)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}


import UIKit
import Mantis

class CropViewControllerNew: UIViewController {

    // MARK: - Properties

    private var images: [UIImage]
    private var croppedImages: [UIImage]
    private var currentIndex: Int = 0

    var onDone: (([UIImage]) -> Void)?

    private var cropVC: CropViewController?

    // MARK: - Init

    init(images: [UIImage]) {
        self.images = images
        self.croppedImages = images
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
     

        guard !images.isEmpty else {
            print("No images received in crop")
            return
        }

        setupNavigation()
        showCropper()
    }

    // MARK: - Setup Navigation

    private func setupNavigation() {

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Previous",
            style: .plain,
            target: self,
            action: #selector(previousTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Next",
            style: .done,
            target: self,
            action: #selector(nextTapped)
        )

        updateNavState()
    }

    private func updateNavState() {
        navigationItem.leftBarButtonItem?.isEnabled = currentIndex > 0
        navigationItem.rightBarButtonItem?.title =
            currentIndex == images.count - 1 ? "Done" : "Next"

        title = "Crop \(currentIndex + 1) / \(images.count)"
    }

    // MARK: - Show Mantis Cropper

    private func showCropper() {

        // Remove previous cropVC if exists
        cropVC?.willMove(toParent: nil)
        cropVC?.view.removeFromSuperview()
        cropVC?.removeFromParent()

        var config = Mantis.Config()
        config.showAttachedCropToolbar = false

        let newCropVC = Mantis.cropViewController(
            image: images[currentIndex],
            config: config
        )

        newCropVC.delegate = self
        cropVC = newCropVC

        addChild(newCropVC)
        view.addSubview(newCropVC.view)
        newCropVC.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newCropVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newCropVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newCropVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newCropVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        newCropVC.didMove(toParent: self)
    }

    // MARK: - Actions

    @objc private func previousTapped() {

        guard currentIndex > 0 else { return }

        currentIndex -= 1
        updateNavState()
        showCropper()
    }

    @objc private func nextTapped() {

        cropVC?.crop()
    }
}

// MARK: - Mantis Delegate

extension CropViewControllerNew: CropViewControllerDelegate {

    func cropViewControllerDidCrop(
        _ cropViewController: CropViewController,
        cropped: UIImage,
        transformation: Transformation,
        cropInfo: CropInfo
    ) {

        croppedImages[currentIndex] = cropped

        if currentIndex < images.count - 1 {
            currentIndex += 1
            updateNavState()
            showCropper()
        } else {

            dismiss(animated: true) {
                self.onDone?(self.croppedImages)
            }
        }
    }

    func cropViewControllerDidCancel(
        _ cropViewController: CropViewController,
        original: UIImage
    ) {
        dismiss(animated: true)
    }
}



import SwiftUI
import AVFoundation
import UIKit

struct VideoPickerView: UIViewControllerRepresentable {

    var maxDuration: Double = 30
    var onFinished: (AVURLAsset) -> Void
    var onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.videoMaximumDuration = maxDuration
        picker.allowsEditing = true   // 🔥 Enables trimming UI
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject,
                       UINavigationControllerDelegate,
                       UIImagePickerControllerDelegate {

        let parent: VideoPickerView

        init(_ parent: VideoPickerView) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            parent.onCancel()
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            picker.dismiss(animated: true)

            guard let url = info[.mediaURL] as? URL else { return }

            let asset = AVURLAsset(url: url)
            let duration = CMTimeGetSeconds(asset.duration)

            print("Selected duration:", duration)

            if duration <= parent.maxDuration {
                parent.onFinished(asset)
            } else {
                print("❌ Video longer than 30 seconds")
                // You can show alert here
                
                AlertView.sharedManager.displayMessageWithAlert(title: "", msg: "Video longer than 30 seconds not supported.")
           
            }
        }
    }
}







struct TrimmerTimelineView: View {
    
    var thumbnails: [UIImage]
    var duration: Double
    
    @Binding var startTime: Double
    @Binding var endTime: Double
    
    var onSeek: (Double) -> Void
    
    @State private var totalWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            
            ZStack(alignment: .leading) {
                
                // 🔹 Thumbnails
                HStack(spacing: 2) {
                    ForEach(thumbnails.indices, id: \.self) { i in
                        Image(uiImage: thumbnails[i])
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: geo.size.width, height: 60)
                .clipped()
                
                // 🔹 Selection overlay
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: geo.size.width)
                
                // 🔹 Active area
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(
                        width: selectedWidth(geo),
                        height: 60
                    )
                    .offset(x: startOffset(geo))
                
                // 🔹 LEFT HANDLE
                handleView
                    .offset(x: startOffset(geo))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let percent = value.location.x / geo.size.width
                                let newTime = max(0, percent * duration)
                                
                                if newTime < endTime - 0.5 {
                                    startTime = newTime
                                    onSeek(startTime)
                                }
                            }
                    )
                
                // 🔹 RIGHT HANDLE
                handleView
                    .offset(x: endOffset(geo) - 20)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let percent = value.location.x / geo.size.width
                                let newTime = min(duration, percent * duration)
                                
                                if newTime > startTime + 0.5 {
                                    endTime = newTime
                                    onSeek(endTime)
                                }
                            }
                    )
            }
            .onAppear {
                totalWidth = geo.size.width
            }
        }
    }
    
    private var handleView: some View {
        Rectangle()
            .fill(Color.yellow)
            .frame(width: 20, height: 70)
            .cornerRadius(4)
    }
    
    private func startOffset(_ geo: GeometryProxy) -> CGFloat {
        CGFloat(startTime / duration) * geo.size.width
    }
    
    private func endOffset(_ geo: GeometryProxy) -> CGFloat {
        CGFloat(endTime / duration) * geo.size.width
    }
    
    private func selectedWidth(_ geo: GeometryProxy) -> CGFloat {
        endOffset(geo) - startOffset(geo)
    }
}



struct ProVideoTrimmerView: View {
    
    let url: URL
    var maxDuration: Double = 30
    var onFinished: (URL) -> Void
    var onCancel: () -> Void

    @State private var thumbnails: [UIImage] = []
    @State private var startTime: Double = 0
    @State private var endTime: Double = 0
    @State private var player = AVPlayer()
    
    //  NEW
    @State private var isCompressing = false
    @State private var progress: Double = 0
    @State private var exportSession: AVAssetExportSession?
  
    @State private var isLoading = true
    
    private var asset: AVAsset {
        AVURLAsset(url: url)
    }
    
    private var duration: Double {
        min(asset.duration.seconds, maxDuration)
    }
    
    var body: some View {
        ZStack {
            
            //  MAIN UI
            VStack(spacing: 20) {
                
                VideoPlayer(player: player)
                    .cornerRadius(12)
                    .padding()
                    .onAppear {
                        player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
                        player.pause()
                    }
                
                TrimmerTimelineView(
                    thumbnails: thumbnails,
                    duration: duration,
                    startTime: $startTime,
                    endTime: $endTime,
                    onSeek: { seekVideo($0) }
                )
                .frame(height: 80)
                .padding()
                Text("\(startTime, specifier: "%.1f")s - \(endTime, specifier: "%.1f")s").font(.inter(.regular, size: 15))
                    .padding()
                
                Spacer()

                Spacer()
                
                //  PROGRESS
                if isCompressing {
                    VStack(spacing: 6) {
                        
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .tint(.blue.opacity(0.7)) // softer color
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial) // blur behind
                            )
                            .frame(height: 3)
                            .animation(nil, value: progress)
                        
                        Text("Compressing Video...")
                            .font(.caption)
                            .foregroundColor(Color(.label))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                HStack {
                    
                    Button("Cancel") {
                        if isCompressing {
                            exportSession?.cancelExport()
                        }
                        onCancel()
                    }.font(.inter(.semiBold, size: 16))
                    .disabled(isCompressing)
                    
                    Spacer()
                    
                    Button("Choose") {
                        startCompression()
                    }.font(.inter(.semiBold, size: 16))
                    .disabled(isCompressing)
                }
                .frame(height: 50)
                .foregroundColor(.white)
                .font(.system(size: 18))
                .padding()
                .background(Color.black.opacity(0.6))
            }
            
            if isLoading {
                Color.black.opacity(0.9).ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Preparing video...")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            setup()
        }
    }
}

extension ProVideoTrimmerView {
    //  MAIN ENTRY
        private func startCompression() {
            isCompressing = true
            progress = 0
            
            compressVideo(
                asset: asset,
                startTime: startTime,
                endTime: endTime
            ) { url in
                
                isCompressing = false
                
                if let url {
                    onFinished(url)
                }
            }
        }
    
    func compressVideo(
        asset: AVAsset,
        startTime: Double,
        endTime: Double,
        completion: @escaping (URL?) -> Void
    ) {
        
        guard endTime > startTime else {
            completion(nil)
            return
        }
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mp4")
        
        try? FileManager.default.removeItem(at: outputURL)
        
        //  FAST preset (same behavior as UIImagePicker)
         let preset = AVAssetExportPresetMediumQuality
        
        
        guard let exporter = AVAssetExportSession(
            asset: asset,
            presetName: preset
        ) else {
            completion(nil)
            return
        }
        
        exportSession = exporter
        
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        let duration = CMTime(seconds: endTime - startTime, preferredTimescale: 600)
        exporter.timeRange = CMTimeRange(start: start, duration: duration)
        
        //  IMPORTANT: DO NOT USE videoComposition
        exporter.videoComposition = nil
        
        //  FAST progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            
            DispatchQueue.main.async {
                progress = Double(exporter.progress)
            }
            
            if exporter.progress >= 1.0 || exporter.status != .exporting {
                timer.invalidate()
            }
        }
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                
                switch exporter.status {
                case .completed:
                    completion(outputURL)
                    
                case .failed:
                    print("❌ Export failed:", exporter.error?.localizedDescription ?? "")
                    completion(nil)
                    
                case .cancelled:
                    completion(nil)
                    
                default:
                    completion(nil)
                }
            }
        }
    }
}

extension ProVideoTrimmerView {
    
    private func setup() {
        startTime = 0
        endTime = duration
        
        generateThumbs()
    }
    
    private func seekVideo(_ time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func generateThumbs() {
        DispatchQueue.global().async {
            let imgs = generateThumbnails(asset: asset, count: 12)
            
            DispatchQueue.main.async {
                self.thumbnails = imgs
                self.isLoading = false
            }
        }
    }
    
    private func trimVideo() {
        trimVideo(asset: asset, startTime: startTime, endTime: endTime) { url in
            if let url {
                onFinished(url)
            }
        }
    }
    

    func generateThumbnails(asset: AVAsset, count: Int) -> [UIImage] {
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 200, height: 200) // performance
        
        let duration = max(asset.duration.seconds, 1)
        let interval = duration / Double(count)
        
        var images: [UIImage] = []
        
        for i in 0..<count {
            let time = CMTime(seconds: Double(i) * interval, preferredTimescale: 600)
            
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                images.append(UIImage(cgImage: cgImage))
            } catch {
                print("Thumbnail error:", error.localizedDescription)
            }
        }
        
        return images
    }

    func trimVideo(
        asset: AVAsset,
        startTime: Double,
        endTime: Double,
        completion: @escaping (URL?) -> Void
    ) {
        
        // 🔒 Safety check (prevents crash)
        guard endTime > startTime else {
            completion(nil)
            return
        }
        
        // 📁 Output URL
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mp4")
        
        // 🧹 Remove if already exists
        try? FileManager.default.removeItem(at: outputURL)
        
        // 🎬 Export session
        guard let exporter = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            completion(nil)
            return
        }
        
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        // ⏱ Time range
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        let duration = CMTime(seconds: endTime - startTime, preferredTimescale: 600)
        
        exporter.timeRange = CMTimeRange(start: start, duration: duration)
        
        // 🚀 Export
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                switch exporter.status {
                case .completed:
                    print("✅ Trim success:", outputURL)
                    completion(outputURL)
                    
                case .failed:
                    print("❌ Trim failed:", exporter.error?.localizedDescription ?? "")
                    completion(nil)
                    
                case .cancelled:
                    print("⚠️ Trim cancelled")
                    completion(nil)
                    
                default:
                    completion(nil)
                }
            }
        }
    }
    
}

struct VideoPickerPHPicker: UIViewControllerRepresentable {
    
    var onVideoPicked: (URL) -> Void
    var onCancel: () -> Void
    @Binding var isLoading: Bool   //  ADD THIS

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        let parent: VideoPickerPHPicker
        
        init(_ parent: VideoPickerPHPicker) {
            self.parent = parent
        }
        
 
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // User tapped cancel
            if results.isEmpty {
                print("User cancelled picker")
                DispatchQueue.main.async {
                    self.parent.onCancel()
                    // picker.dismiss(animated: true)
                }
                return
            }
            
            guard let item = results.first?.itemProvider,
                  item.hasItemConformingToTypeIdentifier("public.movie") else {
                // picker.dismiss(animated: true)
                return
            }
            
            // START LOADING
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
            
            item.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                defer {
                    DispatchQueue.main.async {
                        self.parent.isLoading = false   //  STOP LOADING
                    }
                }
                guard let url else {
                    // picker.dismiss(animated: true)
                    return }
                
                // Copy to temp (IMPORTANT)
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".mov")
                
                try? FileManager.default.copyItem(at: url, to: tempURL)
                
                DispatchQueue.main.async {
                    self.parent.onVideoPicked(tempURL)
                    // picker.dismiss(animated: true)
                }
            }
        }
    }
}


//===

struct ImageCropper: View {

    var originalImage: UIImage
    var onCrop: (UIImage) -> Void

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {

        GeometryReader { geo in

            ZStack {

                Color.black

                Image(uiImage: originalImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                },
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )

                Rectangle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geo.size.width * 0.8,
                           height: geo.size.width * 0.8)
            }
            .onDisappear {
                let cropped = cropImage(size: geo.size)
                onCrop(cropped)
            }
        }
    }

    private func cropImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: originalImage.size)
        return renderer.image { _ in
            originalImage.draw(in: CGRect(origin: .zero,
                                           size: originalImage.size))
        }
    }
}
