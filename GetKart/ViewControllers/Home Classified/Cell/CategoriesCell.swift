//
//  CategoriesCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 20/02/25.
//

import UIKit

class CategoriesCell: UICollectionViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var imageBgView:UIView!
    @IBOutlet weak var threeDotImgView:UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}


// Optimized CategoriesCell
extension CategoriesCell {
    func configureAsMoreCell() {
        imgView.image = nil
        imgView.isHidden = false
        imgView.layer.borderColor = UIColor.lightGray.cgColor
        imgView.layer.borderWidth = 1.0
        imgView.layer.cornerRadius = 10.0
        imgView.clipsToBounds = true
        lblTitle.text = "More"
        threeDotImgView.isHidden = false
    }

    func configure(with obj: CategoryModel) {
        lblTitle.text = obj.name
        imgView.kf.setImage(with: URL(string: obj.image ?? ""), placeholder: UIImage(named: "getkartplaceholder"))
        imgView.layer.borderColor = UIColor.clear.cgColor
        imgView.layer.borderWidth = 0.0
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 10.0
        imgView.clipsToBounds = true
        threeDotImgView.isHidden = true
    }
}
