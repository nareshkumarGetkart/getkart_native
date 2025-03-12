//
//  CustomImageView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 07/03/25.
//



import SwiftUI
import SVGKit


struct SVGImageView: UIViewRepresentable {
    let url: URL?

    class Coordinator {
        var imageView: SVGKFastImageView?
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> SVGKFastImageView {
        let placeholderImage = SVGKImage() // Placeholder SVG
        let svgView = SVGKFastImageView(svgkImage: placeholderImage)
        context.coordinator.imageView = svgView
        loadSVGImage(into: svgView ?? SVGKFastImageView(svgkImage: placeholderImage))
        return svgView ?? SVGKFastImageView(svgkImage: placeholderImage)
    }

    func updateUIView(_ svgView: SVGKFastImageView, context: Context) {
        loadSVGImage(into: svgView)
    }

    private func loadSVGImage(into imageView: SVGKFastImageView) {
        DispatchQueue.global(qos: .background).async {
            if let urll = url {
                if let data = try? Data(contentsOf: urll),
                   let svgImage = SVGKImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = svgImage
                    }
                } else {
                    print("Failed to load SVG image from URL: \(url)")
                }
            }
        }
    }
}
