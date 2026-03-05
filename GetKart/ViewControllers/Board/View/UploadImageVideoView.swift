//
//  UploadImageVideoView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 10/02/26.
//

import SwiftUI
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
  //  @State private var videoSelected: AVURLAsset? = nil

    //  FIXED — use identifiable config instead of showPicker bool
    @State private var pickerConfig: PickerConfig?

    private var currentSelectionLimit: Int {
        switch selectionType {
        case .product:
            return 5
        case .promoteBusiness:
            return 1
        }
    }

    var body: some View {

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

        // Bottom Sheet
        .sheet(isPresented: $showSheet) {

            UploadBottomSheet { type in

                showSheet = false

                switch type {
                case .video:
                    print("Video tapped")
                    self.showVideoSheet = true
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
        .fullScreenCover(isPresented:  $showVideoSheet, content: {
          
            VideoPickerView(maxDuration: 30) { assets in
                //videoSelected = assets
                self.pushToPromotionalVideoView(asset: assets)
                showVideoSheet = false

            } onCancel: {
                showVideoSheet = false

            }

        })
    
      
        // Cropper
        .fullScreenCover(item: $cropWrapper) { wrapper in

//            if selectionType == .promoteBusiness {

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




//==

import SwiftUI
import PhotosUI
import AVFoundation

struct VideoPicker: UIViewControllerRepresentable {
    
    var onPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let item = results.first?.itemProvider,
                  item.hasItemConformingToTypeIdentifier("public.movie") else { return }
            
            item.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, _ in
                guard let url else { return }
                
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".mov")
                
                try? FileManager.default.copyItem(at: url, to: tempURL)
                
                DispatchQueue.main.async {
                    self.parent.onPicked(tempURL)
                }
            }
        }
    }
}

func generateThumbnails(asset: AVAsset, count: Int) -> [UIImage] {
    
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    
    let duration = CMTimeGetSeconds(asset.duration)
    let interval = duration / Double(count)
    
    var images: [UIImage] = []
    
    for i in 0..<count {
        let time = CMTime(seconds: Double(i) * interval, preferredTimescale: 600)
        if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
            images.append(UIImage(cgImage: cgImage))
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
    let outputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString + ".mov")
    
    guard let exporter = AVAssetExportSession(
        asset: asset,
        presetName: AVAssetExportPresetHighestQuality
    ) else {
        completion(nil)
        return
    }
    
    exporter.outputURL = outputURL
    exporter.outputFileType = .mov
    
    let start = CMTime(seconds: startTime, preferredTimescale: 600)
    let duration = CMTime(seconds: endTime - startTime, preferredTimescale: 600)
    exporter.timeRange = CMTimeRange(start: start, duration: duration)
    
    exporter.exportAsynchronously {
        DispatchQueue.main.async {
            completion(exporter.status == .completed ? outputURL : nil)
        }
    }
}

struct VideoTrimmerView: View {
    
    let url: URL
    var maxDuration: Double = 30
    var onFinished: (AVURLAsset) -> Void
    
    @State private var thumbnails: [UIImage] = []
    @State private var startTime: Double = 0
    @State private var endTime: Double = 0
    
    private var asset: AVAsset {
        AVURLAsset(url: url)
    }
    
    var body: some View {
        VStack {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(thumbnails.indices, id: \.self) { i in
                        Image(uiImage: thumbnails[i])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipped()
                    }
                }
            }
            
            VStack {
                Text("Start: \(startTime, specifier: "%.1f")s")
                Slider(value: $startTime,
                       in: 0...(endTime - 1))
            }
            
            VStack {
                Text("End: \(endTime, specifier: "%.1f")s")
                Slider(value: $endTime,
                       in: (startTime + 1)...min(asset.duration.seconds, maxDuration))
            }
            
            Button("Trim Video") {
                trimVideo(asset: asset,
                          startTime: startTime,
                          endTime: endTime) { url in
                    if let url {
                        onFinished(AVURLAsset(url: url))
                    }
                }
            }
            .padding()
        }
        .onAppear {
            endTime = min(asset.duration.seconds, maxDuration)
            thumbnails = generateThumbnails(asset: asset, count: 10)
        }
    }
}
