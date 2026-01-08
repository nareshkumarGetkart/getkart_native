//
//  ImageCropperView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 30/07/25.
//

import SwiftUI
import Mantis

struct ImageCropperView: UIViewControllerRepresentable {
    var image: UIImage
    var cropAspectRatio: CGSize
    var onCropped: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CropViewController {
        var config = Mantis.Config()
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: cropAspectRatio.width / cropAspectRatio.height)

        let cropViewController = Mantis.cropViewController(image: image, config: config)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}

    class Coordinator: NSObject, CropViewControllerDelegate {
        func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
            cropViewController.dismiss(animated: false) {
                self.parent.onCropped(cropped)
            }
            
        }
        
        var parent: ImageCropperView

        init(_ parent: ImageCropperView) {
            self.parent = parent
        }

        func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
            cropViewController.dismiss(animated: false) {
                self.parent.onCropped(cropped)
            }
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            cropViewController.dismiss(animated: false)
        }
    }
}




/*
struct ImageCropperBoardView: UIViewControllerRepresentable {

    var image: UIImage
    var onCropped: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CropViewController {

        var config = Mantis.Config()
        config.presetFixedRatioType = .canUseMultiplePresetFixedRatio()
        config.showAttachedCropToolbar = false

        let cropVC = Mantis.cropViewController(image: image, config: config)
        cropVC.delegate = context.coordinator
        return cropVC
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}

    class Coordinator: NSObject, CropViewControllerDelegate {

        let parent: ImageCropperBoardView

        init(_ parent: ImageCropperBoardView) {
            self.parent = parent
        }

        func cropViewControllerDidCrop(
            _ cropViewController: CropViewController,
            cropped: UIImage,
            transformation: Transformation,
            cropInfo: CropInfo
        ) {
            cropViewController.dismiss(animated: true) {
                self.parent.onCropped(cropped)
            }
        }

        func cropViewControllerDidCancel(
            _ cropViewController: CropViewController,
            original: UIImage
        ) {
            cropViewController.dismiss(animated: true)
        }
    }
}

*/

struct ImageCropperBoardView: UIViewControllerRepresentable {

    let image: UIImage
    let onCropped: (UIImage) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {

        var config = Mantis.Config()

        // ❌ Hide default toolbar
        config.showAttachedCropToolbar = false

        // ✅ Free hand crop
        // (DO NOT set presetFixedRatioType)

        let cropVC = Mantis.cropViewController(image: image, config: config)
        cropVC.delegate = context.coordinator

        let container = UIViewController()
        container.view.backgroundColor = .black

        container.addChild(cropVC)
        container.view.addSubview(cropVC.view)
        cropVC.didMove(toParent: container)

        cropVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cropVC.view.topAnchor.constraint(equalTo: container.view.topAnchor),
            cropVC.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            cropVC.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            cropVC.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor, constant: -80)
        ])

        // 🔥 Custom Bottom Bar
        let bottomBar = CropBottomBar(
            onCancel: {
                self.onCancel()
            },
            onDone: {
                context.coordinator.crop()
            }
        )

        let hosting = UIHostingController(rootView: bottomBar)
        container.addChild(hosting)
        container.view.addSubview(hosting.view)
        hosting.didMove(toParent: container)

        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
            hosting.view.heightAnchor.constraint(equalToConstant: 80)
        ])

        context.coordinator.cropVC = cropVC

        return container
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    // MARK: - Coordinator
    class Coordinator: NSObject, CropViewControllerDelegate {

        var parent: ImageCropperBoardView
        weak var cropVC: CropViewController?

        init(_ parent: ImageCropperBoardView) {
            self.parent = parent
        }

        func crop() {
            cropVC?.crop()
        }

        func cropViewControllerDidCrop(
            _ cropViewController: CropViewController,
            cropped: UIImage,
            transformation: Transformation,
            cropInfo: CropInfo
        ) {
            parent.onCropped(cropped)
        }

        func cropViewControllerDidCancel(
            _ cropViewController: CropViewController,
            original: UIImage
        ) {
            parent.onCancel()
        }
    }
}



struct CropBottomBar: View {

    let onCancel: () -> Void
    let onDone: () -> Void

    var body: some View {
        HStack {
            Button("Cancel") {
                onCancel()
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .medium))

            Spacer()

            Button("Done") {
                onDone()
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .bold))
        }
        .padding(.horizontal, 24)
        .frame(height: 80)
        .background(Color.black.opacity(0.9))
    }
}
