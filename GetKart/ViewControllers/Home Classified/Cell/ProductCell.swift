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
    @IBOutlet weak var lblCapacity:UILabel!
    @IBOutlet weak var emptyBottomBgViewForCapacity:UIView!


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
        btnLike.addShadow(shadowRadius: 1.0)
        
        
        btnIsVerified.layer.cornerRadius = btnIsVerified.frame.size.height/2.0
        btnIsVerified.clipsToBounds = true
        btnIsVerified.addShadow(shadowRadius: 3.0)
        
        if let originalImage = UIImage(named: "location-outline") {
            let tintedImage = originalImage.tinted(with: .label)
            imgViewLoc.image = tintedImage
        }
        imgViewitem.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        emptyBottomBgViewForCapacity.isHidden = true
    }
   
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)

           if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
               if let originalImage = UIImage(named: "location-outline") {
                   let tintedImage = originalImage.tinted(with: .label)
                   imgViewLoc.image = tintedImage
               }
           }
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
    
    //For capacity label empty view added at bottom
    func updateCapacityLabelWithText(obj:ItemModel){
        
        if  let matchedCatId = matchedCategoryId(from: obj.allCategoryIDS ?? ""){
            lblCapacity.isHidden = false
            emptyBottomBgViewForCapacity.isHidden = true
            lblCapacity.text = callSpecificValueBasedOnCategory(catId:matchedCatId, list: obj.customFields ?? [])
            
            if  lblCapacity.text?.count == 0{
                lblCapacity.isHidden = true
                emptyBottomBgViewForCapacity.isHidden = false
            }
        }else{
            lblCapacity.text = ""
            lblCapacity.isHidden = true
            emptyBottomBgViewForCapacity.isHidden = false
        }
    }
    

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
