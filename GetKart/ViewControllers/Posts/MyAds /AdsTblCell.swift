//
//  AdsTblCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit

class AdsTblCell: UITableViewCell {
    
    @IBOutlet weak var imgVwAds:UIImageView!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblViewCount:UILabel!
    @IBOutlet weak var lblLikeCount:UILabel!
    @IBOutlet weak var btnAdStatus:UIButton!
    @IBOutlet weak var lblItem:UILabel!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var btnAdPost:UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnAdStatus.layer.cornerRadius = btnAdStatus.frame.height/2.0
        btnAdStatus.clipsToBounds = true
        
        
        btnAdPost.layer.cornerRadius =  3.0 //btnAdPost.frame.height/2.0
        btnAdPost.clipsToBounds = true
        
        bgView.layer.cornerRadius = 8.0
        bgView.clipsToBounds = true
        
        lblItem.font = UIFont.Manrope.medium(size: 16.0).font
        lblPrice.font = UIFont.Manrope.medium(size: 16.0).font
        lblLikeCount.font = UIFont.Manrope.regular(size: 13.0).font
        lblViewCount.font = UIFont.Manrope.regular(size: 13.0).font
        btnAdStatus.titleLabel?.font = UIFont.Manrope.regular(size: 13.0).font
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
