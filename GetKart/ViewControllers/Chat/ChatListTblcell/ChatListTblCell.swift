//
//  ChatListTblCell.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit

class ChatListTblCell: UITableViewCell {
    
    @IBOutlet weak var imgViewProfile:UIImageView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var imgViewItem:UIImageView!
    @IBOutlet weak var lblLastMessage:UILabel!
    @IBOutlet weak var lblDot:UILabel!
    @IBOutlet weak var btnOption:UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 8.0
        bgView.clipsToBounds = true
        
        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.size.height/2.0
        imgViewProfile.clipsToBounds = true
        imgViewProfile.layer.borderColor = UIColor.label.cgColor
        imgViewProfile.layer.borderWidth = 1.0
        imgViewProfile.clipsToBounds = true
        
        lblDot.layer.cornerRadius = lblDot.frame.size.height/2.0
        lblDot.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
