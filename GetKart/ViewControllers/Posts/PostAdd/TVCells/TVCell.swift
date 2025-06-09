//
//  TVCell.swift
//  GetKart
//
//  Created by gurmukh singh on 3/10/25.
//

import UIKit
protocol TextViewDoneDelegate {
    func textViewEditingDone(selectedRow:Int, strText:String)
    func textViewEditingBegin(selectedRow:Int, strText:String)
}
class TVCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tvTextView:UITextView!
    var textViewDoneDelegate:TextViewDoneDelegate!
    @IBOutlet weak var lblErrorMsg:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        tvTextView.layer.borderWidth = 1
        tvTextView.layer.borderColor = UIColor.lightGray.cgColor
        tvTextView.layer.cornerRadius = 10.0
        tvTextView.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       
        // Configure the view for the selected state
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDoneDelegate?.textViewEditingDone(selectedRow: tvTextView.tag, strText: tvTextView.text ?? "")
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textViewDoneDelegate?.textViewEditingBegin(selectedRow: tvTextView.tag, strText: tvTextView.text ?? "")

        return true
    }
}
