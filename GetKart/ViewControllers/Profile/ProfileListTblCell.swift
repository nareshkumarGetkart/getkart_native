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

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgview.layer.cornerRadius = 8.0
        bgview.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
