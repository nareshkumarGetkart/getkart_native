//
//  ImageExtension.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 09/10/24.
//

import Foundation
import UIKit


extension UIImageView {
   
    func addBlurrEffect(intensity:Int=5) {
        let blurEffectView = TSBlurEffectView() // creating a blur effect view
        blurEffectView.intensity = Double(intensity) // setting blur intensity from 0.1 to 10
        self.addSubview(blurEffectView) // adding blur effect view as a subview to your view in which you want to use
    }
    
   
    func removeBlurEffect() {
        for subview in self.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
                break
            }
        }
    }
}
