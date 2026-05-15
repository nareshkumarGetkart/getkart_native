//
//  SenderImageCell.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 23/09/24.
//

import UIKit

class SenderImageCell: ChatterCell {

//    @IBOutlet weak var bgview:UIView!
//    @IBOutlet weak var imgView:UIImageView!
//    @IBOutlet weak var lblMessage:UILabel!
//    @IBOutlet weak var lblTIme:UILabel!
//    @IBOutlet weak var imgViewSeen:UIImageView!
//    @IBOutlet weak var lblSeen:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgView.layer.cornerRadius = 12.0
        self.imgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
