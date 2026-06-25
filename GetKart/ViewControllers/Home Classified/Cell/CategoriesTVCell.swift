//
//  CategoriesTVCell.swift
//  GetKart
//
//  Created by gurmukh singh on 4/1/25.
//

import UIKit

class CategoriesTVCell: UITableViewCell {
    @IBOutlet weak var imgImageView:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var btnRigt:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
