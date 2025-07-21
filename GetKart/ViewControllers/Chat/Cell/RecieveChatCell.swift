//
//  RecieveChatCell.swift
//  PickzonDating
//
//  Created by Radheshyam Yadav on 10/09/24.
//

import UIKit

class RecieveChatCell: ChatterCell {
   
//    @IBOutlet weak var bgView:UIView!
//    @IBOutlet weak var lblMessage:UILabel!
//    @IBOutlet weak var lblTime:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



class ChatterCell:UITableViewCell{
    
    @IBOutlet weak var bgview:UIView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet weak var lblTime:UILabel!
    @IBOutlet weak var imgViewSeen:UIImageView!
    @IBOutlet weak var lblSeen:UILabel!
    
    @IBOutlet weak var replayView: UIView!
    @IBOutlet weak var replayMsg: UILabel!
    @IBOutlet weak var replayName: UILabel!
    @IBOutlet weak var replayImage: UIImageView!
    @IBOutlet weak var replaySender: UILabel!
    @IBOutlet weak var replayCustomButton: UIButton!

    
    
    
    
    @IBOutlet weak var audioDuration: UILabel!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!

    
    @IBOutlet weak var cautionBgView: UIView!
    @IBOutlet weak var btnCautionOnOff: UIButton!
    @IBOutlet weak var btnCautionClose: UIButton!
    @IBOutlet weak var lblCaution: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

