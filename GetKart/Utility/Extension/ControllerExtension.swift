//
//  ControllerExtension.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 09/10/24.
//

import Foundation
import UIKit


var vSpinner : UIView?

extension UIViewController {
    
    var getNavBarHt:CGFloat  {
        return   UIApplication.shared.statusBarFrame.size.height +
        (self.navigationController?.navigationBar.frame.height ?? 0.0) + 5
        
    }
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}


import UIKit
import ObjectiveC
import SwiftUI

extension UIHostingController {
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass))
            .appending("_IgnoreSafeArea")
        
        // Reuse if already created
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
            return
        }
        
        guard let viewSubclass = objc_allocateClassPair(viewClass, viewSubclassName, 0) else { return }
        
        if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
            let block: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in .zero }
            class_addMethod(
                viewSubclass,
                #selector(getter: UIView.safeAreaInsets),
                imp_implementationWithBlock(block),
                method_getTypeEncoding(method)
            )
        }
        
        objc_registerClassPair(viewSubclass)
        object_setClass(view, viewSubclass)
    }
}
