//
//  ImagePreview.swift
//  Dawai
//
//  Created by Rohit Bisht on 03/08/19.
//  Copyright © 2019 Shambhoo. All rights reserved.
//

import UIKit


class EmptyList: UIView {
    
    var selectedImage = String()
    var btnClose:UIButton?
    var imageView:UIImageView?
    var bgView:UIView?
    var lblMsg:UILabel?
    var subHeadline:UILabel?


    override init(frame: CGRect) {
        
        super.init(frame:frame)
        self.backgroundColor = UIColor.clear
        
        bgView = UIView(frame: CGRect(x: 0, y:0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(bgView!)
        bgView?.backgroundColor = .clear //.systemBackground
        
        imageView = UIImageView(frame: CGRect(x:(bgView?.frame.size.width)!/2.0 - 85, y: (bgView?.frame.size.height)!/2.0 - 150, width: 170, height: 170))
        bgView?.addSubview(imageView!)
        imageView?.contentMode = .scaleAspectFill
        
        lblMsg = UILabel(frame: CGRect(x:  10, y: (imageView?.frame.origin.y)! + (imageView?.frame.size.height)! + 0, width: (bgView?.frame.size.width)! - 20, height: 30))
        lblMsg?.numberOfLines = 0
        lblMsg?.textColor = .orange
        lblMsg?.font = UIFont.Manrope.medium(size: 16.0).font
        bgView?.addSubview(lblMsg!)
        lblMsg?.textAlignment = .center
        
        subHeadline = UILabel(frame: CGRect(x:  10, y: (lblMsg?.frame.origin.y)! + (lblMsg?.frame.size.height)! + 0, width: (bgView?.frame.size.width)! - 20, height: 50))
        subHeadline?.numberOfLines = 0
        bgView?.addSubview(subHeadline!)
        subHeadline?.textAlignment = .center
        subHeadline?.textColor = .black
        subHeadline?.font = UIFont.Manrope.regular(size: 16.0).font
        subHeadline?.text = ""
    }
    
    
    func setImage(imageStr:String) -> Void {
        
        imageView?.image = UIImage(named:imageStr)

    }
    func setMsg(msg:String) -> Void {
        
        lblMsg?.text = msg as String
        
    }
    
    func setSubHeadlineMsg(msg:String) -> Void {
        
        subHeadline?.text = msg as String
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   

}
