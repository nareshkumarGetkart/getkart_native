//
//  ChatListTblCell.swift
//  Getkart
//
//  Created by Radheshyam Yadav on 19/02/25.
//

import UIKit

class ChatListTblCell: UITableViewCell {
    
    @IBOutlet weak var imgViewProfile:ContactImageView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var bgView:UIView!
    @IBOutlet weak var imgViewItem:UIImageView!
    @IBOutlet weak var lblLastMessage:UILabel!
    @IBOutlet weak var lblDot:UILabel!
    @IBOutlet weak var btnOption:UIButton!
    @IBOutlet weak var lblLastMessageTime:UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 8.0
        bgView.clipsToBounds = true
        
        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.size.height/2.0
        imgViewProfile.clipsToBounds = true
        imgViewProfile.layer.borderColor = UIColor.label.cgColor
        imgViewProfile.layer.borderWidth = 1.0
        imgViewProfile.clipsToBounds = true
        
        lblDot.layer.cornerRadius = lblDot.frame.size.height/2.0
        lblDot.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setDateTime(isoDateString:String){
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC time
        
        if let date = isoFormatter.date(from: isoDateString) {
            // print("Converted Date:", date)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "dd/MM/yyyy"
            lblLastMessageTime.text = dateFormatter.string(from: date)
            
        } else {
            print("Invalid date format")
            lblLastMessageTime.text = ""
        }
    }
}
