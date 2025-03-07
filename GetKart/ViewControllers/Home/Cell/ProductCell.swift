//
//  ProductCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var btnLike:UIButton!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblItem:UILabel!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var imgViewitem:UIImageView!
    @IBOutlet weak var bgView:UIView!

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
        
        
    }

}
