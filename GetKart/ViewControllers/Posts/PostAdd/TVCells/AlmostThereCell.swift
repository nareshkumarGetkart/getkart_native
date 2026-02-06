//
//  almostThereCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit

class AlmostThereCell: UITableViewCell {
    @IBOutlet weak var lblCategory:UILabel!
  //  @IBOutlet weak var lblSubCategory:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func setAtrributtedTextToLabel(firstText:String,secondText:String){
    
        guard let fontManrope = UIFont.Manrope.regular(size: 15.0).font else{ return}
        let firstAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label,
            .font:fontManrope
        ]

        let secondAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Themes.sharedInstance.themeColor,
            .font: fontManrope
        ]

        let attributedText = NSMutableAttributedString(string: firstText, attributes: firstAttributes)
        attributedText.append(NSAttributedString(string: secondText, attributes: secondAttributes))

        lblCategory.attributedText = attributedText

    }
    
}
