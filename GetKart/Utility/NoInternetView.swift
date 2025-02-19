//
//  NoInternetView.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 13/02/25.
//

import Foundation
import UIKit

class NoInternetView:UIView {
    
    var lblTitle = UILabel()
    var lblDescription = UILabel()
    var imageView = UIImageView()
    var bgView = UIView()
    
    var imageViewBg = UIImageView()

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.clear
        
        bgView.frame =  CGRect(x: 0, y:0, width: self.frame.size.width, height: self.frame.size.height)
        self.addSubview(bgView)
        bgView.backgroundColor =  .clear //.systemBackground
        
        
        imageViewBg.frame =  CGRect(x: 0, y:0, width: bgView.frame.width, height: bgView.frame.height)
        bgView.addSubview(imageViewBg)
        imageViewBg.image = UIImage(named: "Background")
        imageViewBg.contentMode = .scaleToFill
        
        imageView.frame =  CGRect(x:(bgView.frame.size.width)/2.0 - 75, y: (bgView.frame.size.height)/2.0 - 130, width: 150, height: 150)
        bgView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        
      //  lblTitle .frame =  CGRect(x: 40, y: (imageView.frame.origin.y) + (imageView.frame.size.height) + 0, width: (bgView.frame.size.width) - 80, height: 25)
        lblTitle.numberOfLines = 0
        bgView.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.font = UIFont.Manrope.semiBold(size: 16.0).font
        lblTitle.text = "No Internet Connection"
        
       // lblDescription .frame =  CGRect(x: 40, y: (lblTitle.frame.origin.y) + (lblTitle.frame.size.height) + 0, width: (bgView.frame.size.width) - 80, height: 50)
        lblDescription.numberOfLines = 0
        bgView.addSubview(lblDescription)
        
        lblDescription.textAlignment = .center
        lblDescription.font = UIFont.Manrope.regular(size: 12.0).font
        lblDescription.text = "Please check your connection to continue exploring!"
        updateLabelHeights()

    }
    
    
    func setGIfImage(gif:String = "noInternetConnection"){
        do{
            //try  self.imageView.setGifImage(UIImage(gifName: gif), loopCount: -1)
            self.imageView.startAnimating()

        }catch{
            
        }
        
    }
    
    func updateLabelHeights(){
        
        let htTitle = String(lblTitle.text ?? "").stringHeightWithFontSize(16.0, width: lblTitle.frame.width,textFont:UIFont.Manrope.semiBold(size: 16.0).font)
        
        let htDesc = String(lblDescription.text ?? "").stringHeightWithFontSize(12.0, width: lblDescription.frame.width,textFont: UIFont.Manrope.regular(size: 12.0).font)
        
        lblTitle .frame =  CGRect(x: 40, y: (imageView.frame.origin.y) + (imageView.frame.size.height) + 0, width: (bgView.frame.size.width) - 80, height: htTitle)
        
        lblDescription .frame =  CGRect(x: 40, y: (lblTitle.frame.origin.y) + (lblTitle.frame.size.height) + 10, width: (bgView.frame.size.width) - 80, height: htDesc)
    }
    
    
    func setTitle(title:String){
        lblTitle.text = title
        updateLabelHeights()
    }
    
    func setDescription(desc:String){
        lblDescription.text = desc
        updateLabelHeights()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


