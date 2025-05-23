//
//  PackageAdsCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit

class PackageAdsCell: UITableViewCell {

    @IBOutlet var lblNumberOfAds:UILabel!
    @IBOutlet var lblAmount:UILabel!
    @IBOutlet var lblOriginalAmt:UILabel!
    @IBOutlet var lblDiscountPercentage:UILabel!
    @IBOutlet var bgView:UIViewX!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblDiscountPercentage.layer.cornerRadius = 1.0
        lblDiscountPercentage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



extension String{
    
    func  setStrikeText(color:UIColor) -> NSAttributedString{
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: color
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
}
