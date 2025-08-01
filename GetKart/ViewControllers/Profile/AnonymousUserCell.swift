//
//  AnonymousUserCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit

class AnonymousUserCell: UITableViewCell {

    @IBOutlet weak var bgViewAnonymousUser:UIView!
    @IBOutlet weak var btnLogin:UIButton!

    
    @IBOutlet weak var bgViewLoggedInUser:UIView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblEmail:UILabel!
    @IBOutlet weak var btnPencil:UIButton!
    @IBOutlet weak var imgVwProfile:UIImageView!
    @IBOutlet weak var btnGetVerifiedBadge:UIButton!
        
    @IBOutlet weak var btnResubmit:UIButton!
    @IBOutlet weak var lblStatus:UILabel!
    @IBOutlet weak var bgViewVerified:UIView!

    @IBOutlet weak var btnSetting:UIButton!
    @IBOutlet weak var btnEditProfile:UIButton!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnResubmit.layer.cornerRadius = 5.0
        btnResubmit.clipsToBounds = true
        
        lblStatus.layer.cornerRadius = 5.0
        lblStatus.clipsToBounds = true
        
        btnGetVerifiedBadge.layer.cornerRadius = 5.0
        btnGetVerifiedBadge.clipsToBounds = true
        
        btnSetting.layer.cornerRadius = btnSetting.frame.size.height/2.0
        btnSetting.clipsToBounds = true
        btnSetting.backgroundColor = Themes.sharedInstance.themeColor.withAlphaComponent(0.2)
        
        imgVwProfile.layer.cornerRadius = imgVwProfile.frame.size.height/2.0
        imgVwProfile.clipsToBounds = true
        
        btnPencil.layer.cornerRadius = btnPencil.frame.size.height/2.0
        btnPencil.layer.borderColor = UIColor.white.cgColor
        btnPencil.layer.borderWidth = 1.0
        btnPencil.clipsToBounds = true
        
        btnLogin.layer.cornerRadius = 10
        btnLogin.layer.borderColor = UIColor.lightGray.cgColor
        btnLogin.layer.borderWidth = 1.0
        btnLogin.clipsToBounds = true
        
        
        bgViewVerified.layer.cornerRadius = 5
        bgViewVerified.backgroundColor = Themes.sharedInstance.themeColor
        btnLogin.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
