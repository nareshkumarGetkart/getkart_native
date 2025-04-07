//
//  TFCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit

protocol TextFieldDoneDelegate {
    func textFieldEditingDone(selectedRow:Int, strText:String)
}

class TFCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var txtField:UITextFieldX!
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var btnOptionBig: UIButton!
    var textFieldDoneDelegate:TextFieldDoneDelegate!
    @IBOutlet weak var lblErrorMsg:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder();
            return true
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            print("TextField did end editing method called\(textField.text!)")
        textFieldDoneDelegate?.textFieldEditingDone(selectedRow: txtField.tag, strText: textField.text ?? "")
        }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            print("While entering the characters this method gets called")
            return true;
        }
}
