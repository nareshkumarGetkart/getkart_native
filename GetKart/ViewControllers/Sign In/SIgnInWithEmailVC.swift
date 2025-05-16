//
//  SIgnInWithEmailVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/05/25.
//

import UIKit

class SIgnInWithEmailVC: UIViewController {

    @IBOutlet weak var txtFdEmail:UITextFieldX!
    @IBOutlet weak var btnContinueLogin:UIButtonX!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var lblError:UILabel!

    //MARK: Controller lIfe cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.setImageTintColor(color: .label)
        lblError.text = ""

    }
    

    //MARK: UIButton Action Methods
    @IBAction func backBtnAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueBtnAction(_ sender : UIButton){
        if txtFdEmail.text?.isValidEmail() == true {
            lblError.text = ""
        }else{
            lblError.text = "Please enter valid email id."
        }

    }

}


extension SIgnInWithEmailVC:UITextFieldDelegate {
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        lblError.text = ""

        // Current text in the text field
          let currentText = textField.text ?? ""
          
          // Construct the new text after applying the replacement
          if let stringRange = Range(range, in: currentText) {
              let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
              
//              if updatedText.count <  5{
//                  self.btnContinueLogin.backgroundColor = UIColor.gray
//
//              }else{
//                  self.btnContinueLogin.backgroundColor = UIColor.orange
//
//              }
          }
        
        return true
    }
}
