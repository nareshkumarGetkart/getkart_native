//
//  BudgetTblViewCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/31/25.
//

import UIKit

class BudgetTblViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var txtLowerRange:UITextField!
    @IBOutlet weak var txtUpperRange:UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
