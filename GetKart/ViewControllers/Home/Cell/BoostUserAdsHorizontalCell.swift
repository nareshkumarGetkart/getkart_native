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
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.layer.cornerRadius = 10.0
        bgView.clipsToBounds = true
        
        
        
        imgViewProduct.layer.cornerRadius = 10.0
        imgViewProduct.clipsToBounds = true
        
        lblPrice.font = UIFont.Inter.semiBold(size: 16.0).font
        lblName.font = UIFont.Inter.semiBold(size: 15.0).font
        lblLocation.font = UIFont.Inter.regular(size: 12.0).font
        btnBoostNow.titleLabel?.font = UIFont.Inter.semiBold(size: 14.0).font
        
        if let originalImage = UIImage(named: "location-outline") {
            let tintedImage = originalImage.tinted(with: .label)
            imgViewLocIcon.image = tintedImage
        }
        imgViewProduct.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        
        btnBoostNow.setTitle("Boost Now", for: .normal)
        btnBoostNow.setTitleColor(.white, for: .normal)
        btnBoostNow.layer.cornerRadius = 5
        btnBoostNow.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer.removeFromSuperlayer()
    }
    
    private func applyGradient() {
        gradientLayer.frame = btnBoostNow.bounds
        gradientLayer.colors = [
            UIColor(hexString: "#FF9900").cgColor,
            UIColor(hexString: "#D04747").cgColor
        ]
        
        // CSS: linear-gradient(180deg, #FF9900 1.6%, #D04747 99.37%)
        gradientLayer.locations = [0.016, 0.9937]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.cornerRadius = btnBoostNow.layer.cornerRadius
        
        if gradientLayer.superlayer == nil {
            btnBoostNow.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
}
