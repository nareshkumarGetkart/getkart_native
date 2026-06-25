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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setBannerItem(obj:SliderModel){
        self.imgVwBanner.kf.setImage(with: URL(string: obj.image ?? "")) //, placeholder:UIImage(named: "getkartplaceholder")
        self.imgVwBanner.contentMode = .scaleToFill
        self.imgVwBanner.clipsToBounds = true
    }

}
