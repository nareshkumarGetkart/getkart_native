//
//  CategoriesBigCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 04/03/25.
//

import UIKit

class CategoriesBigCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var imageBgView:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    
    func updateCellItems(obj:CategoryModel){
        
        self.lblTitle.text = obj.name
        self.imgView.kf.setImage(with:  URL(string: obj.image ?? "") , placeholder:UIImage(named: "getkartplaceholder"))
        DispatchQueue.main.async {
            self.imageBgView.backgroundColor = UIColor(hexString: "#fff7e9")
            self.imageBgView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 15.0)
            self.imageBgView.clipsToBounds = true
            self.bgView.layer.borderColor = UIColor.lightGray.cgColor
            self.bgView.layer.borderWidth = 1.5
            self.bgView.layer.cornerRadius = 10.0
            self.bgView.clipsToBounds = true
        }
    }
}
