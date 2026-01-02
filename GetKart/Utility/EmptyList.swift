//
//  ImagePreview.swift
//  Dawai
//
//  Created by Rohit Bisht on 03/08/19.
//  Copyright © 2019 Shambhoo. All rights reserved.
//

import UIKit
import SwiftUICore


protocol EmptyListDelegate{
    func navigationButtonClicked()
}

extension EmptyListDelegate{
    func navigationButtonClicked(){
        
    }
}
class EmptyList: UIView {
    
    var selectedImage = String()
    var btnClose:UIButton?
    var imageView:UIImageView?
    var bgView:UIView?
    var lblMsg:UILabel?
    var subHeadline:UILabel?
    var btnNavigation:UIButton?
    var delegate:EmptyListDelegate?


    override init(frame: CGRect) {
        
        super.init(frame:frame)
        self.backgroundColor = UIColor.clear
        
        bgView = UIView(frame: CGRect(x: 0, y:0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(bgView!)
        bgView?.backgroundColor = .clear //.systemBackground
        
        imageView = UIImageView(frame: CGRect(x:(bgView?.frame.size.width)!/2.0 - 85, y: (bgView?.frame.size.height)!/2.0 - 180, width: 170, height: 170))
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
        subHeadline?.textColor = .label
        subHeadline?.font = UIFont.Manrope.regular(size: 16.0).font
        subHeadline?.text = ""
        
        //Button
        btnNavigation = UIButton(frame:  CGRect(x:(bgView?.frame.size.width)!/2.0 - 100, y: (subHeadline?.frame.origin.y)! + (subHeadline?.frame.size.height)! + 10, width: 200, height: 45))
        btnNavigation?.layer.cornerRadius = 1.0
        btnNavigation?.clipsToBounds = true
        btnNavigation?.backgroundColor = UIColor.systemOrange
        btnNavigation?.setTitleColor(.white, for: .normal)
        btnNavigation?.titleLabel?.font =  UIFont.Manrope.semiBold(size: 16).font
        btnNavigation?.addTarget(self, action: #selector(clickedBtn), for: .touchUpInside)
        bgView?.addSubview(btnNavigation!)
        btnNavigation?.isHidden = true

    }
    
    @objc func clickedBtn(){
        self.delegate?.navigationButtonClicked()
    }
    func setImage(imageStr:String) -> Void {
        
        imageView?.image = UIImage(named:imageStr)

    }
    
    func setTitleToBUtton(strTitle:String) -> Void {
        btnNavigation?.setTitle(strTitle, for: .normal)
        btnNavigation?.isHidden = false
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
