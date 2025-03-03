//
//  BannerCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 03/03/25.
//

import UIKit

class BannerCell: UICollectionViewCell {

    @IBOutlet weak var imgVwBanner:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgVwBanner.layer.cornerRadius = 10.0
        imgVwBanner.clipsToBounds = true
    }

}
