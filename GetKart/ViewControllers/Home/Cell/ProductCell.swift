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
    @IBOutlet weak var lblBoost:UILabel!
    @IBOutlet weak var btnIsVerified:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.layer.cornerRadius = 8.0
        bgView.clipsToBounds = true
        
        lblBoost.layer.cornerRadius = 5.0
        lblBoost.clipsToBounds = true
        
        imgViewitem.layer.cornerRadius = 8.0
        imgViewitem.clipsToBounds = true
        
        btnLike.layer.cornerRadius = btnLike.frame.size.height/2.0
        btnLike.clipsToBounds = true
        btnLike.addShadow(shadowRadius: 5.0)
        
        
        btnIsVerified.layer.cornerRadius = btnIsVerified.frame.size.height/2.0
        btnIsVerified.clipsToBounds = true
        btnIsVerified.addShadow(shadowRadius: 5.0)
        
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
        lblItem.text = nil
        lblAddress.text = nil
        lblPrice.text = nil
        lblBoost.isHidden = true
    }

}


// Optimized ProductCell (in ProductCell.swift)
extension ProductCell {
    func configure(with obj: ItemModel, index: Int, likeAction: Selector) {
        lblItem.text = obj.name
        lblAddress.text = obj.address
        lblPrice.text = "\(Local.shared.currencySymbol) \((obj.price ?? 0.0).formatNumber())"
        lblBoost.isHidden = !(obj.isFeature ?? false)
        let imgName = (obj.isLiked ?? false) ? "like_fill" : "like"
        btnLike.setImage(UIImage(named: imgName), for: .normal)
        btnLike.tag = index
        btnLike.addTarget(nil, action: likeAction, for: .touchUpInside)
        btnLike.backgroundColor = .systemBackground
        imgViewLoc.image = UIImage(named: "location-outline")?.tinted(with: .label)

        btnIsVerified.isHidden = (obj.user?.isVerified ?? 0) == 1 ? false : true
        
        let imageSize = CGSize(width: 130, height: 130)
        let processor = DownsamplingImageProcessor(size: imageSize)
        imgViewitem.kf.setImage(with: URL(string: obj.image ?? ""), placeholder: UIImage(named: "getkartplaceholder"), options: [.processor(processor), .scaleFactor(UIScreen.main.scale)])
    }
}
