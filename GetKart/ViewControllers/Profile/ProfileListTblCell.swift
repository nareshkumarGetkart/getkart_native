//
//  ProfileListTblCell.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit

class ProfileListTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var imgVwArrow:UIImageView!
    @IBOutlet weak var imgVwIcon:UIImageView!
    @IBOutlet weak var bgview:UIView!
    @IBOutlet weak var btnSwitch:UISwitch!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var bgviewIcon:UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgview.layer.cornerRadius = 8.0
        bgview.clipsToBounds = true
        lblSubTitle.isHidden = true
        
        let savedTheme = UserDefaults.standard.string(forKey: LocalKeys.appTheme.rawValue) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: savedTheme) ?? .system
        
        if theme == .dark{
            self.bgviewIcon.backgroundColor = UIColor(hexString: "#342b1e")

        }else{
            self.bgviewIcon.backgroundColor = UIColor(hexString: "#FFF7EA")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
