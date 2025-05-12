//
//  ProductCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit
import Kingfisher

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var btnLike:UIButton!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblItem:UILabel!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var imgViewitem:UIImageView!
    @IBOutlet weak var bgView:UIView!
    
    @IBOutlet weak var imgViewLoc:UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.layer.cornerRadius = 8.0
        bgView.clipsToBounds = true
        
        imgViewitem.layer.cornerRadius = 8.0
        imgViewitem.clipsToBounds = true
        
        btnLike.layer.cornerRadius = btnLike.frame.size.height/2.0
        btnLike.clipsToBounds = true
        btnLike.addShadow(shadowRadius: 5.0)
        
        if let originalImage = UIImage(named: "location-outline") {
            let tintedImage = originalImage.tinted(with: .label)
            imgViewLoc.image = tintedImage
        }
        
        imgViewitem.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            

    }
   
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgViewitem.kf.cancelDownloadTask()
        imgViewitem.image = nil
    }

}
