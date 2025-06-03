//
//  radioBtnCVCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/11/25.
//

import UIKit

class RadioBtnCVCell: UICollectionViewCell {
    @IBOutlet weak var backView:UIViewX!
    @IBOutlet weak var btnValue:UIButtonX!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.layer.borderColor = UIColor.label.cgColor
    }
}
