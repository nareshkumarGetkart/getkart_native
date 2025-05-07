//
//  BudgetTblViewCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/31/25.
//

import UIKit

class BudgetTblViewCell: UITableViewCell , UITextFieldDelegate {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var txtLowerRange:UITextFieldX!
    @IBOutlet weak var lblCurSymbolLowRange:UILabel!
    
    @IBOutlet weak var txtUpperRange:UITextFieldX!
    @IBOutlet weak var lblCurSymbolUpperRange:UILabel!
    
    var textFieldDoneFirstDelegate:TextFieldDoneDelegate!
    var showCurrencySymbolFirst = false
    var showCurrencySymbolSecond = false
    var textFieldSecondDoneDelegate:TextFieldDoneDelegate!
    
    
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
        if textField.tag == 100{
            textFieldDoneFirstDelegate?.textFieldEditingDone(selectedRow: textField.tag, strText: textField.text ?? "")
            
        }else{
            textFieldSecondDoneDelegate.textFieldEditingDone(selectedRow: textField.tag, strText: textField.text ?? "")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if showCurrencySymbolFirst == true && textField.tag == 100 {
            let textFieldText: NSString = (textField.text ?? "") as NSString
            let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
            if txtAfterUpdate.count > 0 {
                lblCurSymbolLowRange.isHidden = false
                txtLowerRange.leftPadding = 15
            }else {
                lblCurSymbolLowRange.isHidden = true
                txtLowerRange.leftPadding = 10
            }
        }else if  showCurrencySymbolSecond == true && textField.tag == 101{
            
            let textFieldText: NSString = (textField.text ?? "") as NSString
            let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
            
            if txtAfterUpdate.count > 0 {
                lblCurSymbolUpperRange.isHidden = false
                txtUpperRange.leftPadding = 15
            }else {
                lblCurSymbolUpperRange.isHidden = true
                txtUpperRange.leftPadding = 10
            }
        }
        return true;
    }
    
}
