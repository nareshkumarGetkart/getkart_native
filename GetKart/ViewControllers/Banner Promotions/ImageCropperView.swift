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
