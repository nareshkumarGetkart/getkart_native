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
  //  @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var bgView:UIView!
   // @IBOutlet weak var imgViewItem:UIImageView!
    @IBOutlet weak var lblLastMessage:UILabel!
    @IBOutlet weak var lblDot:UILabel!
   // @IBOutlet weak var btnOption:UIButton!
    @IBOutlet weak var lblLastMessageTime:UILabel!
    
    
//    @IBOutlet weak var mainBgView:UIView!
//    @IBOutlet weak var deletedBgView:UIView!
//    @IBOutlet weak var lblDeletedMsg:UILabel!



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
        
        lblName.font = UIFont.Inter.medium(size: 15.0).font
        lblLastMessage.font = UIFont.Inter.regular(size: 15.0).font
        lblLastMessageTime.font = UIFont.Inter.medium(size: 13.0).font

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setDateTime(isoDateString:String){
 
        lblLastMessageTime.text = formatChatTime(isoDateString)
    }
   
    func formatChatTime(_ dateString: String) -> String {
        
        let serverFormatter = DateFormatter()
        serverFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        serverFormatter.locale = Locale(identifier: "en_US_POSIX")
        serverFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = serverFormatter.date(from: dateString) else {
            return ""
        }
        
        let calendar = Calendar.current
        
        // Today → 12:26 pm
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            return formatter.string(from: date)
        }
        
        // Yesterday
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        
        // Last 7 days → Monday, Tuesday
        if let days = calendar.dateComponents([.day], from: date, to: Date()).day,
           days < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        
        // Older → 08/05/2026
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
