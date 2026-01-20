//
//  BoostUserAdsHorizontalCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/01/26.
//

import UIKit

class BoostUserAdsHorizontalCell: UICollectionViewCell {
   
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblLocation:UILabel!
    @IBOutlet weak var btnBoostNow:UIButton!
    @IBOutlet weak var imgViewProduct:UIImageView!
    @IBOutlet weak var imgViewLocIcon:UIImageView!
    @IBOutlet weak var bgView:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.layer.cornerRadius = 8.0
        bgView.clipsToBounds = true
        
        btnBoostNow.layer.cornerRadius = 5.0
        btnBoostNow.clipsToBounds = true
        
        imgViewProduct.layer.cornerRadius = 8.0
        imgViewProduct.clipsToBounds = true
        
        if let originalImage = UIImage(named: "location-outline") {
            let tintedImage = originalImage.tinted(with: .label)
            imgViewLocIcon.image = tintedImage
        }
        imgViewProduct.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
    }

}
