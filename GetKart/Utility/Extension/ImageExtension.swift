//
//  ImageExtension.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 09/10/24.
//

import Foundation
import UIKit
import SVGKit

 let imageCache = NSCache<AnyObject, UIImage>()
extension UIImageView {
    
     func loadSVGImagefromURL(strurl: String, placeHolderImage:String) {
        
        self.image = UIImage(named: placeHolderImage)

        if let cachedImage = imageCache.object(forKey: strurl as AnyObject)
        {
            debugPrint("image loaded from cache for =\(strurl)")
            self.image = cachedImage
            return
        }
        
        if let url = URL(string:strurl) {
            if url.pathExtension == "svg"{
                DispatchQueue.global(qos: .background).async {
                    
                        if let data = try? Data(contentsOf: url),
                           let svgImage = SVGKImage(data: data) {
                            DispatchQueue.main.async {
                                self.image = svgImage.uiImage
                            }
                            imageCache.setObject(svgImage.uiImage, forKey: strurl as AnyObject)
                        } else {
                            print("Failed to load SVG image from URL: \(url)")
                        }
                    
                }
            }else {
                self.kf.setImage(with:  URL(string: strurl) , placeholder:UIImage(named: placeHolderImage))
            }
        }
    }
}
