//
//  BannerDetailTblCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 27/10/25.
//

import UIKit

class BannerDetailTblCell: UITableViewCell {

    @IBOutlet weak var imgVwBanner:UIImageView!
    @IBOutlet weak var lblStatus:UILabel!
    @IBOutlet weak var lblViewCount:UILabel!
    @IBOutlet weak var lblLikeCount:UILabel!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var bgViewStatus:UIView!

    @IBOutlet weak var bgViewActiveStatus:UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgViewStatus.layer.cornerRadius = bgViewStatus.frame.height/2.0
        bgViewStatus.clipsToBounds = true
        
        bgViewActiveStatus.layer.cornerRadius = bgViewActiveStatus.frame.height/2.0
        bgViewActiveStatus.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
