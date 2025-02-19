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

    override init(frame: CGRect) {
        
        super.init(frame:frame)
        self.backgroundColor = UIColor.clear
        
        bgView = UIView(frame: CGRect(x: 0, y:0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(bgView!)
        bgView?.backgroundColor = .clear //.systemBackground
        
        
        imageView = UIImageView(frame: CGRect(x:(bgView?.frame.size.width)!/2.0 - 50, y: (bgView?.frame.size.height)!/2.0 - 75, width: 100, height: 100))
        bgView?.addSubview(imageView!)
        imageView?.contentMode = .scaleAspectFit
        
        lblMsg = UILabel(frame: CGRect(x:  10, y: (imageView?.frame.origin.y)! + (imageView?.frame.size.height)! + 0, width: (bgView?.frame.size.width)! - 20, height: 30))
        
       // lblMsg = UILabel(frame: CGRect(x:  10, y: (imageView?.frame.origin.y)! + (imageView?.frame.size.height)! + 0, width:  self.frame.size.width - 20, height: 50))
        lblMsg?.numberOfLines = 0
        bgView?.addSubview(lblMsg!)
        lblMsg?.textAlignment = .center
    }
    
    
    func setImage(imageStr:String) -> Void {
        
        imageView?.image = UIImage(named:imageStr)

    }
    func setMsg(msg:String) -> Void {
        
        lblMsg?.text = msg as String
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   

}
