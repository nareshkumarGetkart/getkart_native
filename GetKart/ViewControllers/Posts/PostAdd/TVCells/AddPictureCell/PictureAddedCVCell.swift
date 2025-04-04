//
//  PictureAddedCVCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/26/25.
//

import UIKit

class PictureAddedCVCell: UICollectionViewCell {
    @IBOutlet weak var viewBack:UIView!
    @IBOutlet weak var imgImage:UIImageView!
    @IBOutlet weak var btnRemove:UIButton!
    @IBOutlet weak var btnAddImage:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnRemove.layer.cornerRadius = 5.0
        viewBack.layer.cornerRadius = 5.0
        viewBack.layer.borderWidth = 1.0
        viewBack.layer.borderColor = UIColor.lightGray.cgColor
    }

}
