//
//  RewardWalletPopup.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 13/07/26.
//

import SwiftUI
import Kingfisher
struct RewardWalletPopup: View {
    
    let objPopup: PopupModel
    let buttonAction: () -> Void
    let closeAction: () -> Void
    @State private var imageAspectRatio: CGFloat = 1
    // @State private var backgroundColor = Color.white
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                
                VStack(spacing: 0) {
                    
                    ZStack(alignment: .topTrailing) {
                        
                        KFImage(URL(string: objPopup.image ?? ""))
                            .onSuccess { result in
                                
                                // Extract background color
                                /* if let color = result.image.averageBgViewColor {
                                 withAnimation(.easeInOut(duration: 0.25)) {
                                 backgroundColor = Color(color)
                                 }
                                 }*/
                            }
                            .placeholder {
                                ProgressView()
                                    .frame(height: 250)
                            }
                            .onFailure { _ in
                                // Optional: handle failure
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(
                                GeometryReader { imgGeo in
                                    Color.clear
                                        .onAppear {
                                            imageAspectRatio = imgGeo.size.height / imgGeo.size.width
                                        }
                                }
                            )
                        
                        Button(action: closeAction) {
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .padding(7)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(12)
                    }
                    
                    Button(action: buttonAction) {
                        
                        Text(objPopup.buttonTitle ?? "Got it")
                            .font(.inter(.medium,size: 16.0))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#0052F9"), Color(hex:"#02D6FB")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                    }
                    .padding()
                }
                .background(Color(hex:"#FBFCFE"))
                .cornerRadius(15)
                .frame(
                    width: geo.size.width * 0.84
                )
                .shadow(radius: 15)
                .position(
                    x: geo.size.width / 2,
                    y: geo.size.height / 2
                )
            }
        }
    }
}

//#Preview {
//    RewardWalletPopup(objPopup: <#PopupModel#>, imageURL: "", buttonTitle: "Got it", buttonAction: {}, closeAction: {})
//}


import UIKit
import CoreImage

extension UIImage {

    var averageBgViewColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let extent = inputImage.extent
        let filter = CIFilter(name: "CIAreaAverage")!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)

        guard
            let outputImage = filter.outputImage
        else {
            return nil
        }

        var bitmap = [UInt8](repeating: 0, count: 4)

        let context = CIContext()

        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1
        )
    }
}
