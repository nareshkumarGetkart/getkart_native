//
//  Themes.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 26/08/24.
//

import UIKit
import MMMaterialDesignSpinner

enum LoaderPosition:Int{
    case mid = 0
    case top
    case bottom
}

final class Themes: NSObject {
  
    static let sharedInstance = Themes()
     
     private override init(){
         
     }
     var is_CHAT_NEW_SEND_OR_RECIEVE_SELLER = true
     var is_CHAT_NEW_SEND_OR_RECIEVE_BUYER = true

     var isLikeSwipePopUp = 0
     let themeColor = UIColor(hexString: "#FF9900")
     var spinnerView:MMMaterialDesignSpinner!
     var spinner:UIView!
     var progressView : UIView!
     
     func activityView(uiView:UIView, isUserInteractionenabled : Bool = false ){
         if spinner == nil {
             spinner = UIView()
         }
         spinner.frame = CGRect(x: uiView.center.x - 30, y: uiView.center.y - 30, width: 60, height: 60)
         spinner.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 237/255, alpha: 1.0);
         spinner.layer.masksToBounds = true
         spinner.layer.cornerRadius = spinner.frame.width / 2
         if spinnerView == nil {
             spinnerView = MMMaterialDesignSpinner()
         }
         spinnerView.frame=CGRect(x: 2.5, y: 2.5, width: 55, height: 55)
         spinnerView.lineWidth = 2.5;
         spinnerView.tintColor = UIColor(red: 90/255, green: 88/255, blue: 85/255, alpha: 1.0);
         spinnerView.startAnimating()
         spinner.addSubview(spinnerView)
         uiView.isUserInteractionEnabled = isUserInteractionenabled
         uiView.addSubview(spinner)
     }
     
    func showActivityViewTop(uiView:UIView, position:LoaderPosition = LoaderPosition.mid){
        if spinner == nil {
            spinner = UIView()
        }
        
        if spinnerView == nil {
            spinnerView = MMMaterialDesignSpinner()
        }
        
         spinner.frame = CGRect(x: uiView.center.x - 25, y: uiView.center.y +  uiView.center.y/2 + 25, width: 50, height: 50)
         spinner.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 237/255, alpha: 1.0);
        spinner.layer.cornerRadius = spinner.frame.width / 2

         if position == .top {
             spinner.frame = CGRect(x: uiView.center.x - 25, y: uiView.center.y/2.0 - 25, width: 50, height: 50)
         }else if position == .bottom {
             spinner.frame = CGRect(x: uiView.center.x - 25, y: uiView.frame.size.height - 150, width: 50, height: 50)
         }
        
         spinner.layer.masksToBounds = true
         spinner.layer.cornerRadius = spinner.frame.width / 2
         spinnerView.frame=CGRect(x: 2.5, y: 2.5, width: 45, height: 45)
         spinnerView.lineWidth = 2.5;
         spinnerView.tintColor = UIColor(red: 90/255, green: 88/255, blue: 85/255, alpha: 1.0);
         spinnerView.startAnimating()
         spinner.addSubview(spinnerView)
         uiView.isUserInteractionEnabled = true
         uiView.addSubview(spinner)
     }
     
     func removeActivityView(uiView:UIView){
         spinnerView.stopAnimating()
         spinnerView.removeFromSuperview()
         spinner.removeFromSuperview()
         uiView.isUserInteractionEnabled = true
     }

}
