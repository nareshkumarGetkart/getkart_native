//
//  TVCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit

class TVCell: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tvTextView:UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        tvTextView.layer.borderWidth = 1
        tvTextView.layer.borderColor = UIColor.lightGray.cgColor
        tvTextView.layer.cornerRadius = 10.0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       
        // Configure the view for the selected state
    }
    
}
