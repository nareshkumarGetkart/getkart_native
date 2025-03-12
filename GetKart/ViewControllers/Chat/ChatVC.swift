//
//  ChatVC.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/03/25.
//

import UIKit

class ChatVC: UIViewController {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var cnstrntHtNavBar:NSLayoutConstraint!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgViewProfile:UIImageView!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var imgViewProduct:UIImageView!
    @IBOutlet weak var lblProduct:UILabel!

    //MARK: Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrntHtNavBar.constant = self.getNavBarHt
        registerTblCell()
    }
   
    
    //MARK: UIButton Action Methods
    @IBAction func backButtonAction(sender : UIButton){
        
    }
    
    @IBAction func threeDotsButtonAction(sender : UIButton){
        
    }
    
    //MARK: Other helpful methods
    func registerTblCell(){
        tblView.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
        tblView.register(UINib(nibName: "RecieveChatCell", bundle: nil), forCellReuseIdentifier: "RecieveChatCell")

        tblView.register(UINib(nibName: "RecieveImageCell", bundle: nil), forCellReuseIdentifier: "RecieveImageCell")

        tblView.register(UINib(nibName: "SenderImageCell", bundle: nil), forCellReuseIdentifier: "SenderImageCell")



        
    }

}
