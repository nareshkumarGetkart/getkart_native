//
//  TFCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit
import WebKit

protocol TextFieldDoneDelegate {
    func textFieldEditingDone(selectedRow:Int, strText:String)
}
extension TextFieldDoneDelegate {
    func textFieldEditingDone(selectedRow:Int, strText:String){}
}

class TFCell: UITableViewCell, UITextFieldDelegate {
   
    @IBOutlet weak var iconImgWebView:WKWebView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblCurSymbol:UILabel!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var txtField:UITextFieldX!
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var btnOptionBig: UIButton!
    var textFieldDoneDelegate:TextFieldDoneDelegate!
    @IBOutlet weak var lblErrorMsg:UILabel!
    var showCurrencySymbol = false
    
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
        textFieldDoneDelegate?.textFieldEditingDone(selectedRow: txtField.tag, strText: textField.text ?? "")
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if showCurrencySymbol == true {
            let textFieldText: NSString = (textField.text ?? "") as NSString
            let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
            if txtAfterUpdate.count > 0 {
                lblCurSymbol.isHidden = false
                txtField.leftPadding = 25
            }else {
                lblCurSymbol.isHidden = true
                txtField.leftPadding = 10
            }
        }
        return true;
    }
}
