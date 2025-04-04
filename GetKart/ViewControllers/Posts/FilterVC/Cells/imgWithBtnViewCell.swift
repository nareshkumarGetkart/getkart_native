//
//  imgWithBtnViewCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/31/25.
//

import UIKit

class imgWithBtnViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var imgImageView:UIImageView!
    @IBOutlet weak var btnTextValue:UIButton!
    @IBOutlet weak var btnArrowDown:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
