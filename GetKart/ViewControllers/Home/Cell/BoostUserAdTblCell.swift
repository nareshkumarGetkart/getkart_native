//
//  BoostUserAdTblCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 19/01/26.
//

import UIKit

class BoostUserAdTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var btnClose:UIButton!
    @IBOutlet weak var bgViewTitle:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
