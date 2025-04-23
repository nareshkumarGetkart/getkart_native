//
//  AlertView.swift
//  Bitrus App
//
//  Created by Rohit Bisht on 31/05/19.
//  Copyright © 2019 Radheshyam Yadav. All rights reserved.
//

import UIKit

typealias alertCompletionBlock = (String?, NSInteger?) -> ()

class AlertView: NSObject {
    static var sharedManager = AlertView()
    var isAlertViewShowing = false
    func presentAlertWith(title : NSString, msg: NSString, buttonTitles:NSArray, onController:UIViewController, tintColor:UIColor = .systemBlue, dismissBlock:@escaping alertCompletionBlock) {
        
        if msg.isKind(of: NSString.self  as AnyClass) {
            
            let buttonTitle = buttonTitles.firstObject
            
            if (buttonTitle == nil) {
                return
            }
            let alertController = UIAlertController.init(title: title as String, message: msg as String, preferredStyle:.alert)
            alertController.view.tintColor = tintColor
            for index in 0..<buttonTitles.count  {
                let alertAction = UIAlertAction.init(title: buttonTitles.object(at: index) as? String, style:.default) { (action) in
                    dismissBlock(action.title,index)
                }
                alertController.addAction(alertAction)
            }
            onController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func displayMessage(title : String, msg : String, controller : UIViewController) -> Void {
        
        presentAlertWith(title: title as NSString, msg: msg as NSString, buttonTitles: ["OK"], onController: controller) { (selectedStr, index) in
            
        }
    }
    
    func displayMessageWithAlert(title : String, msg : String) -> Void {
        
        if isAlertViewShowing == false{
            //            let alert = UIAlertView(title: title, message: msg, delegate: self, cancelButtonTitle: "Ok")
            //            alert.show()
            isAlertViewShowing = true
            
            if let controller = AppDelegate.sharedInstance.navigationController?.topViewController{
                presentAlertWith(title: title as NSString, msg: msg as NSString, buttonTitles: ["OK"], onController:controller ) { (selectedStr, index) in
                    self.isAlertViewShowing = false
                }
            }
        }
    }
    
    func showToast(message : String, font: UIFont = UIFont.Manrope.regular(size: 14).font) {

        if let controller = AppDelegate.sharedInstance.navigationController?.topViewController{
            let toastLabel = UILabel(frame: CGRect(x: 50, y: controller.view.frame.size.height - 150, width: controller.view.frame.size.width - 100, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
            controller.view.addSubview(toastLabel)
            UIView.animate(withDuration: 4.0, delay: 0.8, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
    
}


extension AlertView:UIAlertViewDelegate{
    
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        self.isAlertViewShowing = false
    }
    
}
