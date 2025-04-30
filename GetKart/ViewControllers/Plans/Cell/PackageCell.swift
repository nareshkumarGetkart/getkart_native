//
//  PackageCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/04/25.
//

import UIKit

class PackageCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblAmount:UILabel!
    @IBOutlet weak var lblOriginalAmount:UILabel!
    @IBOutlet weak var lblPercentOff:UILabel!
    @IBOutlet weak var lblSubtitle:UILabel!
    @IBOutlet weak var imgVwIcon:UIImageView!
    @IBOutlet weak var btnViewPlans:UIButton!
    @IBOutlet weak var lblFeatures:UILabel!
    @IBOutlet weak var bgViewMain:UIViewX!
    @IBOutlet weak var imgVwPercentageOffIcon:UIImageView!


    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnViewPlans.layer.cornerRadius = 8.0
        btnViewPlans.layer.borderWidth = 1.0
        btnViewPlans.layer.borderColor = UIColor(hexString: "#FF9900").cgColor
        btnViewPlans.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
